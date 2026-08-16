import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../constants/app_constants.dart';

// Features - Matching (Search & Recommendations)
import '../../features/matching/data/datasources/matching_remote_data_source.dart';
import '../../features/matching/data/repositories/matching_repository_impl.dart';
import '../../features/matching/domain/repositories/matching_repository.dart';
import '../../features/matching/domain/usecases/get_recommendations_usecase.dart';
import '../../features/matching/domain/usecases/search_startups_usecase.dart';
import '../../features/matching/presentation/cubit/recommendations_cubit.dart';
import '../../features/matching/presentation/cubit/startup_search_cubit.dart';

// Features - Startup Profile & Document Uploads (Issues 5 & 6)
import '../../features/startup_profile/data/datasources/startup_profile_remote_data_source.dart';
import '../../features/startup_profile/data/repositories/startup_profile_repository_impl.dart';
import '../../features/startup_profile/domain/repositories/startup_profile_repository.dart';
import '../../features/startup_profile/domain/usecases/create_startup_profile_usecase.dart';
import '../../features/startup_profile/domain/usecases/delete_document_usecase.dart';
import '../../features/startup_profile/domain/usecases/get_startup_profile_usecase.dart';
import '../../features/startup_profile/domain/usecases/update_startup_profile_usecase.dart';
import '../../features/startup_profile/domain/usecases/upload_document_usecase.dart';
import '../../features/startup_profile/presentation/cubit/document_upload_cubit.dart';
import '../../features/startup_profile/presentation/cubit/startup_profile_cubit.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // ==================== External Dependencies ====================
  // Supabase Client registration (or fallback if uninitialized in unit tests)
  sl.registerLazySingleton<SupabaseClient>(() {
    try {
      return Supabase.instance.client;
    } catch (_) {
      return SupabaseClient(
        AppConstants.supabaseUrl,
        AppConstants.supabaseAnonKey,
      );
    }
  });

  // ==================== Feature: Matching ====================
  sl.registerFactory<StartupSearchCubit>(
    () => StartupSearchCubit(searchStartupsUseCase: sl()),
  );
  sl.registerFactory<RecommendationsCubit>(
    () => RecommendationsCubit(getRecommendationsUseCase: sl()),
  );

  sl.registerLazySingleton<SearchStartupsUseCase>(
    () => SearchStartupsUseCase(sl()),
  );
  sl.registerLazySingleton<GetRecommendationsUseCase>(
    () => GetRecommendationsUseCase(sl()),
  );

  sl.registerLazySingleton<MatchingRepository>(
    () => MatchingRepositoryImpl(remoteDataSource: sl()),
  );

  sl.registerLazySingleton<MatchingRemoteDataSource>(
    () => MatchingRemoteDataSourceImpl(),
  );

  // ==================== Feature: Startup Profile & Document Uploads ====================
  sl.registerFactory<StartupProfileCubit>(
    () => StartupProfileCubit(
      createStartupProfileUseCase: sl(),
      getStartupProfileUseCase: sl(),
      updateStartupProfileUseCase: sl(),
      deleteDocumentUseCase: sl(),
    ),
  );
  sl.registerFactory<DocumentUploadCubit>(
    () => DocumentUploadCubit(uploadDocumentUseCase: sl()),
  );

  sl.registerLazySingleton<CreateStartupProfileUseCase>(
    () => CreateStartupProfileUseCase(sl()),
  );
  sl.registerLazySingleton<GetStartupProfileUseCase>(
    () => GetStartupProfileUseCase(sl()),
  );
  sl.registerLazySingleton<UpdateStartupProfileUseCase>(
    () => UpdateStartupProfileUseCase(sl()),
  );
  sl.registerLazySingleton<UploadDocumentUseCase>(
    () => UploadDocumentUseCase(sl()),
  );
  sl.registerLazySingleton<DeleteDocumentUseCase>(
    () => DeleteDocumentUseCase(sl()),
  );

  sl.registerLazySingleton<StartupProfileRepository>(
    () => StartupProfileRepositoryImpl(remoteDataSource: sl()),
  );

  sl.registerLazySingleton<StartupProfileRemoteDataSource>(
    () => StartupProfileRemoteDataSourceImpl(supabaseClient: sl()),
  );
}
