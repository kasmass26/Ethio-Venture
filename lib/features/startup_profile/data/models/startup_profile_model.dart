import 'package:ethioventure/features/startup_profile/domain/entities/startup_profile_entity.dart';

/// Data-layer representation of a row in [public.startup_profiles].
class StartupProfileModel extends StartupProfileEntity {
  const StartupProfileModel({
    required super.id,
    required super.profileId,
    required super.name,
    super.summary,
    required super.industry,
    required super.stage,
    super.location,
    super.fundingTarget,
    super.status,
    super.teamInformation,
    super.contactInformation,
    required super.createdAt,
    required super.updatedAt,
  });

  factory StartupProfileModel.fromEntity(StartupProfileEntity entity) {
    return StartupProfileModel(
      id: entity.id,
      profileId: entity.profileId,
      name: entity.name,
      summary: entity.summary,
      industry: entity.industry,
      stage: entity.stage,
      location: entity.location,
      fundingTarget: entity.fundingTarget,
      status: entity.status,
      teamInformation: entity.teamInformation,
      contactInformation: entity.contactInformation,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  factory StartupProfileModel.fromJson(Map<String, dynamic> json) {
    return StartupProfileModel(
      id: json['id'] as String,
      profileId: (json['profile_id'] ?? json['user_id'] ?? '') as String,
      name: (json['name'] ?? json['startup_name'] ?? '') as String,
      summary: (json['summary'] ?? json['description']) as String?,
      industry: (json['industry'] ?? 'Fintech') as String,
      stage: (json['stage'] ?? json['funding_stage'] ?? 'MVP') as String,
      location: json['location'] as String?,
      fundingTarget: _parseDouble(json['funding_target'] ?? json['funding_amount_needed']),
      status: _parseStatus(json['status']),
      teamInformation: (json['team_information'] ?? 'Core Founder Team') as String,
      contactInformation: (json['contact_information'] ?? 'contact@startup.et') as String,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'] as String) : DateTime.now(),
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at'] as String) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'profile_id': profileId,
      'user_id': profileId,
      'name': name,
      'startup_name': name,
      'summary': summary,
      'description': summary,
      'industry': industry,
      'stage': stage,
      'funding_stage': stage,
      'location': location,
      'funding_target': fundingTarget,
      'funding_amount_needed': fundingTarget,
      'status': status.name,
      'team_information': teamInformation,
      'contact_information': contactInformation,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toInsertJson() => toJson();
  Map<String, dynamic> toUpdateJson() => toJson();

  // ── Private helpers ────────────────────────────────────────────────────────

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  static StartupStatus _parseStatus(dynamic value) {
    if (value == null) return StartupStatus.draft;
    final raw = value.toString().toLowerCase();
    return raw == 'published' ? StartupStatus.published : StartupStatus.draft;
  }
}
