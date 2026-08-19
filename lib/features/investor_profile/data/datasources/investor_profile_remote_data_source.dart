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
    try {
      final data = await _client
          .from(_tableName)
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      if (data == null) {
        return null;
      }

      return InvestorProfileModel.fromJson(data);
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    }
  }

  @override
  Future<InvestorProfileModel> createInvestorProfile(
    InvestorProfileModel profile,
  ) async {
    try {
      final data = await _client
          .from(_tableName)
          .insert(profile.toJson())
          .select()
          .single();

      return InvestorProfileModel.fromJson(data);
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    }
  }

  @override
  Future<InvestorProfileModel> updateInvestorProfile(
    InvestorProfileModel profile,
  ) async {
    try {
      final data = await _client
          .from(_tableName)
          .update(profile.toJson())
          .eq('id', profile.id)
          .select()
          .single();

      return InvestorProfileModel.fromJson(data);
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    }
  }
}
