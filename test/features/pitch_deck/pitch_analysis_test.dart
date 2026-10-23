import 'package:flutter_test/flutter_test.dart';
import 'package:ethioventure/features/pitch_deck/data/models/pitch_analysis_model.dart';
import 'package:ethioventure/features/pitch_deck/domain/entities/document_entity.dart';
import 'package:ethioventure/features/pitch_deck/domain/entities/pitch_analysis_entity.dart';
import 'package:ethioventure/features/pitch_deck/domain/repositories/pitch_analysis_repository.dart';
import 'package:ethioventure/features/pitch_deck/domain/usecases/analyze_pitch_deck_use_case.dart';
import 'package:ethioventure/features/pitch_deck/domain/usecases/get_pitch_analysis_use_case.dart';
import 'package:ethioventure/features/pitch_deck/presentation/cubit/pitch_analysis_cubit.dart';
import 'package:ethioventure/features/pitch_deck/presentation/cubit/pitch_analysis_state.dart';

class MockPitchAnalysisRepository implements PitchAnalysisRepository {
  MockPitchAnalysisRepository({this.returnAnalysis});

  final PitchAnalysisEntity? returnAnalysis;

  @override
  Future<PitchAnalysisEntity> analyzePitchDeck({
    required DocumentEntity document,
    String? startupSector,
    String? startupStage,
  }) async {
    if (returnAnalysis != null) return returnAnalysis!;
    return PitchAnalysisEntity(
      id: 'analysis_123',
      documentId: document.id,
      startupId: document.startupId,
      overallScore: 84,
      readinessTier: 'Investment Ready',
      executiveSummary: 'Strong market opportunity and clear unit economics.',
      categoryScores: const [
        PitchCategoryScore(
          name: 'Problem & Value Proposition',
          score: 88,
          feedback: 'Clear problem with documented market pain.',
        ),
      ],
      strengths: const ['Deep founder market expertise', 'Telebirr integration'],
      weaknesses: const ['Customer acquisition costs not fully proven'],
      recommendations: const [
        PitchRecommendation(
          category: 'Financials',
          suggestion: 'Clarify 3-year revenue milestones.',
          impactLevel: 'High',
          targetSlide: 'Slide 8',
        ),
      ],
      ethiopianMarketFit: 'Strong fit with local Ethiopian digital payment trends.',
      analyzedAt: DateTime.now(),
    );
  }

  @override
  Future<PitchAnalysisEntity?> getAnalysisForDocument({
    required String documentId,
  }) async {
    return returnAnalysis;
  }

  @override
  Future<List<PitchAnalysisEntity>> getStartupAnalyses({
    required String startupId,
  }) async {
    return returnAnalysis != null ? [returnAnalysis!] : [];
  }
}

void main() {
  group('PitchAnalysisModel JSON Serialization', () {
    test('should correctly parse Gemini / Supabase JSON payload', () {
      final jsonPayload = {
        'id': 'test_analysis_1',
        'document_id': 'doc_001',
        'startup_id': 'startup_001',
        'overall_score': 82,
        'readiness_tier': 'Promising with Gaps',
        'executive_summary': 'Impressive solution in Ethiopian logistics.',
        'category_scores': [
          {
            'name': 'Problem & Value Proposition',
            'score': 85,
            'feedback': 'Addresses acute last-mile logistics friction.',
          },
          {
            'name': 'Business Model & Monetization',
            'score': 78,
            'feedback': 'Good commission rate structure.',
          },
        ],
        'strengths': [
          'High operating leverage',
          'Early partnerships established',
        ],
        'weaknesses': [
          'Regulatory transport license requirements need clarity',
        ],
        'recommendations': [
          {
            'category': 'Financials',
            'suggestion': 'Detail driver acquisition cost breakdown',
            'impact_level': 'High',
            'target_slide': 'Slide 6',
          },
        ],
        'ethiopian_market_fit': 'High synergy with Ethiopian freight modernization.',
        'analyzed_at': '2026-10-23T10:00:00.000Z',
      };

      final model = PitchAnalysisModel.fromJson(jsonPayload);

      expect(model.id, 'test_analysis_1');
      expect(model.documentId, 'doc_001');
      expect(model.startupId, 'startup_001');
      expect(model.overallScore, 82);
      expect(model.readinessTier, 'Promising with Gaps');
      expect(model.categoryScores.length, 2);
      expect(model.categoryScores.first.name, 'Problem & Value Proposition');
      expect(model.categoryScores.first.score, 85);
      expect(model.strengths.length, 2);
      expect(model.weaknesses.length, 1);
      expect(model.recommendations.first.targetSlide, 'Slide 6');
      expect(model.ethiopianMarketFit, contains('Ethiopian'));
    });
  });

  group('PitchAnalysisCubit', () {
    late PitchAnalysisCubit cubit;
    late MockPitchAnalysisRepository mockRepo;
    const testDoc = DocumentEntity(
      id: 'doc_123',
      startupId: 'startup_abc',
      title: 'Investor Pitch 2026',
      fileUrl: 'https://example.com/pitch.pdf',
      fileName: 'pitch.pdf',
      fileType: 'pitch_deck',
      fileSizeBytes: 2048576,
    );

    setUp(() {
      mockRepo = MockPitchAnalysisRepository();
      cubit = PitchAnalysisCubit(
        analyzePitchDeckUseCase: AnalyzePitchDeckUseCase(mockRepo),
        getPitchAnalysisUseCase: GetPitchAnalysisUseCase(mockRepo),
      );
    });

    tearDown(() {
      cubit.close();
    });

    test('initial state should be PitchAnalysisInitial', () {
      expect(cubit.state, equals(const PitchAnalysisInitial()));
    });

    test('emits [PitchAnalysisLoading, PitchAnalysisLoaded] when analyzePitchDeck succeeds', () async {
      final expectedStates = [
        isA<PitchAnalysisLoading>(),
        isA<PitchAnalysisLoaded>().having(
          (s) => s.analysis.overallScore,
          'overallScore',
          84,
        ),
      ];

      expectLater(cubit.stream, emitsInOrder(expectedStates));

      await cubit.analyzePitchDeck(
        document: testDoc,
        startupSector: 'Logistics',
        startupStage: 'Seed',
      );
    });

    test('emits [PitchAnalysisLoading, PitchAnalysisNotFound] when no prior analysis exists', () async {
      final expectedStates = [
        isA<PitchAnalysisLoading>(),
        isA<PitchAnalysisNotFound>(),
      ];

      expectLater(cubit.stream, emitsInOrder(expectedStates));

      await cubit.fetchAnalysis(documentId: 'non_existent_doc');
    });
  });
}
