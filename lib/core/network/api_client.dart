import 'package:ethioventure/core/supabase/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Compatibility facade for data sources that need the configured backend.
///
/// Supabase owns session handling and attaches the authenticated access token to
/// its own database, storage, Realtime, and Edge Function requests.
class ApiClient {
  ApiClient._();

  static SupabaseClient get supabase => SupabaseService.client;
}
