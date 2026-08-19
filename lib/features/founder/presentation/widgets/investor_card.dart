import 'package:ethioventure/core/constants/app_styles.dart';
import 'package:ethioventure/features/founder/presentation/pages/founder_dashboard_page.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

import 'dashboard_surface_card.dart';

class InvestorCard extends StatelessWidget {
  final Investor investor;
  final VoidCallback? onViewProfile;

  const InvestorCard({super.key, required this.investor, this.onViewProfile});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 240,
      child: DashboardSurfaceCard(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _Avatar(url: investor.avatarUrl, name: investor.name),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        investor.name,
                        style: AppTextStyles.investorName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        investor.location,
                        style: AppTextStyles.investorLocation,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: investor.tags.map((t) => _TagChip(label: t)).toList(),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: onViewProfile,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.secondary,
                  side: const BorderSide(color: AppColors.border),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('View Profile',
                    style: AppTextStyles.buttonOutline),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final String? url;
  final String name;
  const _Avatar({required this.url, required this.name});

  @override
  Widget build(BuildContext context) {
    final initials = name.isNotEmpty ? name[0].toUpperCase() : '?';
    return CircleAvatar(
      radius: 22,
      backgroundColor: AppColors.secondarySoft,
      backgroundImage: url != null ? NetworkImage(url!) : null,
      child: url == null
          ? Text(
              initials,
              style: const TextStyle(
                color: AppColors.secondary,
                fontWeight: FontWeight.w700,
              ),
            )
          : null,
    );
  }
}

class _TagChip extends StatelessWidget {
  final String label;
  const _TagChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(label, style: AppTextStyles.tag),
    );
  }
}