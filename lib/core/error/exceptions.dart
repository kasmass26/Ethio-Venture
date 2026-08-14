/// Exceptions thrown by datasources (remote or local).
/// Repositories catch these and map them to a [Failure].
class ServerException implements Exception {
  final String message;
  final int? statusCode;
  ServerException({this.message = 'Server error', this.statusCode});
}

class CacheException implements Exception {
  final String message;
  CacheException({this.message = 'Cache error'});
}

class AuthException implements Exception {
  final String message;
  AuthException({this.message = 'Auth error'});
}
