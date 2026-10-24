import 'package:ethioventure/core/theme/app_theme.dart';
import 'package:ethioventure/features/verification/domain/entities/verification_type.dart';
import 'package:ethioventure/features/verification/presentation/pages/verification_submission_page.dart';
import 'package:ethioventure/features/verification/presentation/widgets/verification_document_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
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
    expect(find.textContaining('backend team'), findsOneWidget);
    expect(find.textContaining('does not upload files'), findsOneWidget);
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

  testWidgets('validation displays document and acknowledgement messages', (
    tester,
  ) async {
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
    expect(find.text('Submit Verification (Unavailable)'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('verification-submit-placeholder')),
      findsOneWidget,
    );
  });

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
