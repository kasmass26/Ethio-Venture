import 'package:ethioventure/features/startup_profile/domain/entities/startup_entity.dart';

class StartupModel extends StartupEntity {
  const StartupModel({
    required super.id,
    required super.founderId,
    required super.name,
    required super.tagline,
    required super.description,
    required super.industry,
    super.secondaryIndustries,
    required super.fundingStage,
    required super.targetFunding,
    super.minTicketSize,
    required super.location,
    super.logoUrl,
    super.website,
    super.pitchDeckUrl,
    super.tractionHighlights,
    required super.createdAt,
  });

  factory StartupModel.fromJson(Map<String, dynamic> json) {
    return StartupModel(
      id: json['id'] as String? ?? '',
      founderId: json['founder_id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      tagline: json['tagline'] as String? ?? '',
      description: json['description'] as String? ?? '',
      industry: json['industry'] as String? ?? 'General',
      secondaryIndustries: (json['secondary_industries'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      fundingStage: json['funding_stage'] as String? ?? 'Seed',
      targetFunding: (json['target_funding'] as num?)?.toDouble() ?? 0.0,
      minTicketSize: (json['min_ticket_size'] as num?)?.toDouble(),
      location: json['location'] as String? ?? 'Addis Ababa',
      logoUrl: json['logo_url'] as String?,
      website: json['website'] as String?,
      pitchDeckUrl: json['pitch_deck_url'] as String?,
      tractionHighlights: json['traction_highlights'] is Map<String, dynamic>
          ? json['traction_highlights'] as Map<String, dynamic>
          : {},
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'founder_id': founderId,
      'name': name,
      'tagline': tagline,
      'description': description,
      'industry': industry,
      'secondary_industries': secondaryIndustries,
      'funding_stage': fundingStage,
      'target_funding': targetFunding,
      'min_ticket_size': minTicketSize,
      'location': location,
      'logo_url': logoUrl,
      'website': website,
      'pitch_deck_url': pitchDeckUrl,
      'traction_highlights': tractionHighlights,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory StartupModel.fromEntity(StartupEntity entity) {
    return StartupModel(
      id: entity.id,
      founderId: entity.founderId,
      name: entity.name,
      tagline: entity.tagline,
      description: entity.description,
      industry: entity.industry,
      secondaryIndustries: entity.secondaryIndustries,
      fundingStage: entity.fundingStage,
      targetFunding: entity.targetFunding,
      minTicketSize: entity.minTicketSize,
      location: entity.location,
      logoUrl: entity.logoUrl,
      website: entity.website,
      pitchDeckUrl: entity.pitchDeckUrl,
      tractionHighlights: entity.tractionHighlights,
      createdAt: entity.createdAt,
    );
  }
}
