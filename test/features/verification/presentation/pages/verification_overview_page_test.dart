import 'package:ethioventure/core/theme/app_theme.dart';
import 'package:ethioventure/features/verification/presentation/pages/verification_overview_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget buildSubject() {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      home: const VerificationOverviewPage(),
    );
  }

  testWidgets('renders verification overview and trust explanation',
      (tester) async {
    await tester.pumpWidget(buildSubject());

    expect(find.text('Profile Verification'), findsOneWidget);
    expect(find.text('Build trust with verification'), findsOneWidget);
    expect(find.text('Choose a verification type'), findsOneWidget);
  });

  testWidgets('displays all available verification types', (tester) async {
    await tester.pumpWidget(buildSubject());

    expect(find.text('Student Verification'), findsOneWidget);
    expect(find.text('Identity Verification'), findsOneWidget);
    expect(find.text('Business Verification'), findsOneWidget);
    expect(find.text('Investor Verification'), findsOneWidget);
  });

  testWidgets('selects a verification type in local state', (tester) async {
    await tester.pumpWidget(buildSubject());

    await tester.ensureVisible(find.text('Student Verification'));
    await tester.tap(find.text('Student Verification'));
    await tester.pump();

    expect(
      find.text(
        'Student Verification selected. This does not submit or verify anything.',
      ),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('selected-verification-type')), findsOneWidget);
  });

  testWidgets('changes the selected verification type', (tester) async {
    await tester.pumpWidget(buildSubject());

    await tester.ensureVisible(find.text('Business Verification'));
    await tester.tap(find.text('Business Verification'));
    await tester.pump();
    expect(
      find.text(
        'Business Verification selected. This does not submit or verify anything.',
      ),
      findsOneWidget,
    );

    await tester.ensureVisible(find.text('Investor Verification'));
    await tester.tap(find.text('Investor Verification'));
    await tester.pump();
    expect(
      find.text(
        'Investor Verification selected. This does not submit or verify anything.',
      ),
      findsOneWidget,
    );
    expect(
      find.text(
        'Business Verification selected. This does not submit or verify anything.',
      ),
      findsNothing,
    );
  });

  testWidgets('explains profile approval and selection are separate',
      (tester) async {
    await tester.pumpWidget(buildSubject());

    expect(
      find.textContaining('It is optional'),
      findsOneWidget,
    );
    expect(
      find.textContaining('does not submit a request, approve verification'),
      findsOneWidget,
    );
  });
}
