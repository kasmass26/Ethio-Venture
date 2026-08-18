import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

/// Use case for logging in a Startup Founder.
class LoginUseCase {
  const LoginUseCase(this._repository);

  final AuthRepository _repository;

  Future<UserEntity> call({
    required String email,
    required String password,
  }) {
    return _repository.login(
      email: email,
      password: password,
    );
  }
}
