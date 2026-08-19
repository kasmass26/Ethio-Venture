import 'package:ethioventure/core/constants/app_styles.dart';
import 'package:ethioventure/features/founder/presentation/widgets/dashboard_surface_card.dart';
import 'package:ethioventure/features/investor/presentation/widgets/activity_item.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';


class RecentActivityCard extends StatelessWidget {
  final List<ActivityItem> items;
  final VoidCallback? onViewAll;

  const RecentActivityCard({super.key, required this.items, this.onViewAll});

  @override
  Widget build(BuildContext context) {
    return DashboardSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Recent Activity', style: AppTextStyles.cardLabel),
          const SizedBox(height: 16),
          for (int i = 0; i < items.length; i++)
            _ActivityRow(
              item: items[i],
              isLast: i == items.length - 1,
            ),
          const SizedBox(height: 6),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: onViewAll,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.secondary,
                side: const BorderSide(color: AppColors.border),
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('View All Activity',
                  style: AppTextStyles.buttonOutline),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActivityRow extends StatelessWidget {
  final ActivityItem item;
  final bool isLast;

  const _ActivityRow({required this.item, required this.isLast});

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Icon(item.icon, size: 15, color: AppColors.primaryDark),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 1.4,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    color: AppColors.divider,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text.rich(
                    TextSpan(
                      style: AppTextStyles.activityBody,
                      children: [
                        TextSpan(
                          text: item.actorName,
                          style: AppTextStyles.activityActor,
                        ),
                        TextSpan(text: ' ${item.action}'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(item.timeAgo, style: AppTextStyles.activityTimestamp),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}