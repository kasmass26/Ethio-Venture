import 'dart:developer' as developer;
import 'package:ethioventure/core/error/exceptions.dart';
import 'package:ethioventure/features/investor_profile/data/models/investor_profile_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class InvestorProfileRemoteDataSource {
  Future<InvestorProfileModel?> getInvestorProfileByUserId(String userId);

  Future<InvestorProfileModel> createInvestorProfile(
    InvestorProfileModel profile,
  );

  Future<InvestorProfileModel> updateInvestorProfile(
    InvestorProfileModel profile,
  );
}

class InvestorProfileRemoteDataSourceImpl
    implements InvestorProfileRemoteDataSource {
  InvestorProfileRemoteDataSourceImpl(this._client);

  final SupabaseClient _client;

  static const _tableName = 'investor_profiles';

  @override
  Future<InvestorProfileModel?> getInvestorProfileByUserId(
    String userId,
  ) async {
    developer.log(
      'Fetching investor profile for user_id: $userId',
      name: 'InvestorProfileRemoteDataSource.getInvestorProfileByUserId',
    );
    try {
      final data = await _client
          .from(_tableName)
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      if (data == null) {
        developer.log(
          'No investor profile found for user_id: $userId',
          name: 'InvestorProfileRemoteDataSource.getInvestorProfileByUserId',
        );
        return null;
      }

      developer.log(
        'Fetched investor profile: $data',
        name: 'InvestorProfileRemoteDataSource.getInvestorProfileByUserId',
      );
      return InvestorProfileModel.fromJson(data);
    } on PostgrestException catch (e, st) {
      developer.log(
        'PostgrestException in getInvestorProfileByUserId: ${e.message} (code: ${e.code}, details: ${e.details}, hint: ${e.hint})',
        name: 'InvestorProfileRemoteDataSource.getInvestorProfileByUserId',
        error: e,
        stackTrace: st,
      );
      throw ServerException(message: e.message);
    } catch (e, st) {
      developer.log(
        'Unexpected exception in getInvestorProfileByUserId',
        name: 'InvestorProfileRemoteDataSource.getInvestorProfileByUserId',
        error: e,
        stackTrace: st,
      );
      rethrow;
    }
  }

  @override
  Future<InvestorProfileModel> createInvestorProfile(
    InvestorProfileModel profile,
  ) async {
    final payload = profile.toJson();
    if (payload['id'] == '') {
      payload.remove('id');
    }
    developer.log(
      'Creating investor profile in table "$_tableName" with payload: $payload',
      name: 'InvestorProfileRemoteDataSource.createInvestorProfile',
    );
    try {
      final data = await _client
          .from(_tableName)
          .insert(payload)
          .select()
          .single();

      developer.log(
        'Successfully created investor profile: $data',
        name: 'InvestorProfileRemoteDataSource.createInvestorProfile',
      );
      return InvestorProfileModel.fromJson(data);
    } on PostgrestException catch (e, st) {
      developer.log(
        'PostgrestException during createInvestorProfile: ${e.message} (code: ${e.code}, details: ${e.details}, hint: ${e.hint})',
        name: 'InvestorProfileRemoteDataSource.createInvestorProfile',
        error: e,
        stackTrace: st,
      );
      throw ServerException(message: e.message);
    } catch (e, st) {
      developer.log(
        'Unexpected exception during createInvestorProfile',
        name: 'InvestorProfileRemoteDataSource.createInvestorProfile',
        error: e,
        stackTrace: st,
      );
      rethrow;
    }
  }

  @override
  Future<InvestorProfileModel> updateInvestorProfile(
    InvestorProfileModel profile,
  ) async {
    final payload = profile.toJson();
    developer.log(
      'Updating investor profile id "${profile.id}" in table "$_tableName" with payload: $payload',
      name: 'InvestorProfileRemoteDataSource.updateInvestorProfile',
    );
    try {
      final data = await _client
          .from(_tableName)
          .update(payload)
          .eq('id', profile.id)
          .select()
          .single();

      developer.log(
        'Successfully updated investor profile: $data',
        name: 'InvestorProfileRemoteDataSource.updateInvestorProfile',
      );
      return InvestorProfileModel.fromJson(data);
    } on PostgrestException catch (e, st) {
      developer.log(
        'PostgrestException during updateInvestorProfile: ${e.message} (code: ${e.code}, details: ${e.details}, hint: ${e.hint})',
        name: 'InvestorProfileRemoteDataSource.updateInvestorProfile',
        error: e,
        stackTrace: st,
      );
      throw ServerException(message: e.message);
    } catch (e, st) {
      developer.log(
        'Unexpected exception during updateInvestorProfile',
        name: 'InvestorProfileRemoteDataSource.updateInvestorProfile',
        error: e,
        stackTrace: st,
      );
      rethrow;
    }
  }
}
