import 'package:ethioventure/features/matching/data/datasources/matching_remote_data_source.dart';
import 'package:ethioventure/features/matching/data/repositories/matching_repository_impl.dart';
import 'package:ethioventure/features/matching/domain/repositories/matching_repository.dart';
import 'package:ethioventure/features/matching/domain/usecases/calculate_compatibility_usecase.dart';
import 'package:ethioventure/features/matching/domain/usecases/get_recommended_startups_usecase.dart';
import 'package:ethioventure/features/matching/presentation/cubit/matching_cubit.dart';

/// Lightweight dependency injection service locator
class ServiceLocator {
  static final ServiceLocator _instance = ServiceLocator._internal();
  factory ServiceLocator() => _instance;
  ServiceLocator._internal();

  final Map<Type, dynamic> _factories = {};
  final Map<Type, dynamic> _singletons = {};

  void registerLazySingleton<T>(T Function() factory) {
    _factories[T] = factory;
  }

  void registerFactory<T>(T Function() factory) {
    _factories[T] = factory;
  }

  T get<T>() {
    if (_singletons.containsKey(T)) {
      return _singletons[T] as T;
    }
    if (_factories.containsKey(T)) {
      final instance = _factories[T]() as T;
      _singletons[T] = instance;
      return instance;
    }
    throw Exception('Type $T is not registered in ServiceLocator');
  }

  T call<T>() => get<T>();

  void reset() {
    _singletons.clear();
    _factories.clear();
  }
}

final sl = ServiceLocator();

Future<void> initServiceLocator() async {
  // 1. Scoring & Matching Engine
  sl.registerLazySingleton<CalculateCompatibilityUseCase>(
    () => const CalculateCompatibilityUseCase(),
  );

  // 2. Data Sources
  sl.registerLazySingleton<MatchingRemoteDataSource>(
    () => MatchingRemoteDataSourceImpl(),
  );

  // 3. Repositories
  sl.registerLazySingleton<MatchingRepository>(
    () => MatchingRepositoryImpl(
      remoteDataSource: sl<MatchingRemoteDataSource>(),
      compatibilityEngine: sl<CalculateCompatibilityUseCase>(),
    ),
  );

  // 4. Use Cases
  sl.registerLazySingleton<GetRecommendedStartupsUseCase>(
    () => GetRecommendedStartupsUseCase(sl<MatchingRepository>()),
  );

  // 5. Cubits / State Managers
  sl.registerFactory<MatchingCubit>(
    () => MatchingCubit(
      getRecommendationsUseCase: sl<GetRecommendedStartupsUseCase>(),
      repository: sl<MatchingRepository>(),
    ),
  );
}
