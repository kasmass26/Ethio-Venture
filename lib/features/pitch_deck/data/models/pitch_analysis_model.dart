import 'dart:convert';
import '../../domain/entities/pitch_analysis_entity.dart';

class PitchCategoryScoreModel extends PitchCategoryScore {
  const PitchCategoryScoreModel({
    required super.name,
    required super.score,
    required super.feedback,
  });

  factory PitchCategoryScoreModel.fromJson(Map<String, dynamic> json) {
    final rawScore = json['score'];
    int score = 70;
    if (rawScore is num) {
      score = rawScore.toInt();
    } else if (rawScore is String) {
      score = int.tryParse(rawScore) ?? 70;
    }

    return PitchCategoryScoreModel(
      name: (json['name'] ?? json['category'] ?? 'General').toString(),
      score: score.clamp(0, 100),
      feedback: (json['feedback'] ?? json['comments'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'score': score,
      'feedback': feedback,
    };
  }
}

class PitchRecommendationModel extends PitchRecommendation {
  const PitchRecommendationModel({
    required super.category,
    required super.suggestion,
    required super.impactLevel,
    super.targetSlide,
  });

  factory PitchRecommendationModel.fromJson(Map<String, dynamic> json) {
    return PitchRecommendationModel(
      category: (json['category'] ?? json['topic'] ?? 'General').toString(),
      suggestion: (json['suggestion'] ?? json['recommendation'] ?? '').toString(),
      impactLevel: (json['impact_level'] ?? json['impactLevel'] ?? json['impact'] ?? 'Medium').toString(),
      targetSlide: json['target_slide']?.toString() ?? json['targetSlide']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'category': category,
      'suggestion': suggestion,
      'impact_level': impactLevel,
      if (targetSlide != null) 'target_slide': targetSlide,
    };
  }
}

class PitchAnalysisModel extends PitchAnalysisEntity {
  const PitchAnalysisModel({
    required super.id,
    required super.documentId,
    required super.startupId,
    required super.overallScore,
    required super.readinessTier,
    required super.executiveSummary,
    required super.categoryScores,
    required super.strengths,
    required super.weaknesses,
    required super.recommendations,
    super.ethiopianMarketFit,
    required super.analyzedAt,
  });

  factory PitchAnalysisModel.fromJson(Map<String, dynamic> json) {
    // Parse category scores
    final rawCategoryScores = json['category_scores'] ?? json['categoryScores'];
    List<PitchCategoryScore> categoryScores = [];
    if (rawCategoryScores is List) {
      categoryScores = rawCategoryScores
          .map((item) => item is Map<String, dynamic>
              ? PitchCategoryScoreModel.fromJson(item)
              : PitchCategoryScoreModel.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList();
    } else if (rawCategoryScores is Map) {
      rawCategoryScores.forEach((key, val) {
        if (val is Map) {
          categoryScores.add(PitchCategoryScoreModel.fromJson({
            'name': key,
            ...Map<String, dynamic>.from(val),
          }));
        } else if (val is num) {
          categoryScores.add(PitchCategoryScoreModel(
            name: key.toString(),
            score: val.toInt().clamp(0, 100),
            feedback: '',
          ));
        }
      });
    }

    // Parse strengths
    final rawStrengths = json['strengths'];
    List<String> strengths = [];
    if (rawStrengths is List) {
      strengths = rawStrengths.map((e) => e.toString()).toList();
    } else if (rawStrengths is String && rawStrengths.isNotEmpty) {
      try {
        final decoded = jsonDecode(rawStrengths);
        if (decoded is List) strengths = decoded.map((e) => e.toString()).toList();
      } catch (_) {
        strengths = [rawStrengths];
      }
    }

    // Parse weaknesses
    final rawWeaknesses = json['weaknesses'];
    List<String> weaknesses = [];
    if (rawWeaknesses is List) {
      weaknesses = rawWeaknesses.map((e) => e.toString()).toList();
    } else if (rawWeaknesses is String && rawWeaknesses.isNotEmpty) {
      try {
        final decoded = jsonDecode(rawWeaknesses);
        if (decoded is List) weaknesses = decoded.map((e) => e.toString()).toList();
      } catch (_) {
        weaknesses = [rawWeaknesses];
      }
    }

    // Parse recommendations
    final rawRecommendations = json['recommendations'];
    List<PitchRecommendation> recommendations = [];
    if (rawRecommendations is List) {
      recommendations = rawRecommendations
          .map((item) => item is Map<String, dynamic>
              ? PitchRecommendationModel.fromJson(item)
              : (item is Map
                  ? PitchRecommendationModel.fromJson(Map<String, dynamic>.from(item))
                  : PitchRecommendationModel(
                      category: 'Action Item',
                      suggestion: item.toString(),
                      impactLevel: 'High',
                    )))
          .toList();
    }

    final rawScore = json['overall_score'] ?? json['overallScore'];
    int score = 70;
    if (rawScore is num) {
      score = rawScore.toInt();
    } else if (rawScore is String) {
      score = int.tryParse(rawScore) ?? 70;
    }

    return PitchAnalysisModel(
      id: (json['id'] ?? '').toString(),
      documentId: (json['document_id'] ?? json['documentId'] ?? '').toString(),
      startupId: (json['startup_id'] ?? json['startupId'] ?? '').toString(),
      overallScore: score.clamp(0, 100),
      readinessTier: (json['readiness_tier'] ?? json['readinessTier'] ?? 'Promising').toString(),
      executiveSummary: (json['executive_summary'] ?? json['executiveSummary'] ?? '').toString(),
      categoryScores: categoryScores,
      strengths: strengths,
      weaknesses: weaknesses,
      recommendations: recommendations,
      ethiopianMarketFit: json['ethiopian_market_fit']?.toString() ?? json['ethiopianMarketFit']?.toString(),
      analyzedAt: json['analyzed_at'] != null
          ? (DateTime.tryParse(json['analyzed_at'].toString()) ?? DateTime.now())
          : (json['created_at'] != null
              ? (DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now())
              : DateTime.now()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id.isNotEmpty) 'id': id,
      'document_id': documentId,
      'startup_id': startupId,
      'overall_score': overallScore,
      'readiness_tier': readinessTier,
      'executive_summary': executiveSummary,
      'category_scores': categoryScores
          .map((cs) => {
                'name': cs.name,
                'score': cs.score,
                'feedback': cs.feedback,
              })
          .toList(),
      'strengths': strengths,
      'weaknesses': weaknesses,
      'recommendations': recommendations
          .map((rec) => {
                'category': rec.category,
                'suggestion': rec.suggestion,
                'impact_level': rec.impactLevel,
                if (rec.targetSlide != null) 'target_slide': rec.targetSlide,
              })
          .toList(),
      if (ethiopianMarketFit != null) 'ethiopian_market_fit': ethiopianMarketFit,
      'analyzed_at': analyzedAt.toIso8601String(),
    };
  }
}
