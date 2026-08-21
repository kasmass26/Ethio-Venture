import '../../domain/entities/tracked_startup_entity.dart';
import '../../domain/repositories/tracked_startups_repository.dart';
import '../datasources/tracked_startups_remote_data_source.dart';

class TrackedStartupsRepositoryImpl implements TrackedStartupsRepository {
  TrackedStartupsRepositoryImpl({
    required TrackedStartupsRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  final TrackedStartupsRemoteDataSource _remoteDataSource;

  @override
  Future<List<TrackedStartupEntity>> getTrackedStartups() {
    return _remoteDataSource.getTrackedStartups();
  }

  @override
  Future<TrackedStartupEntity> trackStartup(String startupId) {
    return _remoteDataSource.trackStartup(startupId);
  }

  @override
  Future<void> untrackStartup(String startupId) {
    return _remoteDataSource.untrackStartup(startupId);
  }

  @override
  Future<bool> isTracked(String startupId) {
    return _remoteDataSource.isTracked(startupId);
  }
}
