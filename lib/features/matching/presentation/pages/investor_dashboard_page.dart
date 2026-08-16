import 'package:flutter/material.dart';
import 'package:ethioventure/core/theme/app_colors.dart';
import 'package:ethioventure/core/theme/app_sizes.dart';
import 'package:ethioventure/features/matching/data/datasources/matching_mock_data.dart';
import 'package:ethioventure/features/matching/presentation/cubit/matching_cubit.dart';
import 'package:ethioventure/features/matching/presentation/cubit/matching_state.dart';
import 'package:ethioventure/features/matching/presentation/widgets/preference_summary_card.dart';
import 'package:ethioventure/features/matching/presentation/widgets/recommendation_card.dart';

class InvestorDashboardPage extends StatefulWidget {
  final MatchingCubit cubit;

  const InvestorDashboardPage({super.key, required this.cubit});

  @override
  State<InvestorDashboardPage> createState() => _InvestorDashboardPageState();
}

class _InvestorDashboardPageState extends State<InvestorDashboardPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    widget.cubit.loadRecommendations();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showProfileSwitchSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSizes.radiusLg)),
      ),
      builder: (ctx) {
        final mockInvestors = MatchingMockData.mockInvestors;
        return Padding(
          padding: const EdgeInsets.all(AppSizes.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Switch Investor Thesis',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Test dynamic match re-ranking for different investor preference profiles:',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
              const SizedBox(height: AppSizes.md),
              ...mockInvestors.map(
                (inv) => Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                      child: Text(
                        inv.name[0],
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(inv.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                    subtitle: Text('${inv.companyName} • ${inv.preferredIndustries.join(", ")}'),
                    trailing: widget.cubit.currentInvestorId == inv.id
                        ? const Icon(Icons.check_circle, color: AppColors.primary)
                        : null,
                    onTap: () {
                      Navigator.pop(ctx);
                      widget.cubit.loadRecommendations(investorId: inv.id);
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.cubit,
      builder: (context, _) {
        final state = widget.cubit.state;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Investor Dashboard'),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                tooltip: 'Refresh Recommendations',
                onPressed: () => widget.cubit.loadRecommendations(),
              ),
            ],
          ),
          body: switch (state) {
            MatchingInitial() || MatchingLoading() => const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: AppColors.primary),
                    SizedBox(height: 16),
                    Text(
                      'Calculating startup compatibility...',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            MatchingError(:final message) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppSizes.lg),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 48, color: AppColors.error),
                      const SizedBox(height: 12),
                      const Text(
                        'Unable to load recommendations',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 6),
                      Text(message, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.textSecondary)),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => widget.cubit.loadRecommendations(),
                        child: const Text('Try Again'),
                      ),
                    ],
                  ),
                ),
              ),
            MatchingLoaded() => _buildLoadedDashboard(context, state),
          },
        );
      },
    );
  }

  Widget _buildLoadedDashboard(BuildContext context, MatchingLoaded state) {
    return RefreshIndicator(
      onRefresh: () => widget.cubit.loadRecommendations(),
      color: AppColors.primary,
      child: ListView(
        padding: const EdgeInsets.all(AppSizes.md),
        children: [
          // 1. Investor Thesis & Switch Profile Header
          PreferenceSummaryCard(
            investor: state.investor,
            onSwitchProfile: () => _showProfileSwitchSheet(context),
          ),
          const SizedBox(height: AppSizes.md),

          // 2. Metrics Summary Row
          _buildMetricsStrip(state),
          const SizedBox(height: AppSizes.md),

          // 3. Search & Filters
          _buildSearchAndFilters(state),
          const SizedBox(height: AppSizes.md),

          // 4. Section Title with Count
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recommended Startups (${state.filteredRecommendations.length})',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const Text(
                'Sorted by Match Score',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // 5. List of Recommendations or Empty State
          if (state.filteredRecommendations.isEmpty)
            _buildEmptyState(state)
          else
            ...state.filteredRecommendations.map(
              (rec) => RecommendationCard(
                recommendation: rec,
                onBookmarkToggle: () => widget.cubit.toggleBookmark(rec.startup.id),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMetricsStrip(MatchingLoaded state) {
    return Row(
      children: [
        Expanded(
          child: _buildMetricTile(
            title: 'Top Match',
            value: '${state.topScore.toInt()}%',
            icon: Icons.star_rounded,
            color: const Color(0xFF1B4332),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildMetricTile(
            title: 'High / Top Fits',
            value: '${state.excellentMatchesCount + state.highMatchesCount}',
            icon: Icons.trending_up,
            color: const Color(0xFF2D6A4F),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildMetricTile(
            title: 'Avg Match',
            value: '${state.averageScore.toInt()}%',
            icon: Icons.analytics_outlined,
            color: const Color(0xFFB08968),
          ),
        ),
      ],
    );
  }

  Widget _buildMetricTile({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusSm),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters(MatchingLoaded state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search Bar
        TextField(
          controller: _searchController,
          onChanged: (val) => widget.cubit.setSearchQuery(val),
          decoration: InputDecoration(
            hintText: 'Search startup, industry, or city...',
            prefixIcon: const Icon(Icons.search, size: 20),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, size: 18),
                    onPressed: () {
                      _searchController.clear();
                      widget.cubit.setSearchQuery('');
                    },
                  )
                : null,
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(vertical: 0),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusSm),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusSm),
              borderSide: const BorderSide(color: AppColors.border),
            ),
          ),
        ),
        const SizedBox(height: 10),

        // Score Threshold Filter Chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              const Text('Score: ', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
              const SizedBox(width: 6),
              _buildScoreFilterChip('All Scores', 0.0, state.minScoreFilter == 0.0),
              const SizedBox(width: 6),
              _buildScoreFilterChip('80%+ Top Fits', 80.0, state.minScoreFilter == 80.0),
              const SizedBox(width: 6),
              _buildScoreFilterChip('65%+ Solid Fits', 65.0, state.minScoreFilter == 65.0),
            ],
          ),
        ),
        const SizedBox(height: 8),

        // Industry Filter Chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: state.availableIndustries.map((ind) {
              final isSelected = state.selectedIndustryFilter == ind;
              return Padding(
                padding: const EdgeInsets.only(right: 6),
                child: FilterChip(
                  label: Text(ind),
                  selected: isSelected,
                  onSelected: (_) => widget.cubit.setIndustryFilter(ind),
                  backgroundColor: Colors.white,
                  selectedColor: AppColors.primary.withValues(alpha: 0.15),
                  labelStyle: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.normal,
                    color: isSelected ? AppColors.primary : AppColors.textPrimary,
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildScoreFilterChip(String label, double score, bool isSelected) {
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => widget.cubit.setMinScoreFilter(score),
      selectedColor: AppColors.primary.withValues(alpha: 0.15),
      labelStyle: TextStyle(
        fontSize: 11,
        fontWeight: isSelected ? FontWeight.w700 : FontWeight.normal,
        color: isSelected ? AppColors.primary : AppColors.textPrimary,
      ),
    );
  }

  Widget _buildEmptyState(MatchingLoaded state) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.xl),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.filter_list_off, size: 48, color: AppColors.textSecondary),
          const SizedBox(height: 12),
          const Text(
            'No matching startups found',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          const Text(
            'Try adjusting your industry filters or lowering the match score threshold.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: () {
              _searchController.clear();
              widget.cubit.setIndustryFilter('All');
              widget.cubit.setMinScoreFilter(0.0);
              widget.cubit.setSearchQuery('');
            },
            child: const Text('Reset All Filters'),
          ),
        ],
      ),
    );
  }
}
