import 'package:ethioventure/core/theme/app_theme.dart';
import 'package:ethioventure/features/verification/domain/entities/verification_status.dart';
import 'package:ethioventure/features/verification/presentation/widgets/verification_status_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget buildSubject(VerificationStatus? status) {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      home: Scaffold(
        body: VerificationStatusWidget(status: status),
      ),
    );
  }

  const cases = <VerificationStatus, List<String>>{
    VerificationStatus.notSubmitted: [
      'Not submitted',
      'You have not submitted this verification type yet.',
    ],
    VerificationStatus.pending: [
      'Pending',
      'Your verification request is waiting for review.',
    ],
    VerificationStatus.approved: [
      'Approved',
      'Your verification has been approved by an authoritative review.',
    ],
    VerificationStatus.rejected: [
      'Rejected',
      'Your verification request was not approved.',
    ],
    VerificationStatus.resubmissionRequired: [
      'Resubmission required',
      'Review the feedback and submit the verification again when ready.',
    ],
    VerificationStatus.additionalInfoRequired: [
      'Additional information required',
      'More information is needed before the verification can be reviewed.',
    ],
  };

  for (final entry in cases.entries) {
    testWidgets('presents ${entry.key.value} title and explanation',
        (tester) async {
      await tester.pumpWidget(buildSubject(entry.key));

      expect(find.text(entry.value.first), findsOneWidget);
      expect(find.text(entry.value.last), findsOneWidget);
      expect(
        find.byKey(ValueKey('verification-status-${entry.key.value}')),
        findsOneWidget,
      );
    });
  }

  testWidgets('shows the verified badge only for approved status',
      (tester) async {
    await tester.pumpWidget(buildSubject(VerificationStatus.approved));
    expect(
      find.byKey(const ValueKey('authoritative-verification-badge')),
      findsOneWidget,
    );
    expect(find.text('Verified'), findsOneWidget);

    for (final status in VerificationStatus.values
        .where((status) => status != VerificationStatus.approved)) {
      await tester.pumpWidget(buildSubject(status));
      expect(
        find.byKey(const ValueKey('authoritative-verification-badge')),
        findsNothing,
        reason: status.value,
      );
      expect(find.text('Verified'), findsNothing, reason: status.value);
    }
  });

  testWidgets('treats null and unknown input safely as not submitted',
      (tester) async {
    await tester.pumpWidget(buildSubject(null));

    expect(find.text('Not submitted'), findsOneWidget);
    expect(
      find.byKey(const ValueKey(
        'verification-status-not_submitted',
      )),
      findsOneWidget,
    );
    expect(find.text('Verified'), findsNothing);

    final unknown = VerificationStatus.fromString('verified');
    await tester.pumpWidget(buildSubject(unknown));

    expect(find.text('Not submitted'), findsOneWidget);
    expect(find.text('Verified'), findsNothing);
  });
}
