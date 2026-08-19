import 'package:ethioventure/features/investor/presentation/cubit/recommended_startups_state.dart';
import 'package:ethioventure/features/investor_profile/domain/entities/investor_profile_entity.dart';
import 'package:ethioventure/features/startup_profile/domain/entities/startup_filter.dart';
import 'package:ethioventure/features/startup_profile/domain/entities/startup_profile_entity.dart';
import 'package:ethioventure/features/startup_profile/domain/usecases/search_startups.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Cubit that drives the "Recommended For You" rail on the investor dashboard.
///
/// Workflow:
///   1. Call [load] with the investor's profile.
///   2. A [StartupFilter] is built from the profile's preferences and passed
///      to [SearchStartups].
///   3. Each [StartupProfileEntity] is scored against the investor's
///      preferences and the results are sorted descending by score.
///   4. Emits [RecommendedStartupsLoaded] with the final, scored list.
///
/// Match score breakdown (max 100):
///   +40  startup industry  ∈ investor.preferredIndustries
///   +35  startup stage     ∈ investor.preferredStages
///   +25  fundingAmountNeeded ∈ [ticketSizeMin, ticketSizeMax]
///
/// When the investor has no preferences set the score defaults to 50 so
/// unfiltered results are still shown with a neutral relevance.
class RecommendedStartupsCubit extends Cubit<RecommendedStartupsState> {
  RecommendedStartupsCubit({required SearchStartups searchStartups})
      : _searchStartups = searchStartups,
        super(const RecommendedStartupsInitial());

  final SearchStartups _searchStartups;

  /// Maximum number of recommendations shown in the rail.
  static const int _maxResults = 10;

  /// Fetches and scores startup recommendations based on [profile].
  ///
  /// Passing [profile] as `null` fetches all recent startups with a neutral
  /// score — useful when the investor has not yet created a profile.
  Future<void> load([InvestorProfileEntity? profile]) async {
    emit(const RecommendedStartupsLoading());
    try {
      final filter = _buildFilter(profile);
      final startups = await _searchStartups(filter);
      final scored = _scoreAndSort(startups, profile);
      emit(RecommendedStartupsLoaded(scored));
    } catch (e) {
      debugPrint('[RecommendedStartupsCubit] error: $e');
      emit(RecommendedStartupsError(e.toString()));
    }
  }

  // ── Private helpers ────────────────────────────────────────────────────────

  /// Builds a [StartupFilter] for the initial fetch.
  ///
  /// We intentionally do **not** push industry, stage, or ticket-size
  /// constraints to the database query.  The `StartupFilter` passes those as
  /// strict AND conditions (exact match on industry AND exact match on stage
  /// AND funding range), which silently drops every startup that doesn't
  /// satisfy *all* criteria simultaneously — often returning an empty list
  /// even when plenty of good matches exist.
  ///
  /// Instead we fetch the most-recent approved startups in a single query
  /// and let [_computeScore] rank them against the investor's full
  /// [preferredIndustries] and [preferredStages] lists client-side.
  /// This gives correct, ranked results regardless of how many preferences
  /// the investor has set.
  StartupFilter _buildFilter(InvestorProfileEntity? profile) {
    // Fetch more than the visible cap so scoring has enough candidates to
    // pick the best matches from — especially when only a fraction of
    // startups overlap with the investor's industries.
    const fetchSize = 50;
    return const StartupFilter(pageSize: fetchSize);
  }

  /// Converts raw [StartupProfileEntity] rows to scored [RecommendedStartupItem]
  /// objects, sorted descending by match score.
  List<RecommendedStartupItem> _scoreAndSort(
    List<StartupProfileEntity> startups,
    InvestorProfileEntity? profile,
  ) {
    final scored =
        startups.map((s) => _toItem(s, profile)).toList()
          ..sort((a, b) => b.matchScore.compareTo(a.matchScore));
    return scored;
  }

  RecommendedStartupItem _toItem(
    StartupProfileEntity startup,
    InvestorProfileEntity? profile,
  ) {
    final score = _computeScore(startup, profile);
    return RecommendedStartupItem(
      id: startup.id,
      name: startup.startupName,
      tagline: _excerpt(startup.description),
      industry: startup.industry,
      fundingStage: startup.fundingStage,
      matchScore: score,
    );
  }

  /// Computes a 0–100 match score.
  int _computeScore(
    StartupProfileEntity startup,
    InvestorProfileEntity? profile,
  ) {
    if (profile == null) return 50;

    final hasNoPreferences =
        profile.preferredIndustries.isEmpty &&
        profile.preferredStages.isEmpty &&
        profile.ticketSizeMin == null &&
        profile.ticketSizeMax == null;

    if (hasNoPreferences) return 50;

    int score = 0;

    // +40 for industry match
    if (profile.preferredIndustries.isNotEmpty &&
        profile.preferredIndustries
            .map((i) => i.toLowerCase())
            .contains(startup.industry.toLowerCase())) {
      score += 40;
    }

    // +35 for funding stage match
    if (profile.preferredStages.isNotEmpty &&
        profile.preferredStages
            .map((s) => s.toLowerCase())
            .contains(startup.fundingStage.toLowerCase())) {
      score += 35;
    }

    // +25 for funding amount within investor's ticket range
    final min = profile.ticketSizeMin;
    final max = profile.ticketSizeMax;
    final needed = startup.fundingAmountNeeded;
    if (min == null && max == null) {
      // No ticket size preference → partial credit
      score += 10;
    } else if (min != null && max != null) {
      if (needed >= min && needed <= max) score += 25;
    } else if (min != null && needed >= min) {
      score += 20;
    } else if (max != null && needed <= max) {
      score += 20;
    }

    return score.clamp(0, 100);
  }

  /// Returns the first ~120 characters of [text] as a tagline, trimmed at the
  /// last word boundary so no word is cut in the middle.
  String _excerpt(String text) {
    const maxLen = 120;
    final trimmed = text.trim();
    if (trimmed.length <= maxLen) return trimmed;
    final sub = trimmed.substring(0, maxLen);
    final lastSpace = sub.lastIndexOf(' ');
    return lastSpace > 0 ? '${sub.substring(0, lastSpace)}…' : '$sub…';
  }
}
