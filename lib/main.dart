import 'package:ethioventure/core/bloc/app_bloc_observer.dart';
import 'package:ethioventure/core/config/app_config.dart';
import 'package:ethioventure/core/constants/app_constants.dart';
import 'package:ethioventure/core/di/injection_container.dart';
import 'package:ethioventure/core/routing/app_router.dart';
import 'package:ethioventure/core/theme/app_theme.dart';
import 'package:ethioventure/features/startup_profile/presentation/pages/startup_profile_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');

  final config = AppConfig.fromEnvironment();
  await Supabase.initialize(
    url: config.supabaseUrl,
    publishableKey: config.supabasePublishableKey,
  );
  await configureDependencies();
  Bloc.observer = const AppBlocObserver();

  runApp(EthioVentureApp(environment: config.environment));
}

class EthioVentureApp extends StatelessWidget {
  const EthioVentureApp({super.key, required this.environment});

  final String environment;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: environment != 'production',
      navigatorKey: AppRouter.navigatorKey,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      onGenerateRoute: AppRouter.onGenerateRoute,
      onUnknownRoute: AppRouter.onUnknownRoute,
      home: const StartupProfilePage(),
    );
  }
}
