import 'package:equatable/equatable.dart';
import 'document_entity.dart';

/// Entity representing full Startup Profile details.
class StartupProfileEntity extends Equatable {
  final String id;
  final String userId;
  final String companyName;
  final String tagline;
  final String description;
  final String industry;
  final String fundingStage;
  final double targetFundingAmount;
  final double raisedFundingAmount;
  final double companyValuation;
  final double monthlyBurnRate;
  final double monthlyRevenue;
  final String location;
  final String websiteUrl;
  final String logoUrl;
  final String founderName;
  final String founderEmail;
  final String founderRole;
  final List<String> teamMembers;
  final List<DocumentEntity> documents;
  final DateTime updatedAt;

  const StartupProfileEntity({
    required this.id,
    this.userId = '',
    required this.companyName,
    required this.tagline,
    required this.description,
    required this.industry,
    required this.fundingStage,
    required this.targetFundingAmount,
    required this.raisedFundingAmount,
    required this.companyValuation,
    required this.monthlyBurnRate,
    required this.monthlyRevenue,
    required this.location,
    required this.websiteUrl,
    required this.logoUrl,
    required this.founderName,
    required this.founderEmail,
    required this.founderRole,
    required this.teamMembers,
    required this.documents,
    required this.updatedAt,
  });

  double get fundingProgressPercentage {
    if (targetFundingAmount <= 0) return 0.0;
    return (raisedFundingAmount / targetFundingAmount).clamp(0.0, 1.0);
  }

  DocumentEntity? get pitchDeck {
    try {
      return documents.firstWhere((doc) => doc.isPitchDeck);
    } catch (_) {
      return null;
    }
  }

  StartupProfileEntity copyWith({
    String? id,
    String? userId,
    String? companyName,
    String? tagline,
    String? description,
    String? industry,
    String? fundingStage,
    double? targetFundingAmount,
    double? raisedFundingAmount,
    double? companyValuation,
    double? monthlyBurnRate,
    double? monthlyRevenue,
    String? location,
    String? websiteUrl,
    String? logoUrl,
    String? founderName,
    String? founderEmail,
    String? founderRole,
    List<String>? teamMembers,
    List<DocumentEntity>? documents,
    DateTime? updatedAt,
  }) {
    return StartupProfileEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      companyName: companyName ?? this.companyName,
      tagline: tagline ?? this.tagline,
      description: description ?? this.description,
      industry: industry ?? this.industry,
      fundingStage: fundingStage ?? this.fundingStage,
      targetFundingAmount: targetFundingAmount ?? this.targetFundingAmount,
      raisedFundingAmount: raisedFundingAmount ?? this.raisedFundingAmount,
      companyValuation: companyValuation ?? this.companyValuation,
      monthlyBurnRate: monthlyBurnRate ?? this.monthlyBurnRate,
      monthlyRevenue: monthlyRevenue ?? this.monthlyRevenue,
      location: location ?? this.location,
      websiteUrl: websiteUrl ?? this.websiteUrl,
      logoUrl: logoUrl ?? this.logoUrl,
      founderName: founderName ?? this.founderName,
      founderEmail: founderEmail ?? this.founderEmail,
      founderRole: founderRole ?? this.founderRole,
      teamMembers: teamMembers ?? this.teamMembers,
      documents: documents ?? this.documents,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    companyName,
    tagline,
    description,
    industry,
    fundingStage,
    targetFundingAmount,
    raisedFundingAmount,
    companyValuation,
    monthlyBurnRate,
    monthlyRevenue,
    location,
    websiteUrl,
    logoUrl,
    founderName,
    founderEmail,
    founderRole,
    teamMembers,
    documents,
    updatedAt,
  ];
}
