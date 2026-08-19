import 'package:ethioventure/core/di/injection_container.dart';
import 'package:ethioventure/core/theme/app_theme.dart';
import 'package:ethioventure/features/investor_profile/domain/entities/investor_profile_entity.dart';
import 'package:ethioventure/features/investor_profile/domain/repositories/investor_profile_repository.dart';
import 'package:ethioventure/features/investor_profile/domain/usecases/create_investor_profile.dart';
import 'package:ethioventure/features/investor_profile/domain/usecases/delete_investor_profile.dart';
import 'package:ethioventure/features/investor_profile/domain/usecases/get_investor_profile.dart';
import 'package:ethioventure/features/investor_profile/domain/usecases/update_investor_profile.dart';
import 'package:ethioventure/features/investor_profile/presentation/cubit/investor_profile_cubit.dart';
import 'package:ethioventure/features/investor_profile/presentation/pages/investor_profile_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeInvestorProfileRepository implements InvestorProfileRepository {
  InvestorProfileEntity? profile;

  @override
  Future<InvestorProfileEntity?> getInvestorProfile() async {
    return profile;
  }

  @override
  Future<InvestorProfileEntity> createInvestorProfile(
    InvestorProfileEntity entity,
  ) async {
    profile = entity;
    return entity;
  }

  @override
  Future<InvestorProfileEntity> updateInvestorProfile(
    InvestorProfileEntity entity,
  ) async {
    profile = entity;
    return entity;
  }

  @override
  Future<void> deleteInvestorProfile() async {
    profile = null;
  }
}

void main() {
  late FakeInvestorProfileRepository fakeRepo;

  setUp(() async {
    await sl.reset();
    fakeRepo = FakeInvestorProfileRepository();

    sl
      ..registerLazySingleton<InvestorProfileRepository>(() => fakeRepo)
      ..registerLazySingleton(() => GetInvestorProfile(sl()))
      ..registerLazySingleton(() => CreateInvestorProfile(sl()))
      ..registerLazySingleton(() => UpdateInvestorProfile(sl()))
      ..registerLazySingleton(() => DeleteInvestorProfile(sl()))
      ..registerFactory(
        () => InvestorProfileCubit(
          getInvestorProfile: sl(),
          createInvestorProfile: sl(),
          updateInvestorProfile: sl(),
          deleteInvestorProfile: sl(),
        ),
      );
  });

  tearDown(() async {
    await sl.reset();
  });

  testWidgets('InvestorProfilePage renders header, portal badge, and form', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 2000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: const InvestorProfilePage(),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Investment Thesis Setup'), findsWidgets);
    expect(find.text('Investor Portal'), findsOneWidget);
    expect(find.text('Organization Details'), findsOneWidget);
    expect(find.text('Preferred Industries'), findsOneWidget);
    expect(find.text('Target Funding Stages'), findsOneWidget);
    expect(find.text('Typical Ticket Size'), findsOneWidget);
  });

  testWidgets('InvestorProfilePage creates profile when Complete Profile is pressed', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 2000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: const InvestorProfilePage(),
      ),
    );

    await tester.pumpAndSettle();

    // Fill form
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Organization Name'),
      'Sheba Angels',
    );
    await tester.tap(find.text('Fintech'));
    await tester.pump();
    await tester.tap(find.text('Agri-Tech'));
    await tester.pump();
    await tester.tap(find.text('Seed'));
    await tester.pump();
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Minimum Investment'),
      '50000',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Maximum Investment'),
      '200000',
    );
    await tester.pumpAndSettle();

    // Tap Complete Profile
    await tester.ensureVisible(find.text('Complete Profile'));
    await tester.tap(find.text('Complete Profile'));
    await tester.pumpAndSettle();

    expect(fakeRepo.profile, isNotNull);
    expect(fakeRepo.profile!.organizationName, 'Sheba Angels');
    expect(fakeRepo.profile!.preferredIndustries, ['Fintech', 'Agri-Tech']);
    expect(fakeRepo.profile!.preferredStages, ['Seed']);
    expect(fakeRepo.profile!.ticketSizeMin, 50000.0);
    expect(fakeRepo.profile!.ticketSizeMax, 200000.0);

    expect(
      find.text('Investment thesis saved successfully!'),
      findsOneWidget,
    );
  });
}
