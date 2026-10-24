import 'dart:typed_data';

import 'package:ethioventure/core/error/exceptions.dart';
import 'package:ethioventure/features/verification/data/datasources/verification_remote_data_source.dart';
import 'package:ethioventure/features/verification/data/models/verification_request_model.dart';
import 'package:ethioventure/features/verification/data/repositories/verification_repository_impl.dart';
import 'package:ethioventure/features/verification/domain/entities/public_verification_badge_entity.dart';
import 'package:ethioventure/features/verification/domain/entities/verification_request_entity.dart';
import 'package:ethioventure/features/verification/domain/entities/verification_status.dart';
import 'package:ethioventure/features/verification/domain/entities/verification_type.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeVerificationRemoteDataSource implements VerificationRemoteDataSource {
  List<VerificationRequestModel> requests = [];
  VerificationRequestModel? startedRequest;
  VerificationType? requestedType;
  UnsupportedError? badgeError;

  @override
  Future<List<VerificationRequestModel>> getCurrentUserRequests() async {
    return requests;
  }

  @override
  Future<List<PublicVerificationBadgeEntity>> getPublicApprovedBadges(
    String profileId,
  ) async {
    if (badgeError != null) throw badgeError!;
    return const [];
  }

  @override
  Future<VerificationRequestModel> startVerificationRequest(
    VerificationType type,
  ) async {
    requestedType = type;
    return startedRequest!;
  }

  @override
  Future<VerificationRequestModel> submitWithDocument({
    required VerificationType type,
    required Uint8List fileBytes,
    required String filename,
    required int fileSizeBytes,
  }) async {
    requestedType = type;
    return startedRequest!;
  }
}

void main() {
  late FakeVerificationRemoteDataSource remoteDataSource;
  late VerificationRepositoryImpl repository;

  setUp(() {
    remoteDataSource = FakeVerificationRemoteDataSource();
    repository = VerificationRepositoryImpl(remoteDataSource: remoteDataSource);
  });

  test('getCurrentUserRequests returns domain entities', () async {
    remoteDataSource.requests = [
      const VerificationRequestModel(
        id: 'request-1',
        type: VerificationType.identity,
        status: VerificationStatus.pending,
      ),
    ];

    final result = await repository.getCurrentUserRequests();

    expect(result, hasLength(1));
    expect(result.single, isA<VerificationRequestEntity>());
    expect(result.single.status, VerificationStatus.pending);
  });

  test('startVerificationRequest delegates the type', () async {
    remoteDataSource.startedRequest = const VerificationRequestModel(
      id: 'request-2',
      type: VerificationType.business,
      status: VerificationStatus.pending,
    );

    final result = await repository.startVerificationRequest(
      VerificationType.business,
    );

    expect(remoteDataSource.requestedType, VerificationType.business);
    expect(result, isA<VerificationRequestEntity>());
    expect(result.status, VerificationStatus.pending);
  });

  test('public badge operation propagates its unsupported error', () async {
    remoteDataSource.badgeError = UnsupportedError(
      'Public badges require backend support',
    );

    await expectLater(
      repository.getPublicApprovedBadges('profile-1'),
      throwsA(isA<UnsupportedError>()),
    );
  });

  test('data source exceptions pass through unchanged', () async {
    remoteDataSource.badgeError = null;

    final remoteDataSourceWithError = _ThrowingVerificationRemoteDataSource();
    final errorRepository = VerificationRepositoryImpl(
      remoteDataSource: remoteDataSourceWithError,
    );

    await expectLater(
      errorRepository.getCurrentUserRequests(),
      throwsA(isA<AuthException>()),
    );
  });
}

class _ThrowingVerificationRemoteDataSource
    implements VerificationRemoteDataSource {
  @override
  Future<List<VerificationRequestModel>> getCurrentUserRequests() async {
    throw const AuthException(message: 'User not authenticated');
  }

  @override
  Future<List<PublicVerificationBadgeEntity>> getPublicApprovedBadges(
    String profileId,
  ) async {
    return const [];
  }

  @override
  Future<VerificationRequestModel> startVerificationRequest(
    VerificationType type,
  ) async {
    throw const AuthException(message: 'User not authenticated');
  }

  @override
  Future<VerificationRequestModel> submitWithDocument({
    required VerificationType type,
    required Uint8List fileBytes,
    required String filename,
    required int fileSizeBytes,
  }) async {
    throw const AuthException(message: 'User not authenticated');
  }
}
