import 'package:ethioventure/core/error/exceptions.dart';
import 'package:ethioventure/features/startup_profile/data/models/startup_profile_model.dart';
import 'package:ethioventure/features/startup_profile/domain/entities/startup_filter.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ── Abstract contract ──────────────────────────────────────────────────────

abstract class StartupRemoteDataSource {
  /// Returns a paginated list of startup_profiles rows matching [filter].
  Future<List<StartupProfileModel>> searchStartups(StartupFilter filter);

  /// Returns a single startup_profiles row by [id], or null if not found.
  Future<StartupProfileModel?> getStartupById(String id);
}

// ── Supabase implementation ────────────────────────────────────────────────

/// Translates [StartupFilter] into a single Supabase/PostgREST query so that
/// every criterion is pushed down to Postgres and no client-side filtering
/// is performed.
///
/// Query strategy (all conditions are ANDed in the WHERE clause):
///
///  • status = 'published'            — always applied; investors see only
///                                      live profiles.
///  • or(name.ilike, summary.ilike)   — free-text search across two columns.
///  • eq(industry, value)             — exact match (controlled vocabulary).
///  • eq(stage, value)                — exact match (controlled vocabulary).
///  • ilike(location, value)          — case-insensitive substring match.
///  • gte(funding_target, min)        — inclusive lower bound.
///  • lte(funding_target, max)        — inclusive upper bound.
///  • order(created_at, asc: false)   — newest first.
///  • range(from, to)                 — Supabase offset-based pagination.
///
/// Filter conditions are built up on a [PostgrestFilterBuilder] (WHERE-phase).
/// Transform methods (.order, .range) are chained once all filters are applied,
/// because [PostgrestFilterBuilder] extends [PostgrestTransformBuilder] but the
/// reverse is not true — reassigning to the wider type after calling a filter
/// method avoids the type-narrowing issue.
class StartupRemoteDataSourceImpl implements StartupRemoteDataSource {
  StartupRemoteDataSourceImpl(this._client);

  final SupabaseClient _client;

  static const _table = 'startup_profiles';

  /// Column list for the discovery view.  Enumerating avoids fetching
  /// columns added by future features (e.g. document metadata).
  static const _listColumns =
      'id, user_id, startup_name, description, industry, funding_stage, '
      'location, funding_amount_needed, approval_status, created_at, updated_at';

  // ── searchStartups ──────────────────────────────────────────────────────

  @override
  Future<List<StartupProfileModel>> searchStartups(
    StartupFilter filter,
  ) async {
    try {
      // ── WHERE phase (PostgrestFilterBuilder) ─────────────────────────────
      // Start with the base filter: only approved profiles are visible
      // to investors.  Every subsequent .eq / .ilike / .gte / .lte call
      // narrows this with AND logic.
      PostgrestFilterBuilder<PostgrestList> filterQuery = _client
          .from(_table)
          .select(_listColumns)
          .eq('approval_status', 'approved');

      // Free-text search: OR across startup_name and description (case-insensitive).
      final q = filter.query?.trim();
      if (q != null && q.isNotEmpty) {
        filterQuery = filterQuery.or('startup_name.ilike.%$q%,description.ilike.%$q%');
      }

      // Exact-match filters for controlled-vocabulary columns.
      if (filter.industry != null) {
        filterQuery = filterQuery.eq('industry', filter.industry!);
      }
      if (filter.stage != null) {
        filterQuery = filterQuery.eq('funding_stage', filter.stage!);
      }

      // Case-insensitive location substring match.
      if (filter.location != null) {
        filterQuery = filterQuery.ilike('location', '%${filter.location!}%');
      }

      // Funding-amount-needed range bounds (inclusive).
      if (filter.minFundingTarget != null) {
        filterQuery =
            filterQuery.gte('funding_amount_needed', filter.minFundingTarget!);
      }
      if (filter.maxFundingTarget != null) {
        filterQuery =
            filterQuery.lte('funding_amount_needed', filter.maxFundingTarget!);
      }

      // ── TRANSFORM phase (PostgrestTransformBuilder) ──────────────────────
      // .order() and .range() live on the parent PostgrestTransformBuilder.
      // Calling them on filterQuery is valid because FilterBuilder extends
      // TransformBuilder; we hold the result in the wider type.
      final from = filter.page * filter.pageSize;
      final to = from + filter.pageSize - 1; // inclusive Supabase upper bound

      final rows = await filterQuery
          .order('created_at', ascending: false)
          .range(from, to);

      return (rows as List<dynamic>)
          .cast<Map<String, dynamic>>()
          .map(StartupProfileModel.fromJson)
          .toList();
    } on PostgrestException catch (e) {
      debugPrint('[Startup] searchStartups error: ${e.message} (${e.code})');
      throw ServerException(
        message: 'Failed to load startups: ${e.message}',
        statusCode: int.tryParse(e.code ?? ''),
      );
    } catch (e) {
      debugPrint('[Startup] searchStartups unexpected error: $e');
      throw ServerException(message: 'Failed to load startups: $e');
    }
  }

  // ── getStartupById ──────────────────────────────────────────────────────

  @override
  Future<StartupProfileModel?> getStartupById(String id) async {
    try {
      final data = await _client
          .from(_table)
          .select(_listColumns)
          .eq('id', id)
          .eq('approval_status', 'approved') // investors only see approved profiles
          .maybeSingle();

      if (data == null) return null;
      return StartupProfileModel.fromJson(data);
    } on PostgrestException catch (e) {
      debugPrint('[Startup] getStartupById error: ${e.message} (${e.code})');
      throw ServerException(
        message: 'Failed to load startup: ${e.message}',
        statusCode: int.tryParse(e.code ?? ''),
      );
    } catch (e) {
      debugPrint('[Startup] getStartupById unexpected error: $e');
      throw ServerException(message: 'Failed to load startup: $e');
    }
  }
}
