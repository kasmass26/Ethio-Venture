import 'package:ethioventure/features/investor_profile/domain/entities/investor_entity.dart';

class InvestorModel extends InvestorEntity {
  const InvestorModel({
    required super.id,
    required super.userId,
    required super.name,
    required super.email,
    required super.companyName,
    required super.bio,
    super.avatarUrl,
    super.preferredIndustries,
    super.preferredFundingStages,
    super.minInvestmentAmount,
    super.maxInvestmentAmount,
    super.preferredLocations,
    required super.createdAt,
  });

  factory InvestorModel.fromJson(Map<String, dynamic> json) {
    return InvestorModel(
      id: json['id'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      companyName: json['company_name'] as String? ?? '',
      bio: json['bio'] as String? ?? '',
      avatarUrl: json['avatar_url'] as String?,
      preferredIndustries: (json['preferred_industries'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      preferredFundingStages: (json['preferred_funding_stages'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      minInvestmentAmount: (json['min_investment_amount'] as num?)?.toDouble(),
      maxInvestmentAmount: (json['max_investment_amount'] as num?)?.toDouble(),
      preferredLocations: (json['preferred_locations'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'email': email,
      'company_name': companyName,
      'bio': bio,
      'avatar_url': avatarUrl,
      'preferred_industries': preferredIndustries,
      'preferred_funding_stages': preferredFundingStages,
      'min_investment_amount': minInvestmentAmount,
      'max_investment_amount': maxInvestmentAmount,
      'preferred_locations': preferredLocations,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory InvestorModel.fromEntity(InvestorEntity entity) {
    return InvestorModel(
      id: entity.id,
      userId: entity.userId,
      name: entity.name,
      email: entity.email,
      companyName: entity.companyName,
      bio: entity.bio,
      avatarUrl: entity.avatarUrl,
      preferredIndustries: entity.preferredIndustries,
      preferredFundingStages: entity.preferredFundingStages,
      minInvestmentAmount: entity.minInvestmentAmount,
      maxInvestmentAmount: entity.maxInvestmentAmount,
      preferredLocations: entity.preferredLocations,
      createdAt: entity.createdAt,
    );
  }
}
