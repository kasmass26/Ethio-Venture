import 'package:ethioventure/core/constants/app_constants.dart';
import 'package:ethioventure/core/routing/app_router.dart';
import 'package:ethioventure/core/theme/app_theme.dart';
import 'package:ethioventure/features/verification/presentation/widgets/verification_entry_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget buildSubject() {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      onGenerateRoute: AppRouter.onGenerateRoute,
      home: const Scaffold(
        body: VerificationEntryCard(),
      ),
    );
  }

  testWidgets('verification entry is visible and clearly labeled',
      (tester) async {
    await tester.pumpWidget(buildSubject());

    expect(find.text('Profile Verification'), findsOneWidget);
    expect(
      find.text('Explore optional verification for your profile.'),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('profile-verification-entry')),
      findsOneWidget,
    );
  });

  testWidgets('tapping verification entry opens verification overview',
      (tester) async {
    await tester.pumpWidget(buildSubject());

    await tester.tap(
      find.byKey(const ValueKey('profile-verification-entry')),
    );
    await tester.pumpAndSettle();

    expect(find.text('Profile Verification'), findsOneWidget);
    expect(find.text('Build trust with verification'), findsOneWidget);
    expect(
      find.text('Choose a verification type'),
      findsOneWidget,
    );

    final route = AppRouter.onGenerateRoute(
      const RouteSettings(name: AppConstants.routeVerificationOverview),
    );
    expect(route.settings.name, AppConstants.routeVerificationOverview);
  });
}
