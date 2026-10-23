import 'package:equatable/equatable.dart';

/// Represents a single criterion score in pitch analysis (e.g. Problem, Market, Business Model).
class PitchCategoryScore extends Equatable {
  const PitchCategoryScore({
    required this.name,
    required this.score,
    required this.feedback,
  });

  final String name;
  final int score; // 0 to 100
  final String feedback;

  @override
  List<Object?> get props => [name, score, feedback];
}

/// Represents an actionable recommendation to improve the pitch deck.
class PitchRecommendation extends Equatable {
  const PitchRecommendation({
    required this.category,
    required this.suggestion,
    required this.impactLevel, // 'High', 'Medium', 'Low'
    this.targetSlide,
  });

  final String category;
  final String suggestion;
  final String impactLevel;
  final String? targetSlide;

  @override
  List<Object?> get props => [category, suggestion, impactLevel, targetSlide];
}

/// Domain entity representing full AI evaluation of a pitch deck.
class PitchAnalysisEntity extends Equatable {
  const PitchAnalysisEntity({
    required this.id,
    required this.documentId,
    required this.startupId,
    required this.overallScore,
    required this.readinessTier,
    required this.executiveSummary,
    required this.categoryScores,
    required this.strengths,
    required this.weaknesses,
    required this.recommendations,
    this.ethiopianMarketFit,
    required this.analyzedAt,
  });

  final String id;
  final String documentId;
  final String startupId;
  final int overallScore; // 0 - 100
  final String readinessTier; // e.g., 'Investment Ready', 'Promising with Gaps', 'Early Stage / Needs Work'
  final String executiveSummary;
  final List<PitchCategoryScore> categoryScores;
  final List<String> strengths;
  final List<String> weaknesses;
  final List<PitchRecommendation> recommendations;
  final String? ethiopianMarketFit;
  final DateTime analyzedAt;

  @override
  List<Object?> get props => [
        id,
        documentId,
        startupId,
        overallScore,
        readinessTier,
        executiveSummary,
        categoryScores,
        strengths,
        weaknesses,
        recommendations,
        ethiopianMarketFit,
        analyzedAt,
      ];
}
