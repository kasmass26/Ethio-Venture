import '../entities/pending_approval_entity.dart';

/// Repository contract for admin operations.
abstract class AdminRepository {
  /// Fetches all startup profiles pending approval.
  Future<List<PendingApprovalEntity>> getPendingStartups();

  /// Fetches all investor profiles pending approval.
  Future<List<PendingApprovalEntity>> getPendingInvestors();

  /// Approves a startup or investor profile.
  Future<void> approveProfile(String profileId, String role);

  /// Rejects a startup or investor profile.
  Future<void> rejectProfile(String profileId, String role);
  
  /// Fetches all approved startups.
  Future<List<PendingApprovalEntity>> getApprovedStartups();
  
  /// Fetches all approved investors.
  Future<List<PendingApprovalEntity>> getApprovedInvestors();
  
  /// Fetches all rejected profiles.
  Future<List<PendingApprovalEntity>> getRejectedProfiles();
}
