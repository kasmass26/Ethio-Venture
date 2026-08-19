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
  // Null until Supabase.initialize() completes successfully.
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

    // Only assign after a successful initialize() call.
    supabaseClient = Supabase.instance.client;
  } catch (error, stackTrace) {
    initError = error.toString();
    debugPrint('Supabase initialisation error: $error\n$stackTrace');
  }

  // Step 2: Register GetIt dependencies.
  // Pass the live client so no registration touches Supabase.instance
  // before it is ready. If supabaseClient is null, feature cubits will
  // not be registered and the error screen is shown instead.
  try {
    await configureDependencies(supabaseClient: supabaseClient);
    Bloc.observer = const AppBlocObserver();
  } catch (error, stackTrace) {
    debugPrint('Dependency injection error: $error\n$stackTrace');
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

  runApp(
    EthioVentureApp(
      environment: environment,
      initError: initError,
    ),
  );
}

class EthioVentureApp extends StatelessWidget {
  const EthioVentureApp({super.key, required this.environment});

  final String environment;
  /// Non-null when Supabase failed to initialise; shown to the developer.
  final String? initError;

  @override
  Widget build(BuildContext context) {
    // If Supabase never initialised, show a clear error instead of crashing
    // somewhere deep inside a cubit.
    if (initError != null) {
      return MaterialApp(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: true,
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

/// Shown when the app cannot start due to a missing or invalid configuration.
class _InitErrorPage extends StatelessWidget {
  const _InitErrorPage({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              Text(
                'Configuration Error',
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'The application could not start because the .env file is '
                'missing or contains invalid values.\n\n'
                'Copy .env.example to .env and fill in your '
                'SUPABASE_URL and SUPABASE_PUBLISHABLE_KEY.',
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Text(
                  message,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                    color: Colors.red,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
