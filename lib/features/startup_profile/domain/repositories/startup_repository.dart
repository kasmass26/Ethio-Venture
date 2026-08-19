import 'package:ethioventure/features/startup_profile/domain/entities/startup_filter.dart';
import 'package:ethioventure/features/startup_profile/domain/entities/startup_profile_entity.dart';

/// Repository contract for startup discovery operations.
///
/// Implementations live in the data layer and map Supabase responses to
/// domain entities. Exception handling is delegated to the cubit layer.
///
/// Only read operations are required for Issue #8 (discovery / search).
/// Write operations (create / update / delete startup profile) belong to
/// the startup-profile management feature and will be added separately.
abstract interface class StartupRepository {
  /// Returns a paginated list of published startups matching [filter].
  ///
  /// - When [filter.isEmpty] is true, returns all published startups ordered
  ///   by creation date descending.
  /// - Free-text [filter.query] is matched against [name] and [summary].
  /// - All other criteria are applied as additional AND conditions.
  /// - Pagination uses [filter.page] and [filter.pageSize].
  ///
  /// Returns an empty list when no results match — never returns null.
  /// Throws a [ServerException] on network or database failure.
  Future<List<StartupProfileEntity>> searchStartups(StartupFilter filter);

  /// Retrieves a single startup profile by its [id].
  ///
  /// Returns `null` when no published profile with that [id] exists.
  /// Throws a [ServerException] on network or database failure.
  Future<StartupProfileEntity?> getStartupById(String id);
}
