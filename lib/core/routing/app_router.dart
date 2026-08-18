import 'package:flutter/material.dart';

import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/founder/presentation/pages/founder_dashboard_page.dart';
import '../../features/investor/presentation/pages/investor_dashboard_page.dart';
import '../../features/onboarding/presentation/pages/onboarding_page.dart';
import '../constants/app_constants.dart';

/// Central navigation configuration. Page widgets belong to their features.
class AppRouter {
  AppRouter._();

  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    final Widget page = switch (settings.name) {
      AppConstants.routeHome => const OnboardingPage(),
      AppConstants.routeLogin => const LoginPage(),
      AppConstants.routeRegister => RegisterPage(
          initialRole: settings.arguments is String
              ? settings.arguments as String
              : null,
        ),
      AppConstants.routeRoleSelection => const OnboardingPage(),
      AppConstants.routeFounderDashboard => const FounderDashboardPage(),
      AppConstants.routeInvestorDashboard => const InvestorDashboardPage(),
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
