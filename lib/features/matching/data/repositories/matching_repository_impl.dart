import 'package:ethioventure/core/error/exceptions.dart';
import 'package:ethioventure/core/error/failures.dart';
import 'package:ethioventure/core/usecases/usecase.dart';
import 'package:ethioventure/features/investor_profile/data/models/investor_model.dart';
import 'package:ethioventure/features/investor_profile/domain/entities/investor_entity.dart';
import 'package:ethioventure/features/matching/data/datasources/matching_remote_data_source.dart';
import 'package:ethioventure/features/matching/domain/entities/recommendation_entity.dart';
import 'package:ethioventure/features/matching/domain/repositories/matching_repository.dart';
import 'package:ethioventure/features/matching/domain/usecases/calculate_compatibility_usecase.dart';
import 'package:ethioventure/features/startup_profile/domain/entities/startup_entity.dart';

class MatchingRepositoryImpl implements MatchingRepository {
  final MatchingRemoteDataSource remoteDataSource;
  final CalculateCompatibilityUseCase compatibilityEngine;

  MatchingRepositoryImpl({
    required this.remoteDataSource,
    required this.compatibilityEngine,
  });

  @override
  Future<Result<List<RecommendationEntity>>> getRecommendationsForInvestor(
      String investorId) async {
    try {
      final investor = await remoteDataSource.getInvestorProfile(investorId);
      final startups = await remoteDataSource.getAllStartups();

      // Calculate compatibility for each startup
      final recommendations = startups.map((startup) {
        return compatibilityEngine(
          investor: investor,
          startup: startup,
        );
      }).toList();

      // Sort recommendations descending by compatibility score (highest first)
      recommendations.sort((a, b) => b.compatibilityScore.compareTo(a.compatibilityScore));

      return Success(recommendations);
    } on ServerException catch (e) {
      return Error(ServerFailure(e.message));
    } catch (e) {
      return Error(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<RecommendationEntity>> calculateCompatibility({
    required InvestorEntity investor,
    required StartupEntity startup,
  }) async {
    try {
      final rec = compatibilityEngine(investor: investor, startup: startup);
      return Success(rec);
    } catch (e) {
      return Error(ValidationFailure(e.toString()));
    }
  }

  @override
  Future<Result<InvestorEntity>> getInvestorProfile(String investorId) async {
    try {
      final investor = await remoteDataSource.getInvestorProfile(investorId);
      return Success(investor);
    } on ServerException catch (e) {
      return Error(ServerFailure(e.message));
    } catch (e) {
      return Error(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<List<StartupEntity>>> getAllStartups() async {
    try {
      final startups = await remoteDataSource.getAllStartups();
      return Success(startups);
    } on ServerException catch (e) {
      return Error(ServerFailure(e.message));
    } catch (e) {
      return Error(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<InvestorEntity>> updateInvestorPreferences(
      InvestorEntity updatedInvestor) async {
    try {
      final model = updatedInvestor is InvestorModel
          ? updatedInvestor
          : InvestorModel.fromEntity(updatedInvestor);
      final saved = await remoteDataSource.updateInvestorPreferences(model);
      return Success(saved);
    } on ServerException catch (e) {
      return Error(ServerFailure(e.message));
    } catch (e) {
      return Error(ServerFailure(e.toString()));
    }
  }
}
