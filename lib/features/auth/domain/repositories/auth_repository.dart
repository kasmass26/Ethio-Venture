import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<UserEntity> register({
    required String name,
    required String email,
    required String password,
    required UserRole role,
  });

  Future<UserEntity> login({
    required String email,
    required String password,
  });

  Future<void> logout();
}