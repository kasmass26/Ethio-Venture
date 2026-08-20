import '../entities/pending_approval_entity.dart';
import '../repositories/admin_repository.dart';

/// Use case for fetching pending investor approvals.
class GetPendingInvestors {
  final AdminRepository repository;

  const GetPendingInvestors(this.repository);

  Future<List<PendingApprovalEntity>> call() async {
    return await repository.getPendingInvestors();
  }
}
