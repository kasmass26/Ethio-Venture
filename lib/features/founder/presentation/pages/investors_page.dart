import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../widgets/dashboard_bottom_nav.dart';

class InvestorsPage extends StatefulWidget {
  const InvestorsPage({super.key});

  @override
  State<InvestorsPage> createState() => _InvestorsPageState();
}

class _InvestorsPageState extends State<InvestorsPage> {
  String _selectedFilter = 'All';
  final List<String> _filters = ['All', 'Saved', 'Interested', 'Matched'];

  // Mock data - replace with real data from Cubit/Bloc
  static const _investors = [
    InvestorProfile(
      id: 'inv-1',
      name: 'Nile Capital',
      location: 'Addis Ababa, ETH',
      tags: ['Fintech', 'Seed'],
      description:
          'Early-stage VC focused on financial technology and digital banking solutions across East Africa.',
      investmentRange: '\$50K - \$500K',
      portfolio: 12,
      isSaved: true,
    ),
    InvestorProfile(
      id: 'inv-2',
      name: 'Rift Ventures',
      location: 'Nairobi, KEN',
      tags: ['Agritech', 'Series A'],
      description:
          'Growth-stage investor supporting agriculture and supply chain innovations.',
      investmentRange: '\$500K - \$2M',
      portfolio: 8,
      isSaved: false,
    ),
    InvestorProfile(
      id: 'inv-3',
      name: 'Horn Angels',
      location: 'Addis Ababa, ETH',
      tags: ['Healthtech', 'Pre-seed'],
      description:
          'Angel network backing health technology startups in their earliest stages.',
      investmentRange: '\$10K - \$100K',
      portfolio: 25,
      isSaved: true,
    ),
    InvestorProfile(
      id: 'inv-4',
      name: 'Savanna Fund',
      location: 'Lagos, NGA',
      tags: ['EdTech', 'Seed'],
      description:
          'Pan-African fund investing in education technology and digital learning platforms.',
      investmentRange: '\$100K - \$750K',
      portfolio: 15,
      isSaved: false,
    ),
    InvestorProfile(
      id: 'inv-5',
      name: 'Atlas Capital',
      location: 'Cape Town, RSA',
      tags: ['E-commerce', 'Series A'],
      description:
          'Specialized in scaling e-commerce and marketplace businesses across Africa.',
      investmentRange: '\$750K - \$3M',
      portfolio: 10,
      isSaved: false,
    ),
    InvestorProfile(
      id: 'inv-6',
      name: 'Zephyr Ventures',
      location: 'Kigali, RWA',
      tags: ['Cleantech', 'Seed'],
      description:
          'Impact investor focused on renewable energy and climate solutions.',
      investmentRange: '\$200K - \$1M',
      portfolio: 18,
      isSaved: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            const SliverToBoxAdapter(child: SizedBox(height: 28)),
          ],
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
        'Investors',
        style: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
      actions: [
        _IconButton(
          icon: Icons.filter_list_rounded,
          onTap: () {
            // TODO: Implement advanced filter modal
          },
        ),
        const SizedBox(width: 20),
      ],
    );
  }

  Widget _buildSearchBar() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
        child: TextField(
          decoration: InputDecoration(
            hintText: 'Search investors...',
            hintStyle: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
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
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.primaryDark),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          onChanged: (value) {
            // TODO: Implement search functionality
          },
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return SliverToBoxAdapter(
      child: SizedBox(
        height: 40,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: _filters.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (context, index) {
            final filter = _filters[index];
            final isSelected = filter == _selectedFilter;
            return FilterChip(
              label: Text(filter),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedFilter = filter;
                });
              },
              backgroundColor: AppColors.surface,
              selectedColor: AppColors.primarySoft,
              labelStyle: TextStyle(
                color: isSelected
                    ? AppColors.primaryDark
                    : AppColors.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
              side: BorderSide(
                color: isSelected ? AppColors.primaryDark : AppColors.border,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final investor = _investors[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _InvestorCard(
                investor: investor,
                onTap: () {
                  // TODO: Navigate to investor profile page
                },
                onSaveToggle: () {
                  // TODO: Implement save/unsave functionality
                },
              ),
            );
          },
          childCount: _investors.length,
        ),
      ),
    );
  }
}

class _IconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _IconButton({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Icon(icon, color: AppColors.textPrimary, size: 20),
      ),
    );
  }
}

class _InvestorCard extends StatelessWidget {
  final InvestorProfile investor;
  final VoidCallback onTap;
  final VoidCallback onSaveToggle;

  const _InvestorCard({
    required this.investor,
    required this.onTap,
    required this.onSaveToggle,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Avatar
                Container(
                  width: 48,
                  height: 48,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.primarySoft,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    investor.name.isNotEmpty ? investor.name[0] : '?',
                    style: const TextStyle(
                      color: AppColors.primaryDark,
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Name and location
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        investor.name,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(
                            Icons.place_outlined,
                            size: 13,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 3),
                          Expanded(
                            child: Text(
                              investor.location,
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Save button
                InkWell(
                  onTap: onSaveToggle,
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    width: 36,
                    height: 36,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: investor.isSaved
                          ? AppColors.primarySoft
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      investor.isSaved
                          ? Icons.bookmark_rounded
                          : Icons.bookmark_border_rounded,
                      size: 18,
                      color: investor.isSaved
                          ? AppColors.primaryDark
                          : AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Description
            Text(
              investor.description,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                height: 1.4,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            // Tags
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: investor.tags
                  .map((tag) => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.secondarySoft,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          tag,
                          style: const TextStyle(
                            color: AppColors.secondary,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 12),
            // Investment info
            Row(
              children: [
                _InfoChip(
                  icon: Icons.payments_outlined,
                  text: investor.investmentRange,
                ),
                const SizedBox(width: 8),
                _InfoChip(
                  icon: Icons.business_center_outlined,
                  text: '${investor.portfolio} portfolio',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoChip({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppColors.textSecondary),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Domain model
// ---------------------------------------------------------------------------

class InvestorProfile {
  final String id;
  final String name;
  final String location;
  final List<String> tags;
  final String description;
  final String investmentRange;
  final int portfolio;
  final bool isSaved;
  final String? avatarUrl;

  const InvestorProfile({
    required this.id,
    required this.name,
    required this.location,
    required this.tags,
    required this.description,
    required this.investmentRange,
    required this.portfolio,
    this.isSaved = false,
    this.avatarUrl,
  });
}
