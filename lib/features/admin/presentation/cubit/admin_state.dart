import 'package:equatable/equatable.dart';
import '../../domain/entities/pending_approval_entity.dart';

abstract class AdminState extends Equatable {
  const AdminState();

  @override
  List<Object?> get props => [];
}

class AdminInitial extends AdminState {
  const AdminInitial();
}

class AdminLoading extends AdminState {
  const AdminLoading();
}

class AdminProfilesLoaded extends AdminState {
  final List<PendingApprovalEntity> pendingStartups;
  final List<PendingApprovalEntity> pendingInvestors;
  final List<PendingApprovalEntity> approvedStartups;
  final List<PendingApprovalEntity> approvedInvestors;
  final List<PendingApprovalEntity> rejectedProfiles;

  const AdminProfilesLoaded({
    required this.pendingStartups,
    required this.pendingInvestors,
    required this.approvedStartups,
    required this.approvedInvestors,
    required this.rejectedProfiles,
  });

  @override
  List<Object?> get props => [
        pendingStartups,
        pendingInvestors,
        approvedStartups,
        approvedInvestors,
        rejectedProfiles,
      ];

  AdminProfilesLoaded copyWith({
    List<PendingApprovalEntity>? pendingStartups,
    List<PendingApprovalEntity>? pendingInvestors,
    List<PendingApprovalEntity>? approvedStartups,
    List<PendingApprovalEntity>? approvedInvestors,
    List<PendingApprovalEntity>? rejectedProfiles,
  }) {
    return AdminProfilesLoaded(
      pendingStartups: pendingStartups ?? this.pendingStartups,
      pendingInvestors: pendingInvestors ?? this.pendingInvestors,
      approvedStartups: approvedStartups ?? this.approvedStartups,
      approvedInvestors: approvedInvestors ?? this.approvedInvestors,
      rejectedProfiles: rejectedProfiles ?? this.rejectedProfiles,
    );
  }
}

class AdminActionSuccess extends AdminState {
  final String message;

  const AdminActionSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class AdminError extends AdminState {
  final String message;

  const AdminError(this.message);

  @override
  List<Object?> get props => [message];
}
