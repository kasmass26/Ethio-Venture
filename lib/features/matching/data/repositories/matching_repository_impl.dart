import '../../domain/entities/investor_preferences_entity.dart';
import '../../domain/entities/match_result_entity.dart';
import '../../domain/repositories/matching_repository.dart';
import '../../domain/services/match_scoring_service.dart';
import '../datasources/matching_remote_data_source.dart';

class MatchingRepositoryImpl implements MatchingRepository {
  final MatchingRemoteDataSource _remote;
  final MatchScoringService _scorer;

  MatchingRepositoryImpl({
    required MatchingRemoteDataSource remoteDataSource,
    MatchScoringService? scoringService,
  })  : _remote = remoteDataSource,
        _scorer = scoringService ?? MatchScoringService();

  @override
  Future<InvestorPreferencesEntity> getInvestorPreferences() =>
      _remote.getInvestorPreferences();

  @override
  Future<List<MatchResultEntity>> getRecommendations() async {
    // 1. Fetch investor preferences from investor_profiles (real Supabase data).
    final prefs = await _remote.getInvestorPreferences();

    // 2. Fetch all startup profiles from Supabase.
    final startups = await _remote.getStartupProfiles();

    // 3. Score each startup against the investor's preferences.
    final results = startups
        .map((startup) => _scorer.score(startup: startup, prefs: prefs))
        .toList();

    // 4. Sort highest score first; break ties alphabetically by business name.
    results.sort((a, b) {
      final cmp = b.overallScore.compareTo(a.overallScore);
      if (cmp != 0) return cmp;
      return a.startup.businessName.compareTo(b.startup.businessName);
    });

    return results;
  }
}
