import 'package:flutter/foundation.dart';

import 'verification_request_entity.dart';
import 'verification_status.dart';
import 'verification_type.dart';

/// Public verification metadata that is safe to display on a profile.
///
/// An instance can only be created from an explicitly approved verification
/// request. Profile approval and pending, rejected, or AI-related states do
/// not create an instance of this entity.
@immutable
class PublicVerificationBadgeEntity {
  const PublicVerificationBadgeEntity._({
    required this.type,
    this.approvedAt,
  });

  final VerificationType type;
  final DateTime? approvedAt;

  /// Always true because instances are constructed only by the approved factory.
  bool get isAuthoritativelyApproved => true;

  static PublicVerificationBadgeEntity? fromApprovedRequest(
    VerificationRequestEntity request,
  ) {
    if (request.status != VerificationStatus.approved) return null;

    return PublicVerificationBadgeEntity._(
      type: request.type,
      approvedAt: request.reviewedAt,
    );
  }
}
