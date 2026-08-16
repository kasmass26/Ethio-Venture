import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/constants/app_constants.dart';
import 'core/di/injection_container.dart' as di;
import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/matching/presentation/cubit/recommendations_cubit.dart';
import 'features/matching/presentation/cubit/startup_search_cubit.dart';
import 'features/startup_profile/presentation/cubit/document_upload_cubit.dart';
import 'features/startup_profile/presentation/cubit/startup_profile_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Supabase.initialize(
      url: AppConstants.supabaseUrl,
      anonKey: AppConstants.supabaseAnonKey,
    );
  } catch (e) {
    // Gracefully handled if running in headless test runner environment
  }
  await di.init();
  runApp(const EthioVentureApp());
}

class EthioVentureApp extends StatelessWidget {
  const EthioVentureApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<StartupProfileCubit>(
          create: (_) => di.sl<StartupProfileCubit>(),
        ),
        BlocProvider<DocumentUploadCubit>(
          create: (_) => di.sl<DocumentUploadCubit>(),
        ),
        BlocProvider<StartupSearchCubit>(
          create: (_) => di.sl<StartupSearchCubit>(),
        ),
        BlocProvider<RecommendationsCubit>(
          create: (_) => di.sl<RecommendationsCubit>(),
        ),
      ],
      child: MaterialApp(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        onGenerateRoute: AppRouter.generateRoute,
        initialRoute: AppRouter.initialRoute,
      ),
    );
  }
}
