import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../investor_profile/domain/entities/investor_discovery_entity.dart';
import '../../../startup_profile/presentation/cubit/startup_profile_cubit.dart';
import '../../../startup_profile/presentation/cubit/startup_profile_state.dart';
import '../cubit/recommended_investors_cubit.dart';
import '../cubit/recommended_investors_state.dart';
import '../widgets/dashboard_bottom_nav.dart';
import '../widgets/investor_detail_sheet.dart';

class InvestorsPage extends StatefulWidget {
  const InvestorsPage({super.key});

  @override
  State<InvestorsPage> createState() => _InvestorsPageState();
}

class _InvestorsPageState extends State<InvestorsPage> {
  String _selectedFilter = 'All';
  String _searchQuery = '';
  final List<String> _filters = ['All', 'High Match', 'VC', 'Angel', 'Syndicate'];

  @override
  Widget build(BuildContext context) {
    final currentUserId =
        sl<SupabaseClient>().auth.currentUser?.id ?? '';

    return MultiBlocProvider(
      providers: [
        BlocProvider<StartupProfileCubit>(
          create: (_) => sl<StartupProfileCubit>()..loadProfile(currentUserId),
        ),
        BlocProvider<RecommendedInvestorsCubit>(
          create: (_) => sl<RecommendedInvestorsCubit>()..load(),
        ),
      ],
      child: BlocListener<StartupProfileCubit, StartupProfileState>(
        listener: (context, startupState) {
          if (startupState is StartupProfileLoaded) {
            context
                .read<RecommendedInvestorsCubit>()
                .load(startupState.profile);
          }
        },
        child: Scaffold(
          backgroundColor: AppColors.background,
          bottomNavigationBar: DashboardBottomNav(
            currentIndex: 1,
            onTap: (index) {
              if (index == 0) {
                Navigator.of(context).pushReplacementNamed(
                  AppConstants.routeFounderDashboard,
                );
              } else if (index == 3) {
                Navigator.of(context).pushReplacementNamed(
                  AppConstants.routeStartupProfile,
                );
              }
            },
          ),
          body: SafeArea(
            bottom: false,
            child: CustomScrollView(
              slivers: [
                _buildAppBar(),
                _buildSearchBar(),
                _buildFilterChips(),
                _buildInvestorsList(),
                const SliverToBoxAdapter(child: SizedBox(height: 32)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      backgroundColor: AppColors.background,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      pinned: true,
      titleSpacing: 20,
      title: const Text(
        'Investors Directory',
        style: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
      actions: [
        Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColors.textPrimary),
            onPressed: () => context.read<RecommendedInvestorsCubit>().load(),
          ),
        ),
        const SizedBox(width: 14),
      ],
    );
  }

  Widget _buildSearchBar() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 14),
        child: TextField(
          onChanged: (value) {
            setState(() {
              _searchQuery = value.trim().toLowerCase();
            });
          },
          decoration: InputDecoration(
            hintText: 'Search by investor name, thesis, industry...',
            hintStyle: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13.5,
            ),
            prefixIcon: const Icon(
              Icons.search_rounded,
              color: AppColors.textSecondary,
              size: 20,
            ),
            filled: true,
            fillColor: AppColors.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: AppColors.border.withOpacity(0.7)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: AppColors.border.withOpacity(0.7)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.primaryDark, width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return SliverToBoxAdapter(
      child: SizedBox(
        height: 38,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: _filters.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (context, index) {
            final filter = _filters[index];
            final isSelected = filter == _selectedFilter;
            return ChoiceChip(
              label: Text(filter),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _selectedFilter = filter;
                  });
                }
              },
              backgroundColor: AppColors.surface,
              selectedColor: AppColors.primarySoft,
              labelStyle: TextStyle(
                color: isSelected
                    ? AppColors.primaryDark
                    : AppColors.textSecondary,
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
              ),
              side: BorderSide(
                color: isSelected ? AppColors.primaryDark : AppColors.border.withOpacity(0.7),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildInvestorsList() {
    return BlocBuilder<RecommendedInvestorsCubit, RecommendedInvestorsState>(
      builder: (context, state) {
        if (state is RecommendedInvestorsLoading ||
            state is RecommendedInvestorsInitial) {
          return const SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(AppColors.primary),
              ),
            ),
          );
        }

        if (state is RecommendedInvestorsError) {
          return SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.cloud_off_rounded, size: 48, color: AppColors.warning),
                  const SizedBox(height: 12),
                  Text(
                    state.message,
                    style: const TextStyle(color: AppColors.textSecondary),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => context.read<RecommendedInvestorsCubit>().load(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        if (state is RecommendedInvestorsLoaded) {
          final filtered = _filterInvestors(state.investors);

          if (filtered.isEmpty) {
            return SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: const BoxDecoration(
                          color: AppColors.primarySoft,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.search_off_rounded,
                          size: 36,
                          color: AppColors.primaryDark,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'No investors match your filter',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Try searching with a different keyword or resetting filters.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          return SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final investor = filtered[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: _InvestorCatalogCard(
                      investor: investor,
                      onTap: () => InvestorDetailSheet.show(context, investor),
                    ),
                  );
                },
                childCount: filtered.length,
              ),
            ),
          );
        }

        return const SliverToBoxAdapter(child: SizedBox.shrink());
      },
    );
  }

  List<InvestorDiscoveryEntity> _filterInvestors(
      List<InvestorDiscoveryEntity> list) {
    return list.where((inv) {
      // 1. Text Search query
      if (_searchQuery.isNotEmpty) {
        final nameMatch = inv.displayName.toLowerCase().contains(_searchQuery);
        final bioMatch = inv.bio?.toLowerCase().contains(_searchQuery) ?? false;
        final industryMatch = inv.preferredIndustries
            .any((i) => i.toLowerCase().contains(_searchQuery));
        final locMatch = inv.geographicFocus
            .any((g) => g.toLowerCase().contains(_searchQuery));

        if (!nameMatch && !bioMatch && !industryMatch && !locMatch) {
          return false;
        }
      }

      // 2. Filter chip
      if (_selectedFilter == 'High Match') {
        return inv.matchScore >= 70;
      }
      if (_selectedFilter == 'VC') {
        return inv.investorType.toLowerCase().contains('vc') ||
            inv.investorType.toLowerCase().contains('venture');
      }
      if (_selectedFilter == 'Angel') {
        return inv.investorType.toLowerCase().contains('angel');
      }
      if (_selectedFilter == 'Syndicate') {
        return inv.investorType.toLowerCase().contains('firm') ||
            inv.investorType.toLowerCase().contains('syndicate');
      }

      return true;
    }).toList();
  }
}

class _InvestorCatalogCard extends StatelessWidget {
  const _InvestorCatalogCard({
    required this.investor,
    required this.onTap,
  });

  final InvestorDiscoveryEntity investor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border.withOpacity(0.7)),
            boxShadow: [
              BoxShadow(
                color: AppColors.secondary.withOpacity(0.03),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Row: Avatar + Names + Match Score
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.secondary, AppColors.secondaryLight],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      investor.displayName.isNotEmpty
                          ? investor.displayName[0].toUpperCase()
                          : 'I',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          investor.displayName,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.primarySoft,
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Text(
                                investor.investorTypeLabel,
                                style: const TextStyle(
                                  color: AppColors.primaryDark,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Icon(Icons.place_outlined,
                                size: 12, color: AppColors.textSecondary),
                            const SizedBox(width: 2),
                            Expanded(
                              child: Text(
                                investor.locationDisplay,
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 11.5,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  _MatchScoreBadge(score: investor.matchScore),
                ],
              ),

              // Bio excerpt if available
              if (investor.bio != null && investor.bio!.trim().isNotEmpty) ...[
                const SizedBox(height: 10),
                Text(
                  investor.bio!.trim(),
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12.5,
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],

              const SizedBox(height: 12),

              // Tags
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  ...investor.preferredIndustries.take(3).map((tag) => Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.secondarySoft,
                          borderRadius: BorderRadius.circular(7),
                        ),
                        child: Text(
                          tag,
                          style: const TextStyle(
                            color: AppColors.secondary,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      )),
                  if (investor.preferredStages.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primarySoft,
                        borderRadius: BorderRadius.circular(7),
                      ),
                      child: Text(
                        investor.preferredStages.first,
                        style: const TextStyle(
                          color: AppColors.primaryDark,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 12),

              // Bottom info bar: Ticket size and View Profile
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.payments_outlined,
                            size: 13, color: AppColors.secondary),
                        const SizedBox(width: 5),
                        Text(
                          investor.ticketSizeDisplay,
                          style: const TextStyle(
                            color: AppColors.secondary,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'View Thesis',
                        style: TextStyle(
                          color: AppColors.primaryDark,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(Icons.arrow_forward_ios_rounded,
                          size: 10, color: AppColors.primaryDark),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MatchScoreBadge extends StatelessWidget {
  const _MatchScoreBadge({required this.score});

  final int score;

  @override
  Widget build(BuildContext context) {
    final isHigh = score >= 70;
    final bg = isHigh ? AppColors.successSoft : AppColors.primarySoft;
    final fg = isHigh ? AppColors.success : AppColors.primaryDark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.bolt_rounded, size: 12, color: fg),
          const SizedBox(width: 2),
          Text(
            '$score%',
            style: TextStyle(
              color: fg,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
