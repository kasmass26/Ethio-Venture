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
  SupabaseClient? supabaseClient;
  String? initError;

  // Step 1: Load config and initialise Supabase.
  try {
    await dotenv.load(fileName: '.env');
    final config = AppConfig.fromEnvironment();
    environment = config.environment;

    await Supabase.initialize(
      url: config.supabaseUrl,
      publishableKey: config.supabasePublishableKey,
    );

    supabaseClient = Supabase.instance.client;

    developer.log(
      'Supabase initialized. host=${Uri.parse(config.supabaseUrl).host}, '
      'environment=${config.environment}',
      name: 'EthioVenture.App',
    );
  } catch (error, stackTrace) {
    initError = error.toString();
    debugPrint('Supabase initialisation error: $error\n$stackTrace');
  }

  // Step 2: Register GetIt dependencies.
  try {
    await configureDependencies(supabaseClient: supabaseClient);
    Bloc.observer = const AppBlocObserver();
  } catch (error, stackTrace) {
    initError ??= error.toString();
    developer.log(
      'Application initialization failed.',
      name: 'EthioVenture.App',
      error: error,
      stackTrace: stackTrace,
      level: 1000,
    );
    debugPrint('Initialization error: $error\n$stackTrace');
  }

  runApp(
    EthioVentureApp(
      environment: environment,
      initError: initError,
    ),
  );
}

class EthioVentureApp extends StatelessWidget {
  const EthioVentureApp({
    super.key,
    required this.environment,
    this.initError,
  });

  final String environment;
  final String? initError;

  @override
  Widget build(BuildContext context) {
    if (initError != null) {
      return MaterialApp(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        home: _InitErrorPage(message: initError!),
      );
    }

    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      navigatorKey: AppRouter.navigatorKey,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      onGenerateRoute: AppRouter.onGenerateRoute,
      onUnknownRoute: AppRouter.onUnknownRoute,
    );
  }
}

class _InitErrorPage extends StatelessWidget {
  const _InitErrorPage({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              const Text(
                'Initialization Error',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
