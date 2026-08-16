import '../../domain/entities/startup_entity.dart';

class StartupModel extends StartupEntity {
  const StartupModel({
    required super.id,
    required super.name,
    required super.tagline,
    required super.description,
    required super.industry,
    required super.fundingStage,
    required super.targetAmount,
    required super.raisedAmount,
    required super.location,
    required super.logoUrl,
    required super.pitchDeckUrl,
    required super.founderName,
    required super.tags,
    required super.rating,
    required super.createdAt,
  });

  factory StartupModel.fromJson(Map<String, dynamic> json) {
    return StartupModel(
      id: json['id'] as String,
      name: json['name'] as String,
      tagline: json['tagline'] as String? ?? '',
      description: json['description'] as String? ?? '',
      industry: json['industry'] as String? ?? 'General',
      fundingStage: json['fundingStage'] as String? ?? 'Seed',
      targetAmount: (json['targetAmount'] as num?)?.toDouble() ?? 0.0,
      raisedAmount: (json['raisedAmount'] as num?)?.toDouble() ?? 0.0,
      location: json['location'] as String? ?? 'Addis Ababa',
      logoUrl: json['logoUrl'] as String? ?? '',
      pitchDeckUrl: json['pitchDeckUrl'] as String? ?? '',
      founderName: json['founderName'] as String? ?? 'Founder',
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
          [],
      rating: (json['rating'] as num?)?.toDouble() ?? 4.5,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'tagline': tagline,
      'description': description,
      'industry': industry,
      'fundingStage': fundingStage,
      'targetAmount': targetAmount,
      'raisedAmount': raisedAmount,
      'location': location,
      'logoUrl': logoUrl,
      'pitchDeckUrl': pitchDeckUrl,
      'founderName': founderName,
      'tags': tags,
      'rating': rating,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory StartupModel.fromEntity(StartupEntity entity) {
    return StartupModel(
      id: entity.id,
      name: entity.name,
      tagline: entity.tagline,
      description: entity.description,
      industry: entity.industry,
      fundingStage: entity.fundingStage,
      targetAmount: entity.targetAmount,
      raisedAmount: entity.raisedAmount,
      location: entity.location,
      logoUrl: entity.logoUrl,
      pitchDeckUrl: entity.pitchDeckUrl,
      founderName: entity.founderName,
      tags: entity.tags,
      rating: entity.rating,
      createdAt: entity.createdAt,
    );
  }
}
