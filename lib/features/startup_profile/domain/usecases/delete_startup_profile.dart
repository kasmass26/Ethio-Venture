import 'package:ethioventure/core/usecases/usecase.dart';
import '../repositories/startup_profile_repository.dart';

/// Business use case to delete a startup profile by [userId].
class DeleteStartupProfileUseCase implements UseCase<void, String> {
  const DeleteStartupProfileUseCase(this._repository);

  final StartupProfileRepository _repository;

  @override
  Future<void> call(String userId) async {
    await _repository.deleteStartupProfile(userId);
  }
}
