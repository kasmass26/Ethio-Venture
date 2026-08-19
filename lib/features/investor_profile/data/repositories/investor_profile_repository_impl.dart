import 'package:ethioventure/core/error/exceptions.dart';
import 'package:ethioventure/features/investor_profile/data/datasources/investor_profile_remote_data_source.dart';
import 'package:ethioventure/features/investor_profile/data/models/investor_profile_model.dart';
import 'package:ethioventure/features/investor_profile/domain/entities/investor_profile_entity.dart';
import 'package:ethioventure/features/investor_profile/domain/repositories/investor_profile_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthException;

class InvestorProfileRepositoryImpl implements InvestorProfileRepository {
  const InvestorProfileRepositoryImpl({
    required InvestorProfileRemoteDataSource remoteDataSource,
    required SupabaseClient supabaseClient,
  })  : _remoteDataSource = remoteDataSource,
        _supabaseClient = supabaseClient;

  final InvestorProfileRemoteDataSource _remoteDataSource;
  final SupabaseClient _supabaseClient;

  static const _tableName = 'investor_profiles';

  String _getCurrentUserId() {
    final user = _supabaseClient.auth.currentUser;
    if (user == null) {
      throw const AuthException(message: 'User is not authenticated');
    }
    return user.id;
  }

  InvestorProfileModel _toModel(
    InvestorProfileEntity entity, {
    String? userId,
  }) {
    if (entity is InvestorProfileModel &&
        (userId == null || entity.userId == userId)) {
      return entity;
    }
    return InvestorProfileModel(
      id: entity.id,
      userId: userId ?? entity.userId,
      investorType: entity.investorType,
      organizationName: entity.organizationName,
      bio: entity.bio,
      preferredIndustries: entity.preferredIndustries,
      preferredStages: entity.preferredStages,
      ticketSizeMin: entity.ticketSizeMin,
      ticketSizeMax: entity.ticketSizeMax,
      geographicFocus: entity.geographicFocus,
      createdAt: entity.createdAt,
    );
  }

  @override
  Future<InvestorProfileEntity?> getInvestorProfile() async {
    final userId = _getCurrentUserId();
    return _remoteDataSource.getInvestorProfileByUserId(userId);
  }

  @override
  Future<InvestorProfileEntity> createInvestorProfile(
    InvestorProfileEntity profile,
  ) async {
    final userId = _getCurrentUserId();
    final model = _toModel(profile, userId: userId);
    return _remoteDataSource.createInvestorProfile(model);
  }

  @override
  Future<InvestorProfileEntity> updateInvestorProfile(
    InvestorProfileEntity profile,
  ) async {
    final userId = _getCurrentUserId();
    final model = _toModel(profile, userId: userId);
    return _remoteDataSource.updateInvestorProfile(model);
  }

  @override
  Future<void> deleteInvestorProfile() async {
    final userId = _getCurrentUserId();
    try {
      await _supabaseClient
          .from(_tableName)
          .delete()
          .eq('user_id', userId);
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    }
  }
}
