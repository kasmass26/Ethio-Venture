import 'package:dartz/dartz.dart';
import 'package:ethioventure/core/error/failures.dart';
import 'package:ethioventure/features/matching/domain/entities/investor_preference_entity.dart';
import 'package:ethioventure/features/matching/domain/entities/recommendation_entity.dart';
import 'package:ethioventure/features/matching/domain/entities/startup_entity.dart';
import 'package:ethioventure/features/matching/domain/entities/startup_filter_params.dart';
import 'package:ethioventure/features/matching/domain/repositories/matching_repository.dart';
import 'package:ethioventure/features/matching/domain/usecases/search_startups_usecase.dart';
import 'package:flutter_test/flutter_test.dart';

class MockMatchingRepository implements MatchingRepository {
  List<StartupEntity> dummyStartups = [
    StartupEntity(
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
  ];

  @override
  Future<Either<Failure, List<StartupEntity>>> searchStartups(
    StartupFilterParams params,
  ) async {
    return Right(dummyStartups);
  }

  @override
  Future<Either<Failure, List<RecommendationEntity>>> getRecommendations(
    String userId,
    InvestorPreferenceEntity preference,
  ) async {
    return const Right([]);
  }
}

void main() {
  late SearchStartupsUseCase usecase;
  late MockMatchingRepository mockRepository;

  setUp(() {
    mockRepository = MockMatchingRepository();
    usecase = SearchStartupsUseCase(mockRepository);
  });

  test('should return list of startups from repository on successful search', () async {
    const params = StartupFilterParams(query: 'Chapa', industry: 'FinTech');

    final result = await usecase(params);

    expect(result.isRight(), true);
    result.fold(
      (l) => fail('Should not fail'),
      (r) {
        expect(r.length, 1);
        expect(r.first.name, 'Chapa Financial');
        expect(r.first.industry, 'FinTech');
      },
    );
  });
}
