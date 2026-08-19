import 'package:ethioventure/core/constants/app_constants.dart';
import 'package:ethioventure/core/error/exceptions.dart';
import 'package:ethioventure/features/startup_profile/domain/entities/startup_filter.dart';
import 'package:ethioventure/features/startup_profile/domain/usecases/search_startups.dart';
import 'package:ethioventure/features/startup_profile/presentation/cubit/startup_search_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Manages the startup discovery screen's state.
///
/// Responsibilities:
///  - Holds the current [StartupFilter].
///  - Delegates every query to [SearchStartups] (no inline Supabase calls).
///  - Emits typed states for loading, results, empty, and error.
///  - Resets [filter.page] to 0 whenever a filter criterion changes.
///  - Supports pagination via [loadNextPage].
class StartupSearchCubit extends Cubit<StartupSearchState> {
  StartupSearchCubit({required SearchStartups searchStartups})
      : _searchStartups = searchStartups,
        super(const StartupSearchInitial());

  final SearchStartups _searchStartups;

  // The filter that will be applied on the next _search() call.
  StartupFilter _filter = const StartupFilter(
    pageSize: AppConstants.defaultPageSize,
  );

  /// The active filter, readable by the page for pre-populating controls.
  StartupFilter get currentFilter => _filter;

  // ── Public API ─────────────────────────────────────────────────────────────

  /// Performs an initial search with the default (empty) filter.
  /// Called once when the page is first built.
  Future<void> initialLoad() => _search(_filter);

  /// Applies [query] as a free-text search and resets to page 0.
  Future<void> updateQuery(String? query) {
    _filter = _filter.copyWith(
      query: query?.trim().isEmpty == true ? null : query?.trim(),
      clearQuery: query == null || query.trim().isEmpty,
      page: 0,
    );
    return _search(_filter);
  }

  /// Applies [industry] filter and resets to page 0.
  Future<void> updateIndustry(String? industry) {
    _filter = _filter.copyWith(
      industry: industry,
      clearIndustry: industry == null,
      page: 0,
    );
    return _search(_filter);
  }

  /// Applies [stage] filter and resets to page 0.
  Future<void> updateStage(String? stage) {
    _filter = _filter.copyWith(
      stage: stage,
      clearStage: stage == null,
      page: 0,
    );
    return _search(_filter);
  }

  /// Applies [location] filter and resets to page 0.
  Future<void> updateLocation(String? location) {
    _filter = _filter.copyWith(
      location: location?.trim().isEmpty == true ? null : location?.trim(),
      clearLocation: location == null || location.trim().isEmpty,
      page: 0,
    );
    return _search(_filter);
  }

  /// Applies a funding-target range and resets to page 0.
  Future<void> updateFundingRange({
    double? minFundingTarget,
    double? maxFundingTarget,
  }) {
    _filter = _filter.copyWith(
      minFundingTarget: minFundingTarget,
      maxFundingTarget: maxFundingTarget,
      clearMinFunding: minFundingTarget == null,
      clearMaxFunding: maxFundingTarget == null,
      page: 0,
    );
    return _search(_filter);
  }

  /// Applies all filter values at once (used by the filter sheet on "Apply").
  /// Resets to page 0.
  Future<void> applyFilters({
    String? query,
    String? industry,
    String? stage,
    String? location,
    double? minFundingTarget,
    double? maxFundingTarget,
  }) {
    _filter = StartupFilter(
      query: query?.trim().isEmpty == true ? null : query?.trim(),
      industry: industry,
      stage: stage,
      location: location?.trim().isEmpty == true ? null : location?.trim(),
      minFundingTarget: minFundingTarget,
      maxFundingTarget: maxFundingTarget,
      page: 0,
      pageSize: _filter.pageSize,
    );
    return _search(_filter);
  }

  /// Resets all filters and search term, returns to page 0.
  Future<void> clearFilters() {
    _filter = StartupFilter(pageSize: _filter.pageSize, page: 0);
    return _search(_filter);
  }

  /// Loads the next page. No-op when no more results are available or when
  /// a previous request is still loading.
  Future<void> loadNextPage() {
    final current = state;
    if (current is! StartupSearchLoaded || !current.hasMore) return Future.value();
    _filter = _filter.copyWith(page: _filter.page + 1);
    return _search(_filter, append: true);
  }

  // ── Private ────────────────────────────────────────────────────────────────

  Future<void> _search(StartupFilter filter, {bool append = false}) async {
    emit(const StartupSearchLoading());
    try {
      final results = await _searchStartups(filter);

      if (results.isEmpty) {
        emit(StartupSearchEmpty(filter: filter));
        return;
      }

      // When appending (pagination), merge with previous results.
      final previous = append && state is StartupSearchLoaded
          ? (state as StartupSearchLoaded).startups
          : <dynamic>[];

      emit(
        StartupSearchLoaded(
          startups: [...previous, ...results],
          filter: filter,
          // hasMore: if the page was full there may be more records.
          hasMore: results.length >= filter.pageSize,
        ),
      );
    } on AppException catch (e) {
      emit(StartupSearchError(e.message));
    } catch (e) {
      emit(StartupSearchError(e.toString()));
    }
  }
}
