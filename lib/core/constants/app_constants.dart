/// Non-visual, non-color constants: role names, pagination defaults,
/// storage keys, etc. Color/spacing/type tokens live in core/theme.
class AppConstants {
  AppConstants._();

  static const String appName = 'Ethio Venture';

  // Supabase Config
  static const String supabaseUrl = 'https://jmioioqwaazbdxvuochh.supabase.co';
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImptaW9pb3F3YWF6YmR4dnVvY2hoIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MDAwMDAwMDAsImV4cCI6MjAxNTAwMDAwMH0.placeholder',
  );

  // User roles — mirrors the three actors from the system design:
  // Startup Founder, Investor, Administrator.
  static const String roleFounder = 'founder';
  static const String roleInvestor = 'investor';
  static const String roleAdmin = 'admin';

  static const int defaultPageSize = 20;
}
