import 'package:flutter/foundation.dart';

/// Central place for every REST endpoint path.
/// Keeps datasources free of hardcoded strings.
class ApiEndpoints {
  ApiEndpoints._();

  static String get baseUrl {
    // Web/Chrome runs from the browser, so localhost is the correct host for a
    // locally running backend. Android emulator needs 10.0.2.2 to reach the
    // host machine's localhost. Physical Android devices must use the machine's
    // LAN IP instead.
    if (kIsWeb) {
      return 'http://localhost:3000/v1';
    }

    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:3000/v1';
    }

    return 'http://localhost:3000/v1';
  }

  // Auth
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String refreshToken = '/auth/refresh';
  static const String logout = '/auth/logout';

  // Startup profile
  static const String startups = '/startups';
  static String startupById(String id) => '/startups/$id';

  // Investor profile
  static const String investors = '/investors';
  static String investorById(String id) => '/investors/$id';

  // Matching / AI engine
  static const String matches = '/matches';
  static String matchesForUser(String userId) => '/matches/$userId';

  // Messaging
  static const String conversations = '/conversations';
  static String messagesFor(String conversationId) =>
      '/conversations/$conversationId/messages';

  // Admin
  static const String adminUsers = '/admin/users';
  static const String adminReports = '/admin/reports';
}
