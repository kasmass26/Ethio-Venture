import 'package:ethioventure/core/constants/app_constants.dart';
import 'package:ethioventure/core/theme/app_sizes.dart';
import 'package:flutter/material.dart';

/// Home for investors to manage their investment thesis and discover startups.
class InvestorDashboardPage extends StatelessWidget {
  const InvestorDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Investor dashboard'),
        actions: [
          IconButton(
            tooltip: 'Change role',
            onPressed: () => Navigator.of(
              context,
            ).pushReplacementNamed(AppConstants.routeRoleSelection),
            icon: const Icon(Icons.switch_account_outlined),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSizes.pageHorizontal),
        children: const [
          _DashboardIntro(
            title: 'Discover ventures that fit your thesis.',
            description:
                'Set your preferences to receive better startup matches.',
          ),
          SizedBox(height: AppSizes.lg),
          _DashboardAction(
            icon: Icons.tune_outlined,
            title: 'Investment preferences',
            description:
                'Define industries, stages, locations, and ticket size.',
          ),
          SizedBox(height: AppSizes.md),
          _DashboardAction(
            icon: Icons.explore_outlined,
            title: 'Discover startups',
            description: 'Search published ventures that fit your criteria.',
          ),
          SizedBox(height: AppSizes.md),
          _DashboardAction(
            icon: Icons.handshake_outlined,
            title: 'Your matches',
            description: 'Review recommended ventures and your interactions.',
          ),
        ],
      ),
    );
  }
}

class _DashboardIntro extends StatelessWidget {
  const _DashboardIntro({required this.title, required this.description});
  final String title;
  final String description;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(title, style: Theme.of(context).textTheme.headlineMedium),
      const SizedBox(height: AppSizes.sm),
      Text(description, style: Theme.of(context).textTheme.bodyLarge),
    ],
  );
}

class _DashboardAction extends StatelessWidget {
  const _DashboardAction({
    required this.icon,
    required this.title,
    required this.description,
  });
  final IconData icon;
  final String title;
  final String description;
  @override
  Widget build(BuildContext context) => Card(
    child: ListTile(
      contentPadding: const EdgeInsets.all(AppSizes.md),
      leading: Icon(icon, size: AppSizes.iconLg),
      title: Text(title),
      subtitle: Text(description),
      trailing: const Icon(Icons.arrow_forward),
    ),
  );
}
