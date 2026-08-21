import 'package:flutter/foundation.dart';
import '../../domain/entities/tracked_startup_entity.dart';

@immutable
sealed class TrackedStartupsState {
  const TrackedStartupsState();
}

class TrackedStartupsInitial extends TrackedStartupsState {
  const TrackedStartupsInitial();
}

class TrackedStartupsLoading extends TrackedStartupsState {
  const TrackedStartupsLoading();
}

class TrackedStartupsLoaded extends TrackedStartupsState {
  const TrackedStartupsLoaded({
    required this.startups,
    required this.trackedIds,
  });

  final List<TrackedStartupEntity> startups;
  final Set<String> trackedIds;

  bool isTracked(String startupId) => trackedIds.contains(startupId);

  TrackedStartupsLoaded copyWith({
    List<TrackedStartupEntity>? startups,
    Set<String>? trackedIds,
  }) {
    return TrackedStartupsLoaded(
      startups: startups ?? this.startups,
      trackedIds: trackedIds ?? this.trackedIds,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TrackedStartupsLoaded &&
          runtimeType == other.runtimeType &&
          listEquals(startups, other.startups) &&
          setEquals(trackedIds, other.trackedIds);

  @override
  int get hashCode => Object.hash(
        Object.hashAll(startups),
        Object.hashAll(trackedIds),
      );
}

class TrackedStartupsError extends TrackedStartupsState {
  const TrackedStartupsError(this.message);
  final String message;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TrackedStartupsError &&
          runtimeType == other.runtimeType &&
          message == other.message;

  @override
  int get hashCode => message.hashCode;
}
