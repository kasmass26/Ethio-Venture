import 'package:ethioventure/core/di/injection_container.dart';
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
import 'package:ethioventure/features/verification/presentation/widgets/verification_document_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'dart:typed_data';

// Minimal fake repository — no storage configured so canSubmitWithDocument=false.
class _FakeRepo implements VerificationRepository {
  @override
  Future<List<VerificationRequestEntity>> getCurrentUserRequests() async => [];
  @override
  Future<List<PublicVerificationBadgeEntity>> getPublicApprovedBadges(
    String profileId,
  ) async => [];
  @override
  Future<VerificationRequestEntity> startVerificationRequest(
    VerificationType type,
  ) async => VerificationRequestEntity(
    id: 'r1',
    type: type,
    status: VerificationStatus.pending,
  );
  @override
  Future<VerificationRequestEntity> submitWithDocument({
    required VerificationType type,
    required Uint8List fileBytes,
    required String filename,
    required int fileSizeBytes,
  }) async => VerificationRequestEntity(
    id: 'r1',
    type: type,
    status: VerificationStatus.pending,
  );
}

void main() {
  setUp(() {
    sl.pushNewScope();
    final repo = _FakeRepo();
    sl.registerLazySingleton<GetCurrentUserVerificationRequests>(
      () => GetCurrentUserVerificationRequests(repo),
    );
    sl.registerLazySingleton<StartVerificationRequest>(
      () => StartVerificationRequest(repo),
    );
    // No SubmitVerificationWithDocument registered → canSubmitWithDocument=false
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

  Widget buildSubject({
    VerificationType type = VerificationType.identity,
    VerificationDocumentSelector? selector,
  }) {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      home: VerificationSubmissionPage(type: type, documentSelector: selector),
    );
  }

  testWidgets('displays the correct verification type and backend notice', (
    tester,
  ) async {
    await tester.pumpWidget(buildSubject(type: VerificationType.business));
    await tester.pump();

    expect(find.text('Business Verification'), findsOneWidget);
    // Storage-not-configured notice is shown because no use case is registered.
    expect(
      find.textContaining('Secure document storage is not configured yet'),
      findsOneWidget,
    );
  });

  testWidgets('document picker displays a selected filename', (tester) async {
    await tester.pumpWidget(
      buildSubject(
        selector: () async => PlatformFile(name: 'certificate.pdf', size: 1024),
      ),
    );

    await tester.tap(
      find.byKey(const ValueKey('verification-document-select')),
    );
    await tester.pumpAndSettle();

    expect(find.text('certificate.pdf'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('verification-document-name')),
      findsOneWidget,
    );
  });

  testWidgets('removing a document returns it to the empty state', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildSubject(
        selector: () async => PlatformFile(name: 'identity.jpg', size: 2048),
      ),
    );

    await tester.ensureVisible(
      find.byKey(const ValueKey('verification-document-select')),
    );
    await tester.tap(
      find.byKey(const ValueKey('verification-document-select')),
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(
      find.byKey(const ValueKey('verification-document-remove')),
    );
    await tester.tap(
      find.byKey(const ValueKey('verification-document-remove')),
    );
    await tester.pump();

    expect(
      find.byKey(const ValueKey('verification-document-empty')),
      findsOneWidget,
    );
  });

  testWidgets('replace changes the selected filename', (tester) async {
    var selection = 0;
    await tester.pumpWidget(
      buildSubject(
        selector: () async {
          selection++;
          return PlatformFile(
            name: selection == 1 ? 'first.pdf' : 'second.png',
            size: 1024,
          );
        },
      ),
    );

    await tester.ensureVisible(
      find.byKey(const ValueKey('verification-document-select')),
    );
    await tester.tap(
      find.byKey(const ValueKey('verification-document-select')),
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(
      find.byKey(const ValueKey('verification-document-replace')),
    );
    await tester.tap(
      find.byKey(const ValueKey('verification-document-replace')),
    );
    await tester.pumpAndSettle();

    expect(find.text('second.png'), findsOneWidget);
    expect(find.text('first.pdf'), findsNothing);
  });

  testWidgets(
    'validation displays document and acknowledgement error messages',
    (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.ensureVisible(
        find.byKey(const ValueKey('verification-check-form')),
      );
      await tester.tap(find.byKey(const ValueKey('verification-check-form')));
      await tester.pump();

      expect(
        find.byKey(const ValueKey('verification-document-validation')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('verification-acknowledgement-validation')),
        findsOneWidget,
      );
      // The new submit button is always rendered (disabled when storage not ready).
      expect(
        find.byKey(const ValueKey('verification-submit-button')),
        findsOneWidget,
      );
    },
  );

  testWidgets('file selection cancellation is handled safely', (tester) async {
    await tester.pumpWidget(buildSubject(selector: () async => null));

    await tester.tap(
      find.byKey(const ValueKey('verification-document-select')),
    );
    await tester.pumpAndSettle();

    expect(
      find.text('No file was selected. Try selecting a document again.'),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('verification-document-empty')),
      findsOneWidget,
    );
  });

  testWidgets(
    'file selection errors and unsupported types are handled safely',
    (tester) async {
      await tester.pumpWidget(
        buildSubject(selector: () async => throw Exception('picker failure')),
      );

      await tester.tap(
        find.byKey(const ValueKey('verification-document-select')),
      );
      await tester.pumpAndSettle();

      expect(
        find.text('The document could not be selected. Please try again.'),
        findsOneWidget,
      );

      await tester.pumpWidget(
        buildSubject(
          selector: () async => PlatformFile(name: 'malware.exe', size: 100),
        ),
      );
      await tester.tap(
        find.byKey(const ValueKey('verification-document-select')),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('Unsupported file type'), findsOneWidget);
    },
  );

  testWidgets('back action returns to the overview', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: Builder(
          builder: (context) {
            return Scaffold(
              body: TextButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => VerificationSubmissionPage(
                        type: VerificationType.student,
                      ),
                    ),
                  );
                },
                child: const Text('Open Submission'),
              ),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('Open Submission'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(
      find.byKey(const ValueKey('verification-submission-back-button')),
    );
    await tester.tap(
      find.byKey(const ValueKey('verification-submission-back-button')),
    );
    await tester.pumpAndSettle();

    expect(find.text('Open Submission'), findsOneWidget);
  });
}
