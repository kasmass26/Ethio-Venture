import 'package:flutter/foundation.dart';

/// Domain representation of a row in [public.startup_profiles].
///
/// Fields map directly to the schema defined in migrations:
///   id, user_id, startup_name, description, industry, funding_stage,
///   location, funding_amount_needed, team_information, contact_information,
///   created_at, updated_at.
@immutable
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
    required this.createdAt,
    required this.updatedAt,
  });

  /// Primary key of the startup_profiles row.
  final String id;

  /// Foreign key → public.profiles.id (= auth.users.id of the founder).
  final String userId;

  /// Public name of the startup.
  final String startupName;

  /// Detailed description of the startup.
  final String description;

  /// Primary industry vertical (e.g. 'Fintech', 'Agri-Tech', 'Health').
  final String industry;

  /// Funding stage the startup is currently seeking.
  final String fundingStage;

  /// City / region the startup is based in.
  final String location;

  /// Capital sought in USD. Maps to [funding_amount_needed] in the DB.
  final double fundingAmountNeeded;

  /// Team and founder details.
  final String teamInformation;

  /// Contact information.
  final String contactInformation;

  final DateTime createdAt;
  final DateTime updatedAt;

  // Schema aliases for matching and investor modules
  String get profileId => userId;
  String get name => startupName;
  String? get summary => description;
  String get stage => fundingStage;
  double? get fundingTarget => fundingAmountNeeded;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is StartupProfileEntity &&
            id == other.id &&
            userId == other.userId &&
            startupName == other.startupName &&
            description == other.description &&
            industry == other.industry &&
            fundingStage == other.fundingStage &&
            location == other.location &&
            fundingAmountNeeded == other.fundingAmountNeeded &&
            teamInformation == other.teamInformation &&
            contactInformation == other.contactInformation &&
            createdAt == other.createdAt &&
            updatedAt == other.updatedAt;
  }

  @override
  int get hashCode => Object.hash(
        id,
        userId,
        startupName,
        description,
        industry,
        fundingStage,
        location,
        fundingAmountNeeded,
        teamInformation,
        contactInformation,
        createdAt,
        updatedAt,
      );
}
