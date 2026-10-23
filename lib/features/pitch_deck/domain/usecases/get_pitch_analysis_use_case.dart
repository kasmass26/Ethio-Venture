import '../entities/pitch_analysis_entity.dart';
import '../repositories/pitch_analysis_repository.dart';

/// Use case for fetching the latest analysis of a pitch deck document.
class GetPitchAnalysisUseCase {
  const GetPitchAnalysisUseCase(this._repository);

  final PitchAnalysisRepository _repository;

  Future<PitchAnalysisEntity?> call({required String documentId}) {
    return _repository.getAnalysisForDocument(documentId: documentId);
  }
}
