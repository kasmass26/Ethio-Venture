import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:ethioventure/core/network/network_info.dart';
import 'package:ethioventure/core/supabase/supabase_service.dart';
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

/// Registers shared infrastructure. Feature registrations belong beside their
/// feature and should be added here only as the feature becomes implemented.
Future<void> configureDependencies() async {
  if (sl.isRegistered<SupabaseClient>()) return;

  sl
    ..registerLazySingleton<SupabaseClient>(() => SupabaseService.client)
    ..registerLazySingleton<Connectivity>(Connectivity.new)
    ..registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()))
    // Investor Profile
    ..registerLazySingleton<InvestorProfileRemoteDataSource>(
      () => InvestorProfileRemoteDataSourceImpl(sl()),
    )
    ..registerLazySingleton<InvestorProfileRepository>(
      () => InvestorProfileRepositoryImpl(
        remoteDataSource: sl(),
        supabaseClient: sl(),
      ),
    )
    ..registerLazySingleton(() => GetInvestorProfile(sl()))
    ..registerLazySingleton(() => CreateInvestorProfile(sl()))
    ..registerLazySingleton(() => UpdateInvestorProfile(sl()))
    ..registerLazySingleton(() => DeleteInvestorProfile(sl()))
    ..registerFactory(
      () => InvestorProfileCubit(
        getInvestorProfile: sl(),
        createInvestorProfile: sl(),
        updateInvestorProfile: sl(),
        deleteInvestorProfile: sl(),
      ),
    );
}
