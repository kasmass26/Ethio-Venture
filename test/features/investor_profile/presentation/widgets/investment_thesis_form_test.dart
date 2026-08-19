import 'package:ethioventure/core/theme/app_theme.dart';
import 'package:ethioventure/features/investor_profile/domain/entities/investor_profile_entity.dart';
import 'package:ethioventure/features/investor_profile/presentation/widgets/investment_thesis_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget buildTestWidget({
    InvestorProfileEntity? initialProfile,
    ValueChanged<InvestorProfileEntity>? onSaveDraft,
    ValueChanged<InvestorProfileEntity>? onCompleteProfile,
    bool isSaving = false,
  }) {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      home: Scaffold(
        body: SingleChildScrollView(
          child: InvestmentThesisForm(
            initialProfile: initialProfile,
            onSaveDraft: onSaveDraft ?? (_) {},
            onCompleteProfile: onCompleteProfile ?? (_) {},
            isSaving: isSaving,
          ),
        ),
      ),
    );
  }

  group('InvestmentThesisForm', () {
    testWidgets('renders all 4 sections with titles and actions', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1200, 2000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildTestWidget());

      expect(find.text('Organization Details'), findsOneWidget);
      expect(find.text('Preferred Industries'), findsOneWidget);
      expect(find.text('Target Funding Stages'), findsOneWidget);
      expect(find.text('Typical Ticket Size'), findsOneWidget);

      expect(find.text('Save as Draft'), findsOneWidget);
      expect(find.text('Complete Profile'), findsOneWidget);
    });

    testWidgets('validates required fields on complete profile submission', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1200, 2000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildTestWidget());

      // Attempt to submit empty form
      await tester.ensureVisible(find.text('Complete Profile'));
      await tester.tap(find.text('Complete Profile'));
      await tester.pumpAndSettle();

      expect(find.text('Organization name is required'), findsOneWidget);
      expect(
        find.text('Please select at least one preferred industry'),
        findsOneWidget,
      );
      expect(
        find.text('Please select at least one target funding stage'),
        findsOneWidget,
      );
      expect(find.text('Minimum investment is required'), findsOneWidget);
      expect(find.text('Maximum investment is required'), findsOneWidget);
    });

    testWidgets('enforces max 5 industry selections and allows selecting up to 5', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1200, 2000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildTestWidget());

      // Available industries: Fintech, Agri-Tech, EdTech, HealthTech, E-commerce, Clean Energy, Logistics
      await tester.tap(find.text('Fintech'));
      await tester.pump();
      await tester.tap(find.text('Agri-Tech'));
      await tester.pump();
      await tester.tap(find.text('EdTech'));
      await tester.pump();
      await tester.tap(find.text('HealthTech'));
      await tester.pump();
      await tester.tap(find.text('E-commerce'));
      await tester.pumpAndSettle();

      expect(find.text('5/5 selected'), findsOneWidget);

      // Attempt 6th selection
      await tester.tap(find.text('Clean Energy'));
      await tester.pumpAndSettle();

      // SnackBar with warning
      expect(
        find.text('You can select up to 5 industries only.'),
        findsOneWidget,
      );
      // Counter remains 5/5
      expect(find.text('5/5 selected'), findsOneWidget);
    });

    testWidgets('validates that maximum ticket size is not less than minimum', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1200, 2000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildTestWidget());

      // Enter org name
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Organization Name'),
        'Test Syndicate',
      );

      // Select industry & stage
      await tester.tap(find.text('Fintech'));
      await tester.tap(find.text('Seed'));

      // Enter Min > Max
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Minimum Investment'),
        '50000',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Maximum Investment'),
        '10000',
      );
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Complete Profile'));
      await tester.tap(find.text('Complete Profile'));
      await tester.pumpAndSettle();

      expect(
        find.text('Max ticket must not be less than min (\$50000)'),
        findsOneWidget,
      );
    });

    testWidgets('calls onCompleteProfile with valid data when Complete Profile is tapped', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1200, 2000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      InvestorProfileEntity? capturedEntity;

      await tester.pumpWidget(
        buildTestWidget(
          onCompleteProfile: (entity) {
            capturedEntity = entity;
          },
        ),
      );

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Organization Name'),
        'Addis Ventures',
      );
      await tester.tap(find.text('Fintech'));
      await tester.pump();
      await tester.tap(find.text('Agri-Tech'));
      await tester.pump();
      await tester.tap(find.text('Seed'));
      await tester.pump();
      await tester.tap(find.text('Series A'));
      await tester.pump();
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Minimum Investment'),
        '25000',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Maximum Investment'),
        '250000',
      );
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Complete Profile'));
      await tester.tap(find.text('Complete Profile'));
      await tester.pumpAndSettle();

      expect(capturedEntity, isNotNull);
      expect(capturedEntity!.organizationName, 'Addis Ventures');
      expect(capturedEntity!.preferredIndustries, ['Fintech', 'Agri-Tech']);
      expect(capturedEntity!.preferredStages, ['Seed', 'Series A']);
      expect(capturedEntity!.ticketSizeMin, 25000.0);
      expect(capturedEntity!.ticketSizeMax, 250000.0);
    });

    testWidgets('pre-populates form with initialProfile data', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1200, 2000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final existing = InvestorProfileEntity(
        id: 'test-1',
        userId: 'user-1',
        investorType: 'institutional',
        organizationName: 'Habesha Angels',
        bio: 'Early stage angel syndicate.',
        preferredIndustries: const ['Fintech', 'HealthTech'],
        preferredStages: const ['Pre-Seed', 'Seed'],
        ticketSizeMin: 10000,
        ticketSizeMax: 100000,
        createdAt: DateTime.now(),
      );

      await tester.pumpWidget(buildTestWidget(initialProfile: existing));

      expect(find.text('Habesha Angels'), findsOneWidget);
      expect(find.text('Early stage angel syndicate.'), findsOneWidget);
      expect(find.text('2/5 selected'), findsOneWidget);
      expect(find.text('10000'), findsOneWidget);
      expect(find.text('100000'), findsOneWidget);
    });
  });
}
