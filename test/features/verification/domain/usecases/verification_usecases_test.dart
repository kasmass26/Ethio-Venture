import 'dart:typed_data';

import 'package:ethioventure/core/error/exceptions.dart';
import 'package:ethioventure/features/verification/domain/entities/public_verification_badge_entity.dart';
import 'package:ethioventure/features/verification/domain/entities/verification_request_entity.dart';
import 'package:ethioventure/features/verification/domain/entities/verification_status.dart';
import 'package:ethioventure/features/verification/domain/entities/verification_type.dart';
import 'package:ethioventure/features/verification/domain/repositories/verification_repository.dart';
import 'package:ethioventure/features/verification/domain/usecases/get_current_user_verification_requests.dart';
import 'package:ethioventure/features/verification/domain/usecases/get_public_approved_badges.dart';
import 'package:ethioventure/features/verification/domain/usecases/start_verification_request.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeVerificationRepository implements VerificationRepository {
  List<VerificationRequestEntity> requests = const [];
  VerificationRequestEntity? startedRequest;
  VerificationType? requestedType;
  String? requestedProfileId;
  List<PublicVerificationBadgeEntity> badges = const [];
  Object? error;

  @override
  Future<List<VerificationRequestEntity>> getCurrentUserRequests() async {
    if (error != null) throw error!;
    return requests;
  }

  @override
  Future<List<PublicVerificationBadgeEntity>> getPublicApprovedBadges(
    String profileId,
  ) async {
    requestedProfileId = profileId;
    if (error != null) throw error!;
    return badges;
  }

  @override
  Future<VerificationRequestEntity> startVerificationRequest(
    VerificationType type,
  ) async {
    requestedType = type;
    if (error != null) throw error!;
    return startedRequest!;
  }

  @override
  Future<VerificationRequestEntity> submitWithDocument({
    required VerificationType type,
    required Uint8List fileBytes,
    required String filename,
    required int fileSizeBytes,
  }) async {
    requestedType = type;
    if (error != null) throw error!;
    return startedRequest!;
  }
}

void main() {
  late FakeVerificationRepository repository;

  setUp(() {
    repository = FakeVerificationRepository();
  });

  test(
    'GetCurrentUserVerificationRequests delegates and returns requests',
    () async {
      const request = VerificationRequestEntity(
        id: 'request-1',
        type: VerificationType.identity,
        status: VerificationStatus.pending,
      );
      repository.requests = const [request];

      final result = await GetCurrentUserVerificationRequests(
        repository,
      ).call();

      expect(result, same(repository.requests));
      expect(result.single.id, 'request-1');
    },
  );

  test('StartVerificationRequest delegates type and returns request', () async {
    const request = VerificationRequestEntity(
      id: 'request-2',
      type: VerificationType.business,
      status: VerificationStatus.pending,
    );
    repository.startedRequest = request;

    final result = await StartVerificationRequest(
      repository,
    ).call(VerificationType.business);

    expect(repository.requestedType, VerificationType.business);
    expect(result, same(request));
  });

  test(
    'GetPublicApprovedBadges delegates profile ID and returns badges',
    () async {
      repository.badges = const [];

      final result = await GetPublicApprovedBadges(
        repository,
      ).call('profile-1');

      expect(repository.requestedProfileId, 'profile-1');
      expect(result, same(repository.badges));
    },
  );

  test('use cases propagate repository errors unchanged', () async {
    const authError = AuthException(message: 'User not authenticated');
    repository.error = authError;

    await expectLater(
      GetCurrentUserVerificationRequests(repository).call(),
      throwsA(same(authError)),
    );
    await expectLater(
      StartVerificationRequest(repository).call(VerificationType.student),
      throwsA(same(authError)),
    );

    repository.error = UnsupportedError('Public badges unavailable');
    await expectLater(
      GetPublicApprovedBadges(repository).call('profile-1'),
      throwsA(isA<UnsupportedError>()),
    );
  });
}
