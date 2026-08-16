import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/investor_preference_entity.dart';
import '../entities/recommendation_entity.dart';
import '../repositories/matching_repository.dart';

class GetRecommendationsParams extends Equatable {
  final String userId;
  final InvestorPreferenceEntity preference;

  const GetRecommendationsParams({
    required this.userId,
    required this.preference,
  });

  @override
  List<Object?> get props => [userId, preference];
}

class GetRecommendationsUseCase
    implements UseCase<List<RecommendationEntity>, GetRecommendationsParams> {
  final MatchingRepository repository;

  GetRecommendationsUseCase(this.repository);

  @override
  Future<Either<Failure, List<RecommendationEntity>>> call(
    GetRecommendationsParams params,
  ) {
    return repository.getRecommendations(params.userId, params.preference);
  }
}
