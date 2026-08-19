import 'package:ethioventure/core/usecases/usecase.dart';
import 'package:ethioventure/features/startup_profile/domain/entities/startup_profile_entity.dart';
import 'package:ethioventure/features/startup_profile/domain/repositories/startup_repository.dart';

/// Retrieves a single published startup profile by its primary key.
///
/// Params: [String] — the startup profile UUID.
/// Result: [StartupProfileEntity?] — null when no matching profile is found.
class GetStartupById
    implements UseCase<StartupProfileEntity?, String> {
  const GetStartupById(this._repository);

  final StartupRepository _repository;

  @override
  Future<StartupProfileEntity?> call(String params) {
    return _repository.getStartupById(params);
  }
}
