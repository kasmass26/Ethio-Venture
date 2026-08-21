import 'dart:developer' as developer;
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:ethioventure/features/startup_profile/domain/entities/startup_profile_entity.dart';
import 'package:ethioventure/features/tracked_startups/domain/usecases/get_tracked_startups.dart';
import 'package:ethioventure/features/tracked_startups/domain/usecases/track_startup.dart';
import 'package:ethioventure/features/tracked_startups/domain/usecases/untrack_startup.dart';
import 'tracked_startups_state.dart';

class TrackedStartupsCubit extends Cubit<TrackedStartupsState> {
  TrackedStartupsCubit({
    required GetTrackedStartups getTrackedStartups,
    required TrackStartup trackStartup,
    required UntrackStartup untrackStartup,
  })  : _getTrackedStartups = getTrackedStartups,
        _trackStartup = trackStartup,
        _untrackStartup = untrackStartup,
        super(const TrackedStartupsInitial());

  final GetTrackedStartups _getTrackedStartups;
  final TrackStartup _trackStartup;
  final UntrackStartup _untrackStartup;

  Future<void> loadTrackedStartups() async {
    emit(const TrackedStartupsLoading());
    try {
      final list = await _getTrackedStartups();
      final trackedIds = list.map((e) => e.startupId).toSet();
      emit(TrackedStartupsLoaded(startups: list, trackedIds: trackedIds));
    } catch (e) {
      developer.log('Error loading tracked startups: $e', name: 'TrackedStartupsCubit');
      emit(TrackedStartupsError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  bool isStartupTracked(String startupId) {
    final currentState = state;
    if (currentState is TrackedStartupsLoaded) {
      return currentState.isTracked(startupId);
    }
    return false;
  }

  /// Toggles tracking status for a startup profile. Returns true if now tracked, false if un-tracked.
  Future<bool> toggleTrackStartup(StartupProfileEntity startup) async {
    final currentState = state;
    final currentlyTracked = isStartupTracked(startup.id);

    if (currentlyTracked) {
      // Untrack
      if (currentState is TrackedStartupsLoaded) {
        final updatedList = currentState.startups
            .where((s) => s.startupId != startup.id)
            .toList();
        final updatedIds = Set<String>.from(currentState.trackedIds)
          ..remove(startup.id);
        emit(TrackedStartupsLoaded(
          startups: updatedList,
          trackedIds: updatedIds,
        ));
      }

      try {
        await _untrackStartup(startup.id);
      } catch (e) {
        developer.log('Error untracking startup: $e', name: 'TrackedStartupsCubit');
        // Reload to sync back with server
        await loadTrackedStartups();
      }
      return false;
    } else {
      // Track
      try {
        final trackedEntity = await _trackStartup(startup.id);

        if (state is TrackedStartupsLoaded) {
          final loaded = state as TrackedStartupsLoaded;
          final updatedList = [
            trackedEntity,
            ...loaded.startups.where((s) => s.startupId != startup.id),
          ];
          final updatedIds = Set<String>.from(loaded.trackedIds)
            ..add(startup.id);
          emit(TrackedStartupsLoaded(
            startups: updatedList,
            trackedIds: updatedIds,
          ));
        } else {
          emit(TrackedStartupsLoaded(
            startups: [trackedEntity],
            trackedIds: {startup.id},
          ));
        }
        return true;
      } catch (e) {
        developer.log('Error tracking startup: $e', name: 'TrackedStartupsCubit');
        await loadTrackedStartups();
        return false;
      }
    }
  }
}
