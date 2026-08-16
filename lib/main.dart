import 'package:flutter/material.dart';
import 'package:ethioventure/core/constants/app_constants.dart';
import 'package:ethioventure/core/di/injection_container.dart';
import 'package:ethioventure/core/routing/app_router.dart';
import 'package:ethioventure/core/theme/app_theme.dart';
import 'package:ethioventure/features/matching/presentation/cubit/matching_cubit.dart';
import 'package:ethioventure/features/matching/presentation/pages/investor_dashboard_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initServiceLocator();
  runApp(const EthioVentureApp());
}

class EthioVentureApp extends StatelessWidget {
  const EthioVentureApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      onGenerateRoute: AppRouter.onGenerateRoute,
      home: InvestorDashboardPage(
        cubit: sl<MatchingCubit>(),
      ),
    );
  }
}
