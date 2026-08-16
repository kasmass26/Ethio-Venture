import 'package:ethioventure/features/matching/domain/entities/match_score_breakdown.dart';
import 'package:ethioventure/features/startup_profile/domain/entities/startup_entity.dart';

enum MatchGrade {
  excellent, // >= 85%
  high,      // >= 70%
  moderate,  // >= 50%
  fair,      // < 50%
}

/// Represents a recommended startup paired with compatibility calculations for an investor.
class RecommendationEntity {
  final StartupEntity startup;
  final String investorId;
  final double compatibilityScore; // 0.0 to 100.0
  final MatchScoreBreakdown scoreBreakdown;
  final List<String> matchReasons;
  final bool isBookmarked;
  final DateTime calculatedAt;

  const RecommendationEntity({
    required this.startup,
    required this.investorId,
    required this.compatibilityScore,
    required this.scoreBreakdown,
    required this.matchReasons,
    this.isBookmarked = false,
    required this.calculatedAt,
  });

  MatchGrade get grade {
    if (compatibilityScore >= 85) return MatchGrade.excellent;
    if (compatibilityScore >= 70) return MatchGrade.high;
    if (compatibilityScore >= 50) return MatchGrade.moderate;
    return MatchGrade.fair;
  }

  String get gradeLabel {
    switch (grade) {
      case MatchGrade.excellent:
        return 'Excellent Match';
      case MatchGrade.high:
        return 'High Compatibility';
      case MatchGrade.moderate:
        return 'Moderate Match';
      case MatchGrade.fair:
        return 'Discovery Opportunity';
    }
  }

  RecommendationEntity copyWith({
    StartupEntity? startup,
    String? investorId,
    double? compatibilityScore,
    MatchScoreBreakdown? scoreBreakdown,
    List<String>? matchReasons,
    bool? isBookmarked,
    DateTime? calculatedAt,
  }) {
    return RecommendationEntity(
      startup: startup ?? this.startup,
      investorId: investorId ?? this.investorId,
      compatibilityScore: compatibilityScore ?? this.compatibilityScore,
      scoreBreakdown: scoreBreakdown ?? this.scoreBreakdown,
      matchReasons: matchReasons ?? this.matchReasons,
      isBookmarked: isBookmarked ?? this.isBookmarked,
      calculatedAt: calculatedAt ?? this.calculatedAt,
    );
  }
}
