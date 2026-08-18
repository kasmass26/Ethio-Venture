import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/startup_profile_entity.dart';

/// Data model representing a Startup Profile in the Data Layer.
///
/// Matches the official `20260817185651_create_startup_profiles.sql` table schema
/// (`startup_name`, `funding_amount_needed`, `team_information`, `contact_information`).
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
    String parsedTeamInfo = '';
    if (json['team_information'] != null) {
      parsedTeamInfo = json['team_information'].toString();
    } else if (json['team_members'] != null) {
      if (json['team_members'] is List) {
        parsedTeamInfo = (json['team_members'] as List).join(', ');
      } else {
        parsedTeamInfo = json['team_members'].toString();
      }
    }

    return StartupProfileModel(
      id: (json['id'] ?? json['profile_id'] ?? '').toString(),
      userId: (json['user_id'] ?? json['userId'] ?? '').toString(),
      startupName: (json['startup_name'] ??
              json['company_name'] ??
              json['companyName'] ??
              '')
          .toString(),
      description: (json['description'] ?? '').toString(),
      industry: (json['industry'] ?? 'Fintech').toString(),
      fundingStage:
          (json['funding_stage'] ?? json['fundingStage'] ?? 'MVP').toString(),
      fundingAmountNeeded: (json['funding_amount_needed'] ??
                  json['target_funding_amount'] ??
                  json['targetFundingAmount'] as num?)
              ?.toDouble() ??
          0.0,
      location: (json['location'] ?? 'Addis Ababa, Ethiopia').toString(),
      teamInformation: parsedTeamInfo,
      contactInformation: (json['contact_information'] ??
              json['founder_email'] ??
              json['founderEmail'] ??
              '')
          .toString(),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
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

  /// Standard Insert payload matching `20260817185651_create_startup_profiles.sql`.
  Map<String, dynamic> toInsertJson() {
    final currentAuthUserId = Supabase.instance.client.auth.currentUser?.id;

    final map = <String, dynamic>{
      'startup_name': startupName,
      'description': description,
      'industry': industry,
      'funding_stage': fundingStage,
      'funding_amount_needed': fundingAmountNeeded,
      'location': location,
      'team_information': teamInformation,
      'contact_information': contactInformation,
    };

    if (currentAuthUserId != null && currentAuthUserId.isNotEmpty) {
      map['user_id'] = currentAuthUserId;
    } else if (userId.isNotEmpty && userId != '00000000-0000-0000-0000-000000000000') {
      map['user_id'] = userId;
    }

    return map;
  }

  /// Standard Update payload matching `20260817185651_create_startup_profiles.sql`.
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

  /// Fallback Insert payload for alternative database schemas.
  Map<String, dynamic> toAlternativeInsertJson() {
    final currentAuthUserId = Supabase.instance.client.auth.currentUser?.id;

    final map = <String, dynamic>{
      'company_name': startupName,
      'description': description,
      'industry': industry,
      'funding_stage': fundingStage,
      'target_funding_amount': fundingAmountNeeded,
      'location': location,
      'team_members': [teamInformation],
      'founder_email': contactInformation.contains('@')
          ? contactInformation
          : 'founder@ethioventure.com',
    };

    if (currentAuthUserId != null && currentAuthUserId.isNotEmpty) {
      map['user_id'] = currentAuthUserId;
    } else if (userId.isNotEmpty && userId != '00000000-0000-0000-0000-000000000000') {
      map['user_id'] = userId;
    }

    return map;
  }

  /// Fallback Update payload for alternative database schemas.
  Map<String, dynamic> toAlternativeUpdateJson() {
    return {
      'company_name': startupName,
      'description': description,
      'industry': industry,
      'funding_stage': fundingStage,
      'target_funding_amount': fundingAmountNeeded,
      'location': location,
      'team_members': [teamInformation],
      'founder_email': contactInformation.contains('@')
          ? contactInformation
          : 'founder@ethioventure.com',
      'updated_at': DateTime.now().toIso8601String(),
    };
  }
}
