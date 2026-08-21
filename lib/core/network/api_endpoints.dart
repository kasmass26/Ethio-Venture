/// Supabase resource names shared by feature data sources.
///
/// Keep table, bucket, RPC, and Edge Function identifiers here so feature code
/// does not scatter string literals throughout the application.
class ApiEndpoints {
  ApiEndpoints._();

  // Database tables
  static const String users = 'users';
  static const String startupProfiles = 'startup_profiles';
  static const String investorProfiles = 'investor_profiles';
  static const String investmentPreferences = 'investment_preferences';
  static const String matches = 'matches';
  static const String conversations = 'conversations';
  static const String messages = 'messages';
  static const String notifications = 'notifications';
  static const String documents = 'documents';
  static const String deviceTokens = 'device_tokens';
  static const String connectionRequests = 'connection_requests';

  // Storage buckets
  static const String documentsBucket = 'documents';
  static const String startupDocumentsBucket = 'documents';
  static const String profileAssetsBucket = 'profile-assets';

  // Trusted server-side actions
  static const String generateMatchesFunction = 'generate-matches';
  static const String sendNotificationFunction = 'send-notification';
}
