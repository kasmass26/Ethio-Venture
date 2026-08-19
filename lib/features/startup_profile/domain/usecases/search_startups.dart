import 'package:ethioventure/core/usecases/usecase.dart';
import 'package:ethioventure/features/startup_profile/domain/entities/startup_filter.dart';
import 'package:ethioventure/features/startup_profile/domain/entities/startup_profile_entity.dart';
import 'package:ethioventure/features/startup_profile/domain/repositories/startup_repository.dart';

/// Returns a paginated, filtered list of published startup profiles.
///
/// Params: [StartupFilter] — all criteria are optional.
/// Result: [List<StartupProfileEntity>] — empty list when nothing matches.
class SearchStartups
    implements UseCase<List<StartupProfileEntity>, StartupFilter> {
  const SearchStartups(this._repository);

  final StartupRepository _repository;

  @override
  Future<List<StartupProfileEntity>> call(StartupFilter params) {
    return _repository.searchStartups(params);
  }
}
