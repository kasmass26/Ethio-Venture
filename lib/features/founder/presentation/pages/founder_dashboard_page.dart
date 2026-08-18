import 'package:ethioventure/features/founder/presentation/widgets/metric_section.dart';
import 'package:ethioventure/features/founder/presentation/widgets/recommended_investor_section.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

import '../widgets/dashboard_app_bar.dart';
import '../widgets/dashboard_bottom_nav.dart';

import '../widgets/profile_strength_card.dart';

import '../widgets/welcome_header.dart';

/// Founder dashboard home screen.
///
/// This page is presentation-only: it renders whatever state it is given.
/// In a full clean-architecture setup, a Cubit/Bloc (fed by a repository
/// backed by Supabase) would own [ProfileStrength], the metric list, and
/// the investor list, and expose them via a state object. Swap the mock
/// data below for that state without touching any widget in `widgets/`.
class FounderDashboardPage extends StatelessWidget {
  const FounderDashboardPage({super.key});

  // --- Mock data (replace with real state from a Cubit/Bloc) ---------------

  static const _profileStrength = ProfileStrength(
    percent: 85,
    checklist: [
      ProfileChecklistItem(label: 'Basic Information', isComplete: true),
      ProfileChecklistItem(label: 'Team Members Added', isComplete: true),
      ProfileChecklistItem(
          label: 'Upload Financial Projections', isComplete: false),
    ],
  );

  static const _metrics = [
    DashboardMetric(
      label: 'Profile Views',
      value: '248',
      deltaText: '12% this week',
      iconAsset: 'views',
      isPositive: true,
    ),
    DashboardMetric(
      label: 'Investor Interest',
      value: '15',
      deltaText: '3 new saves',
      iconAsset: 'interest',
      isPositive: true,
    ),
    DashboardMetric(
      label: 'Active Conversations',
      value: '4',
      deltaText: '1 pending reply',
      iconAsset: 'conversations',
      isPositive: false,
    ),
  ];

  static const _metricIcons = [
    Icons.visibility_outlined,
    Icons.favorite_border_rounded,
    Icons.forum_outlined,
  ];

  static const _investors = [
    Investor(
      id: 'inv-1',
      name: 'Nile Capital',
      location: 'Addis Ababa, ETH',
      tags: ['Fintech', 'Seed'],
    ),
    Investor(
      id: 'inv-2',
      name: 'Rift Ventures',
      location: 'Nairobi, KEN',
      tags: ['Agritech', 'Series A'],
    ),
    Investor(
      id: 'inv-3',
      name: 'Horn Angels',
      location: 'Addis Ababa, ETH',
      tags: ['Healthtech', 'Pre-seed'],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const DashboardAppBar(),
      bottomNavigationBar: const DashboardBottomNav(currentIndex: 0),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.only(bottom: 24),
          children: [
            const WelcomeHeader(userName: 'Sarah'),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const ProfileStrengthCard(data: _profileStrength),
                  const SizedBox(height: 16),
                  MetricsSection(metrics: _metrics, icons: _metricIcons),
                ],
              ),
            ),
            const SizedBox(height: 8),
            RecommendedInvestorsSection(
              investors: _investors,
              onViewProfile: (investor) {
              },
            ),
          ],
        ),
      ),
    );
  }
}


/// A single checklist item inside the "Profile Strength" card.
class ProfileChecklistItem {
  final String label;
  final bool isComplete;

  const ProfileChecklistItem({required this.label, required this.isComplete});
}

/// Snapshot of profile-completeness data.
class ProfileStrength {
  final int percent;
  final List<ProfileChecklistItem> checklist;

  const ProfileStrength({required this.percent, required this.checklist});
}

/// One metric tile (Profile Views, Investor Interest, Active Conversations...).
class DashboardMetric {
  final String label;
  final String value;
  final String deltaText;
  final String iconAsset; // maps to an IconData via the widget layer
  final bool isPositive;

  const DashboardMetric({
    required this.label,
    required this.value,
    required this.deltaText,
    required this.iconAsset,
    this.isPositive = true,
  });
}




/// Plain domain entity — no Flutter/UI imports, so it can be reused by
/// any data source (Supabase, REST, cache) without leaking framework details.
class Investor {
  final String id;
  final String name;
  final String location;
  final List<String> tags;
  final String? avatarUrl;

  const Investor({
    required this.id,
    required this.name,
    required this.location,
    required this.tags,
    this.avatarUrl,
  });
}