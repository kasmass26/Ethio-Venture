import 'package:ethioventure/core/usecases/usecase.dart';
import '../entities/startup_profile_entity.dart';
import '../repositories/startup_profile_repository.dart';

/// Business use case to fetch a user's startup profile by their [userId].
class GetStartupProfileUseCase
    implements UseCase<StartupProfileEntity?, String> {
  const GetStartupProfileUseCase(this._repository);

  final StartupProfileRepository _repository;

  @override
  Future<StartupProfileEntity?> call(String userId) async {
    return await _repository.getStartupProfile(userId);
  }
}
