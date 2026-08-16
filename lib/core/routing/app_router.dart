import 'package:flutter/material.dart';
import '../../features/matching/presentation/pages/matching_main_page.dart';
import '../../features/matching/presentation/pages/recommendations_page.dart';
import '../../features/matching/presentation/pages/startup_search_page.dart';
import '../../features/startup_profile/domain/entities/startup_profile_entity.dart';
import '../../features/startup_profile/presentation/pages/create_startup_profile_page.dart';
import '../../features/startup_profile/presentation/pages/edit_startup_profile_page.dart';
import '../../features/startup_profile/presentation/pages/startup_profile_page.dart';

class AppRouter {
  static const String initialRoute = '/';
  static const String searchRoute = '/search';
  static const String recommendationsRoute = '/recommendations';
  static const String matchingRoute = '/matching';
  static const String profileRoute = '/profile';
  static const String createProfileRoute = '/profile/create';
  static const String editProfileRoute = '/profile/edit';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case initialRoute:
        return MaterialPageRoute(builder: (_) => const StartupProfilePage());
      case profileRoute:
        return MaterialPageRoute(builder: (_) => const StartupProfilePage());
      case createProfileRoute:
        return MaterialPageRoute(
          builder: (_) => const CreateStartupProfilePage(),
        );
      case editProfileRoute:
        final profile = settings.arguments as StartupProfileEntity;
        return MaterialPageRoute(
          builder: (_) => EditStartupProfilePage(profile: profile),
        );
      case matchingRoute:
        return MaterialPageRoute(builder: (_) => const MatchingMainPage());
      case searchRoute:
        return MaterialPageRoute(builder: (_) => const StartupSearchPage());
      case recommendationsRoute:
        return MaterialPageRoute(builder: (_) => const RecommendationsPage());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }
}
