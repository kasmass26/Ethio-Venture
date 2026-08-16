import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl(this.remoteDataSource);

  @override
  Future<UserEntity> register({
    required String email,
    required String password,
    required UserRole role,
  }) {
    return remoteDataSource.register(
      email: email,
      password: password,
      role: role.name,
    );
  }

  @override
  Future<UserEntity> login({
    required String email,
    required String password,
  }) {
    return remoteDataSource.login(
      email: email,
      password: password,
    );
  }

  @override
  Future<void> logout() {
    return remoteDataSource.logout();
  }
}