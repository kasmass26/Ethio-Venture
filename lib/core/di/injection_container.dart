import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:ethioventure/core/network/network_info.dart';
import 'package:ethioventure/core/supabase/supabase_service.dart';
import 'package:ethioventure/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:ethioventure/features/auth/data/datasources/auth_remote_data_source_impl.dart';
import 'package:ethioventure/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:ethioventure/features/auth/domain/repositories/auth_repository.dart';
import 'package:ethioventure/features/auth/domain/usecases/login_usecase.dart';
import 'package:ethioventure/features/auth/domain/usecases/logout_user.dart';
import 'package:ethioventure/features/auth/domain/usecases/register_usecase.dart';
import 'package:ethioventure/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final GetIt sl = GetIt.instance;

/// Registers shared infrastructure and feature dependencies.
Future<void> configureDependencies() async {
  if (!sl.isRegistered<SupabaseClient>()) {
    sl.registerLazySingleton<SupabaseClient>(
      () => SupabaseService.client,
    );
  }

  if (!sl.isRegistered<Connectivity>()) {
    sl.registerLazySingleton<Connectivity>(
      Connectivity.new,
    );
  }

  if (!sl.isRegistered<NetworkInfo>()) {
    sl.registerLazySingleton<NetworkInfo>(
      () => NetworkInfoImpl(sl<Connectivity>()),
    );
  }

  if (!sl.isRegistered<AuthRemoteDataSource>()) {
    sl.registerLazySingleton<AuthRemoteDataSource>(
      () => AuthRemoteDataSourceImpl(
        supabaseClient: sl<SupabaseClient>(),
      ),
    );
  }

  if (!sl.isRegistered<AuthRepository>()) {
    sl.registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(
        remoteDataSource: sl<AuthRemoteDataSource>(),
      ),
    );
  }

  if (!sl.isRegistered<RegisterUser>()) {
    sl.registerLazySingleton<RegisterUser>(
      () => RegisterUser(sl<AuthRepository>()),
    );
  }

  if (!sl.isRegistered<LoginUser>()) {
    sl.registerLazySingleton<LoginUser>(
      () => LoginUser(sl<AuthRepository>()),
    );
  }

  if (!sl.isRegistered<LogoutUser>()) {
    sl.registerLazySingleton<LogoutUser>(
      () => LogoutUser(sl<AuthRepository>()),
    );
  }

  if (!sl.isRegistered<AuthCubit>()) {
    sl.registerFactory<AuthCubit>(
      () => AuthCubit(
        loginUser: sl<LoginUser>(),
        registerUser: sl<RegisterUser>(),
        logoutUser: sl<LogoutUser>(),
      ),
    );
  }
}