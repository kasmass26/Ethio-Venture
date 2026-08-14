/// Central place for every REST endpoint path.
/// Keeps datasources free of hardcoded strings.
class ApiEndpoints {
  ApiEndpoints._();

  static const String baseUrl = 'https://api.ethioventure.com/v1';

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
