import 'package:ethioventure/features/investor/presentation/widgets/activity_item.dart';
import 'package:ethioventure/features/investor/presentation/widgets/app_bottom_nav.dart';
import 'package:ethioventure/features/investor/presentation/widgets/branded_appbar.dart';
import 'package:ethioventure/features/investor/presentation/widgets/investor_metric.dart';
import 'package:ethioventure/features/investor/presentation/widgets/recommend_startup_section.dart';
import 'package:ethioventure/features/investor/presentation/widgets/startup_recommendation.dart';
import 'package:ethioventure/features/investor/presentation/widgets/tracked_startup.dart';
import 'package:ethioventure/features/investor/presentation/widgets/tracked_startup_sections.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

import '../widgets/investor_stats_section.dart';
import '../widgets/recent_activity_card.dart';

/// Investor dashboard home screen.
///
/// Presentation-only, same pattern as the founder `DashboardPage`: a
/// Cubit/Bloc backed by a Supabase repository would own this state in a
/// full build. Reuses `BrandedAppBar`, `AppBottomNav`, and
/// `DashboardSurfaceCard` from `shared/widgets` so both dashboards share
/// one visual system.
class InvestorDashboardPage extends StatelessWidget {
  const InvestorDashboardPage({super.key});

  // --- Mock data (replace with real state from a Cubit/Bloc) ---------------

  static const _metrics = [
    InvestorMetric(
      label: 'Active Deals',
      value: '12',
      deltaText: '+2 this month',
      tone: DeltaTone.positive,
      icon: Icons.sell_outlined,
    ),
    InvestorMetric(
      label: 'Startups Tracked',
      value: '48',
      deltaText: 'No change',
      tone: DeltaTone.neutral,
      icon: Icons.visibility_outlined,
    ),
    InvestorMetric(
      label: 'Unread Messages',
      value: '5',
      deltaText: 'Requires attention',
      tone: DeltaTone.warning,
      icon: Icons.chat_bubble_outline_rounded,
    ),
  ];

  static const _recommended = [
    StartupRecommendation(
      id: 'su-1',
      name: 'PayStream',
      tagline: 'Cross-border payment infrastructure for East African SMEs.',
      tags: ['Fintech', 'Seed'],
      matchScore: 94,
    ),
    StartupRecommendation(
      id: 'su-2',
      name: 'FarmLedger',
      tagline: 'Supply chain traceability for smallholder agriculture.',
      tags: ['Agritech', 'Pre-seed'],
      matchScore: 88,
    ),
    StartupRecommendation(
      id: 'su-3',
      name: 'CareLink',
      tagline: 'Tele-health scheduling and records for rural clinics.',
      tags: ['Healthtech', 'Seed'],
      matchScore: 81,
    ),
  ];

  static const _activity = [
    ActivityItem(
      actorName: 'Acme Corp',
      action: 'uploaded a new pitch deck.',
      timeAgo: '2 hours ago',
      kind: ActivityKind.document,
    ),
    ActivityItem(
      actorName: 'GreenTech',
      action: 'requested a meeting.',
      timeAgo: 'Yesterday',
      kind: ActivityKind.meeting,
    ),
    ActivityItem(
      actorName: 'EduNet',
      action: 'closed their Seed round.',
      timeAgo: '3 days ago',
      kind: ActivityKind.milestone,
    ),
  ];

  static const _tracked = [
    TrackedStartup(
      id: 'ts-1',
      name: 'Lomi Logistics',
      fundingGoalLabel: 'Seeking \$500k Seed',
      progressPercent: 75,
    ),
    TrackedStartup(
      id: 'ts-2',
      name: 'Solaris Grid',
      fundingGoalLabel: 'Seeking \$2M Series A',
      progressPercent: 40,
    ),
    TrackedStartup(
      id: 'ts-3',
      name: 'Kifiya Pay',
      fundingGoalLabel: 'Seeking \$150k Pre-Seed',
      progressPercent: 98,
    ),
  ];

  static const _navItems = [
    NavItem(icon: Icons.grid_view_rounded, label: 'Dashboard'),
    NavItem(icon: Icons.search_rounded, label: 'Discover'),
    NavItem(icon: Icons.chat_bubble_outline_rounded, label: 'Messages'),
    NavItem(icon: Icons.person_outline_rounded, label: 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const BrandedAppBar(
        title: 'Investor Dashboard',
        showBackButton: true,
      ),
      bottomNavigationBar: const AppBottomNav(items: _navItems, currentIndex: 0),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.only(top: 20, bottom: 24),
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: InvestorStatsSection(metrics: _metrics),
            ),
            RecommendedStartupsSection(
              startups: _recommended,
              onViewAll: () {
                // TODO: navigate to full recommendations list.
              },
              onViewProfile: (startup) {
                // TODO: navigate to startup profile detail page.
              },
            ),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  RecentActivityCard(
                    items: _activity,
                    onViewAll: () {
                      // TODO: navigate to full activity feed.
                    },
                  ),
                  const SizedBox(height: 16),
                  TrackedStartupsSection(
                    startups: _tracked,
                    onManage: () {
                      // TODO: navigate to tracked startups management.
                    },
                    onTapStartup: (startup) {
                      // TODO: navigate to startup detail page.
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}