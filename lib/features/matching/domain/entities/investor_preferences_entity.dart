/// Domain entity representing an investor's preferences.
/// These fields are stored directly on the `investor_profiles` table —
/// there is no separate investment_preferences table.
class InvestorPreferencesEntity {
  /// `investor_profiles.id`
  final String id;

  /// `investor_profiles.user_id` — links to `users.id`
  final String userId;

  /// `investor_profiles.preferred_industries` text[]
  final List<String> preferredIndustries;

  /// `investor_profiles.preferred_stages` text[]
  final List<String> preferredStages;

  /// `investor_profiles.geographic_focus` text[]
  final List<String> geographicFocus;

  /// `investor_profiles.ticket_size_min` numeric
  final double? ticketSizeMin;

  /// `investor_profiles.ticket_size_max` numeric
  final double? ticketSizeMax;

  const InvestorPreferencesEntity({
    required this.id,
    required this.userId,
    required this.preferredIndustries,
    required this.preferredStages,
    required this.geographicFocus,
    this.ticketSizeMin,
    this.ticketSizeMax,
  });
}
