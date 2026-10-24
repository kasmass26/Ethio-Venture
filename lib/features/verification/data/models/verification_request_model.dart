import '../../domain/entities/verification_request_entity.dart';
import '../../domain/entities/verification_status.dart';
import '../../domain/entities/verification_type.dart';

/// Supabase-backed representation of verification request metadata.
class VerificationRequestModel extends VerificationRequestEntity {
  const VerificationRequestModel({
    required super.id,
    required super.type,
    required super.status,
    super.submittedAt,
    super.reviewedAt,
    super.message,
    super.resubmissionAllowed,
  });

  factory VerificationRequestModel.fromJson(Map<String, dynamic> json) {
    final type = VerificationType.fromString(
      json['verification_type']?.toString(),
    );
    if (type == null) {
      throw FormatException(
        'Unsupported verification_type: ${json['verification_type']}',
      );
    }

    return VerificationRequestModel(
      id: json['id']?.toString() ?? '',
      type: type,
      status: VerificationStatus.fromString(json['status']?.toString()),
      submittedAt: _parseDateTime(json['submitted_at']),
      reviewedAt: _parseDateTime(json['reviewed_at']),
      message: json['message']?.toString(),
      resubmissionAllowed: json['resubmission_allowed'] is bool
          ? json['resubmission_allowed'] as bool
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'verification_type': type.value,
      'status': status.value,
      'submitted_at': submittedAt?.toIso8601String(),
      'reviewed_at': reviewedAt?.toIso8601String(),
      'message': message,
      'resubmission_allowed': resubmissionAllowed,
    };
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;

    try {
      return DateTime.tryParse(value.toString());
    } catch (_) {
      return null;
    }
  }
}
