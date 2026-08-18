import 'package:ethioventure/core/constants/app_constants.dart';
import 'package:ethioventure/core/theme/app_sizes.dart';
import 'package:ethioventure/features/startup_profile/domain/entities/startup_profile_entity.dart';
import 'package:ethioventure/features/startup_profile/presentation/pages/edit_startup_profile_page.dart';
import 'package:ethioventure/features/startup_profile/presentation/pages/startup_profile_page.dart';
import 'package:ethioventure/features/startup_profile/presentation/pages/startup_profile_setup_page.dart';
import 'package:flutter/material.dart';

/// Central navigation configuration.
class AppRouter {
  AppRouter._();

  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppConstants.routeStartupProfileSetup:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const StartupProfileSetupPage(),
        );

      case AppConstants.routeStartupProfile:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const StartupProfilePage(),
        );

      case AppConstants.routeEditStartupProfile:
        final profile = settings.arguments as StartupProfileEntity;
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => EditStartupProfilePage(profile: profile),
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
          child: Text(
            routeName == null
                ? 'This page is unavailable.'
                : 'The page "$routeName" is unavailable.',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
