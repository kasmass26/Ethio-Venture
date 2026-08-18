import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

/// Use case for registering a new Startup Founder account.
class RegisterUseCase {
  const RegisterUseCase(this._repository);

  final AuthRepository _repository;

  Future<UserEntity> call({
    required String email,
    required String password,
    required String fullName,
  }) {
    return _repository.register(
      email: email,
      password: password,
      fullName: fullName,
    );
  }
}
