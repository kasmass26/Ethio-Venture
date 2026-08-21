import '../../domain/entities/pending_approval_entity.dart';

/// Data model for pending approval profiles.
class PendingApprovalModel extends PendingApprovalEntity {
  const PendingApprovalModel({
    required super.id,
    required super.userId,
    required super.name,
    required super.email,
    required super.role,
    required super.businessName,
    required super.description,
    required super.industry,
    required super.fundingStage,
    required super.fundingAmountSought,
    required super.location,
    super.logoUrl,
    required super.createdAt,
    required super.approvalStatus,
    super.rejectionReason,
    super.approvalDate,
    super.rejectionCount = 0,
  });

  /// Creates a model from Supabase JSON response.
  factory PendingApprovalModel.fromJson(Map<String, dynamic> json) {
    DateTime? parsedApprovalDate;
    if (json['approval_date'] != null) {
      try {
        parsedApprovalDate = DateTime.parse(json['approval_date'].toString());
      } catch (_) {
        parsedApprovalDate = null;
      }
    }

    return PendingApprovalModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      name: json['name'] as String? ?? 'Unknown',
      email: json['email'] as String? ?? '',
      role: json['role'] as String? ?? 'founder',
      businessName: json['business_name'] as String? ?? 'N/A',
      description: json['description'] as String? ?? '',
      industry: json['industry'] as String? ?? '',
      fundingStage: json['funding_stage'] as String? ?? '',
      fundingAmountSought: (json['funding_amount_sought'] as num?)?.toDouble() ?? 0.0,
      location: json['location'] as String? ?? '',
      logoUrl: json['logo_url'] as String?,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      approvalStatus: json['approval_status'] as String? ?? 'pending',
      rejectionReason: json['rejection_reason'] as String?,
      approvalDate: parsedApprovalDate,
      rejectionCount: (json['rejection_count'] as num?)?.toInt() ?? 0,
    );
  }

  /// Converts model to JSON for Supabase requests.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'email': email,
      'role': role,
      'business_name': businessName,
      'description': description,
      'industry': industry,
      'funding_stage': fundingStage,
      'funding_amount_sought': fundingAmountSought,
      'location': location,
      'logo_url': logoUrl,
      'created_at': createdAt.toIso8601String(),
      'approval_status': approvalStatus,
      'rejection_reason': rejectionReason,
      'approval_date': approvalDate?.toIso8601String(),
      'rejection_count': rejectionCount,
    };
  }
}
