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
    final name = json['startup_name']?.toString().isNotEmpty == true
        ? json['startup_name'].toString()
        : (json['business_name']?.toString() ?? '');

    final amount = _parseDouble(json['funding_amount_needed']) ??
        _parseDouble(json['funding_amount_sought']) ??
        0.0;

    final teamInfo = (json['team_information']?.toString().trim().isNotEmpty == true)
        ? json['team_information'].toString()
        : (json['team_overview']?.toString().trim().isNotEmpty == true)
            ? json['team_overview'].toString()
            : (json['team_details']?.toString().trim().isNotEmpty == true)
                ? json['team_details'].toString()
                : (json['team']?.toString() ?? '');

    final contactInfo = (json['contact_information']?.toString().trim().isNotEmpty == true)
        ? json['contact_information'].toString()
        : (json['contact_info']?.toString().trim().isNotEmpty == true)
            ? json['contact_info'].toString()
            : (json['contact_email']?.toString().trim().isNotEmpty == true)
                ? json['contact_email'].toString()
                : (json['contact_details']?.toString().trim().isNotEmpty == true)
                    ? json['contact_details'].toString()
                    : (json['contact']?.toString() ?? '');

    DateTime parsedCreated;
    try {
      parsedCreated = json['created_at'] != null
          ? DateTime.parse(json['created_at'].toString())
          : DateTime.now();
    } catch (_) {
      parsedCreated = DateTime.now();
    }

    DateTime parsedUpdated;
    try {
      parsedUpdated = json['updated_at'] != null
          ? DateTime.parse(json['updated_at'].toString())
          : DateTime.now();
    } catch (_) {
      parsedUpdated = DateTime.now();
    }

    return StartupProfileModel(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      startupName: name,
      description: json['description']?.toString() ?? '',
      industry: json['industry']?.toString() ?? '',
      fundingStage: json['funding_stage']?.toString() ?? '',
      location: json['location']?.toString() ?? '',
      fundingAmountNeeded: amount,
      teamInformation: teamInfo,
      contactInformation: contactInfo,
      createdAt: parsedCreated,
      updatedAt: parsedUpdated,
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
