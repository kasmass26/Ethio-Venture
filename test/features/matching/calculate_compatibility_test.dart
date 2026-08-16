import 'package:flutter_test/flutter_test.dart';
import 'package:ethioventure/features/investor_profile/domain/entities/investor_entity.dart';
import 'package:ethioventure/features/matching/domain/entities/recommendation_entity.dart';
import 'package:ethioventure/features/matching/domain/usecases/calculate_compatibility_usecase.dart';
import 'package:ethioventure/features/startup_profile/domain/entities/startup_entity.dart';

void main() {
  late CalculateCompatibilityUseCase scoringEngine;

  setUp(() {
    scoringEngine = const CalculateCompatibilityUseCase();
  });

  group('CalculateCompatibilityUseCase - Match Scoring Tests', () {
    final investor = InvestorEntity(
      id: 'inv_test',
      userId: 'user_test',
      name: 'Alpha VC',
      email: 'alpha@vc.et',
      companyName: 'Alpha Ventures',
      bio: 'Investing in African Fintech & AgriTech',
      preferredIndustries: ['Fintech', 'AgriTech'],
      preferredFundingStages: ['Seed', 'Pre-Seed'],
      minInvestmentAmount: 50000,
      maxInvestmentAmount: 300000,
      preferredLocations: ['Addis Ababa'],
      createdAt: DateTime.now(),
    );

    test('should calculate 100% score for exact match across all 4 criteria', () {
      final perfectStartup = StartupEntity(
        id: 'stp_perfect',
        founderId: 'fnd_1',
        name: 'PayAddis',
        tagline: 'Payment infrastructure',
        description: 'Fintech checkout',
        industry: 'Fintech',
        fundingStage: 'Seed',
        targetFunding: 150000, // Within $50k-$300k
        location: 'Addis Ababa',
        createdAt: DateTime.now(),
      );

      final result = scoringEngine(investor: investor, startup: perfectStartup);

      expect(result.compatibilityScore, equals(100.0));
      expect(result.grade, equals(MatchGrade.excellent));
      expect(result.scoreBreakdown.industryScore, equals(35.0));
      expect(result.scoreBreakdown.stageScore, equals(25.0));
      expect(result.scoreBreakdown.amountScore, equals(25.0));
      expect(result.scoreBreakdown.locationScore, equals(15.0));
      expect(result.matchReasons.length, greaterThanOrEqualTo(4));
    });

    test('should calculate partial score for secondary industry and adjacent stage', () {
      final partialStartup = StartupEntity(
        id: 'stp_partial',
        founderId: 'fnd_2',
        name: 'FarmLog',
        tagline: 'Logistics for farm produce',
        description: 'Supply chain',
        industry: 'Logistics',
        secondaryIndustries: ['AgriTech'], // Secondary industry match (20 pts)
        fundingStage: 'Series A', // Adjacent to Seed (12 pts)
        targetFunding: 200000, // Within range (25 pts)
        location: 'Hawassa', // Different location (5 pts)
        createdAt: DateTime.now(),
      );

      final result = scoringEngine(investor: investor, startup: partialStartup);

      // Expected: 20 (ind) + 12 (stage) + 25 (amount) + 5 (loc) = 62.0%
      expect(result.compatibilityScore, equals(62.0));
      expect(result.grade, equals(MatchGrade.moderate));
      expect(result.scoreBreakdown.industryScore, equals(20.0));
      expect(result.scoreBreakdown.stageScore, equals(12.0));
      expect(result.scoreBreakdown.amountScore, equals(25.0));
      expect(result.scoreBreakdown.locationScore, equals(5.0));
    });

    test('should calculate low score for mismatching startup', () {
      final mismatchStartup = StartupEntity(
        id: 'stp_mismatch',
        founderId: 'fnd_3',
        name: 'UniEdu',
        tagline: 'EdTech platform',
        description: 'Learning',
        industry: 'EdTech', // 0 pts
        fundingStage: 'Growth', // 0 pts
        targetFunding: 2000000, // Far outside $300k limit -> 0 pts
        location: 'Dire Dawa', // 5 pts
        createdAt: DateTime.now(),
      );

      final result = scoringEngine(investor: investor, startup: mismatchStartup);

      expect(result.compatibilityScore, equals(5.0));
      expect(result.grade, equals(MatchGrade.fair));
    });

    test('should handle completely empty/null investor preferences safely without crashing', () {
      final blankInvestor = InvestorEntity(
        id: 'inv_blank',
        userId: 'user_blank',
        name: 'New Investor',
        email: 'new@investor.et',
        companyName: 'Angel',
        bio: 'Open to opportunities',
        preferredIndustries: [],
        preferredFundingStages: [],
        minInvestmentAmount: null,
        maxInvestmentAmount: null,
        preferredLocations: [],
        createdAt: DateTime.now(),
      );

      final startup = StartupEntity(
        id: 'stp_any',
        founderId: 'fnd_any',
        name: 'AnyStartup',
        tagline: 'Tagline',
        description: 'Description',
        industry: 'CleanTech',
        fundingStage: 'Seed',
        targetFunding: 100000,
        location: 'Bahir Dar',
        createdAt: DateTime.now(),
      );

      final result = scoringEngine(investor: blankInvestor, startup: startup);

      // Should default to neutral scores: 25 (ind) + 20 (stage) + 20 (amount) + 15 (loc) = 80.0
      expect(result.compatibilityScore, equals(80.0));
      expect(result.matchReasons, isNotEmpty);
    });
  });
}
