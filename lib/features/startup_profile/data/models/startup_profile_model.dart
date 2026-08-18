import '../../domain/entities/startup_profile_entity.dart';

/// Data model representing a Startup Profile in the Data Layer.
///
/// Extends [StartupProfileEntity] and provides serialization to/from JSON
/// matching the Supabase `startup_profiles` table schema.
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
    super.createdAt,
    super.updatedAt,
  });

  /// Constructs a [StartupProfileModel] from a Supabase PostgreSQL JSON map.
  factory StartupProfileModel.fromJson(Map<String, dynamic> json) {
    return StartupProfileModel(
      id: json['id'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      startupName: json['startup_name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      industry: json['industry'] as String? ?? '',
      fundingStage: json['funding_stage'] as String? ?? '',
      fundingAmountNeeded:
          (json['funding_amount_needed'] as num?)?.toDouble() ?? 0.0,
      location: json['location'] as String? ?? '',
      teamInformation: json['team_information'] as String? ?? '',
      contactInformation: json['contact_information'] as String? ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'] as String)
          : null,
    );
  }

  /// Converts a [StartupProfileEntity] domain instance into a [StartupProfileModel].
  factory StartupProfileModel.fromEntity(StartupProfileEntity entity) {
    return StartupProfileModel(
      id: entity.id,
      userId: entity.userId,
      startupName: entity.startupName,
      description: entity.description,
      industry: entity.industry,
      fundingStage: entity.fundingStage,
      fundingAmountNeeded: entity.fundingAmountNeeded,
      location: entity.location,
      teamInformation: entity.teamInformation,
      contactInformation: entity.contactInformation,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  /// Converts this model into a JSON map formatted for Supabase database queries.
  Map<String, dynamic> toJson() {
    return {
      if (id.isNotEmpty) 'id': id,
      'user_id': userId,
      'startup_name': startupName,
      'description': description,
      'industry': industry,
      'funding_stage': fundingStage,
      'funding_amount_needed': fundingAmountNeeded,
      'location': location,
      'team_information': teamInformation,
      'contact_information': contactInformation,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
    };
  }

  /// Converts JSON map for Supabase insert operations (excluding auto-generated fields).
  Map<String, dynamic> toInsertJson() {
    return {
      'user_id': userId,
      'startup_name': startupName,
      'description': description,
      'industry': industry,
      'funding_stage': fundingStage,
      'funding_amount_needed': fundingAmountNeeded,
      'location': location,
      'team_information': teamInformation,
      'contact_information': contactInformation,
    };
  }

  /// Converts JSON map for Supabase update operations.
  Map<String, dynamic> toUpdateJson() {
    return {
      'startup_name': startupName,
      'description': description,
      'industry': industry,
      'funding_stage': fundingStage,
      'funding_amount_needed': fundingAmountNeeded,
      'location': location,
      'team_information': teamInformation,
      'contact_information': contactInformation,
      'updated_at': DateTime.now().toIso8601String(),
    };
  }
}
