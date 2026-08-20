import '../entities/investor_preferences_entity.dart';
import '../entities/match_result_entity.dart';
import '../entities/startup_profile_entity.dart';

/// Pure domain service that calculates a compatibility score (0–100) between
/// an investor's preferences and a startup's profile.
class MatchScoringService {
  static const int industryWeight = 35;
  static const int stageWeight = 30;
  static const int amountWeight = 20;
  static const int locationWeight = 15;

  const MatchScoringService();

  MatchResultEntity score({
    required StartupProfileEntity startup,
    required InvestorPreferencesEntity prefs,
  }) {
    final industryMatch = _checkIndustryMatch(
      startup.industry,
      prefs.preferredIndustries,
    );
    final stageMatch = _checkStageMatch(
      startup.fundingStage,
      prefs.preferredStages,
    );
    final amountCompatible = _checkAmountCompatible(
      startup.fundingAmountSought,
      prefs.ticketSizeMin,
      prefs.ticketSizeMax,
    );
    final locationMatch = _checkLocationMatch(
      startup.location,
      prefs.geographicFocus,
    );

    int totalScore = 0;
    if (industryMatch) totalScore += industryWeight;
    if (stageMatch) totalScore += stageWeight;
    if (amountCompatible) totalScore += amountWeight;
    if (locationMatch) totalScore += locationWeight;

    return MatchResultEntity(
      startup: startup,
      overallScore: totalScore,
      industryMatch: industryMatch,
      stageMatch: stageMatch,
      amountCompatible: amountCompatible,
      locationMatch: locationMatch,
    );
  }

  bool _checkIndustryMatch(String? industry, List<String> preferredIndustries) {
    if (preferredIndustries.isEmpty) return true;
    if (industry == null || industry.trim().isEmpty) return false;
    final normalized = industry.trim().toLowerCase();
    return preferredIndustries.any((p) => p.trim().toLowerCase() == normalized);
  }

  bool _checkStageMatch(String? stage, List<String> preferredStages) {
    if (preferredStages.isEmpty) return true;
    if (stage == null || stage.trim().isEmpty) return false;
    final normalized = stage.trim().toLowerCase();
    return preferredStages.any((s) => s.trim().toLowerCase() == normalized);
  }

  bool _checkAmountCompatible(
    double? sought,
    double? min,
    double? max,
  ) {
    if (min == null && max == null) return true;
    if (sought == null) return false;
    if (min != null && sought < min) return false;
    if (max != null && sought > max) return false;
    return true;
  }

  bool _checkLocationMatch(String? location, List<String> geographicFocus) {
    if (geographicFocus.isEmpty) return true;
    if (location == null || location.trim().isEmpty) return false;
    final normalized = location.trim().toLowerCase();
    return geographicFocus.any((g) => g.trim().toLowerCase() == normalized);
  }
}
