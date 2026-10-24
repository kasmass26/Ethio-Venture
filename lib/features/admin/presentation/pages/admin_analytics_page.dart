import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../cubit/admin_cubit.dart';
import '../cubit/admin_state.dart';
import '../widgets/metric_card.dart';
import '../widgets/chart_card.dart';

final getIt = GetIt.instance;

class AdminAnalyticsPage extends StatelessWidget {
  const AdminAnalyticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<AdminCubit>()..loadAllProfiles(),
      child: Scaffold(
        backgroundColor: AppColors.fog,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: AppColors.white,
          foregroundColor: AppColors.ink,
          elevation: 0,
          title: const Text(
            'Analytics & Insights',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh_rounded),
              onPressed: () {
                context.read<AdminCubit>().loadAllProfiles();
              },
              tooltip: 'Refresh',
            ),
            const SizedBox(width: AppSizes.sm),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(height: 1, color: AppColors.hairline),
          ),
        ),
        body: BlocBuilder<AdminCubit, AdminState>(
          builder: (context, state) {
            if (state is AdminInitial || state is AdminLoading) {
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
              if (state.analytics.totalStartups == 0 &&
                  state.analytics.totalInvestors == 0) {
                return RefreshIndicator(
                  onRefresh: () async {
                    await context.read<AdminCubit>().loadAllProfiles();
                  },
                  color: AppColors.primary,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: const [
                      SizedBox(height: 140),
                      Center(
                        child: Column(
                          children: [
                            Icon(
                              Icons.analytics_outlined,
                              size: 56,
                              color: AppColors.slate,
                            ),
                            SizedBox(height: AppSizes.md),
                            Text(
                              'No profile analytics available yet.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: AppColors.slate),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () async {
                  await context.read<AdminCubit>().loadAllProfiles();
                },
                color: AppColors.primary,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(AppSizes.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Key Metrics Section
                      const Text(
                        'Key Metrics',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.ink,
                        ),
                      ),
                      const SizedBox(height: AppSizes.md),
                      _buildMetricsGrid(state),
                      const SizedBox(height: AppSizes.xl),

                      // Charts Section
                      const Text(
                        'Overview Charts',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.ink,
                        ),
                      ),
                      const SizedBox(height: AppSizes.md),
                      _buildChartsSection(state),
                      const SizedBox(height: AppSizes.xl),

                      // Status Breakdown
                      const Text(
                        'Status Breakdown',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.ink,
                        ),
                      ),
                      const SizedBox(height: AppSizes.md),
                      _buildStatusBreakdown(state),
                    ],
                  ),
                ),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildMetricsGrid(AdminProfilesLoaded state) {
    final analytics = state.analytics;
    final totalUsers = analytics.totalStartups + analytics.totalInvestors;
    final pendingReview =
        state.pendingStartups.length + state.pendingInvestors.length;

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 1000
            ? 4
            : constraints.maxWidth > 600
            ? 3
            : 2;
        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: crossAxisCount,
          mainAxisSpacing: AppSizes.md,
          crossAxisSpacing: AppSizes.md,
          childAspectRatio: 1.4,
          children: [
            MetricCard(
              title: 'Total Profiles',
              value: totalUsers.toString(),
              icon: Icons.people_rounded,
              color: AppColors.primary,
              subtitle: 'All profile statuses',
            ),
            MetricCard(
              title: 'Startups',
              value: analytics.totalStartups.toString(),
              icon: Icons.business_rounded,
              color: const Color(0xFF00D1FF),
              subtitle: '${state.approvedStartups.length} active',
            ),
            MetricCard(
              title: 'Investors',
              value: analytics.totalInvestors.toString(),
              icon: Icons.account_balance_rounded,
              color: const Color(0xFF7F77DD),
              subtitle: '${state.approvedInvestors.length} active',
            ),
            MetricCard(
              title: 'Compatible Matches',
              value: analytics.compatibleMatches.toString(),
              icon: Icons.handshake_outlined,
              color: AppColors.success,
              subtitle: '${analytics.possibleMatches} approved pairs evaluated',
            ),
            MetricCard(
              title: 'Match Rate',
              value: analytics.matchRate == null
                  ? '—'
                  : '${analytics.matchRate!.toStringAsFixed(1)}%',
              icon: Icons.percent_rounded,
              color: const Color(0xFF7F77DD),
              subtitle: 'Approved pairs scoring above 0',
            ),
            MetricCard(
              title: 'Pending Review',
              value: pendingReview.toString(),
              icon: Icons.pending_actions_rounded,
              color: AppColors.warning,
              subtitle: 'Needs attention',
            ),
          ],
        );
      },
    );
  }

  Widget _buildChartsSection(AdminProfilesLoaded state) {
    return Column(
      children: [
        ChartCard(
          title: 'User Distribution',
          data: {
            'Startups': state.analytics.totalStartups.toDouble(),
            'Investors': state.analytics.totalInvestors.toDouble(),
          },
          colors: const {
            'Startups': Color(0xFF00D1FF),
            'Investors': Color(0xFF7F77DD),
          },
        ),
        const SizedBox(height: AppSizes.md),
        ChartCard(
          title: 'Approval Status',
          data: {
            'Pending':
                (state.pendingStartups.length + state.pendingInvestors.length)
                    .toDouble(),
            'Approved':
                (state.approvedStartups.length + state.approvedInvestors.length)
                    .toDouble(),
            'Rejected': state.rejectedProfiles.length.toDouble(),
          },
          colors: const {
            'Pending': AppColors.warning,
            'Approved': AppColors.success,
            'Rejected': AppColors.error,
          },
        ),
        const SizedBox(height: AppSizes.md),
        ChartCard(
          title: 'Approved Startup Industries',
          data: _toChartData(state.analytics.industryCounts),
          colors: _chartColors(state.analytics.industryCounts.keys),
        ),
        const SizedBox(height: AppSizes.md),
        ChartCard(
          title: 'Approved Startup Funding Stages',
          data: _toChartData(state.analytics.fundingStageCounts),
          colors: _chartColors(state.analytics.fundingStageCounts.keys),
        ),
      ],
    );
  }

  Map<String, double> _toChartData(Map<String, int> counts) =>
      counts.map((label, count) => MapEntry(label, count.toDouble()));

  Map<String, Color> _chartColors(Iterable<String> labels) {
    const palette = [
      AppColors.primary,
      Color(0xFF00D1FF),
      Color(0xFF7F77DD),
      AppColors.success,
      AppColors.warning,
    ];
    return Map.fromEntries(
      labels.indexed.map(
        (entry) => MapEntry(entry.$2, palette[entry.$1 % palette.length]),
      ),
    );
  }

  Widget _buildStatusBreakdown(AdminProfilesLoaded state) {
    return Column(
      children: [
        _buildStatusRow(
          'Pending Startups',
          state.pendingStartups.length,
          Icons.business_rounded,
          AppColors.warning,
        ),
        const SizedBox(height: AppSizes.sm),
        _buildStatusRow(
          'Approved Startups',
          state.approvedStartups.length,
          Icons.business_rounded,
          AppColors.success,
        ),
        const SizedBox(height: AppSizes.sm),
        _buildStatusRow(
          'Pending Investors',
          state.pendingInvestors.length,
          Icons.account_balance_rounded,
          AppColors.warning,
        ),
        const SizedBox(height: AppSizes.sm),
        _buildStatusRow(
          'Approved Investors',
          state.approvedInvestors.length,
          Icons.account_balance_rounded,
          AppColors.success,
        ),
        const SizedBox(height: AppSizes.sm),
        _buildStatusRow(
          'Rejected Profiles',
          state.rejectedProfiles.length,
          Icons.cancel_rounded,
          AppColors.error,
        ),
      ],
    );
  }

  Widget _buildStatusRow(String label, int count, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(color: AppColors.hairline),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSizes.sm),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppSizes.radiusSm),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: AppSizes.md),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.ink,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.md,
              vertical: AppSizes.sm,
            ),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppSizes.radiusLg),
            ),
            child: Text(
              count.toString(),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
