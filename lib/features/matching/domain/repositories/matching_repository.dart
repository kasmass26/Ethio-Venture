import '../entities/investor_preferences_entity.dart';
import '../entities/match_result_entity.dart';

/// Contract for all matching/recommendation data operations.
abstract class MatchingRepository {
  /// Returns the investment preferences for the currently authenticated
  /// investor. Throws if the user is not authenticated or has no preferences.
  Future<InvestorPreferencesEntity> getInvestorPreferences();

  /// Returns scored, sorted recommendations for the authenticated investor.
  /// Startups are fetched from Supabase, scored locally, and returned
  /// highest-score first.
  Future<List<MatchResultEntity>> getRecommendations();
}
