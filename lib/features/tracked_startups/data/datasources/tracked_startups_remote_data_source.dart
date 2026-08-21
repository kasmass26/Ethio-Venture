import 'dart:developer' as developer;
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:ethioventure/core/network/api_endpoints.dart';
import 'package:ethioventure/features/tracked_startups/data/models/tracked_startup_model.dart';

abstract class TrackedStartupsRemoteDataSource {
  Future<List<TrackedStartupModel>> getTrackedStartups();
  Future<TrackedStartupModel> trackStartup(String startupId);
  Future<void> untrackStartup(String startupId);
  Future<bool> isTracked(String startupId);
}

class TrackedStartupsRemoteDataSourceImpl implements TrackedStartupsRemoteDataSource {
  TrackedStartupsRemoteDataSourceImpl({required SupabaseClient supabaseClient})
      : _client = supabaseClient;

  final SupabaseClient _client;

  String? get _currentUserId => _client.auth.currentUser?.id;

  @override
  Future<List<TrackedStartupModel>> getTrackedStartups() async {
    final userId = _currentUserId;
    if (userId == null) return [];

    try {
      // Direct query to tracked_startups table for current investor
      final trackedRows = await _client
          .from(ApiEndpoints.trackedStartups)
          .select()
          .eq('investor_user_id', userId)
          .order('created_at', ascending: false);

      final list = <TrackedStartupModel>[];
      for (final row in (trackedRows as List)) {
        final rowMap = Map<String, dynamic>.from(row as Map);
        final startupId = rowMap['startup_id']?.toString() ?? '';

        if (startupId.isNotEmpty) {
          // Look up startup by primary key id
          dynamic startupData = await _client
              .from(ApiEndpoints.startupProfiles)
              .select()
              .eq('id', startupId)
              .maybeSingle();

          // If not found by id, try by user_id
          startupData ??= await _client
              .from(ApiEndpoints.startupProfiles)
              .select()
              .eq('user_id', startupId)
              .maybeSingle();

          if (startupData != null) {
            rowMap['startup_profiles'] = startupData;
          }
        }
        list.add(TrackedStartupModel.fromJson(rowMap));
      }
      return list;
    } catch (e) {
      developer.log(
        'Error fetching tracked startups: $e',
        name: 'TrackedStartupsRemoteDataSource.getTrackedStartups',
      );
      return [];
    }
  }

  @override
  Future<TrackedStartupModel> trackStartup(String startupId) async {
    final userId = _currentUserId;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    // Delete any existing row first to ensure idempotency
    try {
      await _client
          .from(ApiEndpoints.trackedStartups)
          .delete()
          .eq('investor_user_id', userId)
          .eq('startup_id', startupId);
    } catch (_) {}

    final response = await _client
        .from(ApiEndpoints.trackedStartups)
        .insert({
          'investor_user_id': userId,
          'startup_id': startupId,
        })
        .select()
        .single();

    dynamic startupData = await _client
        .from(ApiEndpoints.startupProfiles)
        .select()
        .eq('id', startupId)
        .maybeSingle();

    startupData ??= await _client
        .from(ApiEndpoints.startupProfiles)
        .select()
        .eq('user_id', startupId)
        .maybeSingle();

    final map = Map<String, dynamic>.from(response);
    if (startupData != null) {
      map['startup_profiles'] = startupData;
    }

    return TrackedStartupModel.fromJson(map);
  }

  @override
  Future<void> untrackStartup(String startupId) async {
    final userId = _currentUserId;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    await _client
        .from(ApiEndpoints.trackedStartups)
        .delete()
        .eq('investor_user_id', userId)
        .eq('startup_id', startupId);
  }

  @override
  Future<bool> isTracked(String startupId) async {
    final userId = _currentUserId;
    if (userId == null) return false;

    try {
      final response = await _client
          .from(ApiEndpoints.trackedStartups)
          .select('id')
          .eq('investor_user_id', userId)
          .eq('startup_id', startupId)
          .maybeSingle();

      return response != null;
    } catch (_) {
      return false;
    }
  }
}
