import 'package:ethioventure/core/constants/app_constants.dart';
import 'package:ethioventure/core/di/injection_container.dart';
import 'package:ethioventure/core/routing/app_router.dart';
import 'package:ethioventure/core/theme/app_theme.dart';
import 'package:ethioventure/features/verification/domain/entities/public_verification_badge_entity.dart';
import 'package:ethioventure/features/verification/domain/entities/verification_request_entity.dart';
import 'package:ethioventure/features/verification/domain/entities/verification_status.dart';
import 'package:ethioventure/features/verification/domain/entities/verification_type.dart';
import 'package:ethioventure/features/verification/domain/repositories/verification_repository.dart';
import 'package:ethioventure/features/verification/domain/usecases/get_current_user_verification_requests.dart';
import 'package:ethioventure/features/verification/domain/usecases/start_verification_request.dart';
import 'package:ethioventure/features/verification/presentation/cubit/verification_cubit.dart';
import 'package:ethioventure/features/verification/presentation/pages/verification_overview_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeVerificationRepository implements VerificationRepository {
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
    id: 'request-test',
    type: type,
    status: VerificationStatus.pending,
  );
}

void main() {
  setUp(() {
    sl.pushNewScope();
    final repository = _FakeVerificationRepository();
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

  Widget buildSubject() {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      onGenerateRoute: AppRouter.onGenerateRoute,
      home: const VerificationOverviewPage(),
    );
  }

  testWidgets('renders verification overview and trust explanation', (
    tester,
  ) async {
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
    expect(
      find.byKey(const ValueKey('selected-verification-type')),
      findsOneWidget,
    );
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

  testWidgets(
    'continue opens the selected type submission page and back returns',
    (tester) async {
      await tester.pumpWidget(buildSubject());

      await tester.ensureVisible(find.text('Student Verification'));
      await tester.tap(find.text('Student Verification'));
      await tester.pump();

      expect(
        find.byKey(const ValueKey('verification-continue')),
        findsOneWidget,
      );
      await tester.ensureVisible(
        find.byKey(const ValueKey('verification-continue')),
      );
      await tester.tap(find.byKey(const ValueKey('verification-continue')));
      await tester.pumpAndSettle();

      expect(find.text('Verification Submission'), findsOneWidget);
      expect(find.text('Student Verification'), findsOneWidget);
      expect(
        find.byKey(const ValueKey('verification-submit-button')),
        findsOneWidget,
      );
      expect(
        find.textContaining('Secure document storage is not configured yet'),
        findsOneWidget,
      );

      await tester.tap(
        find.byKey(const ValueKey('verification-submission-back-button')),
      );
      await tester.pumpAndSettle();

      expect(find.text('Choose a verification type'), findsOneWidget);
    },
  );

  testWidgets(
    'router passes a verification type as a typed submission argument',
    (tester) async {
      final route = AppRouter.onGenerateRoute(
        RouteSettings(
          name: AppConstants.routeVerificationSubmission,
          arguments: VerificationType.business,
        ),
      );

      expect(route.settings.name, AppConstants.routeVerificationSubmission);
    },
  );

  testWidgets('explains profile approval and selection are separate', (
    tester,
  ) async {
    await tester.pumpWidget(buildSubject());

    expect(find.textContaining('It is optional'), findsOneWidget);
    expect(
      find.textContaining('does not submit a request, approve verification'),
      findsOneWidget,
    );
  });
}
