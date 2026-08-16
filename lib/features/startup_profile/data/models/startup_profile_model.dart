import '../../domain/entities/startup_profile_entity.dart';
import 'document_model.dart';

class StartupProfileModel extends StartupProfileEntity {
  const StartupProfileModel({
    required super.id,
    super.userId,
    required super.companyName,
    required super.tagline,
    required super.description,
    required super.industry,
    required super.fundingStage,
    required super.targetFundingAmount,
    required super.raisedFundingAmount,
    required super.companyValuation,
    required super.monthlyBurnRate,
    required super.monthlyRevenue,
    required super.location,
    required super.websiteUrl,
    required super.logoUrl,
    required super.founderName,
    required super.founderEmail,
    required super.founderRole,
    required super.teamMembers,
    required super.documents,
    required super.updatedAt,
  });

  factory StartupProfileModel.fromJson(Map<String, dynamic> json) {
    return StartupProfileModel(
      id: (json['id'] ?? json['profile_id'] ?? '').toString(),
      userId: (json['user_id'] ?? json['userId'] ?? '').toString(),
      companyName: (json['company_name'] ?? json['companyName'] ?? '')
          .toString(),
      tagline: (json['tagline'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      industry: (json['industry'] ?? 'FinTech').toString(),
      fundingStage: (json['funding_stage'] ?? json['fundingStage'] ?? 'Seed')
          .toString(),
      targetFundingAmount:
          (json['target_funding_amount'] ?? json['targetFundingAmount'] as num?)
              ?.toDouble() ??
          0.0,
      raisedFundingAmount:
          (json['raised_funding_amount'] ?? json['raisedFundingAmount'] as num?)
              ?.toDouble() ??
          0.0,
      companyValuation:
          (json['company_valuation'] ?? json['companyValuation'] as num?)
              ?.toDouble() ??
          0.0,
      monthlyBurnRate:
          (json['monthly_burn_rate'] ?? json['monthlyBurnRate'] as num?)
              ?.toDouble() ??
          0.0,
      monthlyRevenue:
          (json['monthly_revenue'] ?? json['monthlyRevenue'] as num?)
              ?.toDouble() ??
          0.0,
      location: (json['location'] ?? 'Addis Ababa').toString(),
      websiteUrl: (json['website_url'] ?? json['websiteUrl'] ?? '').toString(),
      logoUrl: (json['logo_url'] ?? json['logoUrl'] ?? '').toString(),
      founderName: (json['founder_name'] ?? json['founderName'] ?? '')
          .toString(),
      founderEmail: (json['founder_email'] ?? json['founderEmail'] ?? '')
          .toString(),
      founderRole:
          (json['founder_role'] ?? json['founderRole'] ?? 'Founder & CEO')
              .toString(),
      teamMembers:
          (json['team_members'] ?? json['teamMembers'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      documents:
          (json['documents'] as List<dynamic>?)
              ?.map((e) => DocumentModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString()) ?? DateTime.now()
          : (json['updatedAt'] != null
                ? DateTime.tryParse(json['updatedAt'].toString()) ??
                      DateTime.now()
                : DateTime.now()),
    );
  }

  /// Converts model to snake_case Map matching Supabase PostgreSQL column names
  Map<String, dynamic> toSupabaseJson() {
    final map = <String, dynamic>{
      'company_name': companyName,
      'tagline': tagline,
      'description': description,
      'industry': industry,
      'funding_stage': fundingStage,
      'target_funding_amount': targetFundingAmount,
      'raised_funding_amount': raisedFundingAmount,
      'company_valuation': companyValuation,
      'monthly_burn_rate': monthlyBurnRate,
      'monthly_revenue': monthlyRevenue,
      'location': location,
      'website_url': websiteUrl,
      'logo_url': logoUrl,
      'founder_name': founderName,
      'founder_email': founderEmail,
      'founder_role': founderRole,
      'team_members': teamMembers,
      'updated_at': updatedAt.toIso8601String(),
    };
    if (id.isNotEmpty) map['id'] = id;
    if (userId.isNotEmpty) map['user_id'] = userId;
    return map;
  }

  Map<String, dynamic> toJson() => toSupabaseJson();

  factory StartupProfileModel.fromEntity(StartupProfileEntity entity) {
    return StartupProfileModel(
      id: entity.id,
      userId: entity.userId,
      companyName: entity.companyName,
      tagline: entity.tagline,
      description: entity.description,
      industry: entity.industry,
      fundingStage: entity.fundingStage,
      targetFundingAmount: entity.targetFundingAmount,
      raisedFundingAmount: entity.raisedFundingAmount,
      companyValuation: entity.companyValuation,
      monthlyBurnRate: entity.monthlyBurnRate,
      monthlyRevenue: entity.monthlyRevenue,
      location: entity.location,
      websiteUrl: entity.websiteUrl,
      logoUrl: entity.logoUrl,
      founderName: entity.founderName,
      founderEmail: entity.founderEmail,
      founderRole: entity.founderRole,
      teamMembers: entity.teamMembers,
      documents: entity.documents
          .map((doc) => DocumentModel.fromEntity(doc))
          .toList(),
      updatedAt: entity.updatedAt,
    );
  }
}
