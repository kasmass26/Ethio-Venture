import '../../data/models/user_model.dart';
import '../repositories/auth_repository.dart';

class RegisterUser {
  final AuthRepository repository;

  RegisterUser(this.repository);

  Future<UserModel> call({
    required String name,
    required String email,
    required String password,
    required String role,
  }) {
    return repository.register(
      name: name,
      email: email,
      password: password,
      role: role,
    );
  }
}