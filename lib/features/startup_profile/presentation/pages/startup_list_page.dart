import 'package:ethioventure/core/constants/app_constants.dart';
import 'package:ethioventure/core/di/injection_container.dart';
import 'package:ethioventure/core/theme/app_colors.dart';
import 'package:ethioventure/core/theme/app_sizes.dart';
import 'package:ethioventure/features/investor/presentation/widgets/app_bottom_nav.dart';
import 'package:ethioventure/features/startup_profile/domain/entities/startup_profile_entity.dart';
import 'package:ethioventure/features/startup_profile/presentation/cubit/startup_search_cubit.dart';
import 'package:ethioventure/features/startup_profile/presentation/cubit/startup_search_state.dart';
import 'package:ethioventure/features/startup_profile/presentation/widgets/startup_card.dart';
import 'package:ethioventure/features/startup_profile/presentation/widgets/startup_filter_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Startup discovery page for investors.
///
/// Provides:
///  - Free-text search bar (name + summary).
///  - Filter button → [StartupFilterSheet] bottom sheet.
///  - Active-filter chips showing what is currently applied.
///  - Paginated results list with [StartupCard]s.
///  - Loading, empty, and error states.
class StartupListPage extends StatelessWidget {
  const StartupListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<StartupSearchCubit>()..initialLoad(),
      child: const _StartupListView(),
    );
  }
}

// ── Main view ─────────────────────────────────────────────────────────────────

class _StartupListView extends StatefulWidget {
  const _StartupListView();

  @override
  State<_StartupListView> createState() => _StartupListViewState();
}

class _StartupListViewState extends State<_StartupListView> {
  late final TextEditingController _searchController;
  late final ScrollController _scrollController;

  // Debounce timer for the search field.
  bool _searchPending = false;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _scrollController = ScrollController()..addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<StartupSearchCubit>().loadNextPage();
    }
  }

  void _openFilterSheet(BuildContext context) {
    final cubit = context.read<StartupSearchCubit>();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StartupFilterSheet(
        currentFilter: cubit.currentFilter,
        onApply: (result) => cubit.applyFilters(
          query: _searchController.text.trim().isEmpty
              ? null
              : _searchController.text.trim(),
          industry: result.industry,
          stage: result.stage,
          location: result.location,
          minFundingTarget: result.minFundingTarget,
          maxFundingTarget: result.maxFundingTarget,
        ),
        onClear: () {
          _searchController.clear();
          cubit.clearFilters();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Discover Startups'),
        centerTitle: false,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: AppSizes.md),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.sm,
              vertical: AppSizes.xs,
            ),
            decoration: BoxDecoration(
              color: isDark ? AppColors.primaryDark : AppColors.primarySoft,
              borderRadius: BorderRadius.circular(AppSizes.radiusSm),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.verified_outlined,
                  size: 16,
                  color: isDark ? Colors.white : AppColors.secondary,
                ),
                const SizedBox(width: AppSizes.xs),
                Text(
                  'Investor Portal',
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : AppColors.secondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: AppBottomNav(
        items: AppBottomNav.investorNavItems,
        currentIndex: 1,
        onTap: (index) {
          if (index == 0) {
            Navigator.of(context).pushReplacementNamed(
              AppConstants.routeInvestorDashboard,
            );
          } else if (index == 3) {
            Navigator.of(context).pushReplacementNamed(
              AppConstants.routeInvestorProfile,
            );
          }
        },
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Search + Filter bar ──────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSizes.pageHorizontal,
              AppSizes.md,
              AppSizes.pageHorizontal,
              0,
            ),
            child: Row(
              children: [
                Expanded(
                  child: BlocBuilder<StartupSearchCubit, StartupSearchState>(
                    buildWhen: (_, _) => false, // search bar is self-managed
                    builder: (context, _) => TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search startups…',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  _searchController.clear();
                                  context
                                      .read<StartupSearchCubit>()
                                      .updateQuery(null);
                                },
                              )
                            : null,
                      ),
                      textInputAction: TextInputAction.search,
                      onChanged: (value) {
                        setState(() {}); // refresh suffixIcon visibility
                        // Lightweight debounce: only dispatch when user stops
                        // typing for one frame (avoids hammering the DB).
                        if (!_searchPending) {
                          _searchPending = true;
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            _searchPending = false;
                            if (mounted) {
                              context
                                  .read<StartupSearchCubit>()
                                  .updateQuery(value);
                            }
                          });
                        }
                      },
                      onSubmitted: (value) =>
                          context.read<StartupSearchCubit>().updateQuery(value),
                    ),
                  ),
                ),
                const SizedBox(width: AppSizes.sm),
                // Filter button with active-filter indicator dot.
                BlocBuilder<StartupSearchCubit, StartupSearchState>(
                  builder: (context, state) {
                    final filter =
                        context.read<StartupSearchCubit>().currentFilter;
                    final hasFilters = filter.industry != null ||
                        filter.stage != null ||
                        filter.location != null ||
                        filter.minFundingTarget != null ||
                        filter.maxFundingTarget != null;

                    return Stack(
                      clipBehavior: Clip.none,
                      children: [
                        IconButton.outlined(
                          icon: const Icon(Icons.tune),
                          tooltip: 'Filters',
                          onPressed: () => _openFilterSheet(context),
                        ),
                        if (hasFilters)
                          Positioned(
                            right: 6,
                            top: 6,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),

          // ── Active filter chips ──────────────────────────────────────────
          BlocBuilder<StartupSearchCubit, StartupSearchState>(
            builder: (context, state) {
              final cubit = context.read<StartupSearchCubit>();
              final filter = cubit.currentFilter;

              final chips = <_ActiveChip>[
                if (filter.industry != null)
                  _ActiveChip(
                    label: filter.industry!,
                    onRemove: () => cubit.updateIndustry(null),
                  ),
                if (filter.stage != null)
                  _ActiveChip(
                    label: filter.stage!,
                    onRemove: () => cubit.updateStage(null),
                  ),
                if (filter.location != null)
                  _ActiveChip(
                    label: filter.location!,
                    onRemove: () => cubit.updateLocation(null),
                  ),
                if (filter.minFundingTarget != null ||
                    filter.maxFundingTarget != null)
                  _ActiveChip(
                    label: _fundingLabel(
                      filter.minFundingTarget,
                      filter.maxFundingTarget,
                    ),
                    onRemove: () => cubit.updateFundingRange(
                      minFundingTarget: null,
                      maxFundingTarget: null,
                    ),
                  ),
              ];

              if (chips.isEmpty) return const SizedBox.shrink();

              return Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSizes.pageHorizontal,
                  AppSizes.sm,
                  AppSizes.pageHorizontal,
                  0,
                ),
                child: Wrap(
                  spacing: AppSizes.xs,
                  runSpacing: AppSizes.xs,
                  children: chips,
                ),
              );
            },
          ),

          const SizedBox(height: AppSizes.sm),
          const Divider(height: 1),

          // ── Results area ─────────────────────────────────────────────────
          Expanded(
            child: BlocBuilder<StartupSearchCubit, StartupSearchState>(
              builder: (context, state) {
                // Loading
                if (state is StartupSearchLoading) {
                  return const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.primary,
                      ),
                    ),
                  );
                }

                // Error
                if (state is StartupSearchError) {
                  return _ErrorView(
                    message: state.message,
                    onRetry: () =>
                        context.read<StartupSearchCubit>().initialLoad(),
                  );
                }

                // Empty
                if (state is StartupSearchEmpty) {
                  final hasFilters = !state.filter.isEmpty ||
                      _searchController.text.isNotEmpty;
                  return _EmptyView(
                    hasFilters: hasFilters,
                    onClearFilters: () {
                      _searchController.clear();
                      context.read<StartupSearchCubit>().clearFilters();
                    },
                  );
                }

                // Results
                if (state is StartupSearchLoaded) {
                  return _ResultsList(
                    startups: state.startups,
                    hasMore: state.hasMore,
                    scrollController: _scrollController,
                  );
                }

                // Initial — show instructional placeholder.
                return _EmptyView(hasFilters: false, onClearFilters: () {});
              },
            ),
          ),
        ],
      ),
    );
  }

  static String _fundingLabel(double? min, double? max) {
    if (min != null && max != null) {
      return '\$${_short(min)}–\$${_short(max)}';
    }
    if (min != null) return '≥ \$${_short(min)}';
    if (max != null) return '≤ \$${_short(max)}';
    return '';
  }

  static String _short(double v) {
    if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(1)}M';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(0)}K';
    return v.toStringAsFixed(0);
  }
}

// ── Results list ──────────────────────────────────────────────────────────────

class _ResultsList extends StatelessWidget {
  const _ResultsList({
    required this.startups,
    required this.hasMore,
    required this.scrollController,
  });

  final List<StartupProfileEntity> startups;
  final bool hasMore;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: AppSizes.maxContentWidth),
        child: ListView.separated(
          controller: scrollController,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.pageHorizontal,
            vertical: AppSizes.md,
          ),
          itemCount: startups.length + (hasMore ? 1 : 0),
          separatorBuilder: (_, _) => const SizedBox(height: AppSizes.md),
          itemBuilder: (context, index) {
            if (index == startups.length) {
              // Pagination loading indicator at the bottom.
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: AppSizes.lg),
                child: Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                ),
              );
            }
            return StartupCard(
              startup: startups[index],
              onTap: null, // detail page wired in Step 4
            );
          },
        ),
      ),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyView extends StatelessWidget {
  const _EmptyView({
    required this.hasFilters,
    required this.onClearFilters,
  });

  final bool hasFilters;
  final VoidCallback onClearFilters;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              hasFilters
                  ? Icons.search_off_rounded
                  : Icons.rocket_launch_outlined,
              size: 64,
              color: isDark ? AppColors.textSecondaryDark : AppColors.border,
            ),
            const SizedBox(height: AppSizes.lg),
            Text(
              hasFilters
                  ? 'No startups found'
                  : 'No startups yet',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.secondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSizes.sm),
            Text(
              hasFilters
                  ? 'Try adjusting your search or filters to find startups.'
                  : 'Ethiopian startups will appear here once they publish '
                      'their profiles.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            if (hasFilters) ...[
              const SizedBox(height: AppSizes.xl),
              OutlinedButton.icon(
                icon: const Icon(Icons.filter_alt_off_outlined),
                label: const Text('Clear Filters'),
                onPressed: onClearFilters,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Error state ───────────────────────────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.error,
            ),
            const SizedBox(height: AppSizes.lg),
            Text(
              'Something went wrong',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.textPrimaryDark : AppColors.secondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSizes.sm),
            Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color:
                    isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: AppSizes.xl),
            ElevatedButton.icon(
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              onPressed: onRetry,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Active filter chip ────────────────────────────────────────────────────────

class _ActiveChip extends StatelessWidget {
  const _ActiveChip({required this.label, required this.onRemove});

  final String label;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Chip(
      label: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: isDark ? AppColors.secondary : Colors.white,
        ),
      ),
      backgroundColor: isDark ? AppColors.primary : AppColors.secondary,
      deleteIcon: Icon(
        Icons.close,
        size: 14,
        color: isDark ? AppColors.secondary : Colors.white,
      ),
      onDeleted: onRemove,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.xs),
      side: BorderSide.none,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusXl),
      ),
    );
  }
}
