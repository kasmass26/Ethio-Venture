import '../entities/public_verification_badge_entity.dart';
import '../repositories/verification_repository.dart';

class GetPublicApprovedBadges {
  const GetPublicApprovedBadges(this._repository);

  final VerificationRepository _repository;

  Future<List<PublicVerificationBadgeEntity>> call(String profileId) {
    return _repository.getPublicApprovedBadges(profileId);
  }
}
