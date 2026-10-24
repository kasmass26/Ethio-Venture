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
    final industryPreferenceSet = prefs.preferredIndustries.any(
      (value) => value.trim().isNotEmpty,
    );
    final stagePreferenceSet = prefs.preferredStages.any(
      (value) => value.trim().isNotEmpty,
    );
    final amountPreferenceSet = _hasValidTicketRange(
      prefs.ticketSizeMin,
      prefs.ticketSizeMax,
    );
    final locationPreferenceSet = prefs.geographicFocus.any(
      (value) => value.trim().isNotEmpty,
    );
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
    if (industryPreferenceSet && industryMatch) totalScore += industryWeight;
    if (stagePreferenceSet && stageMatch) totalScore += stageWeight;
    if (amountPreferenceSet && amountCompatible) totalScore += amountWeight;
    if (locationPreferenceSet && locationMatch) totalScore += locationWeight;

    return MatchResultEntity(
      startup: startup,
      overallScore: totalScore,
      industryPreferenceSet: industryPreferenceSet,
      stagePreferenceSet: stagePreferenceSet,
      amountPreferenceSet: amountPreferenceSet,
      locationPreferenceSet: locationPreferenceSet,
      industryMatch: industryMatch,
      stageMatch: stageMatch,
      amountCompatible: amountCompatible,
      locationMatch: locationMatch,
    );
  }

  bool _checkIndustryMatch(String? industry, List<String> preferredIndustries) {
    if (preferredIndustries.isEmpty) return false;
    if (industry == null || industry.trim().isEmpty) return false;
    final normalized = industry.trim().toLowerCase();
    return preferredIndustries.any((p) => p.trim().toLowerCase() == normalized);
  }

  bool _checkStageMatch(String? stage, List<String> preferredStages) {
    if (preferredStages.isEmpty) return false;
    if (stage == null || stage.trim().isEmpty) return false;
    final normalized = stage.trim().toLowerCase();
    return preferredStages.any((s) => s.trim().toLowerCase() == normalized);
  }

  bool _checkAmountCompatible(double? sought, double? min, double? max) {
    if (!_hasValidTicketRange(min, max) ||
        sought == null ||
        !sought.isFinite ||
        sought < 0) {
      return false;
    }
    if (min != null && sought < min) return false;
    if (max != null && sought > max) return false;
    return true;
  }

  // Both amount fields are entered in USD by the startup and investor forms.
  bool _hasValidTicketRange(double? min, double? max) {
    if (min == null && max == null) return false;
    if (min != null && (!min.isFinite || min < 0)) return false;
    if (max != null && (!max.isFinite || max < 0)) return false;
    return min == null || max == null || max >= min;
  }

  bool _checkLocationMatch(String? location, List<String> geographicFocus) {
    if (geographicFocus.isEmpty) return false;
    if (location == null || location.trim().isEmpty) return false;
    final normalized = location.trim().toLowerCase();
    return geographicFocus.any((g) => g.trim().toLowerCase() == normalized);
  }

  /// Calculates compatibility score (0–100) and reasons for an investor
  /// relative to a founder's startup profile.
  (int score, List<String> matchReasons) scoreInvestorForStartup({
    required List<String> preferredIndustries,
    required List<String> preferredStages,
    required double? ticketSizeMin,
    required double? ticketSizeMax,
    required String? startupIndustry,
    required String? startupStage,
    required double? startupFundingNeeded,
    String? startupLocation,
    List<String> geographicFocus = const [],
  }) {
    final hasStartupDetails =
        (startupIndustry?.trim().isNotEmpty ?? false) ||
        (startupStage?.trim().isNotEmpty ?? false) ||
        startupFundingNeeded != null ||
        (startupLocation?.trim().isNotEmpty ?? false);
    if (!hasStartupDetails) {
      return (0, ['Complete your startup profile to calculate compatibility']);
    }

    final result = score(
      startup: StartupProfileEntity(
        id: '',
        userId: '',
        businessName: '',
        industry: startupIndustry,
        fundingStage: startupStage,
        fundingAmountSought: startupFundingNeeded,
        location: startupLocation,
      ),
      prefs: InvestorPreferencesEntity(
        id: '',
        userId: '',
        preferredIndustries: preferredIndustries,
        preferredStages: preferredStages,
        geographicFocus: geographicFocus,
        ticketSizeMin: ticketSizeMin,
        ticketSizeMax: ticketSizeMax,
      ),
    );

    if (result.matchReasons.isEmpty &&
        !result.industryPreferenceSet &&
        !result.stagePreferenceSet &&
        !result.amountPreferenceSet &&
        !result.locationPreferenceSet) {
      return (0, ['Investor has not provided investment preferences']);
    }

    return (result.overallScore, result.matchReasons);
  }
}
