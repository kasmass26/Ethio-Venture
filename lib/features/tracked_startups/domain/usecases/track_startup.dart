import '../entities/tracked_startup_entity.dart';
import '../repositories/tracked_startups_repository.dart';

class TrackStartup {
  const TrackStartup(this._repository);

  final TrackedStartupsRepository _repository;

  Future<TrackedStartupEntity> call(String startupId) {
    return _repository.trackStartup(startupId);
  }
}
