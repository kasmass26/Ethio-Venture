import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../features/admin/presentation/pages/admin_dashboard_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/founder/presentation/pages/founder_dashboard_page.dart';
import '../../features/founder/presentation/pages/investors_page.dart';
import '../../features/investor/presentation/pages/investor_dashboard_page.dart';
import '../../features/investor_profile/presentation/pages/investor_profile_page.dart';
import '../../features/matching/domain/entities/match_result_entity.dart';
import '../../features/matching/presentation/pages/recommendations_page.dart';
import '../../features/messaging/presentation/pages/chat_page.dart';
import '../../features/messaging/presentation/pages/conversations_page.dart';
import '../../features/onboarding/presentation/pages/onboarding_page.dart';
import '../../features/splash/splash_page.dart';
import '../../features/startup_profile/domain/entities/startup_profile_entity.dart';
import '../../features/startup_profile/presentation/pages/edit_startup_profile_page.dart';
import '../../features/startup_profile/presentation/pages/startup_detail_page.dart';
import '../../features/startup_profile/presentation/pages/startup_list_page.dart';
import '../../features/startup_profile/presentation/pages/startup_profile_page.dart';
import '../../features/startup_profile/presentation/pages/startup_profile_setup_page.dart';

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
      AppConstants.routeAdminDashboard => const AdminDashboardPage(),
      AppConstants.routeStartupProfileSetup => const StartupProfileSetupPage(),
      AppConstants.routeStartupProfile => const StartupProfilePage(),
      AppConstants.routeEditStartupProfile => settings.arguments
              is StartupProfileEntity
          ? EditStartupProfilePage(
              profile: settings.arguments as StartupProfileEntity,
            )
          : _UnknownRoutePage(routeName: settings.name),
      AppConstants.routeStartupDetail => settings.arguments is StartupProfileEntity
          ? StartupDetailPage(
              startup: settings.arguments as StartupProfileEntity,
            )
          : settings.arguments is MatchResultEntity
              ? StartupDetailPage.fromId(
                  startupId: (settings.arguments as MatchResultEntity).startup.id,
                  matchScore: (settings.arguments as MatchResultEntity).overallScore,
                )
              : settings.arguments is String
                  ? StartupDetailPage.fromId(
                      startupId: settings.arguments as String,
                    )
                  : _UnknownRoutePage(routeName: settings.name),
      AppConstants.routeInvestorProfile => const InvestorProfilePage(),
      AppConstants.routeStartupSearch => const StartupListPage(),
      AppConstants.routeRecommendations => const RecommendationsPage(),
      AppConstants.routeMessages => const ConversationsPage(),
      AppConstants.routeChat => settings.arguments is Map
          ? ChatPage(
              conversationId: ((settings.arguments
                      as Map)['conversationId'] ??
                  '')
                  .toString(),
              participantName: ((settings.arguments
                      as Map)['participantName'] ??
                  'Chat')
                  .toString(),
              participantAvatarUrl: (settings.arguments
                  as Map)['participantAvatarUrl'] as String?,
            )
          : _UnknownRoutePage(routeName: settings.name),
      _ => _UnknownRoutePage(routeName: settings.name),
    };

    return MaterialPageRoute<void>(settings: settings, builder: (_) => page);
  }

  /// Returns the appropriate destination after a successful authentication.
  static String dashboardRouteForRole(String role, String email) {
    // Check if admin email
    if (email == AppConstants.adminEmail) {
      return AppConstants.routeAdminDashboard;
    }
    
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
      appBar: AppBar(title: const Text('Page Not Found')),
      body: Center(
        child: Text('No route defined for ${routeName ?? 'unknown'}'),
      ),
    );
  }
}