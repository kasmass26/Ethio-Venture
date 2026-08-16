import 'package:dartz/dartz.dart';
import 'package:ethioventure/core/error/failures.dart';
import 'package:ethioventure/features/matching/domain/entities/investor_preference_entity.dart';
import 'package:ethioventure/features/matching/domain/entities/recommendation_entity.dart';
import 'package:ethioventure/features/matching/domain/entities/startup_entity.dart';
import 'package:ethioventure/features/matching/domain/repositories/matching_repository.dart';
import 'package:ethioventure/features/matching/domain/usecases/get_recommendations_usecase.dart';
import 'package:flutter_test/flutter_test.dart';

class MockMatchingRepositoryForRecs implements MatchingRepository {
  List<RecommendationEntity> dummyRecs = [
    RecommendationEntity(
      startup: StartupEntity(
        id: 'st_01',
        name: 'Chapa Financial',
        tagline: 'Modern payment gateway',
        description: 'Chapa description',
        industry: 'FinTech',
        fundingStage: 'Series A',
        targetAmount: 1500000.0,
        raisedAmount: 950000.0,
        location: 'Addis Ababa',
        logoUrl: '',
        pitchDeckUrl: '',
        founderName: 'Nael Hailemariam',
        tags: const ['FinTech'],
        rating: 4.9,
        createdAt: DateTime(2025, 1, 1),
      ),
      matchScore: 95.0,
      matchReasons: const ['Industry matches FinTech preference'],
      matchingTags: const ['FinTech'],
    ),
  ];

  @override
  Future<Either<Failure, List<StartupEntity>>> searchStartups(params) async {
    return const Right([]);
  }

  @override
  Future<Either<Failure, List<RecommendationEntity>>> getRecommendations(
    String userId,
    InvestorPreferenceEntity preference,
  ) async {
    return Right(dummyRecs);
  }
}

void main() {
  late GetRecommendationsUseCase usecase;
  late MockMatchingRepositoryForRecs mockRepository;

  setUp(() {
    mockRepository = MockMatchingRepositoryForRecs();
    usecase = GetRecommendationsUseCase(mockRepository);
  });

  test(
    'should return list of recommendation matches for given investor preference',
    () async {
      final params = GetRecommendationsParams(
        userId: 'user_1',
        preference: InvestorPreferenceEntity.defaultPreferences(),
      );

      final result = await usecase(params);

      expect(result.isRight(), true);
      result.fold((l) => fail('Should not fail'), (r) {
        expect(r.length, 1);
        expect(r.first.matchScore, 95.0);
        expect(r.first.startup.name, 'Chapa Financial');
      });
    },
  );
}
