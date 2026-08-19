import 'package:ethioventure/features/startup_profile/domain/entities/startup_profile_entity.dart';

/// Data-layer representation of a row in [public.startup_profiles].
///
/// Extends [StartupProfileEntity] so it can be returned anywhere the domain
/// type is expected.
///
/// Column mapping (DB → Dart):
///   id                     → id
///   user_id                → userId
///   startup_name           → startupName
///   description            → description
///   industry               → industry
///   funding_stage          → fundingStage
///   location               → location
///   funding_amount_needed  → fundingAmountNeeded
///   team_information       → teamInformation
///   contact_information    → contactInformation
///   created_at             → createdAt
///   updated_at             → updatedAt
class StartupProfileModel extends StartupProfileEntity {
  const StartupProfileModel({
    required super.id,
    required super.userId,
    required super.startupName,
    required super.description,
    required super.industry,
    required super.fundingStage,
    required super.fundingAmountNeeded,
    required super.location,
    required super.teamInformation,
    required super.contactInformation,
    required super.createdAt,
    required super.updatedAt,
  });

  factory StartupProfileModel.fromJson(Map<String, dynamic> json) {
    return StartupProfileModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      startupName: json['startup_name'] as String,
      description: json['description'] as String,
      industry: json['industry'] as String,
      fundingStage: json['funding_stage'] as String,
      location: json['location'] as String,
      fundingAmountNeeded: _parseDouble(json['funding_amount_needed']) ?? 0.0,
      teamInformation: json['team_information'] as String? ?? '',
      contactInformation: json['contact_information'] as String? ?? '',
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  factory StartupProfileModel.fromEntity(StartupProfileEntity entity) {
    return StartupProfileModel(
      id: entity.id,
      userId: entity.userId,
      startupName: entity.startupName,
      description: entity.description,
      industry: entity.industry,
      fundingStage: entity.fundingStage,
      location: entity.location,
      fundingAmountNeeded: entity.fundingAmountNeeded,
      teamInformation: entity.teamInformation,
      contactInformation: entity.contactInformation,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'startup_name': startupName,
      'description': description,
      'industry': industry,
      'funding_stage': fundingStage,
      'location': location,
      'funding_amount_needed': fundingAmountNeeded,
      'team_information': teamInformation,
      'contact_information': contactInformation,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toInsertJson() {
    return {
      'user_id': userId,
      'startup_name': startupName,
      'description': description,
      'industry': industry,
      'funding_stage': fundingStage,
      'location': location,
      'funding_amount_needed': fundingAmountNeeded,
      'team_information': teamInformation,
      'contact_information': contactInformation,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toUpdateJson() {
    return {
      'startup_name': startupName,
      'description': description,
      'industry': industry,
      'funding_stage': fundingStage,
      'location': location,
      'funding_amount_needed': fundingAmountNeeded,
      'team_information': teamInformation,
      'contact_information': contactInformation,
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // ── Private helpers ────────────────────────────────────────────────────────

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }
}
