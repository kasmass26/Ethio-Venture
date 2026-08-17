import 'package:supabase_flutter/supabase_flutter.dart';

/// Single application entry point for the configured Supabase client.
///
/// Access this after application startup has called `Supabase.initialize`.
class SupabaseService {
  SupabaseService._();

  static SupabaseClient get client => Supabase.instance.client;
}
