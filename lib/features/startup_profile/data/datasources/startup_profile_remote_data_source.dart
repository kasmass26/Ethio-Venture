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
    Object? lastException;

    // Attempt 1: Minimal Live Schema (company_name, target_funding_amount, founder_email)
    try {
      final response = await _client
          .from(_tableName)
          .insert(profile.toMinimalLiveInsertJson())
          .select()
          .single();
      return StartupProfileModel.fromJson(response);
    } catch (e) {
      lastException = e;
    }

    // Attempt 2: Full Migration Schema (startup_name, funding_amount_needed, contact_information)
    try {
      final response = await _client
          .from(_tableName)
          .insert(profile.toMigrationInsertJson())
          .select()
          .single();
      return StartupProfileModel.fromJson(response);
    } catch (e) {
      lastException = e;
    }

    // Attempt 3: Full Live Schema (with optional fields)
    try {
      final response = await _client
          .from(_tableName)
          .insert(profile.toLiveDatabaseInsertJson())
          .select()
          .single();
      return StartupProfileModel.fromJson(response);
    } catch (e) {
      lastException = e;
    }

    if (lastException is PostgrestException) {
      throw ServerException(
        message: lastException.message,
        statusCode: int.tryParse(lastException.code ?? ''),
      );
    }
    throw ServerException(
      message: 'Failed to create startup profile: $lastException',
    );
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
    Object? lastException;

    // Attempt 1: Minimal Live Schema Update
    try {
      final response = await _client
          .from(_tableName)
          .update(profile.toMinimalLiveUpdateJson())
          .eq('user_id', profile.userId)
          .select()
          .single();
      return StartupProfileModel.fromJson(response);
    } catch (e) {
      lastException = e;
    }

    // Attempt 2: Migration Schema Update
    try {
      final response = await _client
          .from(_tableName)
          .update(profile.toMigrationUpdateJson())
          .eq('user_id', profile.userId)
          .select()
          .single();
      return StartupProfileModel.fromJson(response);
    } catch (e) {
      lastException = e;
    }

    if (lastException is PostgrestException) {
      throw ServerException(
        message: lastException.message,
        statusCode: int.tryParse(lastException.code ?? ''),
      );
    }
    throw ServerException(
      message: 'Failed to update startup profile: $lastException',
    );
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
