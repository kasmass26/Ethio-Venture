import '../../domain/entities/user_entity.dart';

/// Sealed class hierarchy representing state of Startup Founder Authentication.
sealed class AuthState {
  const AuthState();
}

/// Initial state when AuthCubit is instantiated.
final class AuthInitial extends AuthState {
  const AuthInitial();
}

/// State emitted while asynchronous auth operations (login/register/check) execute.
final class AuthLoading extends AuthState {
  const AuthLoading();
}

/// State emitted when a Startup Founder is successfully authenticated.
final class Authenticated extends AuthState {
  const Authenticated(this.user);

  final UserEntity user;
}

/// State emitted when no active authenticated session exists.
final class Unauthenticated extends AuthState {
  const Unauthenticated();
}

/// State emitted when an authentication operation fails.
final class AuthError extends AuthState {
  const AuthError(this.message);

  final String message;
}
