import 'package:ethioventure/core/usecases/usecase.dart';
import '../entities/startup_profile_entity.dart';
import '../repositories/startup_profile_repository.dart';

/// Business use case to register/create a new startup profile.
class CreateStartupProfileUseCase
    implements UseCase<StartupProfileEntity, StartupProfileEntity> {
  const CreateStartupProfileUseCase(this._repository);

  final StartupProfileRepository _repository;

  @override
  Future<StartupProfileEntity> call(StartupProfileEntity params) async {
    return await _repository.createStartupProfile(params);
  }
}
