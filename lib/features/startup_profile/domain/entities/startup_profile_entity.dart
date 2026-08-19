import 'package:flutter/foundation.dart';

/// Domain representation of a row in [public.startup_profiles].
///
/// [profileId] references [public.profiles.id] (= [auth.users.id]) and is
/// unique per startup — one founder owns one startup profile.
///
/// Fields map directly to the schema defined in docs/database-design.md:
///   id, profile_id, name, summary, industry, stage, location,
///   funding_target, status, created_at, updated_at.
@immutable
class StartupProfileEntity {
  const StartupProfileEntity({
    required this.id,
    required this.profileId,
    required this.name,
    this.summary,
    required this.industry,
    required this.stage,
    this.location,
    this.fundingTarget,
    this.status = StartupStatus.draft,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Primary key of the startup_profiles row.
  final String id;

  /// Foreign key → public.profiles.id (= auth.users.id of the founder).
  final String profileId;

  /// Public name of the startup.
  final String name;

  /// Short pitch / summary shown on the listing card.
  final String? summary;

  /// Primary industry vertical (e.g. 'Fintech', 'Agri-Tech', 'Health').
  final String industry;

  /// Funding stage the startup is currently seeking
  /// (e.g. 'Pre-Seed', 'Seed', 'Series A').
  final String stage;

  /// City / region the startup is based in (e.g. 'Addis Ababa').
  final String? location;

  /// Capital sought in USD. Maps to [funding_target] in the DB.
  final double? fundingTarget;

  /// Publication status — only [StartupStatus.published] profiles are
  /// visible to investors.
  final StartupStatus status;

  final DateTime createdAt;
  final DateTime updatedAt;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is StartupProfileEntity &&
            id == other.id &&
            profileId == other.profileId &&
            name == other.name &&
            summary == other.summary &&
            industry == other.industry &&
            stage == other.stage &&
            location == other.location &&
            fundingTarget == other.fundingTarget &&
            status == other.status &&
            createdAt == other.createdAt &&
            updatedAt == other.updatedAt;
  }

  @override
  int get hashCode => Object.hash(
        id,
        profileId,
        name,
        summary,
        industry,
        stage,
        location,
        fundingTarget,
        status,
        createdAt,
        updatedAt,
      );
}

/// Mirrors the [status] check constraint defined in the database schema.
enum StartupStatus {
  draft,
  published,
}
