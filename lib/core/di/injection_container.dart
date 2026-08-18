import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:ethioventure/core/network/network_info.dart';
import 'package:ethioventure/core/supabase/supabase_service.dart';
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
    ..registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));
}
