import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
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
            'Approvals Dashboard',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          ),
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
                  const Icon(Icons.error_outline,
                      size: 64, color: AppColors.error),
                  const SizedBox(height: AppSizes.md),
                  Text(
                    state.message,
                    style: const TextStyle(color: AppColors.slate),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSizes.lg),
                  ElevatedButton.icon(
                    onPressed: () =>
                        context.read<AdminCubit>().loadAllProfiles(),
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

            return Column(
              children: [
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
                    tabs: const [
                      Tab(
                        icon: Icon(Icons.business),
                        text: 'Startups',
                      ),
                      Tab(
                        icon: Icon(Icons.account_balance),
                        text: 'Investors',
                      ),
                    ],
                  ),
                ),
                // Stats Row
                Container(
                  color: AppColors.white,
                  padding: const EdgeInsets.all(AppSizes.md),
                  child: Row(
                    children: [
                      Expanded(
                        child: ApprovalStatsCard(
                          title: 'Pending',
                          count: totalPending,
                          icon: Icons.pending_actions,
                          color: AppColors.warning,
                        ),
                      ),
                      const SizedBox(width: AppSizes.md),
                      Expanded(
                        child: ApprovalStatsCard(
                          title: 'Approved',
                          count: totalApproved,
                          icon: Icons.check_circle,
                          color: AppColors.success,
                        ),
                      ),
                      const SizedBox(width: AppSizes.md),
                      Expanded(
                        child: ApprovalStatsCard(
                          title: 'Rejected',
                          count: totalRejected,
                          icon: Icons.cancel,
                          color: AppColors.error,
                        ),
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
                        _buildStartupsList(context, state.pendingStartups),
                        _buildInvestorsList(context, state.pendingInvestors),
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

  Widget _buildStartupsList(BuildContext context, List profiles) {
    if (profiles.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox, size: 80, color: AppColors.hairline),
            const SizedBox(height: AppSizes.md),
            Text(
              'No pending startups',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.slate,
                  ),
            ),
            const SizedBox(height: AppSizes.sm),
            const Text(
              'All startup applications have been reviewed',
              style: TextStyle(color: AppColors.slate, fontSize: 14),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppSizes.md),
      itemCount: profiles.length,
      itemBuilder: (context, index) {
        final profile = profiles[index];
        return PendingProfileCard(
          profile: profile,
          onApprove: () => context.read<AdminCubit>().approve(
                profile.id,
                profile.role,
              ),
          onReject: () => context.read<AdminCubit>().reject(
                profile.id,
                profile.role,
              ),
        );
      },
    );
  }

  Widget _buildInvestorsList(BuildContext context, List profiles) {
    if (profiles.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox, size: 80, color: AppColors.hairline),
            const SizedBox(height: AppSizes.md),
            Text(
              'No pending investors',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.slate,
                  ),
            ),
            const SizedBox(height: AppSizes.sm),
            const Text(
              'All investor applications have been reviewed',
              style: TextStyle(color: AppColors.slate, fontSize: 14),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppSizes.md),
      itemBuilder: (context, index) {
        final profile = profiles[index];
        return PendingProfileCard(
          profile: profile,
          onApprove: () => context.read<AdminCubit>().approve(
                profile.id,
                profile.role,
              ),
          onReject: () => context.read<AdminCubit>().reject(
                profile.id,
                profile.role,
              ),
        );
      },
      itemCount: profiles.length,
    );
  }
}
