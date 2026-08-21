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
import 'package:ethioventure/features/investor_profile/domain/usecases/get_approved_investors_usecase.dart';
import 'package:ethioventure/features/investor_profile/domain/usecases/get_investor_profile.dart';
import 'package:ethioventure/features/investor_profile/domain/usecases/update_investor_profile.dart';
import 'package:ethioventure/features/investor_profile/presentation/cubit/investor_profile_cubit.dart';
import 'package:ethioventure/features/founder/presentation/cubit/recommended_investors_cubit.dart';
import 'package:ethioventure/features/founder/presentation/cubit/founder_metrics_cubit.dart';
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
import 'package:ethioventure/features/matching/data/datasources/matching_remote_data_source.dart';
import 'package:ethioventure/features/matching/data/repositories/matching_repository_impl.dart';
import 'package:ethioventure/features/matching/domain/repositories/matching_repository.dart';
import 'package:ethioventure/features/matching/domain/services/match_scoring_service.dart';
import 'package:ethioventure/features/matching/presentation/cubit/recommendations_cubit.dart';
import 'package:ethioventure/features/messaging/data/datasources/messaging_remote_data_source.dart';
import 'package:ethioventure/features/messaging/data/repositories/messaging_repository_impl.dart';
import 'package:ethioventure/features/messaging/domain/repositories/messaging_repository.dart';
import 'package:ethioventure/features/messaging/presentation/cubit/chat_cubit.dart';
import 'package:ethioventure/features/messaging/presentation/cubit/conversations_cubit.dart';

import 'package:ethioventure/features/notifications/data/datasources/notification_remote_data_source.dart';
import 'package:ethioventure/features/notifications/data/repositories/notification_repository_impl.dart';
import 'package:ethioventure/features/notifications/domain/repositories/notification_repository.dart';
import 'package:ethioventure/features/notifications/presentation/cubit/notifications_cubit.dart';

import 'package:ethioventure/features/connection_requests/data/datasources/connection_request_remote_data_source.dart';
import 'package:ethioventure/features/connection_requests/data/repositories/connection_request_repository_impl.dart';
import 'package:ethioventure/features/connection_requests/domain/repositories/connection_request_repository.dart';
import 'package:ethioventure/features/connection_requests/presentation/cubit/connection_request_cubit.dart';

import 'package:ethioventure/features/tracked_startups/data/datasources/tracked_startups_remote_data_source.dart';
import 'package:ethioventure/features/tracked_startups/data/repositories/tracked_startups_repository_impl.dart';
import 'package:ethioventure/features/tracked_startups/domain/repositories/tracked_startups_repository.dart';
import 'package:ethioventure/features/tracked_startups/domain/usecases/get_tracked_startups.dart';
import 'package:ethioventure/features/tracked_startups/domain/usecases/track_startup.dart';
import 'package:ethioventure/features/tracked_startups/domain/usecases/untrack_startup.dart';
import 'package:ethioventure/features/tracked_startups/domain/usecases/is_startup_tracked.dart';
import 'package:ethioventure/features/tracked_startups/presentation/cubit/tracked_startups_cubit.dart';

import 'package:ethioventure/core/services/user_service.dart';

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
  SupabaseClient? client = supabaseClient;
  if (client == null) {
    try {
      client = Supabase.instance.client;
    } catch (_) {
      client = null;
    }
  }

  if (client != null && !sl.isRegistered<SupabaseClient>()) {
    sl.registerSingleton<SupabaseClient>(client);
  }

  // Shared infrastructure
  if (!sl.isRegistered<Connectivity>()) {
    sl.registerLazySingleton<Connectivity>(Connectivity.new);
  }

  if (!sl.isRegistered<NetworkInfo>()) {
    sl.registerLazySingleton<NetworkInfo>(
      () => NetworkInfoImpl(sl<Connectivity>()),
    );
  }

  if (!sl.isRegistered<SupabaseClient>()) {
    return;
  }

  // ---------------------------------------------------------------------------
  // Core Services
  // ---------------------------------------------------------------------------
  if (!sl.isRegistered<UserService>()) {
    sl.registerLazySingleton<UserService>(
      () => UserService(sl<SupabaseClient>()),
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

  if (!sl.isRegistered<GetApprovedInvestorsUseCase>()) {
    sl.registerLazySingleton<GetApprovedInvestorsUseCase>(
      () => GetApprovedInvestorsUseCase(sl<InvestorProfileRepository>()),
    );
  }

  if (!sl.isRegistered<RecommendedInvestorsCubit>()) {
    sl.registerFactory<RecommendedInvestorsCubit>(
      () => RecommendedInvestorsCubit(
        getApprovedInvestorsUseCase: sl<GetApprovedInvestorsUseCase>(),
      ),
    );
  }

  if (!sl.isRegistered<FounderMetricsCubit>()) {
    sl.registerFactory<FounderMetricsCubit>(
      () => FounderMetricsCubit(
        supabaseClient: sl<SupabaseClient>(),
      ),
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

  // ---------------------------------------------------------------------------
  // Messaging Feature
  // ---------------------------------------------------------------------------
  if (!sl.isRegistered<MessagingRemoteDataSource>()) {
    sl.registerLazySingleton<MessagingRemoteDataSource>(
      () => MessagingRemoteDataSource(
        supabaseClient: sl<SupabaseClient>(),
      ),
    );
  }

  if (!sl.isRegistered<MessagingRepository>()) {
    sl.registerLazySingleton<MessagingRepository>(
      () => MessagingRepositoryImpl(
        remoteDataSource: sl<MessagingRemoteDataSource>(),
      ),
    );
  }

  if (!sl.isRegistered<ConversationsCubit>()) {
    sl.registerFactory<ConversationsCubit>(
      () => ConversationsCubit(
        repository: sl<MessagingRepository>(),
      ),
    );
  }

  if (!sl.isRegistered<ChatCubit>()) {
    sl.registerFactory<ChatCubit>(
      () => ChatCubit(
        repository: sl<MessagingRepository>(),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Matching / Recommendations Feature
  // ---------------------------------------------------------------------------
  if (!sl.isRegistered<MatchScoringService>()) {
    sl.registerLazySingleton<MatchScoringService>(
      () => const MatchScoringService(),
    );
  }

  if (!sl.isRegistered<MatchingRemoteDataSource>()) {
    sl.registerLazySingleton<MatchingRemoteDataSource>(
      () => MatchingRemoteDataSource(
        supabaseClient: sl<SupabaseClient>(),
      ),
    );
  }

  if (!sl.isRegistered<MatchingRepository>()) {
    sl.registerLazySingleton<MatchingRepository>(
      () => MatchingRepositoryImpl(
        remoteDataSource: sl<MatchingRemoteDataSource>(),
        scoringService: sl<MatchScoringService>(),
      ),
    );
  }

  if (!sl.isRegistered<RecommendationsCubit>()) {
    sl.registerFactory<RecommendationsCubit>(
      () => RecommendationsCubit(
        repository: sl<MatchingRepository>(),
        messagingRepository: sl<MessagingRepository>(),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Notifications Feature
  // ---------------------------------------------------------------------------
  if (!sl.isRegistered<NotificationRemoteDataSource>()) {
    sl.registerLazySingleton<NotificationRemoteDataSource>(
      () => NotificationRemoteDataSource(
        supabaseClient: sl<SupabaseClient>(),
      ),
    );
  }

  if (!sl.isRegistered<NotificationRepository>()) {
    sl.registerLazySingleton<NotificationRepository>(
      () => NotificationRepositoryImpl(
        remoteDataSource: sl<NotificationRemoteDataSource>(),
      ),
    );
  }

  if (!sl.isRegistered<NotificationsCubit>()) {
    sl.registerFactory<NotificationsCubit>(
      () => NotificationsCubit(
        repository: sl<NotificationRepository>(),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Connection Requests Feature
  // ---------------------------------------------------------------------------
  if (!sl.isRegistered<ConnectionRequestRemoteDataSource>()) {
    sl.registerLazySingleton<ConnectionRequestRemoteDataSource>(
      () => ConnectionRequestRemoteDataSource(
        supabaseClient: sl<SupabaseClient>(),
      ),
    );
  }

  if (!sl.isRegistered<ConnectionRequestRepository>()) {
    sl.registerLazySingleton<ConnectionRequestRepository>(
      () => ConnectionRequestRepositoryImpl(
        remoteDataSource: sl<ConnectionRequestRemoteDataSource>(),
      ),
    );
  }

  if (!sl.isRegistered<ConnectionRequestCubit>()) {
    sl.registerFactory<ConnectionRequestCubit>(
      () => ConnectionRequestCubit(
        repository: sl<ConnectionRequestRepository>(),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Tracked Startups Feature
  // ---------------------------------------------------------------------------
  if (!sl.isRegistered<TrackedStartupsRemoteDataSource>()) {
    sl.registerLazySingleton<TrackedStartupsRemoteDataSource>(
      () => TrackedStartupsRemoteDataSourceImpl(
        supabaseClient: sl<SupabaseClient>(),
      ),
    );
  }

  if (!sl.isRegistered<TrackedStartupsRepository>()) {
    sl.registerLazySingleton<TrackedStartupsRepository>(
      () => TrackedStartupsRepositoryImpl(
        remoteDataSource: sl<TrackedStartupsRemoteDataSource>(),
      ),
    );
  }

  if (!sl.isRegistered<GetTrackedStartups>()) {
    sl.registerLazySingleton<GetTrackedStartups>(
      () => GetTrackedStartups(sl<TrackedStartupsRepository>()),
    );
  }

  if (!sl.isRegistered<TrackStartup>()) {
    sl.registerLazySingleton<TrackStartup>(
      () => TrackStartup(sl<TrackedStartupsRepository>()),
    );
  }

  if (!sl.isRegistered<UntrackStartup>()) {
    sl.registerLazySingleton<UntrackStartup>(
      () => UntrackStartup(sl<TrackedStartupsRepository>()),
    );
  }

  if (!sl.isRegistered<IsStartupTracked>()) {
    sl.registerLazySingleton<IsStartupTracked>(
      () => IsStartupTracked(sl<TrackedStartupsRepository>()),
    );
  }

  if (!sl.isRegistered<TrackedStartupsCubit>()) {
    sl.registerFactory<TrackedStartupsCubit>(
      () => TrackedStartupsCubit(
        getTrackedStartups: sl<GetTrackedStartups>(),
        trackStartup: sl<TrackStartup>(),
        untrackStartup: sl<UntrackStartup>(),
      ),
    );
  }
}

