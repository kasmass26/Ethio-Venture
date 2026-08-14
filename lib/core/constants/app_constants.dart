/// Non-visual, non-color constants: role names, pagination defaults,
/// storage keys, etc. Color/spacing/type tokens live in core/theme.
class AppConstants {
  AppConstants._();

  static const String appName = 'Ethio Venture';

  // User roles — mirrors the three actors from the system design:
  // Startup Founder, Investor, Administrator.
  static const String roleFounder = 'founder';
  static const String roleInvestor = 'investor';
  static const String roleAdmin = 'admin';

  static const int defaultPageSize = 20;
}
