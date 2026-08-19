import 'package:ethioventure/core/constants/app_styles.dart';
import 'package:ethioventure/features/founder/presentation/widgets/dashboard_surface_card.dart';
import 'package:ethioventure/features/investor/presentation/widgets/investor_metric.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';


class InvestorStatCard extends StatelessWidget {
  final InvestorMetric metric;

  const InvestorStatCard({super.key, required this.metric});

  @override
  Widget build(BuildContext context) {
    return DashboardSurfaceCard(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(metric.label.toUpperCase(),
                  style: AppTextStyles.statLabelCaps),
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(metric.icon, size: 16, color: AppColors.primaryDark),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(metric.value, style: AppTextStyles.bigStat),
          const SizedBox(height: 8),
          _DeltaLine(text: metric.deltaText, tone: metric.tone),
        ],
      ),
    );
  }
}

class _DeltaLine extends StatelessWidget {
  final String text;
  final DeltaTone tone;
  const _DeltaLine({required this.text, required this.tone});

  @override
  Widget build(BuildContext context) {
    late final IconData icon;
    late final TextStyle style;
    late final Color color;

    switch (tone) {
      case DeltaTone.positive:
        icon = Icons.trending_up_rounded;
        style = AppTextStyles.deltaPositive;
        color = AppColors.success;
        break;
      case DeltaTone.neutral:
        icon = Icons.remove_rounded;
        style = AppTextStyles.deltaNeutral;
        color = AppColors.textSecondary;
        break;
      case DeltaTone.warning:
        icon = Icons.priority_high_rounded;
        style = AppTextStyles.deltaWarning;
        color = AppColors.error;
        break;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: color),
        const SizedBox(width: 4),
        Flexible(
          child: Text(text, style: style, overflow: TextOverflow.ellipsis),
        ),
      ],
    );
  }
}