/// Non-visual, non-color constants: role names, pagination defaults,
/// storage keys, etc. Color/spacing/type tokens live in core/theme.
class AppConstants {
  AppConstants._();

  static const String appName = 'Ethio Venture';
  static const String appTagline = 'Where ventures meet opportunity.';

  // User roles — mirrors the three actors from the system design:
  // Startup Founder, Investor, Administrator.
  static const String roleFounder = 'founder';
  static const String roleInvestor = 'investor';
  static const String roleAdmin = 'admin';

  static const int defaultPageSize = 20;
  static const int maxPageSize = 50;
  static const Duration networkTimeout = Duration(seconds: 20);

  static const String routeHome = '/';
  static const String routeSplash = '/splash';
  static const String routeOnboarding = '/onboarding';
  static const String routeLogin = '/login';
  static const String routeRegister = '/register';
  static const String routeRoleSelection = '/role-selection';
  static const String routeInvestorProfile = '/investor-profile';
  static const String routeStartupSearch = '/startup-search';
  static const String routeFounderDashboard = '/founder-dashboard';
  static const String routeInvestorDashboard = '/investor-dashboard';
  static const String routeAdminDashboard = '/admin-dashboard';
  static const String routeFounderInvestors = '/founder-investors';
  static const String routeStartupProfileSetup = '/startup-profile-setup';
  static const String routeStartupProfile = '/startup-profile';
  static const String routeEditStartupProfile = '/edit-startup-profile';
  static const String routeStartupDetail = '/startup-detail';
  
  // Admin email for special access
  static const String adminEmail = 'admin@gmail.com';
}

