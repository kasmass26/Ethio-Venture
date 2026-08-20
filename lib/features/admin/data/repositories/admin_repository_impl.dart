import '../../domain/entities/pending_approval_entity.dart';
import '../../domain/repositories/admin_repository.dart';
import '../datasources/admin_remote_data_source.dart';

class AdminRepositoryImpl implements AdminRepository {
  final AdminRemoteDataSource remoteDataSource;

  const AdminRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<PendingApprovalEntity>> getPendingStartups() async {
    return await remoteDataSource.getPendingStartups();
  }

  @override
  Future<List<PendingApprovalEntity>> getPendingInvestors() async {
    return await remoteDataSource.getPendingInvestors();
  }

  @override
  Future<void> approveProfile(String profileId, String role) async {
    return await remoteDataSource.approveProfile(profileId, role);
  }

  @override
  Future<void> rejectProfile(String profileId, String role, String rejectionReason) async {
    return await remoteDataSource.rejectProfile(profileId, role, rejectionReason);
  }

  @override
  Future<List<PendingApprovalEntity>> getApprovedStartups() async {
    return await remoteDataSource.getApprovedStartups();
  }

  @override
  Future<List<PendingApprovalEntity>> getApprovedInvestors() async {
    return await remoteDataSource.getApprovedInvestors();
  }

  @override
  Future<List<PendingApprovalEntity>> getRejectedProfiles() async {
    return await remoteDataSource.getRejectedProfiles();
  }
}
