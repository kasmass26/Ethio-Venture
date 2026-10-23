import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/document_entity.dart';
import '../../domain/usecases/analyze_pitch_deck_use_case.dart';
import '../../domain/usecases/get_pitch_analysis_use_case.dart';
import 'pitch_analysis_state.dart';

class PitchAnalysisCubit extends Cubit<PitchAnalysisState> {
  PitchAnalysisCubit({
    required AnalyzePitchDeckUseCase analyzePitchDeckUseCase,
    required GetPitchAnalysisUseCase getPitchAnalysisUseCase,
  })  : _analyzePitchDeckUseCase = analyzePitchDeckUseCase,
        _getPitchAnalysisUseCase = getPitchAnalysisUseCase,
        super(const PitchAnalysisInitial());

  final AnalyzePitchDeckUseCase _analyzePitchDeckUseCase;
  final GetPitchAnalysisUseCase _getPitchAnalysisUseCase;

  Future<void> fetchAnalysis({required String documentId}) async {
    emit(const PitchAnalysisLoading(message: 'Checking previous analysis...'));
    try {
      final analysis = await _getPitchAnalysisUseCase(documentId: documentId);
      if (analysis != null) {
        emit(PitchAnalysisLoaded(analysis));
      } else {
        emit(const PitchAnalysisNotFound());
      }
    } catch (e) {
      emit(PitchAnalysisError('Failed to load analysis: $e'));
    }
  }

  Future<void> analyzePitchDeck({
    required DocumentEntity document,
    String? startupSector,
    String? startupStage,
  }) async {
    emit(const PitchAnalysisLoading(
      message: 'Gemini AI is reviewing your pitch deck & slides...',
    ));
    try {
      final analysis = await _analyzePitchDeckUseCase(
        document: document,
        startupSector: startupSector,
        startupStage: startupStage,
      );
      emit(PitchAnalysisLoaded(analysis));
    } catch (e) {
      emit(PitchAnalysisError(e.toString().replaceAll('Exception: ', '')));
    }
  }
}
