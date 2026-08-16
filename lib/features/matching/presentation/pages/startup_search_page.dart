import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../cubit/startup_search_cubit.dart';
import '../cubit/startup_search_state.dart';
import '../widgets/search_filter_bottom_sheet.dart';
import '../widgets/startup_card.dart';

class StartupSearchPage extends StatefulWidget {
  const StartupSearchPage({super.key});

  @override
  State<StartupSearchPage> createState() => _StartupSearchPageState();
}

class _StartupSearchPageState extends State<StartupSearchPage> {
  final TextEditingController _searchController = TextEditingController();

  final List<String> _quickCategories = [
    'All',
    'FinTech',
    'AgriTech',
    'HealthTech',
    'EdTech',
    'AI / ML',
    'Renewable Energy',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StartupSearchCubit>().loadStartups();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openFilterBottomSheet() {
    final cubit = context.read<StartupSearchCubit>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => SearchFilterBottomSheet(
        currentParams: cubit.currentParams,
        onApplyFilters: (newParams) {
          cubit.applyFilter(newParams);
        },
        onResetFilters: () {
          cubit.resetFilters();
          _searchController.clear();
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
        title: const Text('Search & Filter Startups'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () {
              context.read<StartupSearchCubit>().loadStartups();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search Bar & Filter Button
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: (query) {
                        context.read<StartupSearchCubit>().updateQuery(query);
                      },
                      decoration: InputDecoration(
                        hintText:
                            'Search by startup name, keyword, tech stack...',
                        prefixIcon: const Icon(
                          Icons.search_rounded,
                          color: AppColors.primary,
                        ),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear_rounded, size: 18),
                                onPressed: () {
                                  _searchController.clear();
                                  context
                                      .read<StartupSearchCubit>()
                                      .updateQuery('');
                                },
                              )
                            : null,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  BlocBuilder<StartupSearchCubit, StartupSearchState>(
                    builder: (context, state) {
                      final hasActiveFilters = context
                          .read<StartupSearchCubit>()
                          .currentParams
                          .hasActiveFilters;

                      return Stack(
                        children: [
                          Container(
                            height: 50,
                            width: 50,
                            decoration: BoxDecoration(
                              color: hasActiveFilters
                                  ? AppColors.primary
                                  : (isDark
                                        ? AppColors.surfaceDark
                                        : AppColors.surface),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: hasActiveFilters
                                    ? AppColors.primary
                                    : AppColors.border,
                              ),
                            ),
                            child: IconButton(
                              icon: Icon(
                                Icons.tune_rounded,
                                color: hasActiveFilters
                                    ? Colors.white
                                    : AppColors.primary,
                              ),
                              onPressed: _openFilterBottomSheet,
                            ),
                          ),
                          if (hasActiveFilters)
                            Positioned(
                              right: 6,
                              top: 6,
                              child: Container(
                                width: 10,
                                height: 10,
                                decoration: const BoxDecoration(
                                  color: AppColors.secondary,
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

            // Quick Category Chips Bar
            BlocBuilder<StartupSearchCubit, StartupSearchState>(
              builder: (context, state) {
                final currentIndustry =
                    context.read<StartupSearchCubit>().currentParams.industry ??
                    'All';

                return SizedBox(
                  height: 42,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _quickCategories.length,
                    itemBuilder: (context, index) {
                      final category = _quickCategories[index];
                      final isSelected = currentIndustry == category;

                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ChoiceChip(
                          label: Text(category),
                          selected: isSelected,
                          selectedColor: AppColors.primary,
                          labelStyle: TextStyle(
                            fontSize: 13,
                            color: isSelected
                                ? Colors.white
                                : (isDark
                                      ? Colors.white
                                      : AppColors.textPrimary),
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                          onSelected: (selected) {
                            if (selected) {
                              context.read<StartupSearchCubit>().updateIndustry(
                                category == 'All' ? null : category,
                              );
                            }
                          },
                        ),
                      );
                    },
                  ),
                );
              },
            ),
            const SizedBox(height: 8),

            // Startups Results List View
            Expanded(
              child: BlocBuilder<StartupSearchCubit, StartupSearchState>(
                builder: (context, state) {
                  if (state is StartupSearchLoading) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    );
                  } else if (state is StartupSearchError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline_rounded,
                            size: 48,
                            color: AppColors.error,
                          ),
                          const SizedBox(height: 12),
                          Text(state.message),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: () {
                              context.read<StartupSearchCubit>().loadStartups();
                            },
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  } else if (state is StartupSearchLoaded) {
                    final startups = state.startups;

                    if (startups.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.search_off_rounded,
                                size: 64,
                                color: isDark ? Colors.white24 : Colors.black26,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No startups match your search criteria',
                                textAlign: TextAlign.center,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Try clearing some filters or searching for broader terms.',
                                textAlign: TextAlign.center,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 20),
                              OutlinedButton.icon(
                                icon: const Icon(Icons.restart_alt_rounded),
                                label: const Text('Reset Filters'),
                                onPressed: () {
                                  _searchController.clear();
                                  context
                                      .read<StartupSearchCubit>()
                                      .resetFilters();
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: () async {
                        await context.read<StartupSearchCubit>().loadStartups();
                      },
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: startups.length,
                        itemBuilder: (context, index) {
                          final startup = startups[index];
                          return StartupCard(
                            startup: startup,
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Selected startup: ${startup.name}',
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
