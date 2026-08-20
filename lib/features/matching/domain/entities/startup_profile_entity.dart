/// Domain entity representing a startup's profile.
/// Maps to the `startup_profiles` Supabase table.
class StartupProfileEntity {
  final String id;

  /// References `users.id` via `startup_profiles.user_id`.
  final String userId;

  /// `startup_profiles.business_name`
  final String businessName;

  /// `startup_profiles.description`
  final String? description;

  /// `startup_profiles.industry`
  final String? industry;

  /// `startup_profiles.funding_stage` (USER-DEFINED enum)
  final String? fundingStage;

  /// `startup_profiles.location`
  final String? location;

  /// `startup_profiles.funding_amount_sought`
  final double? fundingAmountSought;

  const StartupProfileEntity({
    required this.id,
    required this.userId,
    required this.businessName,
    this.description,
    this.industry,
    this.fundingStage,
    this.location,
    this.fundingAmountSought,
  });
}
