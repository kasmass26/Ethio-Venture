import '../repositories/tracked_startups_repository.dart';

class IsStartupTracked {
  const IsStartupTracked(this._repository);

  final TrackedStartupsRepository _repository;

  Future<bool> call(String startupId) {
    return _repository.isTracked(startupId);
  }
}
