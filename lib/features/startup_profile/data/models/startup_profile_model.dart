import 'package:ethioventure/features/startup_profile/domain/entities/startup_profile_entity.dart';

/// Data-layer representation of a row in [public.startup_profiles].
///
/// Extends [StartupProfileEntity] so it can be returned anywhere the domain
/// type is expected (same pattern as [InvestorProfileModel]).
///
/// Column mapping (DB → Dart):
///   id              → id
///   profile_id      → profileId
///   name            → name
///   summary         → summary
///   industry        → industry
///   stage           → stage
///   location        → location
///   funding_target  → fundingTarget
///   status          → status
///   created_at      → createdAt
///   updated_at      → updatedAt
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
    required super.createdAt,
    required super.updatedAt,
  });

  factory StartupProfileModel.fromJson(Map<String, dynamic> json) {
    return StartupProfileModel(
      id: json['id'] as String,
      profileId: json['profile_id'] as String,
      name: json['name'] as String,
      summary: json['summary'] as String?,
      industry: json['industry'] as String,
      stage: json['stage'] as String,
      location: json['location'] as String?,
      fundingTarget: _parseDouble(json['funding_target']),
      status: _parseStatus(json['status']),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'profile_id': profileId,
      'name': name,
      'summary': summary,
      'industry': industry,
      'stage': stage,
      'location': location,
      'funding_target': fundingTarget,
      'status': status.name,        // 'draft' | 'published'
      'created_at': createdAt.toIso8601String(),
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

  static StartupStatus _parseStatus(dynamic value) {
    if (value == null) return StartupStatus.draft;
    final raw = value.toString().toLowerCase();
    return raw == 'published' ? StartupStatus.published : StartupStatus.draft;
  }
}
