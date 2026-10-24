import 'package:ethioventure/features/admin/domain/entities/admin_analytics_summary.dart';
import 'package:ethioventure/features/admin/domain/entities/pending_approval_entity.dart';
import 'package:ethioventure/features/admin/data/models/pending_approval_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const calculator = AdminAnalyticsCalculator();
  final createdAt = DateTime.utc(2026, 1, 1);

  PendingApprovalEntity startup({
    String id = 'startup-1',
    String role = 'founder',
    String industry = 'Fintech',
    String fundingStage = 'Seed',
    double fundingAmountSought = 500000,
    String location = 'Addis Ababa',
    String approvalStatus = 'approved',
  }) => PendingApprovalEntity(
    id: id,
    userId: '$id-user',
    name: 'Founder',
    email: 'founder@example.test',
    role: role,
    businessName: 'Startup',
    description: '',
    industry: industry,
    fundingStage: fundingStage,
    fundingAmountSought: fundingAmountSought,
    location: location,
    createdAt: createdAt,
    approvalStatus: approvalStatus,
  );

  PendingApprovalEntity investor({
    String id = 'investor-1',
    List<String> industries = const ['Fintech'],
    List<String> stages = const ['Seed'],
    List<String> locations = const ['Addis Ababa'],
    double? min = 100000,
    double? max = 1000000,
    String approvalStatus = 'approved',
  }) => PendingApprovalEntity(
    id: id,
    userId: '$id-user',
    name: 'Investor',
    email: 'investor@example.test',
    role: 'investor',
    businessName: 'Investment Firm',
    description: '',
    industry: '',
    fundingStage: '',
    fundingAmountSought: 0,
    location: '',
    createdAt: createdAt,
    approvalStatus: approvalStatus,
    preferredIndustries: industries,
    preferredStages: stages,
    geographicFocus: locations,
    ticketSizeMin: min,
    ticketSizeMax: max,
  );

  AdminAnalyticsSummary calculate({
    List<PendingApprovalEntity> pendingStartups = const [],
    List<PendingApprovalEntity> pendingInvestors = const [],
    List<PendingApprovalEntity> approvedStartups = const [],
    List<PendingApprovalEntity> approvedInvestors = const [],
    List<PendingApprovalEntity> rejectedProfiles = const [],
  }) => calculator.calculate(
    pendingStartups: pendingStartups,
    pendingInvestors: pendingInvestors,
    approvedStartups: approvedStartups,
    approvedInvestors: approvedInvestors,
    rejectedProfiles: rejectedProfiles,
  );

  test(
    'calculates totals, approved profile trends, and compatible pair rate',
    () {
      final summary = calculate(
        pendingStartups: [
          startup(id: 'pending-startup', approvalStatus: 'pending'),
        ],
        pendingInvestors: [
          investor(id: 'pending-investor', approvalStatus: 'pending'),
        ],
        approvedStartups: [startup()],
        approvedInvestors: [investor()],
        rejectedProfiles: [
          startup(id: 'rejected-startup', approvalStatus: 'rejected'),
          investor(id: 'rejected-investor', approvalStatus: 'rejected'),
        ],
      );

      expect(summary.totalStartups, 3);
      expect(summary.totalInvestors, 3);
      expect(summary.compatibleMatches, 1);
      expect(summary.possibleMatches, 1);
      expect(summary.matchRate, 100);
      expect(summary.industryCounts, {'Fintech': 1});
      expect(summary.fundingStageCounts, {'Seed': 1});
    },
  );

  test('counts incompatible approved pairs as evaluated, not compatible', () {
    final summary = calculate(
      approvedStartups: [startup()],
      approvedInvestors: [
        investor(
          industries: ['Healthcare'],
          stages: ['Series A'],
          locations: ['Hawassa'],
          min: 2000000,
          max: 3000000,
        ),
      ],
    );

    expect(summary.compatibleMatches, 0);
    expect(summary.possibleMatches, 1);
    expect(summary.matchRate, 0);
  });

  test('returns no match rate when there are no approved pairs', () {
    final summary = calculate();

    expect(summary.totalStartups, 0);
    expect(summary.totalInvestors, 0);
    expect(summary.compatibleMatches, 0);
    expect(summary.possibleMatches, 0);
    expect(summary.matchRate, isNull);
    expect(summary.industryCounts, isEmpty);
    expect(summary.fundingStageCounts, isEmpty);
  });

  test('admin profile model preserves investor preferences for matching', () {
    final model = PendingApprovalModel.fromJson({
      'id': 'investor-1',
      'user_id': 'user-1',
      'name': 'Investor',
      'email': 'investor@example.test',
      'role': 'investor',
      'business_name': 'Investment Firm',
      'description': '',
      'industry': '',
      'funding_stage': '',
      'funding_amount_sought': 0,
      'location': '',
      'created_at': createdAt.toIso8601String(),
      'approval_status': 'approved',
      'preferred_industries': ['Fintech', 'Health'],
      'preferred_stages': '{Seed,Series A}',
      'geographic_focus': ['Addis Ababa'],
      'ticket_size_min': 100000,
      'ticket_size_max': '1000000',
    });

    expect(model.preferredIndustries, ['Fintech', 'Health']);
    expect(model.preferredStages, ['Seed', 'Series A']);
    expect(model.geographicFocus, ['Addis Ababa']);
    expect(model.ticketSizeMin, 100000);
    expect(model.ticketSizeMax, 1000000);
  });
}
