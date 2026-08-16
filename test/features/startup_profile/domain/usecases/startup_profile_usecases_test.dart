import 'package:dartz/dartz.dart';
import 'package:ethioventure/core/error/failures.dart';
import 'package:ethioventure/features/startup_profile/domain/entities/document_entity.dart';
import 'package:ethioventure/features/startup_profile/domain/entities/startup_profile_entity.dart';
import 'package:ethioventure/features/startup_profile/domain/repositories/startup_profile_repository.dart';
import 'package:ethioventure/features/startup_profile/domain/usecases/get_startup_profile_usecase.dart';
import 'package:ethioventure/features/startup_profile/domain/usecases/upload_document_usecase.dart';
import 'package:flutter_test/flutter_test.dart';

class MockStartupProfileRepository implements StartupProfileRepository {
  final StartupProfileEntity dummyProfile = StartupProfileEntity(
    id: 'st_01',
    companyName: 'Chapa Financial',
    tagline: 'Payment gateway',
    description: 'Description',
    industry: 'FinTech',
    fundingStage: 'Series A',
    targetFundingAmount: 1500000.0,
    raisedFundingAmount: 950000.0,
    companyValuation: 12000000.0,
    monthlyBurnRate: 45000.0,
    monthlyRevenue: 85000.0,
    location: 'Addis Ababa',
    websiteUrl: 'https://chapa.co',
    logoUrl: '',
    founderName: 'Nael Hailemariam',
    founderEmail: 'nael@chapa.co',
    founderRole: 'CEO',
    teamMembers: const ['Israel (CTO)'],
    documents: [
      DocumentEntity(
        id: 'doc_01',
        fileName: 'Pitch_Deck.pdf',
        fileType: 'PDF',
        category: 'Pitch Deck',
        fileSizeBytes: 2000000,
        downloadUrl: '',
        uploadedAt: DateTime(2025, 1, 1),
      ),
    ],
    updatedAt: DateTime(2025, 1, 1),
  );

  @override
  Future<Either<Failure, StartupProfileEntity>> createStartupProfile(
    StartupProfileEntity profile,
  ) async {
    return Right(profile);
  }

  @override
  Future<Either<Failure, StartupProfileEntity>> getStartupProfile(
    String id,
  ) async {
    return Right(dummyProfile);
  }

  @override
  Future<Either<Failure, StartupProfileEntity>> updateStartupProfile(
    StartupProfileEntity profile,
  ) async {
    return Right(profile);
  }

  @override
  Future<Either<Failure, DocumentEntity>> uploadDocument({
    required String startupId,
    required String category,
    required String fileName,
    required String fileType,
    required int fileSizeBytes,
  }) async {
    return Right(
      DocumentEntity(
        id: 'doc_new',
        fileName: fileName,
        fileType: fileType,
        category: category,
        fileSizeBytes: fileSizeBytes,
        downloadUrl: '',
        uploadedAt: DateTime.now(),
      ),
    );
  }

  @override
  Future<Either<Failure, void>> deleteDocument({
    required String startupId,
    required String documentId,
  }) async {
    return const Right(null);
  }
}

void main() {
  late GetStartupProfileUseCase getProfileUseCase;
  late UploadDocumentUseCase uploadDocumentUseCase;
  late MockStartupProfileRepository mockRepository;

  setUp(() {
    mockRepository = MockStartupProfileRepository();
    getProfileUseCase = GetStartupProfileUseCase(mockRepository);
    uploadDocumentUseCase = UploadDocumentUseCase(mockRepository);
  });

  test(
    'GetStartupProfileUseCase returns startup profile from repository',
    () async {
      final result = await getProfileUseCase('st_01');

      expect(result.isRight(), true);
      result.fold((l) => fail('Should not fail'), (r) {
        expect(r.companyName, 'Chapa Financial');
        expect(r.pitchDeck?.fileName, 'Pitch_Deck.pdf');
      });
    },
  );

  test(
    'UploadDocumentUseCase uploads pitch deck and returns DocumentEntity',
    () async {
      const params = UploadDocumentParams(
        startupId: 'st_01',
        category: 'Pitch Deck',
        fileName: 'New_Deck.pdf',
        fileType: 'PDF',
        fileSizeBytes: 3000000,
      );

      final result = await uploadDocumentUseCase(params);

      expect(result.isRight(), true);
      result.fold((l) => fail('Should not fail'), (r) {
        expect(r.fileName, 'New_Deck.pdf');
        expect(r.category, 'Pitch Deck');
      });
    },
  );
}
