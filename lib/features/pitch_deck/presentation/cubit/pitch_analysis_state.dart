import 'package:equatable/equatable.dart';
import '../../domain/entities/pitch_analysis_entity.dart';

abstract class PitchAnalysisState extends Equatable {
  const PitchAnalysisState();

  @override
  List<Object?> get props => [];
}

class PitchAnalysisInitial extends PitchAnalysisState {
  const PitchAnalysisInitial();
}

class PitchAnalysisLoading extends PitchAnalysisState {
  const PitchAnalysisLoading({
    this.message = 'Evaluating pitch deck with AI...',
  });

  final String message;

  @override
  List<Object?> get props => [message];
}

class PitchAnalysisLoaded extends PitchAnalysisState {
  const PitchAnalysisLoaded(this.analysis);

  final PitchAnalysisEntity analysis;

  @override
  List<Object?> get props => [analysis];
}

class PitchAnalysisNotFound extends PitchAnalysisState {
  const PitchAnalysisNotFound();
}

class PitchAnalysisError extends PitchAnalysisState {
  const PitchAnalysisError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
