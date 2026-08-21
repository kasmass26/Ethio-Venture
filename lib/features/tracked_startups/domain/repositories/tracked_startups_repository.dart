import '../entities/tracked_startup_entity.dart';

abstract class TrackedStartupsRepository {
  Future<List<TrackedStartupEntity>> getTrackedStartups();
  Future<TrackedStartupEntity> trackStartup(String startupId);
  Future<void> untrackStartup(String startupId);
  Future<bool> isTracked(String startupId);
}
