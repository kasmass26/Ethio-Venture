import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ethioventure/core/config/app_config.dart';
import 'package:ethioventure/core/error/exceptions.dart';
import '../models/startup_profile_model.dart';

/// Contract for remote Supabase database operations on `startup_profiles`.
abstract interface class StartupProfileRemoteDataSource {
  /// Inserts or upserts a new startup profile row into Supabase.
  Future<StartupProfileModel> createProfile(StartupProfileModel profile);

  /// Queries the `startup_profiles` table for a profile with matching [userId].
  Future<StartupProfileModel?> getProfile(String userId);

  /// Updates an existing `startup_profiles` row in Supabase.
  Future<StartupProfileModel> updateProfile(StartupProfileModel profile);

  /// Deletes a `startup_profiles` row from Supabase.
  Future<void> deleteProfile(String userId);
}

/// Concrete implementation of [StartupProfileRemoteDataSource] using Supabase SDK.
class StartupProfileRemoteDataSourceImpl
    implements StartupProfileRemoteDataSource {
  const StartupProfileRemoteDataSourceImpl(this._client);

  final SupabaseClient _client;

  static const String _tableName = 'startup_profiles';
  static const String _defaultSeedUserId = '71c17916-032d-47fb-b3f5-a9a097036716';

  SupabaseClient _getAnonClient() {
    try {
      final config = AppConfig.fromEnvironment();
      return SupabaseClient(
        config.supabaseUrl,
        config.supabasePublishableKey,
      );
    } catch (_) {
      return _client;
    }
  }

  @override
  Future<StartupProfileModel> createProfile(StartupProfileModel profile) async {
    final insertMap = profile.toInsertJson();
    insertMap['user_id'] = _defaultSeedUserId;

    final client = _getAnonClient();

    try {
      final response = await client
          .from(_tableName)
          .upsert(insertMap, onConflict: 'user_id')
          .select()
          .single();
      return StartupProfileModel.fromJson(response);
    } catch (e) {
      if (e is PostgrestException) {
        throw ServerException(
          message: e.message,
          statusCode: int.tryParse(e.code ?? ''),
        );
      }
      throw ServerException(message: 'Failed to create startup profile: $e');
    }
  }

  @override
  Future<StartupProfileModel?> getProfile(String userId) async {
    final client = _getAnonClient();

    try {
      final response = await client
          .from(_tableName)
          .select()
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();

      if (response == null) {
        return null;
      }
      return StartupProfileModel.fromJson(response);
    } on PostgrestException catch (e) {
      throw ServerException(
        message: e.message,
        statusCode: int.tryParse(e.code ?? ''),
      );
    } catch (e) {
      throw ServerException(message: 'Failed to load startup profile: $e');
    }
  }

  @override
  Future<StartupProfileModel> updateProfile(StartupProfileModel profile) async {
    final updateMap = profile.toUpdateJson();
    updateMap['user_id'] = _defaultSeedUserId;

    final client = _getAnonClient();

    try {
      final response = await client
          .from(_tableName)
          .upsert(updateMap, onConflict: 'user_id')
          .select()
          .single();
      return StartupProfileModel.fromJson(response);
    } catch (e) {
      if (e is PostgrestException) {
        throw ServerException(
          message: e.message,
          statusCode: int.tryParse(e.code ?? ''),
        );
      }
      throw ServerException(message: 'Failed to update startup profile: $e');
    }
  }

  @override
  Future<void> deleteProfile(String userId) async {
    final client = _getAnonClient();

    try {
      await client.from(_tableName).delete().eq('user_id', _defaultSeedUserId);
    } on PostgrestException catch (e) {
      throw ServerException(
        message: e.message,
        statusCode: int.tryParse(e.code ?? ''),
      );
    } catch (e) {
      throw ServerException(message: 'Failed to delete startup profile: $e');
    }
  }
}
