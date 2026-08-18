import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../network/network_info.dart';
import '../supabase/supabase_service.dart';
import '../../features/startup_profile/data/datasources/startup_profile_remote_data_source.dart';
import '../../features/startup_profile/data/repositories/startup_profile_repository_impl.dart';
import '../../features/startup_profile/domain/repositories/startup_profile_repository.dart';
import '../../features/startup_profile/domain/usecases/create_startup_profile.dart';
import '../../features/startup_profile/domain/usecases/get_startup_profile.dart';
import '../../features/startup_profile/domain/usecases/update_startup_profile.dart';
import '../../features/startup_profile/presentation/cubit/startup_profile_cubit.dart';

final GetIt sl = GetIt.instance;

/// Registers shared infrastructure and feature dependencies.
Future<void> configureDependencies() async {
  if (sl.isRegistered<SupabaseClient>()) return;

  // Infrastructure
  sl
    ..registerLazySingleton<SupabaseClient>(() => SupabaseService.client)
    ..registerLazySingleton<Connectivity>(Connectivity.new)
    ..registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));

  // ---------------------------------------------------------------------------
  // Startup Profile Feature
  // ---------------------------------------------------------------------------

  // Data Sources
  sl.registerLazySingleton<StartupProfileRemoteDataSource>(
    () => StartupProfileRemoteDataSourceImpl(sl<SupabaseClient>()),
  );

  // Repositories
  sl.registerLazySingleton<StartupProfileRepository>(
    () => StartupProfileRepositoryImpl(sl<StartupProfileRemoteDataSource>()),
  );

  // Use Cases
  sl.registerLazySingleton<CreateStartupProfileUseCase>(
    () => CreateStartupProfileUseCase(sl<StartupProfileRepository>()),
  );
  sl.registerLazySingleton<GetStartupProfileUseCase>(
    () => GetStartupProfileUseCase(sl<StartupProfileRepository>()),
  );
  sl.registerLazySingleton<UpdateStartupProfileUseCase>(
    () => UpdateStartupProfileUseCase(sl<StartupProfileRepository>()),
  );

  // Cubit
  sl.registerFactory<StartupProfileCubit>(
    () => StartupProfileCubit(
      createStartupProfileUseCase: sl<CreateStartupProfileUseCase>(),
      getStartupProfileUseCase: sl<GetStartupProfileUseCase>(),
      updateStartupProfileUseCase: sl<UpdateStartupProfileUseCase>(),
    ),
  );
}
