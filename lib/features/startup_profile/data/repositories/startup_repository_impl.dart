import 'package:ethioventure/features/startup_profile/data/datasources/startup_remote_data_source.dart';
import 'package:ethioventure/features/startup_profile/domain/entities/startup_filter.dart';
import 'package:ethioventure/features/startup_profile/domain/entities/startup_profile_entity.dart';
import 'package:ethioventure/features/startup_profile/domain/repositories/startup_repository.dart';

/// Bridges the domain [StartupRepository] contract to the Supabase-backed
/// [StartupRemoteDataSource].
///
/// Responsibilities:
///  - Delegates all query construction to the data source.
///  - Returns domain entities ([StartupProfileEntity] / subclass) to callers.
///  - Lets [ServerException]s propagate unchanged; the cubit layer handles
///    them and emits appropriate error states.
///
/// Note: [StartupProfileModel] extends [StartupProfileEntity], so returning
/// models directly satisfies the return types without extra conversion
/// (same pattern as [InvestorProfileRepositoryImpl]).
class StartupRepositoryImpl implements StartupRepository {
  const StartupRepositoryImpl({
    required StartupRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  final StartupRemoteDataSource _remoteDataSource;

  @override
  Future<List<StartupProfileEntity>> searchStartups(
    StartupFilter filter,
  ) {
    // Delegate directly — the data source builds and executes the query.
    // Exceptions (ServerException) bubble to the cubit.
    return _remoteDataSource.searchStartups(filter);
  }

  @override
  Future<StartupProfileEntity?> getStartupById(String id) {
    return _remoteDataSource.getStartupById(id);
  }
}
