import 'dart:async';
import 'dart:typed_data';

import 'package:ethioventure/core/error/exceptions.dart';
import 'package:ethioventure/features/verification/domain/entities/public_verification_badge_entity.dart';
import 'package:ethioventure/features/verification/domain/entities/verification_request_entity.dart';
import 'package:ethioventure/features/verification/domain/entities/verification_status.dart';
import 'package:ethioventure/features/verification/domain/entities/verification_type.dart';
import 'package:ethioventure/features/verification/domain/repositories/verification_repository.dart';
import 'package:ethioventure/features/verification/domain/usecases/get_current_user_verification_requests.dart';
import 'package:ethioventure/features/verification/domain/usecases/start_verification_request.dart';
import 'package:ethioventure/features/verification/presentation/cubit/verification_cubit.dart';
import 'package:ethioventure/features/verification/presentation/cubit/verification_state.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeVerificationRepository implements VerificationRepository {
  List<VerificationRequestEntity> requests = const [];
  VerificationRequestEntity? startedRequest;
  Object? error;
  Completer<VerificationRequestEntity>? startCompleter;
  int startCalls = 0;

  @override
  Future<List<VerificationRequestEntity>> getCurrentUserRequests() async {
    if (error != null) throw error!;
    return requests;
  }

  @override
  Future<VerificationRequestEntity> startVerificationRequest(
    VerificationType type,
  ) async {
    startCalls++;
    if (startCompleter != null) return startCompleter!.future;
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
    startCalls++;
    if (startCompleter != null) return startCompleter!.future;
    if (error != null) throw error!;
    return startedRequest!;
  }

  @override
  Future<List<PublicVerificationBadgeEntity>> getPublicApprovedBadges(
    String profileId,
  ) async {
    return const [];
  }
}

void main() {
  late FakeVerificationRepository repository;
  late VerificationCubit cubit;

  setUp(() {
    repository = FakeVerificationRepository();
    cubit = VerificationCubit(
      getCurrentUserRequests: GetCurrentUserVerificationRequests(repository),
      startVerificationRequest: StartVerificationRequest(repository),
    );
  });

  tearDown(() async {
    await cubit.close();
  });

  test('loadRequests emits loading then loaded', () async {
    repository.requests = const [
      VerificationRequestEntity(
        id: 'request-1',
        type: VerificationType.identity,
        status: VerificationStatus.pending,
      ),
    ];

    final expectation = expectLater(
      cubit.stream,
      emitsInOrder([isA<VerificationLoading>(), isA<VerificationLoaded>()]),
    );

    await cubit.loadRequests();
    await expectation;

    expect(cubit.state, isA<VerificationLoaded>());
    expect((cubit.state as VerificationLoaded).requests, hasLength(1));
  });

  test('loadRequests emits empty for no requests', () async {
    await cubit.loadRequests();

    expect(cubit.state, isA<VerificationEmpty>());
  });

  test('startRequest emits submitting then success', () async {
    repository.startedRequest = const VerificationRequestEntity(
      id: 'request-2',
      type: VerificationType.business,
      status: VerificationStatus.pending,
    );

    await cubit.startRequest(VerificationType.business);

    expect(cubit.state, isA<VerificationSuccess>());
    expect(repository.startCalls, 1);
  });

  test('loadRequests and startRequest emit repository errors', () async {
    repository.error = const AuthException(message: 'User not authenticated');

    await cubit.loadRequests();
    expect(cubit.state, isA<VerificationError>());
    expect(
      (cubit.state as VerificationError).message,
      'User not authenticated',
    );

    await cubit.startRequest(VerificationType.student);
    expect(cubit.state, isA<VerificationError>());
    expect(
      (cubit.state as VerificationError).message,
      'User not authenticated',
    );
  });

  test('duplicate submissions while submitting are prevented', () async {
    repository.startCompleter = Completer<VerificationRequestEntity>();

    final first = cubit.startRequest(VerificationType.identity);
    final duplicate = cubit.startRequest(VerificationType.business);

    await Future<void>.delayed(Duration.zero);
    expect(repository.startCalls, 1);
    expect(cubit.state, isA<VerificationSubmitting>());

    repository.startCompleter!.complete(
      const VerificationRequestEntity(
        id: 'request-3',
        type: VerificationType.identity,
        status: VerificationStatus.pending,
      ),
    );

    await first;
    await duplicate;
    expect(repository.startCalls, 1);
    expect(cubit.state, isA<VerificationSuccess>());
  });
}
