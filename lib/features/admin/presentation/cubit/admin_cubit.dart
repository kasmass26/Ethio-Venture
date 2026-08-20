import 'dart:developer' as developer;
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/approve_profile.dart';
import '../../domain/usecases/get_approved_investors.dart';
import '../../domain/usecases/get_approved_startups.dart';
import '../../domain/usecases/get_pending_investors.dart';
import '../../domain/usecases/get_pending_startups.dart';
import '../../domain/usecases/get_rejected_profiles.dart';
import '../../domain/usecases/reject_profile.dart';
import 'admin_state.dart';

class AdminCubit extends Cubit<AdminState> {
  final GetPendingStartups getPendingStartups;
  final GetPendingInvestors getPendingInvestors;
  final GetApprovedStartups getApprovedStartups;
  final GetApprovedInvestors getApprovedInvestors;
  final GetRejectedProfiles getRejectedProfiles;
  final ApproveProfile approveProfile;
  final RejectProfile rejectProfile;

  AdminCubit({
    required this.getPendingStartups,
    required this.getPendingInvestors,
    required this.getApprovedStartups,
    required this.getApprovedInvestors,
    required this.getRejectedProfiles,
    required this.approveProfile,
    required this.rejectProfile,
  }) : super(const AdminInitial());

  Future<void> loadAllProfiles() async {
    emit(const AdminLoading());
    try {
      // Load all profile types in parallel for better performance
      final results = await Future.wait([
        getPendingStartups(),
        getPendingInvestors(),
        getApprovedStartups(),
        getApprovedInvestors(),
        getRejectedProfiles(),
      ]);

      final pendingStartups = results[0];
      final pendingInvestors = results[1];
      final approvedStartups = results[2];
      final approvedInvestors = results[3];
      final rejectedProfiles = results[4];

      developer.log(
        'Loaded profiles - Pending: ${pendingStartups.length} startups, ${pendingInvestors.length} investors | '
        'Approved: ${approvedStartups.length} startups, ${approvedInvestors.length} investors | '
        'Rejected: ${rejectedProfiles.length} total',
        name: 'EthioVenture.Admin',
      );

      emit(AdminProfilesLoaded(
        pendingStartups: pendingStartups,
        pendingInvestors: pendingInvestors,
        approvedStartups: approvedStartups,
        approvedInvestors: approvedInvestors,
        rejectedProfiles: rejectedProfiles,
      ));
    } catch (error, stackTrace) {
      developer.log(
        'Failed to load profiles',
        name: 'EthioVenture.Admin',
        error: error,
        stackTrace: stackTrace,
        level: 1000,
      );
      emit(AdminError('Failed to load profiles: ${error.toString()}'));
    }
  }

  Future<void> approve(String profileId, String role) async {
    final currentState = state;
    if (currentState is! AdminProfilesLoaded) return;

    try {
      await approveProfile(profileId: profileId, role: role);

      developer.log(
        'Approved profile: $profileId, role: $role',
        name: 'EthioVenture.Admin',
      );

      // Emit success snackbar first
      emit(const AdminActionSuccess('Profile approved successfully'));

      // Reload profiles in the background and restore state
      await _reloadProfiles(currentState);
    } catch (error, stackTrace) {
      developer.log(
        'Failed to approve profile: $profileId',
        name: 'EthioVenture.Admin',
        error: error,
        stackTrace: stackTrace,
        level: 1000,
      );
      emit(AdminError('Failed to approve: ${error.toString()}'));
      // Restore list so UI doesn't get stuck
      emit(currentState);
    }
  }

  Future<void> reject(
      String profileId, String role, String rejectionReason) async {
    final currentState = state;
    if (currentState is! AdminProfilesLoaded) return;

    try {
      await rejectProfile(
        profileId: profileId,
        role: role,
        rejectionReason: rejectionReason,
      );

      developer.log(
        'Rejected profile: $profileId, role: $role, reason: $rejectionReason',
        name: 'EthioVenture.Admin',
      );

      // Emit success snackbar first
      emit(const AdminActionSuccess('Profile rejected successfully'));

      // Reload profiles in the background and restore state
      await _reloadProfiles(currentState);
    } catch (error, stackTrace) {
      developer.log(
        'Failed to reject profile: $profileId',
        name: 'EthioVenture.Admin',
        error: error,
        stackTrace: stackTrace,
        level: 1000,
      );
      emit(AdminError('Failed to reject: ${error.toString()}'));
      // Restore list so UI doesn't get stuck
      emit(currentState);
    }
  }

  /// Silently reloads all profiles after an approve/reject action.
  /// Does NOT emit AdminLoading to avoid replacing the UI with a spinner.
  Future<void> _reloadProfiles(AdminProfilesLoaded previousState) async {
    try {
      final results = await Future.wait([
        getPendingStartups(),
        getPendingInvestors(),
        getApprovedStartups(),
        getApprovedInvestors(),
        getRejectedProfiles(),
      ]);

      emit(AdminProfilesLoaded(
        pendingStartups: results[0],
        pendingInvestors: results[1],
        approvedStartups: results[2],
        approvedInvestors: results[3],
        rejectedProfiles: results[4],
      ));
    } catch (error) {
      // If reload fails, restore the previous state so the UI is still functional
      developer.log(
        'Failed to reload profiles after action',
        name: 'EthioVenture.Admin',
        error: error,
        level: 900,
      );
      emit(previousState);
    }
  }
}
