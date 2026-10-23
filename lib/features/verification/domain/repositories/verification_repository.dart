import '../entities/public_verification_badge_entity.dart';
import '../entities/verification_request_entity.dart';
import '../entities/verification_type.dart';

/// Domain contract for user verification requests and public badge results.
///
/// Backend implementation details and evidence uploads are intentionally
/// excluded. Start request support depends on a backend contract and returns
/// the trusted request metadata when that contract is available.
abstract interface class VerificationRepository {
  Future<List<VerificationRequestEntity>> getCurrentUserRequests();

  Future<List<PublicVerificationBadgeEntity>> getPublicApprovedBadges(
    String profileId,
  );

  Future<VerificationRequestEntity> startVerificationRequest(
    VerificationType type,
  );
}
