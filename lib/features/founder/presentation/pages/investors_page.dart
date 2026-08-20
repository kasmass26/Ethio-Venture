import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../connection_requests/domain/entities/connection_request_entity.dart';
import '../../../connection_requests/domain/repositories/connection_request_repository.dart';
import '../../../investor_profile/domain/entities/investor_discovery_entity.dart';
import '../../../messaging/domain/repositories/messaging_repository.dart';
import '../../../startup_profile/presentation/cubit/startup_profile_cubit.dart';
import '../../../startup_profile/presentation/cubit/startup_profile_state.dart';
import '../cubit/recommended_investors_cubit.dart';
import '../cubit/recommended_investors_state.dart';
import '../widgets/dashboard_bottom_nav.dart';
import '../widgets/investor_card.dart';
import '../widgets/investor_detail_sheet.dart';

class InvestorsPage extends StatefulWidget {
  const InvestorsPage({super.key});

  @override
  State<InvestorsPage> createState() => _InvestorsPageState();
}

class _InvestorsPageState extends State<InvestorsPage> {
  String _selectedFilter = 'Recommended ⭐';
  String _searchQuery = '';
  final List<String> _filters = [
    'Recommended ⭐',
    'All',
    'High Match (70%+)',
    'VC',
    'Angel',
    'Syndicate',
  ];

  @override
  Widget build(BuildContext context) {
    final currentUserId = sl<SupabaseClient>().auth.currentUser?.id ?? '';

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
              } else if (index == 2) {
                Navigator.of(context).pushNamed(
                  AppConstants.routeMessages,
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
                _buildMatchHeaderCard(),
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
          builder: (context) => TextButton.icon(
            onPressed: () => Navigator.of(context)
                .pushNamed(AppConstants.routeFounderRequests),
            icon: const Icon(Icons.swap_horiz_rounded,
                size: 16, color: AppColors.primaryDark),
            label: const Text(
              'My Requests',
              style: TextStyle(
                color: AppColors.primaryDark,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.refresh_rounded,
                color: AppColors.textPrimary),
            onPressed: () =>
                context.read<RecommendedInvestorsCubit>().load(),
          ),
        ),
        const SizedBox(width: 6),
      ],
    );
  }

  Widget _buildMatchHeaderCard() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 10),
        child: BlocBuilder<StartupProfileCubit, StartupProfileState>(
          builder: (context, state) {
            if (state is StartupProfileLoaded) {
              final profile = state.profile;
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.secondary, AppColors.secondaryLight],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.secondary.withOpacity(0.15),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.auto_awesome_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'AI Investor Recommendation Engine',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              Text(
                                'Matched & ranked based on your startup profile',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 11.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context)
                                .pushNamed(AppConstants.routeStartupProfile)
                                .then((_) {
                              final uid = sl<SupabaseClient>().auth.currentUser?.id ?? '';
                              if (context.mounted && uid.isNotEmpty) {
                                context.read<StartupProfileCubit>().loadProfile(uid);
                              }
                            });
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Colors.white.withOpacity(0.18),
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            minimumSize: const Size(0, 0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Row(
                            children: [
                              Text(
                                'Edit Profile',
                                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                              ),
                              SizedBox(width: 3),
                              Icon(Icons.edit_outlined, size: 12),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        if (profile.startupName.isNotEmpty)
                          _ProfileChip(
                            icon: Icons.business_rounded,
                            label: profile.startupName,
                          ),
                        if (profile.industry.isNotEmpty)
                          _ProfileChip(
                            icon: Icons.category_rounded,
                            label: profile.industry,
                          ),
                        if (profile.fundingStage.isNotEmpty)
                          _ProfileChip(
                            icon: Icons.stairs_rounded,
                            label: profile.fundingStage,
                          ),
                        if (profile.fundingAmountNeeded > 0)
                          _ProfileChip(
                            icon: Icons.payments_rounded,
                            label: '\$${profile.fundingAmountNeeded.toStringAsFixed(0)} Needed',
                          ),
                      ],
                    ),
                  ],
                ),
              );
            }

            if (state is StartupProfileEmpty) {
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.primary.withOpacity(0.4)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        color: AppColors.primarySoft,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.person_add_alt_1_rounded,
                        color: AppColors.primaryDark,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Unlock Personalised Investor Matches',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Complete your startup profile to rank investors by industry & ticket size.',
                            style: TextStyle(
                              color: AppColors.textSecondary.withOpacity(0.9),
                              fontSize: 11.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context)
                            .pushNamed(AppConstants.routeStartupProfileSetup);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryDark,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Setup',
                        style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 14),
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

        if (state is RecommendedInvestorsEmpty) {
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
                        Icons.person_search_rounded,
                        size: 36,
                        color: AppColors.primaryDark,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'No investors in directory yet',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Investors will appear here once they create and configure their investment thesis.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () => context.read<RecommendedInvestorsCubit>().load(),
                      icon: const Icon(Icons.refresh_rounded, size: 18),
                      label: const Text('Refresh'),
                    ),
                  ],
                ),
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

          // Compute top recommendations for spotlight rail (score >= 50 or top 5)
          final topRecommended = state.investors
              .where((i) => i.matchScore >= 50)
              .take(5)
              .toList();

          final bool showSpotlight =
              (_selectedFilter == 'Recommended ⭐' || _selectedFilter == 'All') &&
                  topRecommended.isNotEmpty &&
                  _searchQuery.isEmpty;

          return SliverMainAxisGroup(
            slivers: [
              // Spotlight Rail for Top Recommended Investors
              if (showSpotlight)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 18, bottom: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            children: [
                              Icon(Icons.star_rounded,
                                  color: AppColors.warning, size: 18),
                              SizedBox(width: 6),
                              Text(
                                'Top Matches For You',
                                style: TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 15.5,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          height: 275,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            itemCount: topRecommended.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(width: 14),
                            itemBuilder: (context, index) {
                              final investor = topRecommended[index];
                              return InvestorCard(
                                investor: investor,
                                onTap: () =>
                                    InvestorDetailSheet.show(context, investor),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: Divider(color: AppColors.border, height: 1),
                        ),
                      ],
                    ),
                  ),
                ),

              // Main Directory List Title
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
                  child: Text(
                    _selectedFilter == 'Recommended ⭐'
                        ? 'Recommended Investors Directory'
                        : 'All Investors (${filtered.length})',
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),

              // Main Directory List
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final investor = filtered[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: _InvestorCatalogCard(
                          investor: investor,
                          onTap: () => InvestorDetailSheet.show(context, investor),
                          onConnectTap: () => _connectAndPitch(context, investor),
                        ),
                      );
                    },
                    childCount: filtered.length,
                  ),
                ),
              ),
            ],
          );
        }

        return const SliverToBoxAdapter(child: SizedBox.shrink());
      },
    );
  }

  List<InvestorDiscoveryEntity> _filterInvestors(
      List<InvestorDiscoveryEntity> list) {
    return list.where((inv) {
      // 0. Ensure strictly approved profiles only
      if (!inv.isApproved) return false;

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
      if (_selectedFilter == 'Recommended ⭐') {
        return true; // Already sorted by score descending in Cubit
      }
      if (_selectedFilter == 'High Match (70%+)') {
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

  /// Handles the Connect button tap — sends a connection request (or opens
  /// chat if already accepted).
  Future<void> _connectAndPitch(
      BuildContext context, InvestorDiscoveryEntity investor) async {
    try {
      developer.log(
        'Connect tapped for investor ${investor.displayName}',
        name: 'InvestorsPage.ConnectPitch',
      );

      final requestRepo = sl<ConnectionRequestRepository>();
      final existing = await requestRepo.getRequestBetween(
        otherUserId: investor.userId,
      );

      if (!context.mounted) return;

      // Already accepted → go directly to chat
      if (existing != null && existing.isAccepted) {
        final messagingRepo = sl<MessagingRepository>();
        final startupProfileId =
            await messagingRepo.resolveStartupProfileId();
        if (startupProfileId == null) return;
        final conv = await messagingRepo.getOrCreateConversation(
          startupProfileId: startupProfileId,
          investorProfileId: investor.id,
        );
        if (context.mounted) {
          Navigator.of(context).pushNamed(
            AppConstants.routeChat,
            arguments: {
              'conversationId': conv.id,
              'participantName': investor.displayName,
            },
          );
        }
        return;
      }

      // Pending → inform user
      if (existing != null && existing.isPending) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              '⏳ Your connection request is pending. Please wait for the investor to respond.',
            ),
            backgroundColor: AppColors.warning,
          ),
        );
        return;
      }

      // Declined → inform user
      if (existing != null && existing.isDeclined) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Your previous request was declined by this investor.',
            ),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }

      // No existing request → show send-request dialog
      await _showSendRequestDialog(context, investor);
    } catch (e, st) {
      developer.log(
        'Error in _connectAndPitch: $e',
        name: 'InvestorsPage.ConnectPitch',
        error: e,
        stackTrace: st,
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.error,
            content: Text(
              'Error: ${e.toString().replaceAll('Exception: ', '')}',
            ),
          ),
        );
      }
    }
  }

  Future<void> _showSendRequestDialog(
      BuildContext context, InvestorDiscoveryEntity investor) async {
    final messageController = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primarySoft,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.connect_without_contact_rounded,
                color: AppColors.primaryDark,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                'Send Connection Request',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'You are requesting to connect with ${investor.displayName}.',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13.5,
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              'Add an intro message (optional)',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: messageController,
              maxLines: 3,
              maxLength: 300,
              decoration: InputDecoration(
                hintText:
                    'Briefly introduce yourself and why you want to connect…',
                hintStyle: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
                filled: true,
                fillColor: AppColors.surfaceVariant,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.all(12),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton.icon(
            onPressed: () => Navigator.of(ctx).pop(true),
            icon: const Icon(Icons.send_rounded, size: 15),
            label: const Text('Send Request'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    try {
      final requestRepo = sl<ConnectionRequestRepository>();
      await requestRepo.sendRequest(
        investorUserId: investor.userId,
        investorProfileId: investor.id,
        message: messageController.text.trim().isEmpty
            ? null
            : messageController.text.trim(),
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '✅ Connection request sent to ${investor.displayName}!',
            ),
            backgroundColor: AppColors.success,
          ),
        );
        // Refresh the list so button states update
        setState(() {});
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to send request: ${e.toString().replaceAll('Exception: ', '')}',
            ),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}

class _ProfileChip extends StatelessWidget {
  const _ProfileChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.18),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _InvestorCatalogCard extends StatefulWidget {
  const _InvestorCatalogCard({
    required this.investor,
    required this.onTap,
    required this.onConnectTap,
  });

  final InvestorDiscoveryEntity investor;
  final VoidCallback onTap;
  final VoidCallback onConnectTap;

  @override
  State<_InvestorCatalogCard> createState() => _InvestorCatalogCardState();
}

class _InvestorCatalogCardState extends State<_InvestorCatalogCard> {
  Future<ConnectionRequestEntity?>? _statusFuture;

  @override
  void initState() {
    super.initState();
    _loadStatus();
  }

  void _loadStatus() {
    final repo = sl<ConnectionRequestRepository>();
    _statusFuture =
        repo.getRequestBetween(otherUserId: widget.investor.userId);
  }

  @override
  Widget build(BuildContext context) {
    final investor = widget.investor;
    final onTap = widget.onTap;
    final onConnectTap = widget.onConnectTap;

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

              // Match Reasons Chips (Why this investor is recommended)
              if (investor.matchReasons.isNotEmpty) ...[
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: investor.matchReasons.map((reason) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.successSoft,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: AppColors.success.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.check_circle_rounded,
                            size: 11,
                            color: AppColors.success,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            reason,
                            style: const TextStyle(
                              color: AppColors.success,
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],

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

              const SizedBox(height: 14),

              // Bottom info & action bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Container(
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
                          Flexible(
                            child: Text(
                              investor.ticketSizeDisplay,
                              style: const TextStyle(
                                color: AppColors.secondary,
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 4,
                    children: [
                      TextButton(
                        onPressed: onTap,
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.textSecondary,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 6),
                          minimumSize: const Size(0, 0),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text(
                          'View Thesis',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      // Dynamic connect button based on request status
                      FutureBuilder<ConnectionRequestEntity?>(
                        future: _statusFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const SizedBox(
                              width: 90,
                              height: 34,
                              child: Center(
                                child: SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            );
                          }

                          final req = snapshot.data;

                          // ── Accepted → Message button ──────────────────
                          if (req != null && req.isAccepted) {
                            return ElevatedButton.icon(
                              onPressed: () {
                                onConnectTap();
                                setState(_loadStatus);
                              },
                              icon: const Icon(Icons.chat_bubble_outline_rounded,
                                  size: 13, color: Colors.white),
                              label: const Text(
                                'Message',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.success,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                                minimumSize: const Size(0, 34),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                elevation: 0,
                              ),
                            );
                          }

                          // ── Pending → show status chip ─────────────────
                          if (req != null && req.isPending) {
                            return GestureDetector(
                              onTap: () {
                                onConnectTap();
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: AppColors.warningSoft,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                      color: AppColors.warning
                                          .withOpacity(0.4)),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.hourglass_top_rounded,
                                        size: 12, color: AppColors.warning),
                                    SizedBox(width: 4),
                                    Text(
                                      'Pending',
                                      style: TextStyle(
                                        color: AppColors.warning,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }

                          // ── Declined → muted chip ──────────────────────
                          if (req != null && req.isDeclined) {
                            return GestureDetector(
                              onTap: () => onConnectTap(),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFEEEE),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                      color: AppColors.error
                                          .withOpacity(0.3)),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.cancel_outlined,
                                        size: 12, color: AppColors.error),
                                    SizedBox(width: 4),
                                    Text(
                                      'Declined',
                                      style: TextStyle(
                                        color: AppColors.error,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }

                          // ── No request → Connect button ────────────────
                          return ElevatedButton.icon(
                            onPressed: () {
                              onConnectTap();
                              // Refresh status after action
                              Future.delayed(
                                const Duration(milliseconds: 800),
                                () {
                                  if (mounted) setState(_loadStatus);
                                },
                              );
                            },
                            icon: const Icon(Icons.send_rounded,
                                size: 13, color: Colors.white),
                            label: const Text(
                              'Connect',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.secondary,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              minimumSize: const Size(0, 34),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              elevation: 0,
                            ),
                          );
                        },
                      ),
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
    final label = isHigh ? 'High Match' : 'Match';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: fg.withOpacity(0.25)),
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
          const SizedBox(width: 3),
          Text(
            label,
            style: TextStyle(
              color: fg,
              fontSize: 9.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
