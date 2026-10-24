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
import 'package:ethioventure/features/verification/presentation/widgets/verification_entry_card.dart';
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
    id: 'test-request',
    type: type,
    status: VerificationStatus.pending,
  );

  @override
  Future<VerificationRequestEntity> submitWithDocument({
    required VerificationType type,
    required dynamic fileBytes,
    required String filename,
    required int fileSizeBytes,
  }) async => VerificationRequestEntity(
    id: 'test-request',
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
        // No document submission in this test scope — Storage not configured.
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
    expect(find.text('Choose a verification type'), findsOneWidget);

    final route = AppRouter.onGenerateRoute(
      const RouteSettings(name: AppConstants.routeVerificationOverview),
    );
    expect(route.settings.name, AppConstants.routeVerificationOverview);
  });
}
