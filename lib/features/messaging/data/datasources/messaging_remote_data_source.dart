import 'dart:async';
import 'dart:developer' as developer;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/network/api_endpoints.dart';
import '../models/conversation_model.dart';
import '../models/message_model.dart';

/// All Supabase calls for the messaging feature.
///
/// Schema relationships:
///   auth.uid() == users.id
///   users.id  -> startup_profiles.user_id  -> startup_profiles.id
///   users.id  -> investor_profiles.user_id -> investor_profiles.id
///
///   conversations.startup_id  references startup_profiles.id
///   conversations.investor_id references investor_profiles.id
///   messages.sender_id        references startup_profiles.id OR investor_profiles.id
class MessagingRemoteDataSource {
  final SupabaseClient _client;

  MessagingRemoteDataSource({required SupabaseClient supabaseClient})
      : _client = supabaseClient;

  // ─── auth helpers ─────────────────────────────────────────────────────────

  String get _currentUserId {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) {
      developer.log(
        'ERROR: No authenticated user session found in SupabaseClient.',
        name: 'MessagingRemoteDataSource',
        level: 1000,
      );
      throw Exception('No authenticated user.');
    }
    return uid;
  }

  /// Resolves the authenticated user's startup_profiles.id (if they are a
  /// founder) and investor_profiles.id (if they are an investor).
  ///
  /// Returns a record with whichever IDs exist; both may be null if the
  /// user has not completed that profile type.
  Future<({String? startupProfileId, String? investorProfileId})>
      _resolveProfileIds() async {
    final userId = _currentUserId;
    developer.log(
      'Resolving profile IDs for auth user_id: $userId',
      name: 'MessagingRemoteDataSource._resolveProfileIds',
    );

    try {
      // Run both lookups concurrently.
      final results = await Future.wait([
        _client
            .from(ApiEndpoints.startupProfiles)
            .select('id')
            .eq('user_id', userId)
            .maybeSingle(),
        _client
            .from(ApiEndpoints.investorProfiles)
            .select('id')
            .eq('user_id', userId)
            .maybeSingle(),
      ]);

      String? startupId = results[0]?['id']?.toString();
      String? investorId = results[1]?['id']?.toString();

      developer.log(
        'Initial lookup -> startupProfileId: $startupId, investorProfileId: $investorId',
        name: 'MessagingRemoteDataSource._resolveProfileIds',
      );

      // If both are null, try to auto-provision based on account_type
      if (startupId == null && investorId == null) {
        developer.log(
          'Neither profile found for user $userId. Checking users table for account_type...',
          name: 'MessagingRemoteDataSource._resolveProfileIds',
        );

        final userRow = await _client
            .from(ApiEndpoints.users)
            .select('full_name, account_type')
            .eq('id', userId)
            .maybeSingle();

        final accountType = userRow?['account_type']?.toString().toLowerCase() ??
            _client.auth.currentUser?.userMetadata?['role']?.toString().toLowerCase();

        final name = userRow?['full_name']?.toString() ??
            _client.auth.currentUser?.userMetadata?['full_name']?.toString() ??
            'User';

        developer.log(
          'User metadata -> name: "$name", accountType: "$accountType"',
          name: 'MessagingRemoteDataSource._resolveProfileIds',
        );

        try {
          if (accountType == 'investor') {
            developer.log(
              'Creating baseline investor profile row for user $userId...',
              name: 'MessagingRemoteDataSource._resolveProfileIds',
            );
            final inserted = await _client
                .from(ApiEndpoints.investorProfiles)
                .insert({
                  'user_id': userId,
                  'investor_type': 'angel',
                  'organization_name': name,
                })
                .select('id')
                .single();
            investorId = inserted['id']?.toString();
            developer.log(
              'Successfully created investor profile: $investorId',
              name: 'MessagingRemoteDataSource._resolveProfileIds',
            );
          } else if (accountType == 'startup' || accountType == 'founder') {
            developer.log(
              'Creating baseline startup profile row for user $userId...',
              name: 'MessagingRemoteDataSource._resolveProfileIds',
            );
            final inserted = await _client
                .from(ApiEndpoints.startupProfiles)
                .insert({
                  'user_id': userId,
                  'startup_name': '$name Startup',
                  'business_name': '$name Startup',
                  'industry': 'Technology',
                  'funding_stage': 'Pre-Seed',
                })
                .select('id')
                .single();
            startupId = inserted['id']?.toString();
            developer.log(
              'Successfully created startup profile: $startupId',
              name: 'MessagingRemoteDataSource._resolveProfileIds',
            );
          }
        } catch (e, st) {
          developer.log(
            'Auto-provisioning profile failed for user $userId: $e',
            name: 'MessagingRemoteDataSource._resolveProfileIds',
            error: e,
            stackTrace: st,
          );
        }
      }

      developer.log(
        'Final resolved profiles -> startupProfileId: $startupId, investorProfileId: $investorId',
        name: 'MessagingRemoteDataSource._resolveProfileIds',
      );

      return (
        startupProfileId: startupId,
        investorProfileId: investorId,
      );
    } on PostgrestException catch (e, st) {
      developer.log(
        'PostgrestException in _resolveProfileIds: ${e.message} (code: ${e.code}, details: ${e.details}, hint: ${e.hint})',
        name: 'MessagingRemoteDataSource._resolveProfileIds',
        error: e,
        stackTrace: st,
        level: 1000,
      );
      rethrow;
    } catch (e, st) {
      developer.log(
        'Unexpected exception in _resolveProfileIds: $e',
        name: 'MessagingRemoteDataSource._resolveProfileIds',
        error: e,
        stackTrace: st,
        level: 1000,
      );
      rethrow;
    }
  }

  // ─── conversations ────────────────────────────────────────────────────────

  Future<List<ConversationModel>> getConversations() async {
    developer.log(
      'Fetching all conversations for current user...',
      name: 'MessagingRemoteDataSource.getConversations',
    );

    try {
      final ids = await _resolveProfileIds();
      final startupId = ids.startupProfileId;
      final investorId = ids.investorProfileId;

      if (startupId == null && investorId == null) {
        developer.log(
          'ERROR: No startup or investor profile found for account $_currentUserId',
          name: 'MessagingRemoteDataSource.getConversations',
          level: 900,
        );
        throw Exception(
          'No startup or investor profile found for this account.',
        );
      }

      // Build OR filter using whichever profile IDs this user has.
      final orParts = <String>[];
      if (startupId != null) orParts.add('startup_id.eq.$startupId');
      if (investorId != null) orParts.add('investor_id.eq.$investorId');
      final orFilter = orParts.join(',');

      developer.log(
        'Executing conversations query with filter: "$orFilter"',
        name: 'MessagingRemoteDataSource.getConversations',
      );

      final rows = await _client
          .from(ApiEndpoints.conversations)
          .select('id, startup_id, investor_id, created_at')
          .or(orFilter)
          .order('created_at', ascending: false);

      developer.log(
        'Found ${(rows as List).length} conversation row(s)',
        name: 'MessagingRemoteDataSource.getConversations',
      );

      final List<ConversationModel> result = [];

      for (final row in rows as List<dynamic>) {
        final map = Map<String, dynamic>.from(row as Map);
        final convId = map['id'].toString();
        final convStartupId = map['startup_id']?.toString() ?? '';
        final convInvestorId = map['investor_id']?.toString() ?? '';

        // Determine whether the current user is the startup or investor side.
        final bool isStartupSide = startupId != null && convStartupId == startupId;
        final otherProfileId =
            isStartupSide ? convInvestorId : convStartupId;

        String otherName = 'Unknown';
        String? otherAvatar;

        try {
          if (isStartupSide) {
            // Other side is an investor — look up investor_profiles → users
            final investorProfile = await _client
                .from(ApiEndpoints.investorProfiles)
                .select('user_id, organization_name')
                .eq('id', otherProfileId)
                .maybeSingle();

            if (investorProfile != null) {
              final otherUserId =
                  investorProfile['user_id']?.toString() ?? '';
              final orgName =
                  investorProfile['organization_name']?.toString();

              final userRow = await _client
                  .from(ApiEndpoints.users)
                  .select('full_name')
                  .eq('id', otherUserId)
                  .maybeSingle();

              otherName = orgName?.isNotEmpty == true
                  ? orgName!
                  : (userRow?['full_name']?.toString() ?? 'Investor');
            }
          } else {
            // Other side is a startup — look up startup_profiles → users
            final startupProfile = await _client
                .from(ApiEndpoints.startupProfiles)
                .select('user_id, business_name, startup_name')
                .eq('id', otherProfileId)
                .maybeSingle();

            if (startupProfile != null) {
              final businessName =
                  startupProfile['business_name']?.toString();
              final startupName =
                  startupProfile['startup_name']?.toString();
              otherName = (businessName?.isNotEmpty == true)
                  ? businessName!
                  : (startupName?.isNotEmpty == true ? startupName! : 'Startup');
            }
          }
        } catch (enrichError) {
          developer.log(
            'Non-fatal: could not enrich participant info for conv $convId: $enrichError',
            name: 'MessagingRemoteDataSource.getConversations',
          );
        }

        // Fetch latest message for preview.
        String? latestContent;
        String? latestAt;
        try {
          final msgs = await _client
              .from(ApiEndpoints.messages)
              .select('content, sent_at')
              .eq('conversation_id', convId)
              .order('sent_at', ascending: false)
              .limit(1);

          if ((msgs as List).isNotEmpty) {
            final latest = msgs.first as Map;
            latestContent = latest['content']?.toString();
            latestAt = latest['sent_at']?.toString();
          }
        } catch (msgError) {
          developer.log(
            'Non-fatal: could not fetch latest message for conv $convId: $msgError',
            name: 'MessagingRemoteDataSource.getConversations',
          );
        }

        result.add(
          ConversationModel.fromEnriched({
            'id': convId,
            'startup_id': convStartupId,
            'investor_id': convInvestorId,
            'created_at': map['created_at'],
            'other_participant_profile_id': otherProfileId,
            'other_participant_name': otherName,
            'other_participant_avatar_url': otherAvatar,
            'latest_message_content': latestContent,
            'latest_message_at': latestAt,
          }),
        );
      }

      // Sort by latest message time descending.
      result.sort((a, b) {
        final aTime = a.latestMessageAt ?? a.createdAt;
        final bTime = b.latestMessageAt ?? b.createdAt;
        return bTime.compareTo(aTime);
      });

      developer.log(
        'Successfully loaded and enriched ${result.length} conversations.',
        name: 'MessagingRemoteDataSource.getConversations',
      );
      return result;
    } on PostgrestException catch (e, st) {
      developer.log(
        'PostgrestException in getConversations: ${e.message} (code: ${e.code}, details: ${e.details}, hint: ${e.hint})',
        name: 'MessagingRemoteDataSource.getConversations',
        error: e,
        stackTrace: st,
        level: 1000,
      );
      rethrow;
    } catch (e, st) {
      developer.log(
        'Unexpected exception in getConversations: $e',
        name: 'MessagingRemoteDataSource.getConversations',
        error: e,
        stackTrace: st,
        level: 1000,
      );
      rethrow;
    }
  }

  // ─── messages ─────────────────────────────────────────────────────────────

  Future<List<MessageModel>> getMessages(String conversationId) async {
    developer.log(
      'Fetching messages for conversationId: "$conversationId"',
      name: 'MessagingRemoteDataSource.getMessages',
    );

    try {
      final rows = await _client
          .from(ApiEndpoints.messages)
          .select()
          .eq('conversation_id', conversationId)
          .order('sent_at', ascending: true);

      final list = (rows as List)
          .map(
            (r) => MessageModel.fromJson(Map<String, dynamic>.from(r as Map)),
          )
          .toList();

      developer.log(
        'Fetched ${list.length} message(s) for conversation "$conversationId"',
        name: 'MessagingRemoteDataSource.getMessages',
      );
      return list;
    } on PostgrestException catch (e, st) {
      developer.log(
        'PostgrestException in getMessages: ${e.message} (code: ${e.code}, details: ${e.details}, hint: ${e.hint})',
        name: 'MessagingRemoteDataSource.getMessages',
        error: e,
        stackTrace: st,
        level: 1000,
      );
      rethrow;
    } catch (e, st) {
      developer.log(
        'Unexpected exception in getMessages: $e',
        name: 'MessagingRemoteDataSource.getMessages',
        error: e,
        stackTrace: st,
        level: 1000,
      );
      rethrow;
    }
  }

  Future<MessageModel> sendMessage({
    required String conversationId,
    required String content,
  }) async {
    final userId = _currentUserId;
    developer.log(
      'Sending message in conversation "$conversationId" with sender_id: "$userId", content: "$content"',
      name: 'MessagingRemoteDataSource.sendMessage',
    );

    try {
      final row = await _client
          .from(ApiEndpoints.messages)
          .insert({
            'conversation_id': conversationId,
            'sender_id': userId,
            'content': content,
          })
          .select()
          .single();

      developer.log(
        'Message sent successfully! Row id: "${row['id']}"',
        name: 'MessagingRemoteDataSource.sendMessage',
      );

      final msg = MessageModel.fromJson(Map<String, dynamic>.from(row as Map));
      unawaited(_notifyRecipientOfMessage(
        conversationId: conversationId,
        content: content,
        senderId: userId,
      ));
      return msg;
    } on PostgrestException catch (e, st) {
      developer.log(
        'PostgrestException in sendMessage with sender_id = userId ($userId): ${e.message} (code: ${e.code}, details: ${e.details}, hint: ${e.hint})',
        name: 'MessagingRemoteDataSource.sendMessage',
        error: e,
        stackTrace: st,
        level: 900,
      );

      // Fallback: if inserting with userId failed, attempt with profileId
      final ids = await _resolveProfileIds();
      final profileSenderId = ids.startupProfileId ?? ids.investorProfileId;
      if (profileSenderId != null && profileSenderId != userId) {
        developer.log(
          'Attempt 2 (Fallback): Trying with profileSenderId = "$profileSenderId"...',
          name: 'MessagingRemoteDataSource.sendMessage',
        );
        try {
          final fallbackRow = await _client
              .from(ApiEndpoints.messages)
              .insert({
                'conversation_id': conversationId,
                'sender_id': profileSenderId,
                'content': content,
              })
              .select()
              .single();

          developer.log(
            'Message sent successfully on attempt 2! Row id: "${fallbackRow['id']}"',
            name: 'MessagingRemoteDataSource.sendMessage',
          );
          return MessageModel.fromJson(
            Map<String, dynamic>.from(fallbackRow as Map),
          );
        } on PostgrestException catch (e2, st2) {
          developer.log(
            'Attempt 2 (with profileId) also failed: ${e2.message} (code: ${e2.code})',
            name: 'MessagingRemoteDataSource.sendMessage',
            error: e2,
            stackTrace: st2,
            level: 1000,
          );
          rethrow;
        }
      }
      rethrow;
    } catch (e, st) {
      developer.log(
        'Unexpected exception in sendMessage: $e',
        name: 'MessagingRemoteDataSource.sendMessage',
        error: e,
        stackTrace: st,
        level: 1000,
      );
      rethrow;
    }
  }

  Stream<MessageModel> subscribeToMessages(String conversationId) {
    developer.log(
      'Subscribing to realtime messages for conversation "$conversationId"',
      name: 'MessagingRemoteDataSource.subscribeToMessages',
    );

    // Use a StreamController so we can switch between realtime and polling.
    late StreamController<MessageModel> controller;
    Timer? pollTimer;
    final seen = <String>{};
    bool realtimeFailed = false;

    Future<void> fetchAndEmit() async {
      try {
        final rows = await _client
            .from(ApiEndpoints.messages)
            .select()
            .eq('conversation_id', conversationId)
            .order('sent_at', ascending: true);

        for (final row in rows as List) {
          final map = Map<String, dynamic>.from(row as Map);
          final id = map['id']?.toString() ?? '';
          if (!seen.contains(id)) {
            seen.add(id);
            if (!controller.isClosed) {
              controller.add(MessageModel.fromJson(map));
            }
          }
        }
      } catch (e) {
        developer.log(
          'Poll fetch error: $e',
          name: 'MessagingRemoteDataSource.subscribeToMessages',
          level: 900,
        );
      }
    }

    void startPolling() {
      if (realtimeFailed) return;
      realtimeFailed = true;
      developer.log(
        'Realtime unavailable for conversation "$conversationId". Falling back to 3-second polling.',
        name: 'MessagingRemoteDataSource.subscribeToMessages',
        level: 900,
      );
      // Do an immediate fetch, then poll every 3 seconds.
      fetchAndEmit();
      pollTimer = Timer.periodic(const Duration(seconds: 3), (_) {
        fetchAndEmit();
      });
    }

    // Try Supabase Realtime via .stream()
    StreamSubscription<MessageModel>? realtimeSub;

    controller = StreamController<MessageModel>(
      onListen: () {
        try {
          final realtimeStream = _client
              .from(ApiEndpoints.messages)
              .stream(primaryKey: ['id'])
              .eq('conversation_id', conversationId)
              .order('sent_at', ascending: true)
              .map((rows) => rows as List)
              .expand((rows) {
                final newRows = <Map<String, dynamic>>[];
                for (final row in rows) {
                  final map = Map<String, dynamic>.from(row as Map);
                  final id = map['id']?.toString() ?? '';
                  if (!seen.contains(id)) {
                    seen.add(id);
                    newRows.add(map);
                  }
                }
                return newRows;
              })
              .map((row) => MessageModel.fromJson(row));

          realtimeSub = realtimeStream.listen(
            (msg) {
              if (!controller.isClosed) controller.add(msg);
            },
            onError: (err, st) {
              developer.log(
                'Realtime stream error, switching to polling: $err',
                name: 'MessagingRemoteDataSource.subscribeToMessages',
                error: err,
                stackTrace: st,
                level: 900,
              );
              realtimeSub?.cancel();
              startPolling();
            },
          );
        } catch (e, st) {
          developer.log(
            'Failed to create realtime stream, switching to polling: $e',
            name: 'MessagingRemoteDataSource.subscribeToMessages',
            error: e,
            stackTrace: st,
            level: 900,
          );
          startPolling();
        }
      },
      onCancel: () {
        realtimeSub?.cancel();
        pollTimer?.cancel();
      },
    );

    return controller.stream;
  }

  /// Creates a new conversation between a startup profile and an investor
  /// profile, or returns the existing one if already present.
  Future<ConversationModel> getOrCreateConversation({
    required String startupProfileId,
    required String investorProfileId,
    String startupName = '',
    String investorName = '',
  }) async {
    developer.log(
      'getOrCreateConversation called: startupProfileId="$startupProfileId", investorProfileId="$investorProfileId"',
      name: 'MessagingRemoteDataSource.getOrCreateConversation',
    );

    try {
      // Check for existing conversation between this exact pair.
      final existing = await _client
          .from(ApiEndpoints.conversations)
          .select('id, startup_id, investor_id, created_at')
          .eq('startup_id', startupProfileId)
          .eq('investor_id', investorProfileId)
          .maybeSingle();

      final ids = await _resolveProfileIds();
      final bool currentUserIsStartup =
          ids.startupProfileId == startupProfileId;
      final otherName =
          currentUserIsStartup ? investorName : startupName;
      final otherProfileId =
          currentUserIsStartup ? investorProfileId : startupProfileId;

      if (existing != null) {
        developer.log(
          'Found existing conversation id: "${existing['id']}"',
          name: 'MessagingRemoteDataSource.getOrCreateConversation',
        );
        final map = Map<String, dynamic>.from(existing as Map);
        return ConversationModel.fromEnriched({
          ...map,
          'other_participant_profile_id': otherProfileId,
          'other_participant_name':
              otherName.isNotEmpty ? otherName : 'Unknown',
        });
      }

      developer.log(
        'No existing conversation found. Inserting new conversation (startup_id: $startupProfileId, investor_id: $investorProfileId)...',
        name: 'MessagingRemoteDataSource.getOrCreateConversation',
      );

      final row = await _client
          .from(ApiEndpoints.conversations)
          .insert({
            'startup_id': startupProfileId,
            'investor_id': investorProfileId,
          })
          .select()
          .single();

      developer.log(
        'Created new conversation successfully! ID: "${row['id']}"',
        name: 'MessagingRemoteDataSource.getOrCreateConversation',
      );

      final map = Map<String, dynamic>.from(row as Map);
      return ConversationModel.fromEnriched({
        ...map,
        'other_participant_profile_id': otherProfileId,
        'other_participant_name':
            otherName.isNotEmpty ? otherName : 'Unknown',
      });
    } on PostgrestException catch (e, st) {
      developer.log(
        'PostgrestException in getOrCreateConversation: ${e.message} (code: ${e.code}, details: ${e.details}, hint: ${e.hint})',
        name: 'MessagingRemoteDataSource.getOrCreateConversation',
        error: e,
        stackTrace: st,
        level: 1000,
      );
      rethrow;
    } catch (e, st) {
      developer.log(
        'Unexpected exception in getOrCreateConversation: $e',
        name: 'MessagingRemoteDataSource.getOrCreateConversation',
        error: e,
        stackTrace: st,
        level: 1000,
      );
      rethrow;
    }
  }

  /// Returns the `investor_profiles.id` for the currently authenticated user,
  /// creating a minimal profile if not yet initialized, or `null` on failure.
  Future<String?> resolveInvestorProfileId() async {
    final userId = _currentUserId;
    developer.log(
      'Resolving investor profile ID for user $userId...',
      name: 'MessagingRemoteDataSource.resolveInvestorProfileId',
    );

    try {
      final row = await _client
          .from(ApiEndpoints.investorProfiles)
          .select('id')
          .eq('user_id', userId)
          .maybeSingle();

      if (row != null && row['id'] != null) {
        final id = row['id'].toString();
        developer.log(
          'Found existing investor profile ID: "$id"',
          name: 'MessagingRemoteDataSource.resolveInvestorProfileId',
        );
        return id;
      }

      developer.log(
        'No investor profile found for user $userId. Auto-creating baseline record...',
        name: 'MessagingRemoteDataSource.resolveInvestorProfileId',
      );

      final userRow = await _client
          .from(ApiEndpoints.users)
          .select('full_name, email')
          .eq('id', userId)
          .maybeSingle();

      final name = userRow?['full_name']?.toString() ??
          _client.auth.currentUser?.userMetadata?['full_name']?.toString() ??
          'Investor';

      final inserted = await _client
          .from(ApiEndpoints.investorProfiles)
          .insert({
            'user_id': userId,
            'investor_type': 'Individual Angel',
            'organization_name': name,
          })
          .select('id')
          .single();

      final newId = inserted['id']?.toString();
      developer.log(
        'Auto-created investor profile with ID: "$newId"',
        name: 'MessagingRemoteDataSource.resolveInvestorProfileId',
      );
      return newId;
    } on PostgrestException catch (e, st) {
      developer.log(
        'PostgrestException in resolveInvestorProfileId: ${e.message} (code: ${e.code}, details: ${e.details}, hint: ${e.hint})',
        name: 'MessagingRemoteDataSource.resolveInvestorProfileId',
        error: e,
        stackTrace: st,
        level: 1000,
      );
      return null;
    } catch (e, st) {
      developer.log(
        'Unexpected exception in resolveInvestorProfileId: $e',
        name: 'MessagingRemoteDataSource.resolveInvestorProfileId',
        error: e,
        stackTrace: st,
        level: 1000,
      );
      return null;
    }
  }

  /// Returns the `startup_profiles.id` for the currently authenticated user,
  /// or `null` if no startup profile exists.
  Future<String?> resolveStartupProfileId() async {
    final userId = _currentUserId;
    developer.log(
      'Resolving startup profile ID for user $userId...',
      name: 'MessagingRemoteDataSource.resolveStartupProfileId',
    );

    try {
      final row = await _client
          .from(ApiEndpoints.startupProfiles)
          .select('id')
          .eq('user_id', userId)
          .maybeSingle();

      final id = row?['id']?.toString();
      developer.log(
        'Resolved startup profile ID: "$id"',
        name: 'MessagingRemoteDataSource.resolveStartupProfileId',
      );
      return id;
    } on PostgrestException catch (e, st) {
      developer.log(
        'PostgrestException in resolveStartupProfileId: ${e.message} (code: ${e.code})',
        name: 'MessagingRemoteDataSource.resolveStartupProfileId',
        error: e,
        stackTrace: st,
        level: 1000,
      );
      return null;
    } catch (e, st) {
      developer.log(
        'Unexpected exception in resolveStartupProfileId: $e',
        name: 'MessagingRemoteDataSource.resolveStartupProfileId',
        error: e,
        stackTrace: st,
        level: 1000,
      );
      return null;
    }
  }

  Future<void> _notifyRecipientOfMessage({
    required String conversationId,
    required String content,
    required String senderId,
  }) async {
    try {
      final conv = await _client
          .from(ApiEndpoints.conversations)
          .select('startup_id, investor_id')
          .eq('id', conversationId)
          .maybeSingle();

      if (conv == null) return;

      final startupId = conv['startup_id']?.toString();
      final investorId = conv['investor_id']?.toString();

      String? recipientUserId;

      final ids = await _resolveProfileIds();
      final currentStartupId = ids.startupProfileId;
      final currentInvestorId = ids.investorProfileId;

      if (currentStartupId != null && currentStartupId == startupId) {
        final investorRow = await _client
            .from(ApiEndpoints.investorProfiles)
            .select('user_id')
            .eq('id', investorId ?? '')
            .maybeSingle();
        recipientUserId = investorRow?['user_id']?.toString();
      } else if (currentInvestorId != null && currentInvestorId == investorId) {
        final startupRow = await _client
            .from(ApiEndpoints.startupProfiles)
            .select('user_id')
            .eq('id', startupId ?? '')
            .maybeSingle();
        recipientUserId = startupRow?['user_id']?.toString();
      } else {
        final investorRow = await _client
            .from(ApiEndpoints.investorProfiles)
            .select('user_id')
            .eq('id', investorId ?? '')
            .maybeSingle();
        final startupRow = await _client
            .from(ApiEndpoints.startupProfiles)
            .select('user_id')
            .eq('id', startupId ?? '')
            .maybeSingle();

        final invUserId = investorRow?['user_id']?.toString();
        final stUserId = startupRow?['user_id']?.toString();

        if (senderId == invUserId) {
          recipientUserId = stUserId;
        } else {
          recipientUserId = invUserId;
        }
      }

      if (recipientUserId != null && recipientUserId.isNotEmpty) {
        // Look up sender's display name for a friendlier notification title.
        String notificationTitle = 'New Message';
        try {
          final senderRow = await _client
              .from(ApiEndpoints.users)
              .select('full_name')
              .eq('id', senderId)
              .maybeSingle();
          final senderName = senderRow?['full_name']?.toString();
          if (senderName != null && senderName.isNotEmpty) {
            notificationTitle = senderName;
          }
        } catch (_) {}

        await _client.from(ApiEndpoints.notifications).insert({
          'user_id': recipientUserId,
          'title': notificationTitle,
          'body': content,
          'type': 'message',
          'is_read': false,
          'data': {
            'conversation_id': conversationId,
            'sender_id': senderId,
          },
        });

        try {
          await _client.functions.invoke(
            ApiEndpoints.sendNotificationFunction,
            body: {
              'user_id': recipientUserId,
              'title': notificationTitle,
              'body': content,
              'data': {
                'conversation_id': conversationId,
                'sender_id': senderId,
              },
            },
          );
        } catch (_) {}
      }
    } catch (e) {
      developer.log(
        'Non-fatal notification error: $e',
        name: 'MessagingRemoteDataSource._notifyRecipientOfMessage',
      );
    }
  }
}
