import 'package:ethioventure/core/constants/app_styles.dart';
import 'package:ethioventure/features/founder/presentation/pages/founder_dashboard_page.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

import 'dashboard_surface_card.dart';

class MetricCard extends StatelessWidget {
  final IconData icon;
  final DashboardMetric metric;

  const MetricCard({super.key, required this.icon, required this.metric});

  @override
  Widget build(BuildContext context) {
    return DashboardSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: AppColors.secondarySoft,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(icon, size: 18, color: AppColors.secondary),
              ),
              const SizedBox(width: 10),
              Text(metric.label, style: AppTextStyles.statLabel),
            ],
          ),
          const SizedBox(height: 18),
          Text(metric.value, style: AppTextStyles.bigStat),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(
                metric.isPositive
                    ? Icons.arrow_upward_rounded
                    : Icons.schedule_rounded,
                size: 13,
                color: metric.isPositive
                    ? AppColors.success
                    : AppColors.textSecondary,
              ),
              const SizedBox(width: 4),
              Text(
                metric.deltaText,
                style: metric.isPositive
                    ? AppTextStyles.deltaPositive
                    : AppTextStyles.statLabel,
              ),
            ],
          ),
        ],
      ),
    );
  }
}