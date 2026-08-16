import 'package:flutter/material.dart';
import 'package:ethioventure/core/di/injection_container.dart';
import 'package:ethioventure/features/matching/presentation/cubit/matching_cubit.dart';
import 'package:ethioventure/features/matching/presentation/pages/investor_dashboard_page.dart';

class AppRouter {
  AppRouter._();

  static const String dashboard = '/';
  static const String recommendations = '/recommendations';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case dashboard:
      case recommendations:
      default:
        return MaterialPageRoute(
          builder: (_) => InvestorDashboardPage(
            cubit: sl<MatchingCubit>(),
          ),
          settings: settings,
        );
    }
  }
}
