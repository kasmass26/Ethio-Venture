import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:ethioventure/core/di/injection_container.dart';
import 'package:ethioventure/core/error/exceptions.dart';
import 'package:ethioventure/core/theme/app_theme.dart';
import 'package:ethioventure/features/verification/domain/entities/public_verification_badge_entity.dart';
import 'package:ethioventure/features/verification/domain/entities/verification_request_entity.dart';
import 'package:ethioventure/features/verification/domain/entities/verification_status.dart';
import 'package:ethioventure/features/verification/domain/entities/verification_type.dart';
import 'package:ethioventure/features/verification/domain/repositories/verification_repository.dart';
import 'package:ethioventure/features/verification/domain/usecases/get_current_user_verification_requests.dart';
import 'package:ethioventure/features/verification/domain/usecases/start_verification_request.dart';
import 'package:ethioventure/features/verification/presentation/cubit/verification_cubit.dart';
import 'package:ethioventure/features/verification/presentation/pages/verification_submission_page.dart';
import 'package:ethioventure/features/verification/presentation/widgets/verification_document_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeVerificationRepository implements VerificationRepository {
  VerificationRequestEntity? startedRequest;
  Object? error;

  @override
  Future<List<VerificationRequestEntity>> getCurrentUserRequests() async => [];

  @override
  Future<List<PublicVerificationBadgeEntity>> getPublicApprovedBadges(
    String profileId,
  ) async => [];

  @override
  Future<VerificationRequestEntity> startVerificationRequest(
    VerificationType type,
  ) async {
    if (error != null) throw error!;
    return startedRequest!;
  }
}

void main() {
  late _FakeVerificationRepository repository;

  setUp(() {
    sl.pushNewScope();
    repository = _FakeVerificationRepository();
    sl.registerLazySingleton<GetCurrentUserVerificationRequests>(
      () => GetCurrentUserVerificationRequests(repository),
    );
    sl.registerLazySingleton<StartVerificationRequest>(
      () => StartVerificationRequest(repository),
    );
    sl.registerFactory<VerificationCubit>(
      () => VerificationCubit(
        getCurrentUserRequests: sl<GetCurrentUserVerificationRequests>(),
        startVerificationRequest: sl<StartVerificationRequest>(),
      ),
    );
  });

  tearDown(() {
    sl.popScope();
  });

  Widget buildSubject({Future<PlatformFile?> Function()? documentPicker}) {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      home: VerificationSubmissionPage(
        type: VerificationType.identity,
        documentPicker: documentPicker,
      ),
    );
  }

  PlatformFile validPdf() => PlatformFile(
    name: 'identity-proof.pdf',
    size: 3,
    bytes: Uint8List.fromList([1, 2, 3]),
  );

  testWidgets('successful submission shows pending feedback', (tester) async {
    repository.startedRequest = const VerificationRequestEntity(
      id: 'request-1',
      type: VerificationType.identity,
      status: VerificationStatus.pending,
    );

    await tester.pumpWidget(
      buildSubject(documentPicker: () async => validPdf()),
    );
    expect(
      find.byKey(const ValueKey('verification-submit-button')),
      findsOneWidget,
    );

    await tester.tap(
      find.byKey(const ValueKey('verification-select-document')),
    );
    await tester.pumpAndSettle();
    expect(find.text('identity-proof.pdf'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('verification-submit-button')));
    await tester.pumpAndSettle();

    expect(find.text('Verification Submission'), findsNothing);
  });

  testWidgets('removing the selected file disables submission', (tester) async {
    await tester.pumpWidget(
      buildSubject(documentPicker: () async => validPdf()),
    );
    await tester.tap(
      find.byKey(const ValueKey('verification-select-document')),
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('verification-remove-document')),
      findsOneWidget,
    );
    await tester.tap(
      find.byKey(const ValueKey('verification-remove-document')),
    );
    await tester.pumpAndSettle();

    final submitButton = tester.widget<FilledButton>(
      find.byKey(const ValueKey('verification-submit-button')),
    );
    expect(submitButton.onPressed, isNull);
  });

  testWidgets('submission error remains visible as feedback', (tester) async {
    repository.error = const ServerException(
      message: 'Verification request failed',
    );

    await tester.pumpWidget(
      buildSubject(documentPicker: () async => validPdf()),
    );
    await tester.tap(
      find.byKey(const ValueKey('verification-select-document')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('verification-submit-button')));
    await tester.pumpAndSettle();

    expect(find.text('Verification request failed'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('verification-submit-button')),
      findsOneWidget,
    );
  });

  testWidgets('invalid file type shows an error', (tester) async {
    await tester.pumpWidget(
      buildSubject(
        documentPicker: () async => PlatformFile(
          name: 'proof.docx',
          size: 100,
          bytes: Uint8List.fromList([1, 2, 3]),
        ),
      ),
    );
    await tester.tap(
      find.byKey(const ValueKey('verification-select-document')),
    );
    await tester.pumpAndSettle();

    expect(find.text('Choose a JPG, PNG, or PDF file.'), findsOneWidget);
  });

  testWidgets('oversized file shows an error', (tester) async {
    await tester.pumpWidget(
      buildSubject(
        documentPicker: () async => PlatformFile(
          name: 'large.pdf',
          size: VerificationDocumentValidator.maxFileSizeBytes + 1,
          bytes: null,
        ),
      ),
    );
    await tester.tap(
      find.byKey(const ValueKey('verification-select-document')),
    );
    await tester.pumpAndSettle();

    expect(
      find.text('The selected file must be 10 MB or smaller.'),
      findsOneWidget,
    );
  });
}
