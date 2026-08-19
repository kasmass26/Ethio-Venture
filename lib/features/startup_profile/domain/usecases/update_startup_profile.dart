import 'package:ethioventure/core/usecases/usecase.dart';
import '../entities/startup_profile_entity.dart';
import '../repositories/startup_profile_repository.dart';

/// Business use case to update an existing startup profile.
class UpdateStartupProfileUseCase
    implements UseCase<StartupProfileEntity, StartupProfileEntity> {
  const UpdateStartupProfileUseCase(this._repository);

  final StartupProfileRepository _repository;

  @override
  Future<StartupProfileEntity> call(StartupProfileEntity params) async {
    return await _repository.updateStartupProfile(params);
  }
}
