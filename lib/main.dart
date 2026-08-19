import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/bloc/app_bloc_observer.dart';
import 'core/config/app_config.dart';
import 'core/constants/app_constants.dart';
import 'core/di/injection_container.dart';
import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  String environment = 'development';

  try {
    await dotenv.load(fileName: '.env');
    final config = AppConfig.fromEnvironment();
    environment = config.environment;

    await Supabase.initialize(
      url: config.supabaseUrl,
      publishableKey: config.supabasePublishableKey,
    );

    developer.log(
      'Supabase initialized. host=${Uri.parse(config.supabaseUrl).host}, '
      'environment=${config.environment}',
      name: 'EthioVenture.App',
    );

    await configureDependencies();
    Bloc.observer = const AppBlocObserver();
  } catch (error, stackTrace) {
    developer.log(
      'Application initialization failed.',
      name: 'EthioVenture.App',
      error: error,
      stackTrace: stackTrace,
      level: 1000,
    );
    debugPrint('Initialization error: $error\n$stackTrace');
  }

  runApp(EthioVentureApp(environment: environment));
}

class EthioVentureApp extends StatelessWidget {
  const EthioVentureApp({super.key, required this.environment});

  final String environment;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      navigatorKey: AppRouter.navigatorKey,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.lightTheme,
      onGenerateRoute: AppRouter.onGenerateRoute,
      onUnknownRoute: AppRouter.onUnknownRoute,
    );
  }
}
