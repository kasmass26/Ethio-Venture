import '../models/pending_approval_model.dart';

/// Remote data source contract for admin operations.
abstract class AdminRemoteDataSource {
  /// Fetches all startup profiles pending approval from Supabase.
  Future<List<PendingApprovalModel>> getPendingStartups();

  /// Fetches all investor profiles pending approval from Supabase.
  Future<List<PendingApprovalModel>> getPendingInvestors();

  /// Approves a profile in Supabase.
  Future<void> approveProfile(String profileId, String role);

  /// Rejects a profile in Supabase with a mandatory reason.
  Future<void> rejectProfile(String profileId, String role, String rejectionReason);
  
  /// Fetches all approved startups.
  Future<List<PendingApprovalModel>> getApprovedStartups();
  
  /// Fetches all approved investors.
  Future<List<PendingApprovalModel>> getApprovedInvestors();
  
  /// Fetches all rejected profiles.
  Future<List<PendingApprovalModel>> getRejectedProfiles();
}
