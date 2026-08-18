import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
    required String role,
  }) {
    return remoteDataSource.register(
      name: name,
      email: email,
      password: password,
      role: role,
    );
  }

  @override
  Future<UserModel> login({
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