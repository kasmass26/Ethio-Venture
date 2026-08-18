import '../entities/user_entity.dart';

/// Domain contract repository interface for Startup Founder Authentication.
abstract interface class AuthRepository {
  /// Signs in an existing Startup Founder with email and password.
  Future<UserEntity> login({
    required String email,
    required String password,
  });

  /// Registers a new Startup Founder account.
  Future<UserEntity> register({
    required String email,
    required String password,
    required String fullName,
  });

  /// Logs out the currently active Startup Founder session.
  Future<void> logout();

  /// Gets the currently active authenticated Startup Founder session, if any.
  Future<UserEntity?> getCurrentUser();
}
