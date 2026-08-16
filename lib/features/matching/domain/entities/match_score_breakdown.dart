/// Detailed breakdown of compatibility scores across 4 key criteria.
class MatchScoreBreakdown {
  final double industryScore;      // Max 35 points
  final double maxIndustryScore;   // 35.0
  final double stageScore;         // Max 25 points
  final double maxStageScore;      // 25.0
  final double amountScore;        // Max 25 points
  final double maxAmountScore;     // 25.0
  final double locationScore;      // Max 15 points
  final double maxLocationScore;   // 15.0

  const MatchScoreBreakdown({
    required this.industryScore,
    this.maxIndustryScore = 35.0,
    required this.stageScore,
    this.maxStageScore = 25.0,
    required this.amountScore,
    this.maxAmountScore = 25.0,
    required this.locationScore,
    this.maxLocationScore = 15.0,
  });

  double get totalScore => industryScore + stageScore + amountScore + locationScore;
  double get maxPossibleScore => maxIndustryScore + maxStageScore + maxAmountScore + maxLocationScore;
  
  double get industryPercentage => maxIndustryScore > 0 ? (industryScore / maxIndustryScore) * 100 : 0;
  double get stagePercentage => maxStageScore > 0 ? (stageScore / maxStageScore) * 100 : 0;
  double get amountPercentage => maxAmountScore > 0 ? (amountScore / maxAmountScore) * 100 : 0;
  double get locationPercentage => maxLocationScore > 0 ? (locationScore / maxLocationScore) * 100 : 0;

  Map<String, dynamic> toJson() {
    return {
      'industry_score': industryScore,
      'stage_score': stageScore,
      'amount_score': amountScore,
      'location_score': locationScore,
      'total_score': totalScore,
    };
  }

  factory MatchScoreBreakdown.fromJson(Map<String, dynamic> json) {
    return MatchScoreBreakdown(
      industryScore: (json['industry_score'] as num?)?.toDouble() ?? 0.0,
      stageScore: (json['stage_score'] as num?)?.toDouble() ?? 0.0,
      amountScore: (json['amount_score'] as num?)?.toDouble() ?? 0.0,
      locationScore: (json['location_score'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
