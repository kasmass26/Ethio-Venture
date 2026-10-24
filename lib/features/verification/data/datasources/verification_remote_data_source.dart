import 'package:supabase_flutter/supabase_flutter.dart'
    show PostgrestException, SupabaseClient;

import '../../../../core/error/exceptions.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../domain/entities/public_verification_badge_entity.dart';
import '../../domain/entities/verification_type.dart';
import '../models/verification_request_model.dart';

abstract interface class VerificationRemoteDataSource {
  Future<List<VerificationRequestModel>> getCurrentUserRequests();

  Future<VerificationRequestModel> startVerificationRequest(
    VerificationType type,
  );

  Future<List<PublicVerificationBadgeEntity>> getPublicApprovedBadges(
    String profileId,
  );
}

class VerificationRemoteDataSourceImpl implements VerificationRemoteDataSource {
  VerificationRemoteDataSourceImpl(this._client);

  final SupabaseClient _client;

  @override
  Future<List<VerificationRequestModel>> getCurrentUserRequests() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      throw const AuthException(message: 'User not authenticated');
    }

    try {
      final response = await _client
          .from(ApiEndpoints.verificationRequests)
          .select()
          .eq('user_id', userId)
          .order('submitted_at', ascending: false);

      return response
          .map<VerificationRequestModel>(
            (json) => VerificationRequestModel.fromJson(json),
          )
          .toList();
    } on PostgrestException catch (error) {
      throw ServerException(
        message: error.message,
        statusCode: int.tryParse(error.code ?? ''),
      );
    } on FormatException catch (error) {
      throw ServerException(
        message: 'Invalid verification request data: ${error.message}',
      );
    } catch (error) {
      throw ServerException(
        message: 'Failed to load verification requests: $error',
      );
    }
  }

  @override
  Future<VerificationRequestModel> startVerificationRequest(
    VerificationType type,
  ) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      throw const AuthException(message: 'User not authenticated');
    }

    final payload = <String, dynamic>{
      'user_id': userId,
      'verification_type': type.value,
      'status': 'pending',
    };

    try {
      final response = await _client
          .from(ApiEndpoints.verificationRequests)
          .insert(payload)
          .select()
          .single();

      return VerificationRequestModel.fromJson(response);
    } on PostgrestException catch (error) {
      throw ServerException(
        message: error.message,
        statusCode: int.tryParse(error.code ?? ''),
      );
    } on FormatException catch (error) {
      throw ServerException(
        message: 'Invalid verification request data: ${error.message}',
      );
    } catch (error) {
      throw ServerException(
        message: 'Failed to start verification request: $error',
      );
    }
  }

  @override
  Future<List<PublicVerificationBadgeEntity>> getPublicApprovedBadges(
    String profileId,
  ) async {
    throw UnsupportedError(
      'Public verification badges are not backed by the current '
      'verification_requests schema. Add a profile-to-user mapping and '
      'an authorized public badge query before implementing profileId-based '
      'badge lookup for $profileId.',
    );
  }
}
