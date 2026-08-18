import 'package:ethioventure/core/error/exceptions.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

/// Concrete implementation of [AuthRepository] bridging domain use cases to remote data source.
class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl(this._remoteDataSource);

  final AuthRemoteDataSource _remoteDataSource;

  @override
  Future<UserEntity> login({
    required String email,
    required String password,
  }) async {
    try {
      return await _remoteDataSource.login(
        email: email,
        password: password,
      );
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<UserEntity> register({
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      return await _remoteDataSource.register(
        email: email,
        password: password,
        fullName: fullName,
      );
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _remoteDataSource.logout();
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    try {
      return await _remoteDataSource.getCurrentUser();
    } catch (_) {
      return null;
    }
  }
}
