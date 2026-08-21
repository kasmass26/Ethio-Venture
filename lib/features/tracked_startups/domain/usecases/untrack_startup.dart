import '../repositories/tracked_startups_repository.dart';

class UntrackStartup {
  const UntrackStartup(this._repository);

  final TrackedStartupsRepository _repository;

  Future<void> call(String startupId) {
    return _repository.untrackStartup(startupId);
  }
}
