import '../entities/tracked_startup_entity.dart';
import '../repositories/tracked_startups_repository.dart';

class GetTrackedStartups {
  const GetTrackedStartups(this._repository);

  final TrackedStartupsRepository _repository;

  Future<List<TrackedStartupEntity>> call() {
    return _repository.getTrackedStartups();
  }
}
