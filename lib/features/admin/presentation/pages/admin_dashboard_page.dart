import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/di/injection_container.dart';
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

  void _handleLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to log out of Admin Panel?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              try {
                await sl<SupabaseClient>().auth.signOut();
              } catch (_) {}
              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppConstants.routeLogin,
                  (route) => false,
                );
              }
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<AdminCubit>()..loadAllProfiles(),
      child: Builder(
        builder: (context) => Scaffold(
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
                  context.read<AdminCubit>().loadAllProfiles();
                },
              ),
              IconButton(
                icon: const Icon(Icons.logout_rounded),
                tooltip: 'Logout',
                color: AppColors.error,
                onPressed: () => _handleLogout(context),
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
  String _selectedStatusFilter = 'all'; // 'all', 'pending', 'approved', 'rejected'
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AdminCubit, AdminState>(
      listenWhen: (previous, current) =>
          current is AdminActionSuccess || current is AdminError,
      buildWhen: (previous, current) =>
          current is AdminProfilesLoaded ||
          current is AdminLoading ||
          current is AdminError,
      listener: (context, state) {
        if (state is AdminActionSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle_rounded, color: AppColors.white),
                  const SizedBox(width: AppSizes.sm),
                  Expanded(child: Text(state.message)),
                ],
              ),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              ),
            ),
          );
        } else if (state is AdminError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error_outline_rounded, color: AppColors.white),
                  const SizedBox(width: AppSizes.sm),
                  Expanded(child: Text(state.message)),
                ],
              ),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              ),
            ),
          );
        }
      },
      builder: (context, state) {
        if (state is AdminLoading) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: AppColors.primary),
                SizedBox(height: AppSizes.md),
                Text(
                  'Updating applications...',
                  style: TextStyle(color: AppColors.slate, fontSize: 13),
                ),
              ],
            ),
          );
        }

        if (state is AdminError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline_rounded,
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
                  icon: const Icon(Icons.refresh_rounded),
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
          final totalAll = totalPending + totalApproved + totalRejected;

          // Categorized lists
          List<PendingApprovalEntity> startupList;
          List<PendingApprovalEntity> investorList;

          final allStartups = [
            ...state.pendingStartups,
            ...state.approvedStartups,
            ...state.rejectedProfiles
                .where((p) => p.role == 'founder' || p.role == 'startup'),
          ];
          final allInvestors = [
            ...state.pendingInvestors,
            ...state.approvedInvestors,
            ...state.rejectedProfiles
                .where((p) => p.role == 'investor'),
          ];

          if (_selectedStatusFilter == 'pending') {
            startupList = state.pendingStartups;
            investorList = state.pendingInvestors;
          } else if (_selectedStatusFilter == 'approved') {
            startupList = state.approvedStartups;
            investorList = state.approvedInvestors;
          } else if (_selectedStatusFilter == 'rejected') {
            startupList = state.rejectedProfiles
                .where((p) => p.role == 'founder' || p.role == 'startup')
                .toList();
            investorList = state.rejectedProfiles
                .where((p) => p.role == 'investor')
                .toList();
          } else {
            // 'all'
            startupList = allStartups;
            investorList = allInvestors;
          }

          // Apply Live Search Filter
          final query = _searchQuery.trim().toLowerCase();
          if (query.isNotEmpty) {
            startupList = startupList.where((p) {
              return p.businessName.toLowerCase().contains(query) ||
                  p.name.toLowerCase().contains(query) ||
                  p.email.toLowerCase().contains(query) ||
                  p.industry.toLowerCase().contains(query);
            }).toList();

            investorList = investorList.where((p) {
              return p.businessName.toLowerCase().contains(query) ||
                  p.name.toLowerCase().contains(query) ||
                  p.email.toLowerCase().contains(query) ||
                  p.industry.toLowerCase().contains(query);
            }).toList();
          }

          return Column(
            children: [
              // Stats Row (Interactive Filter Cards: All, Pending, Approved, Rejected)
              Container(
                color: AppColors.white,
                padding: const EdgeInsets.all(AppSizes.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LayoutBuilder(
                      builder: (context, constraints) {
                        return Row(
                          children: [
                            Expanded(
                              child: InkWell(
                                onTap: () {
                                  setState(() => _selectedStatusFilter = 'all');
                                },
                                borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                                child: ApprovalStatsCard(
                                  title: 'All',
                                  count: totalAll,
                                  icon: Icons.grid_view_rounded,
                                  color: AppColors.primary,
                                  isSelected: _selectedStatusFilter == 'all',
                                ),
                              ),
                            ),
                            const SizedBox(width: AppSizes.xs + 2),
                            Expanded(
                              child: InkWell(
                                onTap: () {
                                  setState(() => _selectedStatusFilter = 'pending');
                                },
                                borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                                child: ApprovalStatsCard(
                                  title: 'Pending',
                                  count: totalPending,
                                  icon: Icons.hourglass_top_rounded,
                                  color: AppColors.warning,
                                  isSelected: _selectedStatusFilter == 'pending',
                                ),
                              ),
                            ),
                            const SizedBox(width: AppSizes.xs + 2),
                            Expanded(
                              child: InkWell(
                                onTap: () {
                                  setState(() => _selectedStatusFilter = 'approved');
                                },
                                borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                                child: ApprovalStatsCard(
                                  title: 'Approved',
                                  count: totalApproved,
                                  icon: Icons.check_circle_rounded,
                                  color: AppColors.success,
                                  isSelected: _selectedStatusFilter == 'approved',
                                ),
                              ),
                            ),
                            const SizedBox(width: AppSizes.xs + 2),
                            Expanded(
                              child: InkWell(
                                onTap: () {
                                  setState(() => _selectedStatusFilter = 'rejected');
                                },
                                borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                                child: ApprovalStatsCard(
                                  title: 'Rejected',
                                  count: totalRejected,
                                  icon: Icons.cancel_rounded,
                                  color: AppColors.error,
                                  isSelected: _selectedStatusFilter == 'rejected',
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: AppSizes.md),
                    // Live Search Field
                    TextField(
                      controller: _searchController,
                      onChanged: (val) {
                        setState(() => _searchQuery = val);
                      },
                      decoration: InputDecoration(
                        hintText: 'Search applications by name, email, or industry...',
                        hintStyle: const TextStyle(
                          fontSize: 13,
                          color: AppColors.slate,
                        ),
                        prefixIcon: const Icon(
                          Icons.search_rounded,
                          color: AppColors.primary,
                          size: 20,
                        ),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear_rounded, size: 18),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() => _searchQuery = '');
                                },
                              )
                            : null,
                        filled: true,
                        fillColor: AppColors.fog,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: AppSizes.md,
                          vertical: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                          borderSide: const BorderSide(color: AppColors.hairline),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                          borderSide: const BorderSide(
                            color: AppColors.primary,
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSizes.xs),
                    Row(
                      children: [
                        Text(
                          'Showing ${_selectedStatusFilter.toUpperCase()} applications',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.slate,
                          ),
                        ),
                        if (_searchQuery.isNotEmpty) ...[
                          const SizedBox(width: 4),
                          Text(
                            '(filtered by "$_searchQuery")',
                            style: const TextStyle(
                              fontSize: 11,
                              fontStyle: FontStyle.italic,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                        const Spacer(),
                        if (_selectedStatusFilter != 'all')
                          TextButton.icon(
                            onPressed: () {
                              setState(() => _selectedStatusFilter = 'all');
                            },
                            icon: const Icon(Icons.apps_rounded, size: 13),
                            label: const Text('View All'),
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: const Size(50, 24),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              foregroundColor: AppColors.primary,
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
                  labelStyle: const TextStyle(fontWeight: FontWeight.w700),
                  tabs: [
                    Tab(
                      icon: const Icon(Icons.business_rounded),
                      text: 'Startups (${startupList.length})',
                    ),
                    Tab(
                      icon: const Icon(Icons.account_balance_rounded),
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
                        searchQuery: _searchQuery,
                      ),
                      _buildProfilesList(
                        context,
                        profiles: investorList,
                        typeLabel: 'investor',
                        status: _selectedStatusFilter,
                        searchQuery: _searchQuery,
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
    required String searchQuery,
  }) {
    if (profiles.isEmpty) {
      String title = 'No pending ${typeLabel}s';
      String subtitle = 'All $typeLabel applications have been reviewed';
      IconData icon = Icons.inbox_rounded;

      if (searchQuery.isNotEmpty) {
        title = 'No ${typeLabel}s match your search';
        subtitle = 'Try searching with a different term or clear the search query';
        icon = Icons.search_off_rounded;
      } else if (status == 'all') {
        title = 'No $typeLabel applications found';
        subtitle = 'New applications submitted by $typeLabel users will appear here';
        icon = Icons.folder_open_rounded;
      } else if (status == 'approved') {
        title = 'No approved ${typeLabel}s yet';
        subtitle = 'Approved profiles will appear here';
        icon = Icons.check_circle_outline_rounded;
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
              Icon(icon, size: 68, color: AppColors.hairline),
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
