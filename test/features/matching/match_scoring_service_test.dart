import 'package:ethioventure/features/matching/domain/entities/investor_preferences_entity.dart';
import 'package:ethioventure/features/matching/domain/entities/startup_profile_entity.dart';
import 'package:ethioventure/features/matching/domain/services/match_scoring_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final scorer = MatchScoringService();

  // ── test helpers ──────────────────────────────────────────────────────────

  InvestorPreferencesEntity prefs({
    List<String> industries = const [],
    List<String> stages = const [],
    List<String> locations = const [],
    double? min,
    double? max,
  }) => InvestorPreferencesEntity(
    id: 'inv-1',
    userId: 'user-1',
    preferredIndustries: industries,
    preferredStages: stages,
    geographicFocus: locations,
    ticketSizeMin: min,
    ticketSizeMax: max,
  );

  StartupProfileEntity startup({
    String? industry,
    String? fundingStage,
    String? location,
    double? fundingAmountSought,
  }) => StartupProfileEntity(
    id: 'sp-1',
    userId: 'user-2',
    businessName: 'Test Startup',
    industry: industry,
    fundingStage: fundingStage,
    location: location,
    fundingAmountSought: fundingAmountSought,
  );

  // ── tests ─────────────────────────────────────────────────────────────────

  group('MatchScoringService', () {
    test('perfect match scores 100', () {
      final result = scorer.score(
        startup: startup(
          industry: 'fintech',
          fundingStage: 'seed',
          location: 'Addis Ababa',
          fundingAmountSought: 500000,
        ),
        prefs: prefs(
          industries: ['fintech'],
          stages: ['seed'],
          locations: ['Addis Ababa'],
          min: 100000,
          max: 1000000,
        ),
      );
      expect(result.overallScore, 100);
      expect(result.industryMatch, isTrue);
      expect(result.stageMatch, isTrue);
      expect(result.amountCompatible, isTrue);
      expect(result.locationMatch, isTrue);
    });

    test('zero match scores 0', () {
      final result = scorer.score(
        startup: startup(
          industry: 'agritech',
          fundingStage: 'series_b',
          location: 'Hawassa',
          fundingAmountSought: 50000,
        ),
        prefs: prefs(
          industries: ['fintech'],
          stages: ['seed'],
          locations: ['Addis Ababa'],
          min: 500000,
          max: 2000000,
        ),
      );
      expect(result.overallScore, 0);
    });

    test('industry-only match scores 35', () {
      final result = scorer.score(
        startup: startup(
          industry: 'fintech',
          fundingStage: 'series_b',
          location: 'Hawassa',
          fundingAmountSought: 50000,
        ),
        prefs: prefs(
          industries: ['fintech'],
          stages: ['seed'],
          locations: ['Addis Ababa'],
          min: 500000,
          max: 2000000,
        ),
      );
      expect(result.overallScore, 35);
      expect(result.industryMatch, isTrue);
    });

    test('stage-only match scores 30', () {
      final result = scorer.score(
        startup: startup(
          industry: 'agritech',
          fundingStage: 'seed',
          location: 'Hawassa',
          fundingAmountSought: 50000,
        ),
        prefs: prefs(
          industries: ['fintech'],
          stages: ['seed'],
          locations: ['Addis Ababa'],
          min: 500000,
          max: 2000000,
        ),
      );
      expect(result.overallScore, 30);
      expect(result.stageMatch, isTrue);
    });

    test('amount-only match scores 20', () {
      final result = scorer.score(
        startup: startup(
          industry: 'agritech',
          fundingStage: 'series_b',
          location: 'Hawassa',
          fundingAmountSought: 500000,
        ),
        prefs: prefs(
          industries: ['fintech'],
          stages: ['seed'],
          locations: ['Addis Ababa'],
          min: 100000,
          max: 1000000,
        ),
      );
      expect(result.overallScore, 20);
      expect(result.amountCompatible, isTrue);
    });

    test('location-only match scores 15', () {
      final result = scorer.score(
        startup: startup(
          industry: 'agritech',
          fundingStage: 'series_b',
          location: 'Addis Ababa',
          fundingAmountSought: 50000,
        ),
        prefs: prefs(
          industries: ['fintech'],
          stages: ['seed'],
          locations: ['Addis Ababa'],
          min: 500000,
          max: 2000000,
        ),
      );
      expect(result.overallScore, 15);
      expect(result.locationMatch, isTrue);
    });

    test('empty preferences do not claim any compatibility', () {
      final result = scorer.score(
        startup: startup(
          industry: 'healthtech',
          fundingStage: 'pre_seed',
          location: 'Dire Dawa',
          fundingAmountSought: 50000,
        ),
        prefs: prefs(),
      );
      expect(result.overallScore, 0);
      expect(result.industryMatch, isFalse);
      expect(result.industryPreferenceSet, isFalse);
      expect(result.matchReasons, isEmpty);
    });

    test('case-insensitive industry comparison', () {
      final result = scorer.score(
        startup: startup(industry: 'FinTech'),
        prefs: prefs(industries: ['fintech']),
      );
      expect(result.industryMatch, isTrue);
    });

    test('amount below min is not compatible', () {
      final result = scorer.score(
        startup: startup(fundingAmountSought: 10000),
        prefs: prefs(min: 100000),
      );
      expect(result.amountCompatible, isFalse);
    });

    test('amount above max is not compatible', () {
      final result = scorer.score(
        startup: startup(fundingAmountSought: 5000000),
        prefs: prefs(max: 1000000),
      );
      expect(result.amountCompatible, isFalse);
    });

    test('matchReasons lists only matched criteria', () {
      final result = scorer.score(
        startup: startup(
          industry: 'fintech',
          fundingStage: 'seed',
          location: 'Hawassa',
          fundingAmountSought: 50000,
        ),
        prefs: prefs(
          industries: ['fintech'],
          stages: ['seed'],
          locations: ['Addis Ababa'],
          min: 500000,
          max: 2000000,
        ),
      );
      expect(
        result.matchReasons,
        containsAll(['Industry match', 'Funding stage match']),
      );
      expect(
        result.matchReasons,
        isNot(contains('Investment amount compatible')),
      );
      expect(result.matchReasons, isNot(contains('Location match')));
    });

    test(
      'founder and investor recommendations use the same criteria weights',
      () {
        final (score, reasons) = scorer.scoreInvestorForStartup(
          preferredIndustries: ['fintech'],
          preferredStages: ['seed'],
          ticketSizeMin: 100000,
          ticketSizeMax: 1000000,
          startupIndustry: 'FinTech',
          startupStage: 'seed',
          startupFundingNeeded: 500000,
          startupLocation: 'Addis Ababa',
          geographicFocus: ['Addis Ababa'],
        );

        expect(score, 100);
        expect(
          reasons,
          containsAll([
            'Industry match',
            'Funding stage match',
            'Investment amount compatible',
            'Location match',
          ]),
        );
      },
    );

    test(
      'founder recommendation does not invent a score without startup data',
      () {
        final (score, reasons) = scorer.scoreInvestorForStartup(
          preferredIndustries: ['fintech'],
          preferredStages: ['seed'],
          ticketSizeMin: 100000,
          ticketSizeMax: 1000000,
          startupIndustry: null,
          startupStage: null,
          startupFundingNeeded: null,
        );

        expect(score, 0);
        expect(reasons, [
          'Complete your startup profile to calculate compatibility',
        ]);
      },
    );

    test('industry matching requires a normalized exact match', () {
      final (score, reasons) = scorer.scoreInvestorForStartup(
        preferredIndustries: ['fintech'],
        preferredStages: [],
        ticketSizeMin: null,
        ticketSizeMax: null,
        startupIndustry: 'tech',
        startupStage: null,
        startupFundingNeeded: null,
      );

      expect(score, 0);
      expect(reasons, isNot(contains('Industry match')));
    });

    test('blank preference values are treated as unset', () {
      final result = scorer.score(
        startup: startup(industry: 'fintech'),
        prefs: prefs(industries: ['  ']),
      );

      expect(result.industryPreferenceSet, isFalse);
      expect(result.overallScore, 0);
      expect(result.matchReasons, isEmpty);
    });

    test('only configured preferences contribute compatibility points', () {
      final result = scorer.score(
        startup: startup(
          industry: 'fintech',
          fundingStage: 'seed',
          location: 'Addis Ababa',
          fundingAmountSought: 500000,
        ),
        prefs: prefs(industries: ['fintech']),
      );

      expect(result.overallScore, 35);
      expect(result.industryPreferenceSet, isTrue);
      expect(result.stagePreferenceSet, isFalse);
      expect(result.stageMatch, isFalse);
      expect(result.matchReasons, ['Industry match']);
    });

    test('invalid amount values and reversed USD ranges never match', () {
      final invalidStartupAmount = scorer.score(
        startup: startup(fundingAmountSought: double.nan),
        prefs: prefs(min: 0, max: 100000),
      );
      final reversedRange = scorer.score(
        startup: startup(fundingAmountSought: 50000),
        prefs: prefs(min: 100000, max: 50000),
      );

      expect(invalidStartupAmount.amountCompatible, isFalse);
      expect(invalidStartupAmount.overallScore, 0);
      expect(reversedRange.amountPreferenceSet, isFalse);
      expect(reversedRange.amountCompatible, isFalse);
      expect(reversedRange.overallScore, 0);
    });

    test(
      'founder recommendation explains when investor has no preferences',
      () {
        final (score, reasons) = scorer.scoreInvestorForStartup(
          preferredIndustries: [],
          preferredStages: [],
          ticketSizeMin: null,
          ticketSizeMax: null,
          startupIndustry: 'fintech',
          startupStage: 'seed',
          startupFundingNeeded: 500000,
        );

        expect(score, 0);
        expect(reasons, ['Investor has not provided investment preferences']);
      },
    );
  });
}
