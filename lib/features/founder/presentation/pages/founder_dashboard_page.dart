import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../widgets/dashboard_app_bar.dart';
import '../widgets/dashboard_bottom_nav.dart';
import '../widgets/metric_section.dart';
import '../widgets/profile_strength_card.dart';
import '../widgets/recommended_investor_section.dart';
import '../widgets/welcome_header.dart';

/// Founder dashboard home screen.
class FounderDashboardPage extends StatelessWidget {
  const FounderDashboardPage({super.key});

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
    String displayName = 'Founder';

    final currentUser = Supabase.instance.client.auth.currentUser;
    if (currentUser != null) {
      final metaName = currentUser.userMetadata?['name'] as String?;
      if (metaName != null && metaName.trim().isNotEmpty) {
        displayName = metaName.trim();
      } else if (currentUser.email != null && currentUser.email!.contains('@')) {
        displayName = currentUser.email!.split('@').first;
      }
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const DashboardAppBar(),
      bottomNavigationBar: DashboardBottomNav(
        currentIndex: 0,
        onTap: (index) {
          if (index == 1) {
            Navigator.pushNamed(context, '/startup-profile');
          }
        },
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.only(bottom: 24),
          children: [
            WelcomeHeader(
              userName: displayName,
              onUpdatePitchDeck: () {
                Navigator.pushNamed(context, '/startup-profile');
              },
            ),
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

class ProfileChecklistItem {
  final String label;
  final bool isComplete;

  const ProfileChecklistItem({required this.label, required this.isComplete});
}

class ProfileStrength {
  final int percent;
  final List<ProfileChecklistItem> checklist;

  const ProfileStrength({required this.percent, required this.checklist});
}

class DashboardMetric {
  final String label;
  final String value;
  final String deltaText;
  final String iconAsset;
  final bool isPositive;

  const DashboardMetric({
    required this.label,
    required this.value,
    required this.deltaText,
    required this.iconAsset,
    this.isPositive = true,
  });
}

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