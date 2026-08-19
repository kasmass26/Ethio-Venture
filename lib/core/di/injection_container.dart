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

import 'package:ethioventure/features/admin/data/datasources/admin_remote_data_source.dart';
import 'package:ethioventure/features/admin/data/datasources/admin_remote_data_source_impl.dart';
import 'package:ethioventure/features/admin/data/repositories/admin_repository_impl.dart';
import 'package:ethioventure/features/admin/domain/repositories/admin_repository.dart';
import 'package:ethioventure/features/admin/domain/usecases/approve_profile.dart';
import 'package:ethioventure/features/admin/domain/usecases/get_approved_investors.dart';
import 'package:ethioventure/features/admin/domain/usecases/get_approved_startups.dart';
import 'package:ethioventure/features/admin/domain/usecases/get_pending_investors.dart';
import 'package:ethioventure/features/admin/domain/usecases/get_pending_startups.dart';
import 'package:ethioventure/features/admin/domain/usecases/get_rejected_profiles.dart';
import 'package:ethioventure/features/admin/domain/usecases/reject_profile.dart';
import 'package:ethioventure/features/admin/presentation/cubit/admin_cubit.dart';

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

  // ---------------------------------------------------------------------------
  // Admin Feature
  // ---------------------------------------------------------------------------
  if (!sl.isRegistered<AdminRemoteDataSource>()) {
    sl.registerLazySingleton<AdminRemoteDataSource>(
      () => AdminRemoteDataSourceImpl(sl<SupabaseClient>()),
    );
  }

  if (!sl.isRegistered<AdminRepository>()) {
    sl.registerLazySingleton<AdminRepository>(
      () => AdminRepositoryImpl(sl<AdminRemoteDataSource>()),
    );
  }

  if (!sl.isRegistered<GetPendingStartups>()) {
    sl.registerLazySingleton<GetPendingStartups>(
      () => GetPendingStartups(sl<AdminRepository>()),
    );
  }

  if (!sl.isRegistered<GetPendingInvestors>()) {
    sl.registerLazySingleton<GetPendingInvestors>(
      () => GetPendingInvestors(sl<AdminRepository>()),
    );
  }

  if (!sl.isRegistered<GetApprovedStartups>()) {
    sl.registerLazySingleton<GetApprovedStartups>(
      () => GetApprovedStartups(sl<AdminRepository>()),
    );
  }

  if (!sl.isRegistered<GetApprovedInvestors>()) {
    sl.registerLazySingleton<GetApprovedInvestors>(
      () => GetApprovedInvestors(sl<AdminRepository>()),
    );
  }

  if (!sl.isRegistered<GetRejectedProfiles>()) {
    sl.registerLazySingleton<GetRejectedProfiles>(
      () => GetRejectedProfiles(sl<AdminRepository>()),
    );
  }

  if (!sl.isRegistered<ApproveProfile>()) {
    sl.registerLazySingleton<ApproveProfile>(
      () => ApproveProfile(sl<AdminRepository>()),
    );
  }

  if (!sl.isRegistered<RejectProfile>()) {
    sl.registerLazySingleton<RejectProfile>(
      () => RejectProfile(sl<AdminRepository>()),
    );
  }

  if (!sl.isRegistered<AdminCubit>()) {
    sl.registerFactory<AdminCubit>(
      () => AdminCubit(
        getPendingStartups: sl<GetPendingStartups>(),
        getPendingInvestors: sl<GetPendingInvestors>(),
        getApprovedStartups: sl<GetApprovedStartups>(),
        getApprovedInvestors: sl<GetApprovedInvestors>(),
        getRejectedProfiles: sl<GetRejectedProfiles>(),
        approveProfile: sl<ApproveProfile>(),
        rejectProfile: sl<RejectProfile>(),
      ),
    );
  }
}
