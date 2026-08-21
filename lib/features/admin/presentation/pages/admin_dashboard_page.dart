import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../domain/entities/pending_approval_entity.dart';
import '../cubit/admin_cubit.dart';
import '../cubit/admin_state.dart';
import '../widgets/approval_stats_card.dart';
import '../widgets/pending_profile_card.dart';

final getIt = GetIt.instance;

class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<AdminCubit>()..loadAllProfiles(),
      child: Scaffold(
        backgroundColor: AppColors.fog,
        appBar: AppBar(
          backgroundColor: AppColors.white,
          foregroundColor: AppColors.ink,
          elevation: 0,
          title: const Text(
            'Approvals & Verification',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh_rounded),
              tooltip: 'Refresh',
              onPressed: () {
                // Read from cubit inside builder or using Builder widget
              },
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(
              height: 1,
              color: AppColors.hairline,
            ),
          ),
        ),
        body: const _AdminDashboardContent(),
      ),
    );
  }
}

class _AdminDashboardContent extends StatefulWidget {
  const _AdminDashboardContent();

  @override
  State<_AdminDashboardContent> createState() => _AdminDashboardContentState();
}

class _AdminDashboardContentState extends State<_AdminDashboardContent>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedStatusFilter = 'pending'; // 'pending', 'approved', 'rejected'

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AdminCubit, AdminState>(
      listener: (context, state) {
        if (state is AdminActionSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: AppColors.white),
                  const SizedBox(width: AppSizes.sm),
                  Expanded(child: Text(state.message)),
                ],
              ),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else if (state is AdminError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error, color: AppColors.white),
                  const SizedBox(width: AppSizes.sm),
                  Expanded(child: Text(state.message)),
                ],
              ),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      builder: (context, state) {
        if (state is AdminLoading) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        if (state is AdminError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 64,
                  color: AppColors.error,
                ),
                const SizedBox(height: AppSizes.md),
                Text(
                  state.message,
                  style: const TextStyle(color: AppColors.slate),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSizes.lg),
                ElevatedButton.icon(
                  onPressed: () => context.read<AdminCubit>().loadAllProfiles(),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (state is AdminProfilesLoaded) {
          final totalPending = state.pendingStartups.length +
              state.pendingInvestors.length;
          final totalApproved = state.approvedStartups.length +
              state.approvedInvestors.length;
          final totalRejected = state.rejectedProfiles.length;

          // Categorized lists
          final List<PendingApprovalEntity> startupList;
          final List<PendingApprovalEntity> investorList;

          if (_selectedStatusFilter == 'pending') {
            startupList = state.pendingStartups;
            investorList = state.pendingInvestors;
          } else if (_selectedStatusFilter == 'approved') {
            startupList = state.approvedStartups;
            investorList = state.approvedInvestors;
          } else {
            // rejected
            startupList = state.rejectedProfiles
                .where((p) => p.role == 'founder')
                .toList();
            investorList = state.rejectedProfiles
                .where((p) => p.role == 'investor')
                .toList();
          }

          return Column(
            children: [
              // Stats Row (Interactive Filter Cards)
              Container(
                color: AppColors.white,
                padding: const EdgeInsets.all(AppSizes.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              setState(() => _selectedStatusFilter = 'pending');
                            },
                            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                                border: Border.all(
                                  color: _selectedStatusFilter == 'pending'
                                      ? AppColors.warning
                                      : Colors.transparent,
                                  width: 2,
                                ),
                              ),
                              child: ApprovalStatsCard(
                                title: 'Pending',
                                count: totalPending,
                                icon: Icons.pending_actions,
                                color: AppColors.warning,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSizes.sm),
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              setState(() => _selectedStatusFilter = 'approved');
                            },
                            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                                border: Border.all(
                                  color: _selectedStatusFilter == 'approved'
                                      ? AppColors.success
                                      : Colors.transparent,
                                  width: 2,
                                ),
                              ),
                              child: ApprovalStatsCard(
                                title: 'Approved',
                                count: totalApproved,
                                icon: Icons.check_circle,
                                color: AppColors.success,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSizes.sm),
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              setState(() => _selectedStatusFilter = 'rejected');
                            },
                            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                                border: Border.all(
                                  color: _selectedStatusFilter == 'rejected'
                                      ? AppColors.error
                                      : Colors.transparent,
                                  width: 2,
                                ),
                              ),
                              child: ApprovalStatsCard(
                                title: 'Rejected',
                                count: totalRejected,
                                icon: Icons.cancel,
                                color: AppColors.error,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSizes.sm),
                    // Current Status indicator chip
                    Row(
                      children: [
                        Text(
                          'Viewing ${_selectedStatusFilter.toUpperCase()} profiles',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.slate,
                          ),
                        ),
                        const Spacer(),
                        if (_selectedStatusFilter != 'pending')
                          TextButton.icon(
                            onPressed: () {
                              setState(() => _selectedStatusFilter = 'pending');
                            },
                            icon: const Icon(Icons.arrow_back, size: 14),
                            label: const Text('Back to Pending'),
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: const Size(50, 24),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),

              // Tabs
              Container(
                color: AppColors.white,
                child: TabBar(
                  controller: _tabController,
                  indicatorColor: AppColors.primary,
                  indicatorWeight: 3,
                  labelColor: AppColors.ink,
                  unselectedLabelColor: AppColors.slate,
                  labelStyle: const TextStyle(fontWeight: FontWeight.w600),
                  tabs: [
                    Tab(
                      icon: const Icon(Icons.business),
                      text: 'Startups (${startupList.length})',
                    ),
                    Tab(
                      icon: const Icon(Icons.account_balance),
                      text: 'Investors (${investorList.length})',
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),

              // Tabbed Content
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    await context.read<AdminCubit>().loadAllProfiles();
                  },
                  color: AppColors.primary,
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildProfilesList(
                        context,
                        profiles: startupList,
                        typeLabel: 'startup',
                        status: _selectedStatusFilter,
                      ),
                      _buildProfilesList(
                        context,
                        profiles: investorList,
                        typeLabel: 'investor',
                        status: _selectedStatusFilter,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildProfilesList(
    BuildContext context, {
    required List<PendingApprovalEntity> profiles,
    required String typeLabel,
    required String status,
  }) {
    if (profiles.isEmpty) {
      String title = 'No pending ${typeLabel}s';
      String subtitle = 'All ${typeLabel} applications have been reviewed';
      IconData icon = Icons.inbox_outlined;

      if (status == 'approved') {
        title = 'No approved ${typeLabel}s yet';
        subtitle = 'Approved profiles will appear here';
        icon = Icons.check_circle_outline;
      } else if (status == 'rejected') {
        title = 'No rejected ${typeLabel}s';
        subtitle = 'Rejected applications with reasons will appear here';
        icon = Icons.cancel_outlined;
      }

      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 72, color: AppColors.hairline),
              const SizedBox(height: AppSizes.md),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.slate,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: AppSizes.xs),
              Text(
                subtitle,
                style: const TextStyle(color: AppColors.slate, fontSize: 13),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppSizes.md),
      itemCount: profiles.length,
      itemBuilder: (context, index) {
        final profile = profiles[index];
        return PendingProfileCard(
          key: ValueKey('${profile.role}_${profile.id}_${profile.approvalStatus}'),
          profile: profile,
          onApprove: () => context.read<AdminCubit>().approve(
                profile.id,
                profile.role,
              ),
          onRejectWithReason: (reason) => context.read<AdminCubit>().reject(
                profile.id,
                profile.role,
                reason,
              ),
        );
      },
    );
  }
}
