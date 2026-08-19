import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:ethioventure/core/network/network_info.dart';
import 'package:ethioventure/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:ethioventure/features/auth/data/datasources/auth_remote_data_source_impl.dart';
import 'package:ethioventure/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:ethioventure/features/auth/domain/repositories/auth_repository.dart';
import 'package:ethioventure/features/auth/domain/usecases/login_usecase.dart';
import 'package:ethioventure/features/auth/domain/usecases/logout_user.dart';
import 'package:ethioventure/features/auth/domain/usecases/register_usecase.dart';
import 'package:ethioventure/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:ethioventure/features/investor_profile/data/datasources/investor_profile_remote_data_source.dart';
import 'package:ethioventure/features/investor_profile/data/repositories/investor_profile_repository_impl.dart';
import 'package:ethioventure/features/investor_profile/domain/repositories/investor_profile_repository.dart';
import 'package:ethioventure/features/investor_profile/domain/usecases/create_investor_profile.dart';
import 'package:ethioventure/features/investor_profile/domain/usecases/delete_investor_profile.dart';
import 'package:ethioventure/features/investor_profile/domain/usecases/get_investor_profile.dart';
import 'package:ethioventure/features/investor_profile/domain/usecases/update_investor_profile.dart';
import 'package:ethioventure/features/investor_profile/presentation/cubit/investor_profile_cubit.dart';
import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final GetIt sl = GetIt.instance;

/// Registers shared infrastructure and feature dependencies.
///
/// [supabaseClient] must be the already-initialised [SupabaseClient] returned
/// by [Supabase.instance.client] after a successful [Supabase.initialize]
/// call. When it is null (Supabase failed to initialise) the Supabase-dependent
/// registrations are skipped — the app will show the config-error screen
/// instead of crashing inside a cubit.
Future<void> configureDependencies({SupabaseClient? supabaseClient}) async {
  // Shared infrastructure
  if (!sl.isRegistered<Connectivity>()) {
    sl.registerLazySingleton<Connectivity>(Connectivity.new);
  }

  if (!sl.isRegistered<NetworkInfo>()) {
    sl.registerLazySingleton<NetworkInfo>(
      () => NetworkInfoImpl(sl<Connectivity>()),
    );
  }

  // All Supabase-dependent registrations require a live client.
  if (supabaseClient == null) return;

  if (!sl.isRegistered<SupabaseClient>()) {
    sl.registerSingleton<SupabaseClient>(supabaseClient);
  }

  // ── Auth Feature ─────────────────────────────────────────────────────────

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

  // ── Investor Profile Feature ──────────────────────────────────────────────

  if (!sl.isRegistered<InvestorProfileRemoteDataSource>()) {
    sl.registerLazySingleton<InvestorProfileRemoteDataSource>(
      () => InvestorProfileRemoteDataSourceImpl(sl<SupabaseClient>()),
    );
  }

  if (!sl.isRegistered<InvestorProfileRepository>()) {
    sl.registerLazySingleton<InvestorProfileRepository>(
      () => InvestorProfileRepositoryImpl(
        remoteDataSource: sl<InvestorProfileRemoteDataSource>(),
        supabaseClient: sl<SupabaseClient>(),
      ),
    );
  }

  if (!sl.isRegistered<GetInvestorProfile>()) {
    sl.registerLazySingleton<GetInvestorProfile>(
      () => GetInvestorProfile(sl<InvestorProfileRepository>()),
    );
  }

  if (!sl.isRegistered<CreateInvestorProfile>()) {
    sl.registerLazySingleton<CreateInvestorProfile>(
      () => CreateInvestorProfile(sl<InvestorProfileRepository>()),
    );
  }

  if (!sl.isRegistered<UpdateInvestorProfile>()) {
    sl.registerLazySingleton<UpdateInvestorProfile>(
      () => UpdateInvestorProfile(sl<InvestorProfileRepository>()),
    );
  }

  if (!sl.isRegistered<DeleteInvestorProfile>()) {
    sl.registerLazySingleton<DeleteInvestorProfile>(
      () => DeleteInvestorProfile(sl<InvestorProfileRepository>()),
    );
  }

  if (!sl.isRegistered<InvestorProfileCubit>()) {
    sl.registerFactory<InvestorProfileCubit>(
      () => InvestorProfileCubit(
        getInvestorProfile: sl<GetInvestorProfile>(),
        createInvestorProfile: sl<CreateInvestorProfile>(),
        updateInvestorProfile: sl<UpdateInvestorProfile>(),
        deleteInvestorProfile: sl<DeleteInvestorProfile>(),
      ),
    );
  }
}
