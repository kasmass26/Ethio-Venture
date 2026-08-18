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

  @override
  Future<StartupProfileModel> createProfile(StartupProfileModel profile) async {
    try {
      // First attempt: try live database schema keys (company_name, founder_email, etc.)
      final response = await _client
          .from(_tableName)
          .insert(profile.toLiveDatabaseInsertJson())
          .select()
          .single();

      return StartupProfileModel.fromJson(response);
    } on PostgrestException catch (e) {
      if (e.message.contains('column') || e.code == 'PGRST204' || e.code == '42703') {
        try {
          // Fallback attempt: try migration schema keys (startup_name, contact_information, etc.)
          final response = await _client
              .from(_tableName)
              .insert(profile.toMigrationInsertJson())
              .select()
              .single();
          return StartupProfileModel.fromJson(response);
        } catch (_) {}
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
    try {
      final response = await _client
          .from(_tableName)
          .select()
          .eq('user_id', userId)
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
    try {
      final response = await _client
          .from(_tableName)
          .update(profile.toLiveDatabaseUpdateJson())
          .eq('user_id', profile.userId)
          .select()
          .single();

      return StartupProfileModel.fromJson(response);
    } on PostgrestException catch (e) {
      if (e.message.contains('column') || e.code == 'PGRST204' || e.code == '42703') {
        try {
          final response = await _client
              .from(_tableName)
              .update(profile.toMigrationUpdateJson())
              .eq('user_id', profile.userId)
              .select()
              .single();
          return StartupProfileModel.fromJson(response);
        } catch (_) {}
      }
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
    try {
      await _client.from(_tableName).delete().eq('user_id', userId);
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
