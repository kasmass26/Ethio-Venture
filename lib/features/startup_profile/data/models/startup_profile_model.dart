import 'package:ethioventure/features/startup_profile/domain/entities/startup_profile_entity.dart';

/// Data-layer representation of a row in [public.startup_profiles].
///
/// Extends [StartupProfileEntity] so it can be returned anywhere the domain
/// type is expected.
///
/// Column mapping (DB → Dart):
///   id                     → id
///   user_id                → userId
///   startup_name           → startupName
///   description            → description
///   industry               → industry
///   funding_stage          → fundingStage
///   location               → location
///   funding_amount_needed  → fundingAmountNeeded
///   team_information       → teamInformation
///   contact_information    → contactInformation
///   created_at             → createdAt
///   updated_at             → updatedAt
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
    required super.createdAt,
    required super.updatedAt,
    super.approvalStatus = 'pending',
    super.rejectionReason,
    super.approvalDate,
    super.rejectionCount = 0,
  });

  factory StartupProfileModel.fromJson(Map<String, dynamic> json) {
    String cleanString(dynamic val) {
      if (val == null) return '';
      final str = val.toString().trim();
      if (str.isEmpty || str.toLowerCase() == 'null' || str.toLowerCase() == 'undefined') return '';
      return str;
    }

    final name = cleanString(json['startup_name']).isNotEmpty
        ? cleanString(json['startup_name'])
        : cleanString(json['business_name']);

    final amount = _parseDouble(json['funding_amount_needed']) ??
        _parseDouble(json['funding_amount_sought']) ??
        0.0;

    final teamInfo = cleanString(json['team_information']).isNotEmpty
        ? cleanString(json['team_information'])
        : cleanString(json['team_overview']).isNotEmpty
            ? cleanString(json['team_overview'])
            : cleanString(json['team_details']).isNotEmpty
                ? cleanString(json['team_details'])
                : cleanString(json['team']);

    final contactInfo = cleanString(json['contact_information']).isNotEmpty
        ? cleanString(json['contact_information'])
        : cleanString(json['contact_info']).isNotEmpty
            ? cleanString(json['contact_info'])
            : cleanString(json['contact_email']).isNotEmpty
                ? cleanString(json['contact_email'])
                : cleanString(json['contact_details']).isNotEmpty
                    ? cleanString(json['contact_details'])
                    : cleanString(json['contact']);

    DateTime parsedCreated;
    try {
      parsedCreated = json['created_at'] != null
          ? DateTime.parse(json['created_at'].toString())
          : DateTime.now();
    } catch (_) {
      parsedCreated = DateTime.now();
    }

    DateTime parsedUpdated;
    try {
      parsedUpdated = json['updated_at'] != null
          ? DateTime.parse(json['updated_at'].toString())
          : DateTime.now();
    } catch (_) {
      parsedUpdated = DateTime.now();
    }

    DateTime? parsedApprovalDate;
    if (json['approval_date'] != null) {
      try {
        parsedApprovalDate = DateTime.parse(json['approval_date'].toString());
      } catch (_) {
        parsedApprovalDate = null;
      }
    }

    return StartupProfileModel(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      startupName: name,
      description: json['description']?.toString() ?? '',
      industry: json['industry']?.toString() ?? '',
      fundingStage: json['funding_stage']?.toString() ?? '',
      location: json['location']?.toString() ?? '',
      fundingAmountNeeded: amount,
      teamInformation: teamInfo,
      contactInformation: contactInfo,
      createdAt: parsedCreated,
      updatedAt: parsedUpdated,
      approvalStatus: json['approval_status']?.toString() ?? 'pending',
      rejectionReason: json['rejection_reason']?.toString(),
      approvalDate: parsedApprovalDate,
      rejectionCount: (json['rejection_count'] as num?)?.toInt() ?? 0,
    );
  }

  factory StartupProfileModel.fromEntity(StartupProfileEntity entity) {
    return StartupProfileModel(
      id: entity.id,
      userId: entity.userId,
      startupName: entity.startupName,
      description: entity.description,
      industry: entity.industry,
      fundingStage: entity.fundingStage,
      location: entity.location,
      fundingAmountNeeded: entity.fundingAmountNeeded,
      teamInformation: entity.teamInformation,
      contactInformation: entity.contactInformation,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      approvalStatus: entity.approvalStatus,
      rejectionReason: entity.rejectionReason,
      approvalDate: entity.approvalDate,
      rejectionCount: entity.rejectionCount,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'startup_name': startupName,
      'description': description,
      'industry': industry,
      'funding_stage': fundingStage,
      'location': location,
      'funding_amount_needed': fundingAmountNeeded,
      'team_information': teamInformation,
      'contact_information': contactInformation,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'approval_status': approvalStatus,
      'rejection_reason': rejectionReason,
      'approval_date': approvalDate?.toIso8601String(),
      'rejection_count': rejectionCount,
    };
  }

  Map<String, dynamic> toInsertJson() {
    return {
      'user_id': userId,
      'startup_name': startupName,
      'description': description,
      'industry': industry,
      'funding_stage': fundingStage,
      'location': location,
      'funding_amount_needed': fundingAmountNeeded,
      'team_information': teamInformation,
      'contact_information': contactInformation,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'approval_status': approvalStatus,
      'rejection_reason': rejectionReason,
      'approval_date': approvalDate?.toIso8601String(),
      'rejection_count': rejectionCount,
    };
  }

  Map<String, dynamic> toUpdateJson() {
    return {
      'startup_name': startupName,
      'description': description,
      'industry': industry,
      'funding_stage': fundingStage,
      'location': location,
      'funding_amount_needed': fundingAmountNeeded,
      'team_information': teamInformation,
      'contact_information': contactInformation,
      'updated_at': updatedAt.toIso8601String(),
      'approval_status': approvalStatus,
      'rejection_reason': rejectionReason,
      'approval_date': approvalDate?.toIso8601String(),
      'rejection_count': rejectionCount,
    };
  }

  // ── Private helpers ────────────────────────────────────────────────────────

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }
}
