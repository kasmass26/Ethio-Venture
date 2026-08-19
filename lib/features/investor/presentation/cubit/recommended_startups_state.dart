import 'package:flutter/foundation.dart';

@immutable
sealed class RecommendedStartupsState {
  const RecommendedStartupsState();
}

/// Before any fetch has been triggered.
final class RecommendedStartupsInitial extends RecommendedStartupsState {
  const RecommendedStartupsInitial();
}

/// Fetching recommendations from Supabase.
final class RecommendedStartupsLoading extends RecommendedStartupsState {
  const RecommendedStartupsLoading();
}

/// Successfully loaded a (possibly empty) list of recommendations.
final class RecommendedStartupsLoaded extends RecommendedStartupsState {
  const RecommendedStartupsLoaded(this.startups);

  /// Scored and sorted list of startup recommendations.
  final List<RecommendedStartupItem> startups;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecommendedStartupsLoaded &&
          listEquals(other.startups, startups);

  @override
  int get hashCode => Object.hashAll(startups);
}

/// An error occurred while fetching recommendations.
final class RecommendedStartupsError extends RecommendedStartupsState {
  const RecommendedStartupsError(this.message);

  final String message;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecommendedStartupsError && other.message == message;

  @override
  int get hashCode => message.hashCode;
}

// ─────────────────────────────────────────────────────────────────────────────
// Value object emitted inside [RecommendedStartupsLoaded].
// ─────────────────────────────────────────────────────────────────────────────

/// A startup profile enriched with a match score relative to an investor's
/// preferences, ready to be displayed in the "Recommended For You" rail.
@immutable
class RecommendedStartupItem {
  const RecommendedStartupItem({
    required this.id,
    required this.name,
    required this.tagline,
    required this.industry,
    required this.fundingStage,
    required this.matchScore,
  });

  final String id;
  final String name;

  /// Short description used as the card tagline (truncated from [description]).
  final String tagline;

  final String industry;
  final String fundingStage;

  /// 0–100 match score derived from investor profile preferences.
  final int matchScore;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecommendedStartupItem &&
          id == other.id &&
          matchScore == other.matchScore;

  @override
  int get hashCode => Object.hash(id, matchScore);
}
