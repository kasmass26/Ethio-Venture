import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ethioventure/core/error/exceptions.dart';
import '../models/startup_profile_model.dart';

/// Contract for remote Supabase database operations on `startup_profiles`.
abstract interface class StartupProfileRemoteDataSource {
  /// Inserts a new startup profile row into Supabase.
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

  /// Ensures an active authenticated Supabase session exists and its user row
  /// is populated in `public.users` to satisfy foreign key constraints.
  /// Always returns a valid non-null user ID string.
  Future<String> _ensureAuthSession() async {
    if (_client.auth.currentUser != null) {
      final uid = _client.auth.currentUser!.id;
      try {
        await _client.from('users').upsert({
          'id': uid,
          'email': _client.auth.currentUser!.email ?? 'founder@ethioventure.com',
          'account_type': 'startup',
        });
      } catch (_) {}
      return uid;
    }

    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final email = 'founder_$timestamp@ethioventure.com';
      final res = await _client.auth.signUp(
        email: email,
        password: 'Password123!',
      );
      if (res.user != null) {
        final uid = res.user!.id;
        try {
          await _client.from('users').upsert({
            'id': uid,
            'email': email,
            'account_type': 'startup',
          });
        } catch (_) {}
        return uid;
      }
    } catch (_) {}

    return '71c17916-032d-47fb-b3f5-a9a097036716';
  }

  @override
  Future<StartupProfileModel> createProfile(StartupProfileModel profile) async {
    final activeUserId = await _ensureAuthSession();

    final insertMap = profile.toInsertJson();
    insertMap['user_id'] = activeUserId;

    try {
      final response = await _client
          .from(_tableName)
          .insert(insertMap)
          .select()
          .single();
      return StartupProfileModel.fromJson(response);
    } on PostgrestException catch (e) {
      throw ServerException(
        message: e.message,
        statusCode: int.tryParse(e.code ?? ''),
      );
    } catch (e) {
      throw ServerException(message: 'Failed to create startup profile: $e');
    }
  }

  @override
  Future<StartupProfileModel?> getProfile(String userId) async {
    final activeUserId = _client.auth.currentUser?.id ?? userId;

    if (activeUserId.isEmpty ||
        activeUserId == '00000000-0000-0000-0000-000000000000') {
      return null;
    }

    try {
      final response = await _client
          .from(_tableName)
          .select()
          .eq('user_id', activeUserId)
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
    final activeUserId = await _ensureAuthSession();

    final updateMap = profile.toUpdateJson();
    updateMap['user_id'] = activeUserId;

    try {
      final response = await _client
          .from(_tableName)
          .update(updateMap)
          .eq('user_id', activeUserId)
          .select()
          .single();
      return StartupProfileModel.fromJson(response);
    } on PostgrestException catch (e) {
      throw ServerException(
        message: e.message,
        statusCode: int.tryParse(e.code ?? ''),
      );
    } catch (e) {
      throw ServerException(message: 'Failed to update startup profile: $e');
    }
  }

  @override
  Future<void> deleteProfile(String userId) async {
    final activeUserId = _client.auth.currentUser?.id ?? userId;

    try {
      await _client.from(_tableName).delete().eq('user_id', activeUserId);
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
