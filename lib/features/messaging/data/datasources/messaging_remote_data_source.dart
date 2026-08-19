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
    if (uid == null) throw Exception('No authenticated user.');
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

    final startupRow = results[0];
    final investorRow = results[1];

    return (
      startupProfileId: startupRow?['id']?.toString(),
      investorProfileId: investorRow?['id']?.toString(),
    );
  }

  // ─── conversations ────────────────────────────────────────────────────────

  Future<List<ConversationModel>> getConversations() async {
    final ids = await _resolveProfileIds();
    final startupId = ids.startupProfileId;
    final investorId = ids.investorProfileId;

    if (startupId == null && investorId == null) {
      throw Exception(
        'No startup or investor profile found for this account.',
      );
    }

    // Build OR filter using whichever profile IDs this user has.
    final orParts = <String>[];
    if (startupId != null) orParts.add('startup_id.eq.$startupId');
    if (investorId != null) orParts.add('investor_id.eq.$investorId');
    final orFilter = orParts.join(',');

    final rows = await _client
        .from(ApiEndpoints.conversations)
        .select('id, startup_id, investor_id, created_at')
        .or(orFilter)
        .order('created_at', ascending: false);

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

      // Resolve the other participant's display name through their profile
      // then through the users table.
      String otherName = 'Unknown';
      String? otherAvatar;

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

      // Fetch latest message for preview.
      final msgs = await _client
          .from(ApiEndpoints.messages)
          .select('content, sent_at')
          .eq('conversation_id', convId)
          .order('sent_at', ascending: false)
          .limit(1);

      String? latestContent;
      String? latestAt;
      if ((msgs as List).isNotEmpty) {
        final latest = msgs.first as Map;
        latestContent = latest['content']?.toString();
        latestAt = latest['sent_at']?.toString();
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

    return result;
  }

  // ─── messages ─────────────────────────────────────────────────────────────

  Future<List<MessageModel>> getMessages(String conversationId) async {
    final rows = await _client
        .from(ApiEndpoints.messages)
        .select()
        .eq('conversation_id', conversationId)
        .order('sent_at', ascending: true);

    return (rows as List)
        .map(
          (r) => MessageModel.fromJson(Map<String, dynamic>.from(r as Map)),
        )
        .toList();
  }

  Future<MessageModel> sendMessage({
    required String conversationId,
    required String content,
  }) async {
    // Resolve the correct sender profile ID (startup or investor).
    final ids = await _resolveProfileIds();
    final senderId = ids.startupProfileId ?? ids.investorProfileId;
    if (senderId == null) {
      throw Exception('No profile found. Cannot send message.');
    }

    final row = await _client
        .from(ApiEndpoints.messages)
        .insert({
          'conversation_id': conversationId,
          'sender_id': senderId,
          'content': content,
        })
        .select()
        .single();

    return MessageModel.fromJson(Map<String, dynamic>.from(row as Map));
  }

  Stream<MessageModel> subscribeToMessages(String conversationId) {
    final seen = <String>{};

    return _client
        .from(ApiEndpoints.messages)
        .stream(primaryKey: ['id'])
        .eq('conversation_id', conversationId)
        .order('sent_at', ascending: true)
        .expand((rows) {
          final newRows = <Map<String, dynamic>>[];
          for (final row in rows) {
            final id = row['id']?.toString() ?? '';
            if (!seen.contains(id)) {
              seen.add(id);
              newRows.add(Map<String, dynamic>.from(row));
            }
          }
          return newRows;
        })
        .map((row) => MessageModel.fromJson(row));
  }

  /// Creates a new conversation between a startup profile and an investor
  /// profile, or returns the existing one if already present.
  ///
  /// [startupProfileId]  — `startup_profiles.id`
  /// [investorProfileId] — `investor_profiles.id`
  /// [startupName]       — display name of the startup (for the return model)
  /// [investorName]      — display name of the investor (for the return model)
  Future<ConversationModel> getOrCreateConversation({
    required String startupProfileId,
    required String investorProfileId,
    String startupName = '',
    String investorName = '',
  }) async {
    // Check for existing conversation between this exact pair.
    final existing = await _client
        .from(ApiEndpoints.conversations)
        .select('id, startup_id, investor_id, created_at')
        .eq('startup_id', startupProfileId)
        .eq('investor_id', investorProfileId)
        .maybeSingle();

    // Determine which side the current user is on so we know who the
    // "other" participant is for the returned model.
    final ids = await _resolveProfileIds();
    final bool currentUserIsStartup =
        ids.startupProfileId == startupProfileId;
    final otherName =
        currentUserIsStartup ? investorName : startupName;
    final otherProfileId =
        currentUserIsStartup ? investorProfileId : startupProfileId;

    if (existing != null) {
      final map = Map<String, dynamic>.from(existing as Map);
      return ConversationModel.fromEnriched({
        ...map,
        'other_participant_profile_id': otherProfileId,
        'other_participant_name':
            otherName.isNotEmpty ? otherName : 'Unknown',
      });
    }

    final row = await _client
        .from(ApiEndpoints.conversations)
        .insert({
          'startup_id': startupProfileId,
          'investor_id': investorProfileId,
        })
        .select()
        .single();

    final map = Map<String, dynamic>.from(row as Map);
    return ConversationModel.fromEnriched({
      ...map,
      'other_participant_profile_id': otherProfileId,
      'other_participant_name':
          otherName.isNotEmpty ? otherName : 'Unknown',
    });
  }

  /// Returns the `investor_profiles.id` for the currently authenticated user,
  /// or `null` if no investor profile exists.
  Future<String?> resolveInvestorProfileId() async {
    final userId = _currentUserId;
    final row = await _client
        .from(ApiEndpoints.investorProfiles)
        .select('id')
        .eq('user_id', userId)
        .maybeSingle();
    return row?['id']?.toString();
  }
}
