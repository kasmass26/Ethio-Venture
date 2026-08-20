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
import 'package:ethioventure/features/startup_profile/data/datasources/startup_remote_data_source.dart';
import 'package:ethioventure/features/startup_profile/data/repositories/startup_repository_impl.dart';
import 'package:ethioventure/features/startup_profile/domain/repositories/startup_repository.dart';
import 'package:ethioventure/features/startup_profile/domain/usecases/get_startup_by_id.dart';
import 'package:ethioventure/features/startup_profile/domain/usecases/search_startups.dart';
import 'package:ethioventure/features/startup_profile/presentation/cubit/startup_search_cubit.dart';

import 'package:ethioventure/features/pitch_deck/data/datasources/document_remote_data_source.dart';
import 'package:ethioventure/features/pitch_deck/data/repositories/document_repository_impl.dart';
import 'package:ethioventure/features/pitch_deck/domain/repositories/document_repository.dart';
import 'package:ethioventure/features/pitch_deck/domain/usecases/delete_document_use_case.dart';
import 'package:ethioventure/features/pitch_deck/domain/usecases/get_startup_documents_use_case.dart';
import 'package:ethioventure/features/pitch_deck/domain/usecases/toggle_document_visibility_use_case.dart';
import 'package:ethioventure/features/pitch_deck/domain/usecases/upload_document_use_case.dart';
import 'package:ethioventure/features/pitch_deck/presentation/cubit/document_cubit.dart';

import 'package:ethioventure/features/startup_profile/data/datasources/startup_profile_remote_data_source.dart';
import 'package:ethioventure/features/startup_profile/data/repositories/startup_profile_repository_impl.dart';
import 'package:ethioventure/features/startup_profile/domain/repositories/startup_profile_repository.dart';
import 'package:ethioventure/features/startup_profile/domain/usecases/create_startup_profile.dart';
import 'package:ethioventure/features/startup_profile/domain/usecases/get_startup_profile.dart';
import 'package:ethioventure/features/startup_profile/domain/usecases/update_startup_profile.dart';
import 'package:ethioventure/features/startup_profile/presentation/cubit/startup_profile_cubit.dart';

import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final GetIt sl = GetIt.instance;

/// Registers shared infrastructure and feature dependencies.
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

  // ---------------------------------------------------------------------------
  // Auth Feature
  // ---------------------------------------------------------------------------
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

  // ── Startup Discovery Feature (Issue #8) ─────────────────────────────────

  if (!sl.isRegistered<StartupRemoteDataSource>()) {
    sl.registerLazySingleton<StartupRemoteDataSource>(
      () => StartupRemoteDataSourceImpl(sl<SupabaseClient>()),
    );
  }

  if (!sl.isRegistered<StartupRepository>()) {
    sl.registerLazySingleton<StartupRepository>(
      () => StartupRepositoryImpl(
        remoteDataSource: sl<StartupRemoteDataSource>(),
      ),
    );
  }

  if (!sl.isRegistered<SearchStartups>()) {
    sl.registerLazySingleton<SearchStartups>(
      () => SearchStartups(sl<StartupRepository>()),
    );
  }

  if (!sl.isRegistered<GetStartupById>()) {
    sl.registerLazySingleton<GetStartupById>(
      () => GetStartupById(sl<StartupRepository>()),
    );
  }

  if (!sl.isRegistered<StartupSearchCubit>()) {
    sl.registerFactory<StartupSearchCubit>(
      () => StartupSearchCubit(searchStartups: sl<SearchStartups>()),
    );
  }

  // ---------------------------------------------------------------------------
  // Pitch Deck & Document Feature
  // ---------------------------------------------------------------------------
  if (!sl.isRegistered<DocumentRemoteDataSource>()) {
    sl.registerLazySingleton<DocumentRemoteDataSource>(
      () => DocumentRemoteDataSourceImpl(sl<SupabaseClient>()),
    );
  }

  if (!sl.isRegistered<DocumentRepository>()) {
    sl.registerLazySingleton<DocumentRepository>(
      () => DocumentRepositoryImpl(sl<DocumentRemoteDataSource>()),
    );
  }

  if (!sl.isRegistered<UploadDocumentUseCase>()) {
    sl.registerLazySingleton<UploadDocumentUseCase>(
      () => UploadDocumentUseCase(sl<DocumentRepository>()),
    );
  }

  if (!sl.isRegistered<GetStartupDocumentsUseCase>()) {
    sl.registerLazySingleton<GetStartupDocumentsUseCase>(
      () => GetStartupDocumentsUseCase(sl<DocumentRepository>()),
    );
  }

  if (!sl.isRegistered<DeleteDocumentUseCase>()) {
    sl.registerLazySingleton<DeleteDocumentUseCase>(
      () => DeleteDocumentUseCase(sl<DocumentRepository>()),
    );
  }

  if (!sl.isRegistered<ToggleDocumentVisibilityUseCase>()) {
    sl.registerLazySingleton<ToggleDocumentVisibilityUseCase>(
      () => ToggleDocumentVisibilityUseCase(sl<DocumentRepository>()),
    );
  }

  if (!sl.isRegistered<DocumentCubit>()) {
    sl.registerFactory<DocumentCubit>(
      () => DocumentCubit(
        uploadDocumentUseCase: sl<UploadDocumentUseCase>(),
        getStartupDocumentsUseCase: sl<GetStartupDocumentsUseCase>(),
        deleteDocumentUseCase: sl<DeleteDocumentUseCase>(),
        toggleDocumentVisibilityUseCase: sl<ToggleDocumentVisibilityUseCase>(),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Startup Profile Feature
  // ---------------------------------------------------------------------------
  if (!sl.isRegistered<StartupProfileRemoteDataSource>()) {
    sl.registerLazySingleton<StartupProfileRemoteDataSource>(
      () => StartupProfileRemoteDataSourceImpl(sl<SupabaseClient>()),
    );
  }

  if (!sl.isRegistered<StartupProfileRepository>()) {
    sl.registerLazySingleton<StartupProfileRepository>(
      () => StartupProfileRepositoryImpl(sl<StartupProfileRemoteDataSource>()),
    );
  }

  if (!sl.isRegistered<CreateStartupProfileUseCase>()) {
    sl.registerLazySingleton<CreateStartupProfileUseCase>(
      () => CreateStartupProfileUseCase(sl<StartupProfileRepository>()),
    );
  }

  if (!sl.isRegistered<GetStartupProfileUseCase>()) {
    sl.registerLazySingleton<GetStartupProfileUseCase>(
      () => GetStartupProfileUseCase(sl<StartupProfileRepository>()),
    );
  }

  if (!sl.isRegistered<UpdateStartupProfileUseCase>()) {
    sl.registerLazySingleton<UpdateStartupProfileUseCase>(
      () => UpdateStartupProfileUseCase(sl<StartupProfileRepository>()),
    );
  }

  if (!sl.isRegistered<StartupProfileCubit>()) {
    sl.registerFactory<StartupProfileCubit>(
      () => StartupProfileCubit(
        createStartupProfileUseCase: sl<CreateStartupProfileUseCase>(),
        getStartupProfileUseCase: sl<GetStartupProfileUseCase>(),
        updateStartupProfileUseCase: sl<UpdateStartupProfileUseCase>(),
      ),
    );
  }
}
