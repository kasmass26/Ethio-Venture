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

class Unauthenticated extends AuthState {
  const Unauthenticated();
}

class AuthFailureState extends AuthState {
  final String message;

  const AuthFailureState(this.message);
}

/// Emitted after signUp() when Supabase requires the user to confirm their
/// email address before a live session is granted.  The account exists in
/// auth.users but currentUser / currentSession will be null until the user
/// clicks the confirmation link and signs in.
class EmailConfirmationRequired extends AuthState {
  /// Email address the confirmation was sent to.
  final String email;

  const EmailConfirmationRequired({required this.email});
}
