import '../entities/document_entity.dart';
import '../entities/pitch_analysis_entity.dart';

/// Abstract domain repository interface for AI Pitch Deck Analysis.
abstract interface class PitchAnalysisRepository {
  /// Evaluates a startup pitch deck document using AI and saves the analysis.
  Future<PitchAnalysisEntity> analyzePitchDeck({
    required DocumentEntity document,
    String? startupSector,
    String? startupStage,
  });

  /// Retrieves the latest saved analysis for a specific document.
  Future<PitchAnalysisEntity?> getAnalysisForDocument({
    required String documentId,
  });

  /// Retrieves all pitch deck analyses for a specific startup.
  Future<List<PitchAnalysisEntity>> getStartupAnalyses({
    required String startupId,
  });
}
