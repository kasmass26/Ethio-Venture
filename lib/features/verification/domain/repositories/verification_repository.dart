import 'dart:typed_data';

import '../entities/public_verification_badge_entity.dart';
import '../entities/verification_request_entity.dart';
import '../entities/verification_type.dart';

/// Domain contract for user verification requests, document submission,
/// and public badge retrieval.
abstract interface class VerificationRepository {
  /// Returns all verification requests for the authenticated user.
  Future<List<VerificationRequestEntity>> getCurrentUserRequests();

  /// Creates a pending request, uploads the document, and stores metadata.
  /// [fileBytes] must be non-empty and ≤ 10 MB.
  Future<VerificationRequestEntity> submitWithDocument({
    required VerificationType type,
    required Uint8List fileBytes,
    required String filename,
    required int fileSizeBytes,
  });

  /// Creates a minimal pending request without uploading a document.
  /// Kept for backward compatibility with existing tests and the cubit.
  Future<VerificationRequestEntity> startVerificationRequest(
    VerificationType type,
  );

  /// Returns public approved-badge data for [profileId].
  /// Only type and approval timestamp are exposed; no private data.
  Future<List<PublicVerificationBadgeEntity>> getPublicApprovedBadges(
    String profileId,
  );
}
