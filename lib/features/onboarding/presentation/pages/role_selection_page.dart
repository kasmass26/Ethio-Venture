import 'package:ethioventure/core/constants/app_constants.dart';
import 'package:ethioventure/core/theme/app_sizes.dart';
import 'package:flutter/material.dart';

/// Lets a new user enter the experience designed for their account role.
class RoleSelectionPage extends StatelessWidget {
  const RoleSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppConstants.appName)),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: AppSizes.maxContentWidth,
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.pageHorizontal),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'How will you use Ethio Venture?',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: AppSizes.sm),
                  Text(
                    AppConstants.appTagline,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: AppSizes.xl),
                  _RoleCard(
                    icon: Icons.rocket_launch_outlined,
                    title: 'I am a founder',
                    description:
                        'Create your startup profile and discover suitable investors.',
                    onTap: () => _openDashboard(
                      context,
                      AppConstants.routeFounderDashboard,
                    ),
                  ),
                  const SizedBox(height: AppSizes.md),
                  _RoleCard(
                    icon: Icons.account_balance_outlined,
                    title: 'I am an investor',
                    description:
                        'Set your investment preferences and discover startups.',
                    onTap: () => _openDashboard(
                      context,
                      AppConstants.routeInvestorDashboard,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _openDashboard(BuildContext context, String route) {
    Navigator.of(context).pushReplacementNamed(route);
  }
}

class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.lg),
          child: Row(
            children: [
              Icon(icon, size: AppSizes.iconLg),
              const SizedBox(width: AppSizes.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: AppSizes.xs),
                    Text(description),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward),
            ],
          ),
        ),
      ),
    );
  }
}
