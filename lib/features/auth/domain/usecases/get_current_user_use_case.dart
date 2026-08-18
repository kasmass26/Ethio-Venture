import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

/// Use case for fetching the active authenticated founder session.
class GetCurrentUserUseCase {
  const GetCurrentUserUseCase(this._repository);

  final AuthRepository _repository;

  Future<UserEntity?> call() {
    return _repository.getCurrentUser();
  }
}
