import 'package:flutter/material.dart';

import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/onboarding/presentation/pages/role_selection_page.dart';
import '../constants/app_constants.dart';
import '../theme/app_colors.dart';
import '../theme/app_sizes.dart';

/// Central navigation configuration. Features register a typed route here.
class AppRouter {
  AppRouter._();

  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppConstants.routeHome:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const _LandingHomePage(),
        );

      case AppConstants.routeLogin:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const LoginPage(),
        );

      case AppConstants.routeRegister:
        final roleArg = settings.arguments as String?;
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => RegisterPage(initialRole: roleArg),
        );

      case AppConstants.routeRoleSelection:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const RoleSelectionPage(),
        );

      default:
        return onUnknownRoute(settings);
    }
  }

  static Route<dynamic> onUnknownRoute(RouteSettings settings) {
    return MaterialPageRoute<void>(
      settings: settings,
      builder: (_) => _UnknownRoutePage(routeName: settings.name),
    );
  }
}

class _LandingHomePage extends StatelessWidget {
  const _LandingHomePage();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.hub_outlined, color: AppColors.primary),
            SizedBox(width: AppSizes.xs),
            Text(
              AppConstants.appName,
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pushNamed(AppConstants.routeLogin);
            },
            child: const Text('Sign In'),
          ),
          const SizedBox(width: AppSizes.xs),
          Padding(
            padding: const EdgeInsets.only(right: AppSizes.md),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(110, 40),
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
              ),
              onPressed: () {
                Navigator.of(context).pushNamed(AppConstants.routeRoleSelection);
              },
              child: const Text('Get Started'),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 960),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.lg,
                vertical: AppSizes.xxl,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: AppSizes.lg),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.md,
                      vertical: AppSizes.xs,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primarySoft,
                      borderRadius: BorderRadius.circular(AppSizes.radiusXl),
                    ),
                    child: Text(
                      'Ethiopia\'s Premier Venture Ecosystem',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: AppColors.secondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSizes.lg),
                  Text(
                    'Where Ethiopian Ventures\nMeet Global Opportunity',
                    style: theme.textTheme.headlineLarge?.copyWith(
                      fontSize: 40,
                      height: 1.2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSizes.md),
                  Text(
                    'Connecting high-growth Ethiopian startups with investors, angel networks, and venture funds.',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSizes.xl),
                  Wrap(
                    spacing: AppSizes.md,
                    runSpacing: AppSizes.md,
                    alignment: WrapAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(200, 52),
                        ),
                        icon: const Icon(Icons.rocket_launch),
                        label: const Text('Join as Founder'),
                        onPressed: () {
                          Navigator.of(context).pushNamed(
                            AppConstants.routeRegister,
                            arguments: AppConstants.roleFounder,
                          );
                        },
                      ),
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(200, 52),
                        ),
                        icon: const Icon(Icons.trending_up),
                        label: const Text('Join as Investor'),
                        onPressed: () {
                          Navigator.of(context).pushNamed(
                            AppConstants.routeRegister,
                            arguments: AppConstants.roleInvestor,
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSizes.xxl * 1.5),
                  Row(
                    children: [
                      Expanded(
                        child: _FeatureHighlightCard(
                          icon: Icons.business_center_outlined,
                          title: 'For Startups',
                          description:
                              'Create a verified pitch deck, publish metrics, and connect with thesis-aligned capital providers.',
                          buttonText: 'Register Startup',
                          onTap: () {
                            Navigator.of(context).pushNamed(
                              AppConstants.routeRegister,
                              arguments: AppConstants.roleFounder,
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: AppSizes.lg),
                      Expanded(
                        child: _FeatureHighlightCard(
                          icon: Icons.pie_chart_outline_rounded,
                          title: 'For Investors',
                          description:
                              'Define criteria, explore vetted startups across sectors, and initiate direct conversations.',
                          buttonText: 'Explore Opportunities',
                          onTap: () {
                            Navigator.of(context).pushNamed(
                              AppConstants.routeRegister,
                              arguments: AppConstants.roleInvestor,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FeatureHighlightCard extends StatelessWidget {
  const _FeatureHighlightCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.buttonText,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String description;
  final String buttonText;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        side: const BorderSide(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSizes.md),
              decoration: BoxDecoration(
                color: AppColors.primarySoft,
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              ),
              child: Icon(icon, color: AppColors.secondary, size: 28),
            ),
            const SizedBox(height: AppSizes.lg),
            Text(title, style: theme.textTheme.titleLarge),
            const SizedBox(height: AppSizes.xs),
            Text(
              description,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSizes.lg),
            TextButton.icon(
              onPressed: onTap,
              icon: const Icon(Icons.arrow_forward, size: 16),
              label: Text(buttonText),
            ),
          ],
        ),
      ),
    );
  }
}

class _UnknownRoutePage extends StatelessWidget {
  const _UnknownRoutePage({this.routeName});

  final String? routeName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppConstants.appName)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                routeName == null
                    ? 'This page is unavailable.'
                    : 'The page "$routeName" is unavailable.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSizes.lg),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushReplacementNamed(AppConstants.routeHome);
                },
                child: const Text('Return Home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
