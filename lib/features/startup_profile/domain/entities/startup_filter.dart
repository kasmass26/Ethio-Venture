import 'package:flutter/foundation.dart';

/// Value object that carries every search / filter criterion for the
/// startup discovery query.
///
/// All fields are optional — an empty [StartupFilter] returns all published
/// startups. Multiple fields are combined with AND logic in the repository.
@immutable
class StartupFilter {
  const StartupFilter({
    this.query,
    this.industry,
    this.stage,
    this.location,
    this.minFundingTarget,
    this.maxFundingTarget,
    this.page = 0,
    this.pageSize = 20,
  }) : assert(
         minFundingTarget == null ||
             maxFundingTarget == null ||
             maxFundingTarget >= minFundingTarget,
         'maxFundingTarget must be >= minFundingTarget',
       );

  /// Free-text search term matched against startup name and summary.
  final String? query;

  /// Filter by a single industry vertical (exact match or ilike).
  final String? industry;

  /// Filter by a single funding stage (exact match).
  final String? stage;

  /// Filter by city / region (exact match or ilike).
  final String? location;

  /// Minimum capital sought, in USD (inclusive).
  final double? minFundingTarget;

  /// Maximum capital sought, in USD (inclusive).
  final double? maxFundingTarget;

  /// Zero-based page index for paginated results.
  final int page;

  /// Number of records per page. Mirrors [AppConstants.defaultPageSize].
  final int pageSize;

  /// Returns true when no filter criteria are set (query would return all
  /// published startups).
  bool get isEmpty =>
      query == null &&
      industry == null &&
      stage == null &&
      location == null &&
      minFundingTarget == null &&
      maxFundingTarget == null;

  /// Creates a copy with selectively overridden fields.
  StartupFilter copyWith({
    String? query,
    String? industry,
    String? stage,
    String? location,
    double? minFundingTarget,
    double? maxFundingTarget,
    int? page,
    int? pageSize,
    // Nullable-clear sentinels — pass [clearQuery] = true to set query to null.
    bool clearQuery = false,
    bool clearIndustry = false,
    bool clearStage = false,
    bool clearLocation = false,
    bool clearMinFunding = false,
    bool clearMaxFunding = false,
  }) {
    return StartupFilter(
      query: clearQuery ? null : (query ?? this.query),
      industry: clearIndustry ? null : (industry ?? this.industry),
      stage: clearStage ? null : (stage ?? this.stage),
      location: clearLocation ? null : (location ?? this.location),
      minFundingTarget:
          clearMinFunding ? null : (minFundingTarget ?? this.minFundingTarget),
      maxFundingTarget:
          clearMaxFunding ? null : (maxFundingTarget ?? this.maxFundingTarget),
      page: page ?? this.page,
      pageSize: pageSize ?? this.pageSize,
    );
  }

  /// Returns a copy reset to page 0 — used when filter criteria change.
  StartupFilter resetPage() => copyWith(page: 0);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is StartupFilter &&
            query == other.query &&
            industry == other.industry &&
            stage == other.stage &&
            location == other.location &&
            minFundingTarget == other.minFundingTarget &&
            maxFundingTarget == other.maxFundingTarget &&
            page == other.page &&
            pageSize == other.pageSize;
  }

  @override
  int get hashCode => Object.hash(
        query,
        industry,
        stage,
        location,
        minFundingTarget,
        maxFundingTarget,
        page,
        pageSize,
      );
}
