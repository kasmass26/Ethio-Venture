import 'package:dartz/dartz.dart';
import 'package:ethioventure/core/error/failures.dart';
import 'package:ethioventure/core/utils/input_validators.dart';
import 'package:ethioventure/features/startup_profile/domain/entities/document_entity.dart';
import 'package:ethioventure/features/startup_profile/domain/entities/startup_profile_entity.dart';
import 'package:ethioventure/features/startup_profile/domain/repositories/startup_profile_repository.dart';
import 'package:ethioventure/features/startup_profile/domain/usecases/create_startup_profile_usecase.dart';
import 'package:flutter_test/flutter_test.dart';

class MockStartupProfileRepositoryForCreate
    implements StartupProfileRepository {
  late StartupProfileEntity savedProfile;

  @override
  Future<Either<Failure, StartupProfileEntity>> createStartupProfile(
    StartupProfileEntity profile,
  ) async {
    savedProfile = profile;
    return Right(profile);
  }

  @override
  Future<Either<Failure, StartupProfileEntity>> getStartupProfile(
    String id,
  ) async {
    return Right(savedProfile);
  }

  @override
  Future<Either<Failure, StartupProfileEntity>> updateStartupProfile(
    StartupProfileEntity profile,
  ) async {
    savedProfile = profile;
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
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, void>> deleteDocument({
    required String startupId,
    required String documentId,
  }) async {
    throw UnimplementedError();
  }
}

void main() {
  late CreateStartupProfileUseCase usecase;
  late MockStartupProfileRepositoryForCreate mockRepository;

  setUp(() {
    mockRepository = MockStartupProfileRepositoryForCreate();
    usecase = CreateStartupProfileUseCase(mockRepository);
  });

  test(
    'CreateStartupProfileUseCase persists profile and returns created entity',
    () async {
      final profile = StartupProfileEntity(
        id: 'st_new',
        userId: 'user_123',
        companyName: 'BeBlocky',
        tagline: 'Gamified EdTech',
        description: 'EdTech platform',
        industry: 'EdTech',
        fundingStage: 'Seed',
        targetFundingAmount: 500000.0,
        raisedFundingAmount: 0.0,
        companyValuation: 2500000.0,
        monthlyBurnRate: 10000.0,
        monthlyRevenue: 5000.0,
        location: 'Addis Ababa',
        websiteUrl: 'https://beblocky.com',
        logoUrl: '',
        founderName: 'Nathaniel',
        founderEmail: 'nathaniel@beblocky.com',
        founderRole: 'Founder',
        teamMembers: const [],
        documents: const [],
        updatedAt: DateTime.now(),
      );

      final result = await usecase(profile);

      expect(result.isRight(), true);
      result.fold((l) => fail('Should not fail'), (r) {
        expect(r.companyName, 'BeBlocky');
        expect(r.userId, 'user_123');
        expect(r.targetFundingAmount, 500000.0);
      });
    },
  );

  group('InputValidators Tests', () {
    test('email validator validates format correctly', () {
      expect(InputValidators.email('founder@example.com'), null);
      expect(InputValidators.email('founder@'), 'Enter a valid email address');
      expect(InputValidators.email(''), 'Email is required');
    });

    test('positiveNumber validator validates numbers and positive values', () {
      expect(InputValidators.positiveNumber('500000'), null);
      expect(
        InputValidators.positiveNumber('-100'),
        'Funding amount must be greater than zero',
      );
      expect(
        InputValidators.positiveNumber('abc'),
        'Enter a valid number for Funding amount',
      );
      expect(InputValidators.positiveNumber(''), 'Funding amount is required');
    });

    test('notEmpty validator rejects empty strings', () {
      expect(InputValidators.notEmpty('Chapa', field: 'Startup name'), null);
      expect(
        InputValidators.notEmpty('', field: 'Startup name'),
        'Startup name is required',
      );
    });
  });
}
