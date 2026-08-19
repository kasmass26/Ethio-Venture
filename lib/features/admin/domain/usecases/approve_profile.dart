import '../repositories/admin_repository.dart';

/// Use case for approving a startup or investor profile.
class ApproveProfile {
  final AdminRepository repository;

  const ApproveProfile(this.repository);

  Future<void> call({
    required String profileId,
    required String role,
  }) async {
    return await repository.approveProfile(profileId, role);
  }
}
