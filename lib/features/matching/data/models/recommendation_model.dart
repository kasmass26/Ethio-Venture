import 'package:ethioventure/features/matching/domain/entities/match_score_breakdown.dart';
import 'package:ethioventure/features/matching/domain/entities/recommendation_entity.dart';
import 'package:ethioventure/features/startup_profile/data/models/startup_model.dart';
import 'package:ethioventure/features/startup_profile/domain/entities/startup_entity.dart';

class RecommendationModel extends RecommendationEntity {
  const RecommendationModel({
    required super.startup,
    required super.investorId,
    required super.compatibilityScore,
    required super.scoreBreakdown,
    required super.matchReasons,
    super.isBookmarked,
    required super.calculatedAt,
  });

  factory RecommendationModel.fromJson(Map<String, dynamic> json) {
    return RecommendationModel(
      startup: json['startup'] != null
          ? StartupModel.fromJson(json['startup'] as Map<String, dynamic>)
          : StartupEntity(
              id: '',
              founderId: '',
              name: '',
              tagline: '',
              description: '',
              industry: '',
              fundingStage: '',
              targetFunding: 0,
              location: '',
              createdAt: DateTime.now(),
            ),
      investorId: json['investor_id'] as String? ?? '',
      compatibilityScore: (json['compatibility_score'] as num?)?.toDouble() ?? 0.0,
      scoreBreakdown: json['score_breakdown'] != null
          ? MatchScoreBreakdown.fromJson(json['score_breakdown'] as Map<String, dynamic>)
          : const MatchScoreBreakdown(
              industryScore: 0,
              stageScore: 0,
              amountScore: 0,
              locationScore: 0,
            ),
      matchReasons: (json['match_reasons'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      isBookmarked: json['is_bookmarked'] as bool? ?? false,
      calculatedAt: json['calculated_at'] != null
          ? DateTime.tryParse(json['calculated_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'startup': (startup is StartupModel)
          ? (startup as StartupModel).toJson()
          : StartupModel.fromEntity(startup).toJson(),
      'investor_id': investorId,
      'compatibility_score': compatibilityScore,
      'score_breakdown': scoreBreakdown.toJson(),
      'match_reasons': matchReasons,
      'is_bookmarked': isBookmarked,
      'calculated_at': calculatedAt.toIso8601String(),
    };
  }

  factory RecommendationModel.fromEntity(RecommendationEntity entity) {
    return RecommendationModel(
      startup: entity.startup,
      investorId: entity.investorId,
      compatibilityScore: entity.compatibilityScore,
      scoreBreakdown: entity.scoreBreakdown,
      matchReasons: entity.matchReasons,
      isBookmarked: entity.isBookmarked,
      calculatedAt: entity.calculatedAt,
    );
  }
}
