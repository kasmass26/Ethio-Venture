import 'package:equatable/equatable.dart';
import '../../domain/entities/investor_preference_entity.dart';
import '../../domain/entities/recommendation_entity.dart';

abstract class RecommendationsState extends Equatable {
  const RecommendationsState();

  @override
  List<Object?> get props => [];
}

class RecommendationsInitial extends RecommendationsState {
  const RecommendationsInitial();
}

class RecommendationsLoading extends RecommendationsState {
  const RecommendationsLoading();
}

class RecommendationsLoaded extends RecommendationsState {
  final List<RecommendationEntity> recommendations;
  final InvestorPreferenceEntity preferences;

  const RecommendationsLoaded({
    required this.recommendations,
    required this.preferences,
  });

  @override
  List<Object?> get props => [recommendations, preferences];
}

class RecommendationsError extends RecommendationsState {
  final String message;

  const RecommendationsError(this.message);

  @override
  List<Object?> get props => [message];
}
