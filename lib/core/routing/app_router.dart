import 'package:ethioventure/core/constants/app_constants.dart';
import 'package:ethioventure/core/di/injection_container.dart';
import 'package:ethioventure/core/theme/app_sizes.dart';
import 'package:ethioventure/features/messaging/presentation/cubit/conversation_list_cubit.dart';
import 'package:ethioventure/features/messaging/presentation/pages/conversations_page.dart';
import 'package:flutter/material.dart';

/// Central navigation configuration. Features register a typed route here when
/// their page is ready; route names are kept in [AppConstants].
class AppRouter {
  AppRouter._();

  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppConstants.routeConversations:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => ConversationsPage(
            cubit: sl<ConversationListCubit>(),
          ),
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
