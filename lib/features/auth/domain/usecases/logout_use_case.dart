import '../repositories/auth_repository.dart';

/// Use case for logging out the current active founder session.
class LogoutUseCase {
  const LogoutUseCase(this._repository);

  final AuthRepository _repository;

  Future<void> call() {
    return _repository.logout();
  }
}
