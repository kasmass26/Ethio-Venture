import '../entities/document_entity.dart';
import '../entities/pitch_analysis_entity.dart';
import '../repositories/pitch_analysis_repository.dart';

/// Use case for triggering AI evaluation of a pitch deck document.
class AnalyzePitchDeckUseCase {
  const AnalyzePitchDeckUseCase(this._repository);

  final PitchAnalysisRepository _repository;

  Future<PitchAnalysisEntity> call({
    required DocumentEntity document,
    String? startupSector,
    String? startupStage,
  }) {
    return _repository.analyzePitchDeck(
      document: document,
      startupSector: startupSector,
      startupStage: startupStage,
    );
  }
}
