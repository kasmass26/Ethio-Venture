import 'package:flutter/foundation.dart';

import 'verification_status.dart';
import 'verification_type.dart';

/// Immutable metadata for one user verification request.
///
/// This intentionally contains no identity numbers, document contents,
/// document URLs, storage paths, or raw AI output.
@immutable
class VerificationRequestEntity {
  const VerificationRequestEntity({
    required this.id,
    required this.type,
    required this.status,
    this.submittedAt,
    this.reviewedAt,
    this.message,
    this.resubmissionAllowed,
  });

  final String id;
  final VerificationType type;
  final VerificationStatus status;
  final DateTime? submittedAt;
  final DateTime? reviewedAt;

  /// Safe, backend-provided user-facing rejection or information request.
  final String? message;

  /// Null means the frontend has not received a confirmed backend guarantee.
  final bool? resubmissionAllowed;

  bool get isApproved => status.isApproved;
  bool get isPending => status == VerificationStatus.pending;
  bool get isRejected => status == VerificationStatus.rejected;
  bool get requiresResubmission =>
      status == VerificationStatus.resubmissionRequired;
  bool get requiresAdditionalInformation =>
      status == VerificationStatus.additionalInfoRequired;
}
