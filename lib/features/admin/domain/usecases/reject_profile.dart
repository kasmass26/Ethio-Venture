import '../repositories/admin_repository.dart';

/// Use case for rejecting a startup or investor profile.
class RejectProfile {
  final AdminRepository repository;

  const RejectProfile(this.repository);

  Future<void> call({
    required String profileId,
    required String role,
    required String rejectionReason,
  }) async {
    return await repository.rejectProfile(profileId, role, rejectionReason);
  }
}
