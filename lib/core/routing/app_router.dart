import 'package:flutter/material.dart';

import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/founder/presentation/pages/founder_dashboard_page.dart';
import '../../features/founder/presentation/pages/investors_page.dart';
import '../../features/investor/presentation/pages/investor_dashboard_page.dart';
import '../../features/onboarding/presentation/pages/onboarding_page.dart';
import '../../features/splash/splash_page.dart';
import '../../features/startup_profile/domain/entities/startup_profile_entity.dart';
import '../../features/startup_profile/presentation/pages/edit_startup_profile_page.dart';
import '../../features/startup_profile/presentation/pages/startup_profile_page.dart';
import '../../features/startup_profile/presentation/pages/startup_profile_setup_page.dart';
import '../constants/app_constants.dart';

/// Central navigation configuration. Page widgets belong to their features.
class AppRouter {
  AppRouter._();

  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    final Widget page = switch (settings.name) {
      AppConstants.routeHome => const SplashPage(),
      AppConstants.routeSplash => const SplashPage(),
      AppConstants.routeOnboarding => const OnboardingPage(),
      AppConstants.routeLogin => const LoginPage(),
      AppConstants.routeRegister => RegisterPage(
          initialRole: settings.arguments is String
              ? settings.arguments as String
              : null,
        ),
      AppConstants.routeRoleSelection => const OnboardingPage(),
      AppConstants.routeFounderDashboard => const FounderDashboardPage(),
      AppConstants.routeFounderInvestors => const InvestorsPage(),
      AppConstants.routeInvestorDashboard => const InvestorDashboardPage(),
      AppConstants.routeStartupProfileSetup => const StartupProfileSetupPage(),
      AppConstants.routeStartupProfile => const StartupProfilePage(),
      AppConstants.routeEditStartupProfile => settings.arguments
              is StartupProfileEntity
          ? EditStartupProfilePage(
              profile: settings.arguments as StartupProfileEntity,
            )
          : const _UnknownRoutePage(routeName: AppConstants.routeEditStartupProfile),
      _ => _UnknownRoutePage(routeName: settings.name),
    };

    return MaterialPageRoute<void>(settings: settings, builder: (_) => page);
  }

  /// Returns the appropriate destination after a successful authentication.
  static String dashboardRouteForRole(String role) {
    return role == AppConstants.roleInvestor
        ? AppConstants.routeInvestorDashboard
        : AppConstants.routeFounderDashboard;
  }

  static Route<dynamic> onUnknownRoute(RouteSettings settings) {
    return MaterialPageRoute<void>(
      settings: settings,
      builder: (_) => _UnknownRoutePage(routeName: settings.name),
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
        child: Text(
          routeName == null
              ? 'This page is unavailable.'
              : 'The page "$routeName" is unavailable.',
        ),
      ),
    );
  }
}
