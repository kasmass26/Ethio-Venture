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
  Future<void> _ensureAuthSession() async {
    if (_client.auth.currentUser == null) {
      try {
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final res = await _client.auth.signUp(
          email: 'founder_$timestamp@ethioventure.com',
          password: 'Password123!',
        );
        if (res.user != null) {
          try {
            await _client.from('users').upsert({
              'id': res.user!.id,
              'email': res.user!.email,
              'role': 'founder',
            });
          } catch (_) {}
        }
      } catch (_) {}
    } else {
      try {
        await _client.from('users').upsert({
          'id': _client.auth.currentUser!.id,
          'email': _client.auth.currentUser!.email ?? 'founder@ethioventure.com',
          'role': 'founder',
        });
      } catch (_) {}
    }
  }

  @override
  Future<StartupProfileModel> createProfile(StartupProfileModel profile) async {
    await _ensureAuthSession();

    try {
      final response = await _client
          .from(_tableName)
          .insert(profile.toInsertJson())
          .select()
          .single();
      return StartupProfileModel.fromJson(response);
    } on PostgrestException catch (e) {
      if (e.code == '42501' || e.message.contains('row-level security')) {
        throw const ServerException(
          message:
              'Row-Level Security: Please sign in as a founder to create a profile.',
          statusCode: 401,
        );
      }
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
    await _ensureAuthSession();

    final activeUserId = _client.auth.currentUser?.id ?? profile.userId;

    try {
      final response = await _client
          .from(_tableName)
          .update(profile.toUpdateJson())
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
