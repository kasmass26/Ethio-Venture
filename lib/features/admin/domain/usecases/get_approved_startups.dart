import '../entities/pending_approval_entity.dart';
import '../repositories/admin_repository.dart';

/// Use case for fetching approved startups.
class GetApprovedStartups {
  final AdminRepository repository;

  const GetApprovedStartups(this.repository);

  Future<List<PendingApprovalEntity>> call() async {
    return await repository.getApprovedStartups();
  }
}
