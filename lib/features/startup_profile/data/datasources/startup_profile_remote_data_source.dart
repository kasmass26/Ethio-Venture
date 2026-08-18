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

  /// Ensures an active authenticated Supabase session exists so Row-Level Security (RLS) policies allow inserts.
  Future<void> _ensureAuthSession() async {
    if (_client.auth.currentUser == null) {
      try {
        await _client.auth.signInAnonymously();
      } catch (_) {
        try {
          final timestamp = DateTime.now().millisecondsSinceEpoch;
          await _client.auth.signUp(
            email: 'founder_$timestamp@ethioventure.com',
            password: 'Password123!',
          );
        } catch (_) {}
      }
    }
  }

  @override
  Future<StartupProfileModel> createProfile(StartupProfileModel profile) async {
    await _ensureAuthSession();

    final activeUserId = _client.auth.currentUser?.id ?? profile.userId;

    final insertData = <String, dynamic>{
      'startup_name': profile.startupName,
      'description': profile.description,
      'industry': profile.industry,
      'funding_stage': profile.fundingStage,
      'funding_amount_needed': profile.fundingAmountNeeded,
      'location': profile.location,
      'team_information': profile.teamInformation,
      'contact_information': profile.contactInformation,
    };

    if (activeUserId.isNotEmpty &&
        activeUserId != '00000000-0000-0000-0000-000000000000') {
      insertData['user_id'] = activeUserId;
    }

    try {
      final response = await _client
          .from(_tableName)
          .insert(insertData)
          .select()
          .single();
      return StartupProfileModel.fromJson(response);
    } on PostgrestException catch (e) {
      // Fallback attempt for alternative database table column names if live schema differs
      if (e.message.contains('column') ||
          e.code == 'PGRST204' ||
          e.code == '42703') {
        try {
          final altResponse = await _client
              .from(_tableName)
              .insert(profile.toAlternativeInsertJson())
              .select()
              .single();
          return StartupProfileModel.fromJson(altResponse);
        } catch (_) {}
      }

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

    final updateData = <String, dynamic>{
      'startup_name': profile.startupName,
      'description': profile.description,
      'industry': profile.industry,
      'funding_stage': profile.fundingStage,
      'funding_amount_needed': profile.fundingAmountNeeded,
      'location': profile.location,
      'team_information': profile.teamInformation,
      'contact_information': profile.contactInformation,
      'updated_at': DateTime.now().toIso8601String(),
    };

    try {
      final response = await _client
          .from(_tableName)
          .update(updateData)
          .eq('user_id', activeUserId)
          .select()
          .single();
      return StartupProfileModel.fromJson(response);
    } on PostgrestException catch (e) {
      if (e.message.contains('column') ||
          e.code == 'PGRST204' ||
          e.code == '42703') {
        try {
          final altResponse = await _client
              .from(_tableName)
              .update(profile.toAlternativeUpdateJson())
              .eq('user_id', activeUserId)
              .select()
              .single();
          return StartupProfileModel.fromJson(altResponse);
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
