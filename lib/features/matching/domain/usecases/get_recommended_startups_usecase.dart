import 'package:ethioventure/core/usecases/usecase.dart';
import 'package:ethioventure/features/matching/domain/entities/recommendation_entity.dart';
import 'package:ethioventure/features/matching/domain/repositories/matching_repository.dart';

class GetRecommendationsParams {
  final String investorId;
  const GetRecommendationsParams({required this.investorId});
}

class GetRecommendedStartupsUseCase
    implements UseCase<List<RecommendationEntity>, GetRecommendationsParams> {
  final MatchingRepository repository;

  GetRecommendedStartupsUseCase(this.repository);

  @override
  Future<Result<List<RecommendationEntity>>> call(GetRecommendationsParams params) async {
    return await repository.getRecommendationsForInvestor(params.investorId);
  }
}
