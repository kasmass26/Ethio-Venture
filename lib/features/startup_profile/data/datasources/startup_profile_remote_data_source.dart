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

  @override
  Future<StartupProfileModel> createProfile(StartupProfileModel profile) async {
    final currentUserId = _client.auth.currentUser?.id ?? profile.userId;

    final primaryPayload = {
      'user_id': currentUserId,
      'startup_name': profile.startupName,
      'description': profile.description,
      'industry': profile.industry,
      'funding_stage': profile.fundingStage,
      'location': profile.location,
      'funding_amount_needed': profile.fundingAmountNeeded,
      'team_information': profile.teamInformation,
      'contact_information': profile.contactInformation,
      'updated_at': DateTime.now().toIso8601String(),
    };

    try {
      final response = await _client
          .from(_tableName)
          .upsert(primaryPayload, onConflict: 'user_id')
          .select()
          .single();
      return StartupProfileModel.fromJson(response);
    } catch (e) {
      // If table uses business_name / funding_amount_sought columns
      if (e is PostgrestException && (e.code == '42703' || e.message.contains('column'))) {
        try {
          final fallbackPayload = {
            'user_id': currentUserId,
            'business_name': profile.startupName,
            'description': profile.description,
            'industry': profile.industry,
            'funding_stage': profile.fundingStage,
            'location': profile.location,
            'funding_amount_sought': profile.fundingAmountNeeded,
            'updated_at': DateTime.now().toIso8601String(),
          };
          final response = await _client
              .from(_tableName)
              .upsert(fallbackPayload, onConflict: 'user_id')
              .select()
              .single();
          return StartupProfileModel.fromJson(response);
        } catch (fallbackError) {
          if (fallbackError is PostgrestException) {
            throw ServerException(
              message: fallbackError.message,
              statusCode: int.tryParse(fallbackError.code ?? ''),
            );
          }
          throw ServerException(
            message: 'Failed to create startup profile: $fallbackError',
          );
        }
      }

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
    final currentUserId = _client.auth.currentUser?.id ?? profile.userId;

    final primaryPayload = {
      'user_id': currentUserId,
      'startup_name': profile.startupName,
      'description': profile.description,
      'industry': profile.industry,
      'funding_stage': profile.fundingStage,
      'location': profile.location,
      'funding_amount_needed': profile.fundingAmountNeeded,
      'team_information': profile.teamInformation,
      'contact_information': profile.contactInformation,
      'updated_at': DateTime.now().toIso8601String(),
    };

    try {
      final response = await _client
          .from(_tableName)
          .upsert(primaryPayload, onConflict: 'user_id')
          .select()
          .single();
      return StartupProfileModel.fromJson(response);
    } catch (e) {
      if (e is PostgrestException && (e.code == '42703' || e.message.contains('column'))) {
        try {
          final fallbackPayload = {
            'user_id': currentUserId,
            'business_name': profile.startupName,
            'description': profile.description,
            'industry': profile.industry,
            'funding_stage': profile.fundingStage,
            'location': profile.location,
            'funding_amount_sought': profile.fundingAmountNeeded,
            'updated_at': DateTime.now().toIso8601String(),
          };
          final response = await _client
              .from(_tableName)
              .upsert(fallbackPayload, onConflict: 'user_id')
              .select()
              .single();
          return StartupProfileModel.fromJson(response);
        } catch (fallbackError) {
          if (fallbackError is PostgrestException) {
            throw ServerException(
              message: fallbackError.message,
              statusCode: int.tryParse(fallbackError.code ?? ''),
            );
          }
          throw ServerException(
            message: 'Failed to update startup profile: $fallbackError',
          );
        }
      }

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
