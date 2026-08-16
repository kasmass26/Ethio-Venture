import 'package:flutter_test/flutter_test.dart';
import 'package:ethioventure/features/matching/data/datasources/matching_remote_data_source.dart';
import 'package:ethioventure/features/matching/data/repositories/matching_repository_impl.dart';
import 'package:ethioventure/features/matching/domain/usecases/calculate_compatibility_usecase.dart';

void main() {
  late MatchingRemoteDataSourceImpl remoteDataSource;
  late CalculateCompatibilityUseCase compatibilityEngine;
  late MatchingRepositoryImpl repository;

  setUp(() {
    remoteDataSource = MatchingRemoteDataSourceImpl();
    compatibilityEngine = const CalculateCompatibilityUseCase();
    repository = MatchingRepositoryImpl(
      remoteDataSource: remoteDataSource,
      compatibilityEngine: compatibilityEngine,
    );
  });

  group('MatchingRepositoryImpl - Ranking and Data Tests', () {
    test('should return recommendations sorted descending by compatibility score', () async {
      // inv_001 (Dawit Abebe: Fintech, AgriTech, Logistics | $50k-$300k | Addis Ababa)
      final result = await repository.getRecommendationsForInvestor('inv_001');

      expect(result.isSuccess, isTrue);
      final recommendations = result.dataOrNull!;
      expect(recommendations, isNotEmpty);

      // Verify strict descending sort order
      for (int i = 0; i < recommendations.length - 1; i++) {
        expect(
          recommendations[i].compatibilityScore,
          greaterThanOrEqualTo(recommendations[i + 1].compatibilityScore),
          reason: 'Item at index $i must have a higher or equal score than item at ${i + 1}',
        );
      }

      // Top recommendations for Dawit should be AgriTrust and EthioPay (Fintech/AgriTech in Addis)
      final topMatch = recommendations.first;
      expect(topMatch.compatibilityScore, greaterThanOrEqualTo(85.0));
      expect(['AgriTech', 'Fintech'], contains(topMatch.startup.industry));
    });

    test('should re-rank startups when different investor profile is evaluated', () async {
      // inv_002 (Sara Mengistu: CleanTech, AgriTech, HealthTech | $100k-$500k | Hawassa/Bahir Dar)
      final result = await repository.getRecommendationsForInvestor('inv_002');

      expect(result.isSuccess, isTrue);
      final recommendations = result.dataOrNull!;

      // Top match for Sara should be CleanTech or AgriTech (SunPower Horn / AgriTrust)
      final topMatch = recommendations.first;
      expect(['CleanTech', 'AgriTech'], contains(topMatch.startup.industry));
    });
  });
}
