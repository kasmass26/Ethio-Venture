import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
    required String role,
  });

  Future<UserModel> login({
    required String email,
    required String password,
  });

  Future<void> logout();
}
