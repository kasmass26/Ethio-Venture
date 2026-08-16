import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/investor_preference_entity.dart';
import '../../domain/entities/recommendation_entity.dart';
import '../../domain/entities/startup_entity.dart';
import '../../domain/entities/startup_filter_params.dart';
import '../../domain/repositories/matching_repository.dart';
import '../datasources/matching_remote_data_source.dart';

class MatchingRepositoryImpl implements MatchingRepository {
  final MatchingRemoteDataSource remoteDataSource;

  MatchingRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<StartupEntity>>> searchStartups(
    StartupFilterParams params,
  ) async {
    try {
      final startups = await remoteDataSource.searchStartups(params);
      return Right(startups);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to search startups: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<RecommendationEntity>>> getRecommendations(
    String userId,
    InvestorPreferenceEntity preference,
  ) async {
    try {
      final recommendations = await remoteDataSource.getRecommendations(
        userId,
        preference,
      );
      return Right(recommendations);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(
        ServerFailure('Failed to get recommendations: ${e.toString()}'),
      );
    }
  }
}
