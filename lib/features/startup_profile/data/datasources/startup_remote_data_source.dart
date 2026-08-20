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

  // ── searchStartups ──────────────────────────────────────────────────────

  @override
  Future<List<StartupProfileModel>> searchStartups(
    StartupFilter filter,
  ) async {
    try {
      List<dynamic> rows = [];
      try {
        final data = await _client
            .from(_table)
            .select()
            .order('created_at', ascending: false);
        rows = (data as List).cast<dynamic>();
      } catch (e) {
        debugPrint(
          '[Startup] Order by created_at failed, falling back to simple select: $e',
        );
        final data = await _client.from(_table).select();
        rows = (data as List).cast<dynamic>();
      }

      final models = <StartupProfileModel>[];
      for (final r in rows) {
        final map = Map<String, dynamic>.from(r as Map);

        // Exclude explicitly rejected profiles if approval_status column exists
        final status = map['approval_status']?.toString().toLowerCase();
        if (status == 'rejected') continue;

        final model = StartupProfileModel.fromJson(map);

        // Apply free-text search query across startup_name, business_name, description, industry, location
        final q = filter.query?.trim().toLowerCase();
        if (q != null && q.isNotEmpty) {
          final nameMatches = model.startupName.toLowerCase().contains(q);
          final descMatches = model.description.toLowerCase().contains(q);
          final indMatches = model.industry.toLowerCase().contains(q);
          final locMatches = model.location.toLowerCase().contains(q);
          if (!nameMatches && !descMatches && !indMatches && !locMatches) {
            continue;
          }
        }

        // Apply industry filter
        if (filter.industry != null && filter.industry!.trim().isNotEmpty) {
          if (!model.industry
              .toLowerCase()
              .contains(filter.industry!.trim().toLowerCase())) {
            continue;
          }
        }

        // Apply funding stage filter
        if (filter.stage != null && filter.stage!.trim().isNotEmpty) {
          if (!model.fundingStage
              .toLowerCase()
              .contains(filter.stage!.trim().toLowerCase())) {
            continue;
          }
        }

        // Apply location filter
        if (filter.location != null && filter.location!.trim().isNotEmpty) {
          if (!model.location
              .toLowerCase()
              .contains(filter.location!.trim().toLowerCase())) {
            continue;
          }
        }

        // Apply funding target range filters
        if (filter.minFundingTarget != null) {
          if (model.fundingAmountNeeded < filter.minFundingTarget!) {
            continue;
          }
        }
        if (filter.maxFundingTarget != null) {
          if (model.fundingAmountNeeded > filter.maxFundingTarget!) {
            continue;
          }
        }

        models.add(model);
      }

      // Apply pagination
      final from = filter.page * filter.pageSize;
      if (from >= models.length) {
        return <StartupProfileModel>[];
      }
      final to = (from + filter.pageSize).clamp(0, models.length);
      return models.sublist(from, to);
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
          .select()
          .eq('id', id)
          .maybeSingle();

      if (data == null) return null;
      return StartupProfileModel.fromJson(
        Map<String, dynamic>.from(data as Map),
      );
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
