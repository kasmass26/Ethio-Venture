import 'package:equatable/equatable.dart';
import '../../domain/entities/startup_entity.dart';
import '../../domain/entities/startup_filter_params.dart';

abstract class StartupSearchState extends Equatable {
  const StartupSearchState();

  @override
  List<Object?> get props => [];
}

class StartupSearchInitial extends StartupSearchState {
  const StartupSearchInitial();
}

class StartupSearchLoading extends StartupSearchState {
  const StartupSearchLoading();
}

class StartupSearchLoaded extends StartupSearchState {
  final List<StartupEntity> startups;
  final StartupFilterParams params;

  const StartupSearchLoaded({required this.startups, required this.params});

  @override
  List<Object?> get props => [startups, params];
}

class StartupSearchError extends StartupSearchState {
  final String message;

  const StartupSearchError(this.message);

  @override
  List<Object?> get props => [message];
}
