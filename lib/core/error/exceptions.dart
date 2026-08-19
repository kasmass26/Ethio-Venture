/// Exceptions thrown by a data source before a repository maps them to failures.
sealed class AppException implements Exception {
  const AppException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => '$runtimeType: $message';
}

class ServerException extends AppException {
  const ServerException({
    String message = 'Server error',
    int? statusCode,
  }) : super(message, statusCode: statusCode);
}

class CacheException extends AppException {
  const CacheException({String message = 'Local cache error'}) : super(message);
}

class AuthException extends AppException {
  const AuthException({String message = 'Authentication failed'}) : super(message);
}

class NetworkException extends AppException {
  const NetworkException({String message = 'No internet connection'})
    : super(message);
}

class ValidationException extends AppException {
  const ValidationException(super.message);
}

/// Thrown by the auth data source when Supabase creates the auth.users record
/// but returns no session because email confirmation is required.
/// The account exists — the user must confirm their email before signing in.
class EmailConfirmationRequiredException extends AppException {
  /// Email address the confirmation was sent to.
  final String email;

  const EmailConfirmationRequiredException({required this.email})
      : super('Please check your email to confirm your account.');
}
