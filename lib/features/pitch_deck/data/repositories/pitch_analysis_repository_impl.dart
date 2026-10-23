import '../../domain/entities/document_entity.dart';
import '../../domain/entities/pitch_analysis_entity.dart';
import '../../domain/repositories/pitch_analysis_repository.dart';
import '../datasources/pitch_analysis_remote_data_source.dart';

class PitchAnalysisRepositoryImpl implements PitchAnalysisRepository {
  const PitchAnalysisRepositoryImpl(this._remoteDataSource);

  final PitchAnalysisRemoteDataSource _remoteDataSource;

  @override
  Future<PitchAnalysisEntity> analyzePitchDeck({
    required DocumentEntity document,
    String? startupSector,
    String? startupStage,
  }) {
    return _remoteDataSource.analyzePitchDeck(
      document: document,
      startupSector: startupSector,
      startupStage: startupStage,
    );
  }

  @override
  Future<PitchAnalysisEntity?> getAnalysisForDocument({
    required String documentId,
  }) {
    return _remoteDataSource.getAnalysisForDocument(documentId: documentId);
  }

  @override
  Future<List<PitchAnalysisEntity>> getStartupAnalyses({
    required String startupId,
  }) {
    return _remoteDataSource.getStartupAnalyses(startupId: startupId);
  }
}
