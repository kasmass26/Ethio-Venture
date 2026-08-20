import '../../data/models/user_model.dart';

sealed class AuthState {
  const AuthState();
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class Authenticated extends AuthState {
  final UserModel user;

  const Authenticated(this.user);
}

/// Emitted after signUp() when Supabase requires the user to confirm their
/// email address before a live session is granted.
class EmailConfirmationRequired extends AuthState {
  final String email;

  const EmailConfirmationRequired([this.email = '']);
}

class Unauthenticated extends AuthState {
  const Unauthenticated();
}

class AuthFailureState extends AuthState {
  final String message;

  const AuthFailureState(this.message);
}
