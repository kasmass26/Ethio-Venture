import 'package:flutter/foundation.dart';

/// Domain representation of a row in [public.startup_profiles].
@immutable
class StartupProfileEntity {
  const StartupProfileEntity({
    required this.id,
    required this.userId,
    required this.startupName,
    required this.description,
    required this.industry,
    required this.fundingStage,
    required this.fundingAmountNeeded,
    required this.location,
    required this.teamInformation,
    required this.contactInformation,
    required this.createdAt,
    required this.updatedAt,
    this.approvalStatus = 'pending',
    this.rejectionReason,
    this.approvalDate,
  });

  /// Primary key of the startup_profiles row.
  final String id;

  /// Foreign key → public.profiles.id (= auth.users.id of the founder).
  final String userId;

  /// Public name of the startup.
  final String startupName;

  /// Detailed description of the startup.
  final String description;

  /// Primary industry vertical (e.g. 'Fintech', 'Agri-Tech', 'Health').
  final String industry;

  /// Funding stage the startup is currently seeking.
  final String fundingStage;

  /// City / region the startup is based in.
  final String location;

  /// Capital sought in USD. Maps to [funding_amount_needed] in the DB.
  final double fundingAmountNeeded;

  /// Team and founder details.
  final String teamInformation;

  /// Contact information.
  final String contactInformation;

  final DateTime createdAt;
  final DateTime updatedAt;

  /// Approval status ('pending', 'approved', 'rejected')
  final String approvalStatus;

  /// Admin provided rejection reason if status is 'rejected'
  final String? rejectionReason;

  /// Date of latest approval or rejection
  final DateTime? approvalDate;

  bool get isApproved => approvalStatus == 'approved';
  bool get isPending => approvalStatus == 'pending';
  bool get isRejected => approvalStatus == 'rejected';

  StartupProfileEntity copyWith({
    String? id,
    String? userId,
    String? startupName,
    String? description,
    String? industry,
    String? fundingStage,
    double? fundingAmountNeeded,
    String? location,
    String? teamInformation,
    String? contactInformation,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? approvalStatus,
    String? rejectionReason,
    DateTime? approvalDate,
  }) {
    return StartupProfileEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      startupName: startupName ?? this.startupName,
      description: description ?? this.description,
      industry: industry ?? this.industry,
      fundingStage: fundingStage ?? this.fundingStage,
      fundingAmountNeeded: fundingAmountNeeded ?? this.fundingAmountNeeded,
      location: location ?? this.location,
      teamInformation: teamInformation ?? this.teamInformation,
      contactInformation: contactInformation ?? this.contactInformation,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      approvalStatus: approvalStatus ?? this.approvalStatus,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      approvalDate: approvalDate ?? this.approvalDate,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is StartupProfileEntity &&
            id == other.id &&
            userId == other.userId &&
            startupName == other.startupName &&
            description == other.description &&
            industry == other.industry &&
            fundingStage == other.fundingStage &&
            location == other.location &&
            fundingAmountNeeded == other.fundingAmountNeeded &&
            teamInformation == other.teamInformation &&
            contactInformation == other.contactInformation &&
            createdAt == other.createdAt &&
            updatedAt == other.updatedAt &&
            approvalStatus == other.approvalStatus &&
            rejectionReason == other.rejectionReason &&
            approvalDate == other.approvalDate;
  }

  @override
  int get hashCode => Object.hash(
        id,
        userId,
        startupName,
        description,
        industry,
        fundingStage,
        location,
        fundingAmountNeeded,
        teamInformation,
        contactInformation,
        createdAt,
        updatedAt,
        approvalStatus,
        rejectionReason,
        approvalDate,
      );
}
