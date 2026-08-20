/// Domain entity representing a user profile pending admin approval.
class PendingApprovalEntity {
  const PendingApprovalEntity({
    required this.id,
    required this.userId,
    required this.name,
    required this.email,
    required this.role,
    required this.businessName,
    required this.description,
    required this.industry,
    required this.fundingStage,
    required this.fundingAmountSought,
    required this.location,
    this.logoUrl,
    required this.createdAt,
    required this.approvalStatus,
    this.rejectionReason,
    this.approvalDate,
    this.rejectionCount = 0,
  });

  final String id;
  final String userId;
  final String name;
  final String email;
  final String role;
  final String businessName;
  final String description;
  final String industry;
  final String fundingStage;
  final double fundingAmountSought;
  final String location;
  final String? logoUrl;
  final DateTime createdAt;
  final String approvalStatus; // 'pending', 'approved', 'rejected'
  final String? rejectionReason;
  final DateTime? approvalDate;
  final int rejectionCount;

  PendingApprovalEntity copyWith({
    String? id,
    String? userId,
    String? name,
    String? email,
    String? role,
    String? businessName,
    String? description,
    String? industry,
    String? fundingStage,
    double? fundingAmountSought,
    String? location,
    String? logoUrl,
    DateTime? createdAt,
    String? approvalStatus,
    String? rejectionReason,
    DateTime? approvalDate,
    int? rejectionCount,
  }) {
    return PendingApprovalEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      businessName: businessName ?? this.businessName,
      description: description ?? this.description,
      industry: industry ?? this.industry,
      fundingStage: fundingStage ?? this.fundingStage,
      fundingAmountSought: fundingAmountSought ?? this.fundingAmountSought,
      location: location ?? this.location,
      logoUrl: logoUrl ?? this.logoUrl,
      createdAt: createdAt ?? this.createdAt,
      approvalStatus: approvalStatus ?? this.approvalStatus,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      approvalDate: approvalDate ?? this.approvalDate,
      rejectionCount: rejectionCount ?? this.rejectionCount,
    );
  }
}
