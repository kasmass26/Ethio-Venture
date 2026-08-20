import '../entities/pending_approval_entity.dart';
import '../repositories/admin_repository.dart';

/// Use case for fetching approved investors.
class GetApprovedInvestors {
  final AdminRepository repository;

  const GetApprovedInvestors(this.repository);

  Future<List<PendingApprovalEntity>> call() async {
    return await repository.getApprovedInvestors();
  }
}
