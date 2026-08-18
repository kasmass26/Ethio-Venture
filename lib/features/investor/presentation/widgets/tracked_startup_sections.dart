import 'package:ethioventure/core/constants/app_styles.dart';
import 'package:ethioventure/features/founder/presentation/widgets/dashboard_surface_card.dart';
import 'package:ethioventure/features/investor/presentation/widgets/tracked_startup.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

import 'tracked_startup_tile.dart';

class TrackedStartupsSection extends StatelessWidget {
  final List<TrackedStartup> startups;
  final VoidCallback? onManage;
  final ValueChanged<TrackedStartup>? onTapStartup;

  const TrackedStartupsSection({
    super.key,
    required this.startups,
    this.onManage,
    this.onTapStartup,
  });

  @override
  Widget build(BuildContext context) {
    return DashboardSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Tracked Startups', style: AppTextStyles.cardLabel),
              InkWell(
                onTap: onManage,
                borderRadius: BorderRadius.circular(8),
                child: const Padding(
                  padding: EdgeInsets.all(4),
                  child: Text('Manage', style: AppTextStyles.linkAction),
                ),
              ),
            ],
          ),
          for (int i = 0; i < startups.length; i++) ...[
            if (i > 0)
              const Divider(color: AppColors.divider, height: 1),
            TrackedStartupTile(
              startup: startups[i],
              onTap: () => onTapStartup?.call(startups[i]),
            ),
          ],
        ],
      ),
    );
  }
}