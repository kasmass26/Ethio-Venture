import 'package:ethioventure/features/startup_profile/domain/entities/startup_filter.dart';
import 'package:ethioventure/features/startup_profile/domain/entities/startup_profile_entity.dart';
import 'package:flutter/foundation.dart';

@immutable
sealed class StartupSearchState {
  const StartupSearchState();
}

/// Initial state — no search has been issued yet.
final class StartupSearchInitial extends StartupSearchState {
  const StartupSearchInitial();
}

/// A search / filter change is in flight.
final class StartupSearchLoading extends StartupSearchState {
  const StartupSearchLoading();
}

/// Results returned successfully.
///
/// [startups]    — current page of results.
/// [filter]      — the filter that produced these results.
/// [hasMore]     — true when the page was full and more records may exist.
final class StartupSearchLoaded extends StartupSearchState {
  const StartupSearchLoaded({
    required this.startups,
    required this.filter,
    required this.hasMore,
  });

  final List<StartupProfileEntity> startups;
  final StartupFilter filter;
  final bool hasMore;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StartupSearchLoaded &&
          listEquals(startups, other.startups) &&
          filter == other.filter &&
          hasMore == other.hasMore;

  @override
  int get hashCode => Object.hash(Object.hashAll(startups), filter, hasMore);
}

/// The query returned zero results.
///
/// [filter] is retained so the page can display which criteria produced
/// the empty result and offer a "clear filters" action.
final class StartupSearchEmpty extends StartupSearchState {
  const StartupSearchEmpty({required this.filter});

  final StartupFilter filter;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StartupSearchEmpty && filter == other.filter;

  @override
  int get hashCode => filter.hashCode;
}

/// A search operation failed.
final class StartupSearchError extends StartupSearchState {
  const StartupSearchError(this.message);

  final String message;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StartupSearchError && message == other.message;

  @override
  int get hashCode => message.hashCode;
}
