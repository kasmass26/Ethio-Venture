import '../entities/pending_approval_entity.dart';
import '../repositories/admin_repository.dart';

/// Use case for fetching pending startup approvals.
class GetPendingStartups {
  final AdminRepository repository;

  const GetPendingStartups(this.repository);

  Future<List<PendingApprovalEntity>> call() async {
    return await repository.getPendingStartups();
  }
}
