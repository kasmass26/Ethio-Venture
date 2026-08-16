import '../../domain/entities/recommendation_entity.dart';
import 'startup_model.dart';

class RecommendationModel extends RecommendationEntity {
  const RecommendationModel({
    required super.startup,
    required super.matchScore,
    required super.matchReasons,
    required super.matchingTags,
  });

  factory RecommendationModel.fromJson(Map<String, dynamic> json) {
    return RecommendationModel(
      startup: StartupModel.fromJson(json['startup'] as Map<String, dynamic>),
      matchScore: (json['matchScore'] as num).toDouble(),
      matchReasons: (json['matchReasons'] as List<dynamic>)
          .map((e) => e.toString())
          .toList(),
      matchingTags: (json['matchingTags'] as List<dynamic>)
          .map((e) => e.toString())
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'startup': (startup as StartupModel).toJson(),
      'matchScore': matchScore,
      'matchReasons': matchReasons,
      'matchingTags': matchingTags,
    };
  }
}
