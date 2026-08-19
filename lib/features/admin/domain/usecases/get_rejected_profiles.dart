import '../entities/pending_approval_entity.dart';
import '../repositories/admin_repository.dart';

/// Use case for fetching all rejected profiles (both startups and investors).
class GetRejectedProfiles {
  final AdminRepository repository;

  const GetRejectedProfiles(this.repository);

  Future<List<PendingApprovalEntity>> call() async {
    return await repository.getRejectedProfiles();
  }
}
