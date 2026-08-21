import 'dart:async';
import 'dart:developer' as developer;

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/network/api_endpoints.dart';
import '../../domain/entities/connection_request_entity.dart';
import '../models/connection_request_model.dart';

/// Supabase implementation of connection request CRUD operations.
class ConnectionRequestRemoteDataSource {
  ConnectionRequestRemoteDataSource({required SupabaseClient supabaseClient})
      : _client = supabaseClient;

  final SupabaseClient _client;

  String? get _currentUserId => _client.auth.currentUser?.id;

  // ── Send Request ──────────────────────────────────────────────────────────

  Future<ConnectionRequestModel> sendRequest({
    required String investorUserId,
    required String investorProfileId,
    String? message,
  }) async {
    final userId = _currentUserId;
    if (userId == null) throw Exception('User not authenticated');

    // Resolve startup profile for the current founder
    final startupResp = await _client
        .from(ApiEndpoints.startupProfiles)
        .select('id')
        .eq('user_id', userId)
        .maybeSingle();

    final startupProfileId = startupResp?['id']?.toString();

    final data = {
      'founder_user_id': userId,
      'investor_user_id': investorUserId,
      if (startupProfileId != null) 'startup_profile_id': startupProfileId,
      'investor_profile_id': investorProfileId,
      'status': 'pending',
      if (message != null && message.isNotEmpty) 'message': message,
    };

    final response = await _client
        .from(ApiEndpoints.connectionRequests)
        .upsert(data, onConflict: 'founder_user_id,investor_user_id')
        .select()
        .single();

    developer.log(
      'Connection request sent to investor $investorUserId',
      name: 'ConnectionRequestRemoteDataSource.sendRequest',
    );

    return ConnectionRequestModel.fromJson(response);
  }

  // ── Investor: Get incoming requests ──────────────────────────────────────

  Future<List<ConnectionRequestModel>> getRequestsForInvestor() async {
    final userId = _currentUserId;
    if (userId == null) return [];

    try {
      final response = await _client
          .from(ApiEndpoints.connectionRequests)
          .select('''
            id, founder_user_id, investor_user_id, startup_profile_id,
            investor_profile_id, status, message, created_at, updated_at,
            startup_profiles!startup_profile_id(startup_name)
          ''')
          .eq('investor_user_id', userId)
          .order('created_at', ascending: false);

      final list = (response as List).map((json) {
        // Flatten startup name
        final map = Map<String, dynamic>.from(json as Map);
        if (map['startup_profiles'] != null) {
          map['startup_name'] =
              (map['startup_profiles'] as Map?)?['startup_name'];
        }
        return ConnectionRequestModel.fromJson(map);
      }).toList();

      return list;
    } catch (e) {
      developer.log(
        'Error fetching investor requests: $e',
        name: 'ConnectionRequestRemoteDataSource.getRequestsForInvestor',
      );
      return [];
    }
  }

  // ── Founder: Get outgoing requests ────────────────────────────────────────

  Future<List<ConnectionRequestModel>> getRequestsForFounder() async {
    final userId = _currentUserId;
    if (userId == null) return [];

    try {
      final response = await _client
          .from(ApiEndpoints.connectionRequests)
          .select('''
            id, founder_user_id, investor_user_id, startup_profile_id,
            investor_profile_id, status, message, created_at, updated_at,
            investor_profiles!investor_profile_id(display_name)
          ''')
          .eq('founder_user_id', userId)
          .order('created_at', ascending: false);

      final list = (response as List).map((json) {
        final map = Map<String, dynamic>.from(json as Map);
        if (map['investor_profiles'] != null) {
          map['investor_name'] =
              (map['investor_profiles'] as Map?)?['display_name'];
        }
        return ConnectionRequestModel.fromJson(map);
      }).toList();

      return list;
    } catch (e) {
      developer.log(
        'Error fetching founder requests: $e',
        name: 'ConnectionRequestRemoteDataSource.getRequestsForFounder',
      );
      return [];
    }
  }

  // ── Respond to Request ────────────────────────────────────────────────────

  Future<ConnectionRequestModel> respondToRequest({
    required String requestId,
    required ConnectionRequestStatus status,
  }) async {
    final response = await _client
        .from(ApiEndpoints.connectionRequests)
        .update({'status': status.name})
        .eq('id', requestId)
        .select()
        .single();

    return ConnectionRequestModel.fromJson(response);
  }

  // ── Check status between two users ───────────────────────────────────────

  Future<ConnectionRequestModel?> getRequestBetween({
    required String otherUserId,
  }) async {
    final userId = _currentUserId;
    if (userId == null) return null;

    try {
      // Check both directions: current user is founder or investor
      final response = await _client
          .from(ApiEndpoints.connectionRequests)
          .select()
          .or('and(founder_user_id.eq.$userId,investor_user_id.eq.$otherUserId),'
              'and(founder_user_id.eq.$otherUserId,investor_user_id.eq.$userId)')
          .maybeSingle();

      if (response == null) return null;
      return ConnectionRequestModel.fromJson(response);
    } catch (e) {
      developer.log(
        'Error checking request status: $e',
        name: 'ConnectionRequestRemoteDataSource.getRequestBetween',
      );
      return null;
    }
  }

  // ── Real-time stream for investor ─────────────────────────────────────────

  Stream<List<ConnectionRequestModel>> subscribeToInvestorRequests() {
    final userId = _currentUserId;
    if (userId == null) return const Stream.empty();

    final controller = StreamController<List<ConnectionRequestModel>>();

    // Initial fetch
    getRequestsForInvestor().then((list) {
      if (!controller.isClosed) controller.add(list);
    });

    final subscription = _client
        .from(ApiEndpoints.connectionRequests)
        .stream(primaryKey: ['id'])
        .eq('investor_user_id', userId)
        .listen(
          (data) {
            final list = data.map(ConnectionRequestModel.fromJson).toList();
            if (!controller.isClosed) controller.add(list);
          },
          onError: (e) {
            developer.log(
              'Realtime error: $e',
              name:
                  'ConnectionRequestRemoteDataSource.subscribeToInvestorRequests',
            );
          },
        );

    controller.onCancel = () {
      subscription.cancel();
      controller.close();
    };

    return controller.stream;
  }

  // ── Send in-app notification ──────────────────────────────────────────────

  Future<void> sendInAppNotification({
    required String recipientUserId,
    required String title,
    required String body,
    required String type,
    Map<String, dynamic>? data,
  }) async {
    try {
      await _client.from(ApiEndpoints.notifications).insert({
        'user_id': recipientUserId,
        'title': title,
        'body': body,
        'type': type,
        'is_read': false,
        'data': ?data,
      });
    } catch (e) {
      developer.log(
        'Error sending in-app notification: $e',
        name: 'ConnectionRequestRemoteDataSource.sendInAppNotification',
      );
    }
  }
}
