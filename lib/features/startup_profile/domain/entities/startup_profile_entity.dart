/// Pure domain entity representing a Startup Profile in Ethio Venture.
///
/// This entity lives in the Domain Layer and has zero dependencies on
/// external frameworks (Supabase, Flutter UI, etc.).
class StartupProfileEntity {
  const StartupProfileEntity({
    required this.id,
    required this.userId,
    required this.startupName,
    required this.description,
    required this.industry,
    required this.fundingStage,
    required this.fundingAmountNeeded,
    required this.location,
    required this.teamInformation,
    required this.contactInformation,
    this.createdAt,
    this.updatedAt,
  });

  /// Unique UUID of the startup profile database row.
  final String id;

  /// Supabase authenticated user ID (`auth.users.id`) of the founder owner.
  final String userId;

  /// Name of the startup venture.
  final String startupName;

  /// Comprehensive description/pitch of the startup.
  final String description;

  /// Industry sector (e.g., Fintech, AgriTech, HealthTech, EduTech).
  final String industry;

  /// Current funding stage (e.g., Idea, MVP, Seed, Series A).
  final String fundingStage;

  /// Amount of funding requested (must be > 0).
  final double fundingAmountNeeded;

  /// Physical or primary operating location (e.g., Addis Ababa, Ethiopia).
  final String location;

  /// Overview of co-founders, key team members, and qualifications.
  final String teamInformation;

  /// Primary contact details (email, phone, or website).
  final String contactInformation;

  /// Audit timestamp when profile was created.
  final DateTime? createdAt;

  /// Audit timestamp when profile was last updated.
  final DateTime? updatedAt;

  /// Creates a copy of this entity with updated fields.
  StartupProfileEntity copyWith({
    String? id,
    String? userId,
    String? startupName,
    String? description,
    String? industry,
    String? fundingStage,
    double? fundingAmountNeeded,
    String? location,
    String? teamInformation,
    String? contactInformation,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return StartupProfileEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      startupName: startupName ?? this.startupName,
      description: description ?? this.description,
      industry: industry ?? this.industry,
      fundingStage: fundingStage ?? this.fundingStage,
      fundingAmountNeeded: fundingAmountNeeded ?? this.fundingAmountNeeded,
      location: location ?? this.location,
      teamInformation: teamInformation ?? this.teamInformation,
      contactInformation: contactInformation ?? this.contactInformation,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
