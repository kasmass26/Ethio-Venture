import 'package:ethioventure/core/usecases/usecase.dart';
import 'package:ethioventure/features/investor_profile/domain/entities/investor_entity.dart';
import 'package:ethioventure/features/matching/domain/entities/recommendation_entity.dart';
import 'package:ethioventure/features/startup_profile/domain/entities/startup_entity.dart';

abstract class MatchingRepository {
  /// Fetches and computes ranked startup recommendations for an investor.
  Future<Result<List<RecommendationEntity>>> getRecommendationsForInvestor(String investorId);

  /// Evaluates compatibility for a specific startup-investor pair.
  Future<Result<RecommendationEntity>> calculateCompatibility({
    required InvestorEntity investor,
    required StartupEntity startup,
  });

  /// Retrieves the active investor's profile and investment preferences.
  Future<Result<InvestorEntity>> getInvestorProfile(String investorId);

  /// Retrieves all active startups from the platform.
  Future<Result<List<StartupEntity>>> getAllStartups();

  /// Updates investor preferences (e.g. from Dashboard thesis manager).
  Future<Result<InvestorEntity>> updateInvestorPreferences(InvestorEntity updatedInvestor);
}
