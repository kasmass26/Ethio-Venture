import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ethioventure/core/widgets/app_logo.dart';
import 'package:ethioventure/features/onboarding/presentation/pages/onboarding_page.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Widget buildTestWidget() {
    return const MaterialApp(
      home: OnboardingPage(),
    );
  }

  testWidgets('OnboardingPage renders top bar with AppLogo, title, and initial slide', (tester) async {
    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    // Verify AppLogo is rendered in top bar and hero visual
    expect(find.byType(AppLogo), findsWidgets);

    // Verify App Title
    expect(find.text('Ethio Venture'), findsOneWidget);

    // Verify Initial Slide content
    expect(find.text('Where Ambition Meets Capital'), findsOneWidget);
    expect(find.text('Next'), findsOneWidget);
    expect(find.text('Skip'), findsOneWidget);
    expect(find.text('Sign in'), findsOneWidget);
  });

  testWidgets('OnboardingPage navigates through slides to role selection', (tester) async {
    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    // Tap Next to slide 2 (Founders)
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(find.text('Build, Pitch & Raise'), findsOneWidget);

    // Tap Next to slide 3 (Investors & Role Selection)
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(find.text('Discover High-Impact Deals'), findsOneWidget);

    // Verify both Founder and Investor role cards exist
    expect(find.text("I'm a Founder"), findsOneWidget);
    expect(find.text('Join as Founder'), findsOneWidget);
    expect(find.text("I'm an Investor"), findsOneWidget);
    expect(find.text('Join as Investor'), findsOneWidget);
  });

  testWidgets('OnboardingPage Skip jumps directly to the last slide', (tester) async {
    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    // Tap Skip
    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle();

    // Verify Role selection is immediately displayed
    expect(find.text('Join as Founder'), findsOneWidget);
    expect(find.text('Join as Investor'), findsOneWidget);
  });
}
