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
  }) {
    if (startupIndustry == null &&
        startupStage == null &&
        startupFundingNeeded == null) {
      final reasons = <String>[];
      if (preferredIndustries.isNotEmpty) {
        reasons.add(preferredIndustries.first);
      }
      if (preferredStages.isNotEmpty) {
        reasons.add(preferredStages.first);
      }
      if (reasons.isEmpty) {
        reasons.add('Verified Investor');
      }
      return (75, reasons);
    }

    int score = 0;
    final List<String> reasons = [];

    // 1. Industry match (+40)
    if (startupIndustry != null && startupIndustry.trim().isNotEmpty) {
      final normInd = startupIndustry.trim().toLowerCase();
      final hasMatch = preferredIndustries.any((ind) {
        final i = ind.trim().toLowerCase();
        return i == normInd || i.contains(normInd) || normInd.contains(i);
      });
      if (hasMatch) {
        score += 40;
        reasons.add('$startupIndustry fit');
      }
    }

    // 2. Stage match (+35)
    if (startupStage != null && startupStage.trim().isNotEmpty) {
      final normStg = startupStage.trim().toLowerCase();
      final hasMatch = preferredStages.any((stg) {
        final s = stg.trim().toLowerCase();
        return s == normStg || s.contains(normStg) || normStg.contains(s);
      });
      if (hasMatch) {
        score += 35;
        reasons.add('$startupStage stage');
      }
    }

    // 3. Ticket size match (+25)
    if (ticketSizeMin == null && ticketSizeMax == null) {
      score += 15;
    } else if (startupFundingNeeded != null) {
      final min = ticketSizeMin;
      final max = ticketSizeMax;
      final needed = startupFundingNeeded;
      if (min != null && max != null) {
        if (needed >= min && needed <= max) {
          score += 25;
          reasons.add('Ticket size match');
        } else if (needed >= min * 0.7 && needed <= max * 1.3) {
          score += 15;
          reasons.add('Flexible ticket');
        }
      } else if (min != null && needed >= min) {
        score += 20;
        reasons.add('Ticket size match');
      } else if (max != null && needed <= max) {
        score += 20;
        reasons.add('Ticket size match');
      }
    }

    if (reasons.isEmpty) {
      if (preferredIndustries.isNotEmpty) {
        reasons.add(preferredIndustries.first);
      } else {
        reasons.add('Active Investor');
      }
    }

    final finalScore = (score == 0 ? 55 : score).clamp(20, 99);
    return (finalScore, reasons);
  }
}
