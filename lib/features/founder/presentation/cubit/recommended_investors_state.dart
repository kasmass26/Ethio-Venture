import 'package:equatable/equatable.dart';
import 'package:ethioventure/features/investor_profile/domain/entities/investor_discovery_entity.dart';

abstract class RecommendedInvestorsState extends Equatable {
  const RecommendedInvestorsState();

  @override
  List<Object?> get props => [];
}

class RecommendedInvestorsInitial extends RecommendedInvestorsState {
  const RecommendedInvestorsInitial();
}

class RecommendedInvestorsLoading extends RecommendedInvestorsState {
  const RecommendedInvestorsLoading();
}

class RecommendedInvestorsLoaded extends RecommendedInvestorsState {
  const RecommendedInvestorsLoaded(this.investors);

  final List<InvestorDiscoveryEntity> investors;

  @override
  List<Object?> get props => [investors];
}

class RecommendedInvestorsEmpty extends RecommendedInvestorsState {
  const RecommendedInvestorsEmpty();
}

class RecommendedInvestorsError extends RecommendedInvestorsState {
  const RecommendedInvestorsError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
