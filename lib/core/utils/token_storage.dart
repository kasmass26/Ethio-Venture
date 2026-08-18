import 'package:ethioventure/core/supabase/supabase_service.dart';

/// Session access backed by Supabase's platform-secure persistence.
///
/// Do not duplicate tokens in SharedPreferences or application state. The
/// Supabase SDK refreshes and persists sessions securely on supported platforms.
class TokenStorage {
  TokenStorage._();

  static Future<String?> getAccessToken() async {
    return SupabaseService.client.auth.currentSession?.accessToken;
  }

  static Future<String?> getRefreshToken() async {
    return SupabaseService.client.auth.currentSession?.refreshToken;
  }

  static Future<bool> hasActiveSession() async {
    return SupabaseService.client.auth.currentSession != null;
  }

  static Future<void> clearSession() {
    return SupabaseService.client.auth.signOut();
  }
}
