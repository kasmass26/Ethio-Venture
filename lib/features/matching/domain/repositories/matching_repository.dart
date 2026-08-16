import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/investor_preference_entity.dart';
import '../entities/recommendation_entity.dart';
import '../entities/startup_entity.dart';
import '../entities/startup_filter_params.dart';

abstract class MatchingRepository {
  /// Issue 5: Search and filter startups based on query and filter parameters
  Future<Either<Failure, List<StartupEntity>>> searchStartups(
    StartupFilterParams params,
  );

  /// Issue 6: Get personalized investment opportunity recommendations for an investor
  Future<Either<Failure, List<RecommendationEntity>>> getRecommendations(
    String userId,
    InvestorPreferenceEntity preference,
  );
}
