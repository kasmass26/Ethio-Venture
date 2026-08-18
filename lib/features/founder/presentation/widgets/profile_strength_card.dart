import 'package:ethioventure/core/constants/app_styles.dart';
import 'package:ethioventure/features/founder/presentation/pages/founder_dashboard_page.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import 'dashboard_surface_card.dart';

class ProfileStrengthCard extends StatelessWidget {
  final ProfileStrength data;

  const ProfileStrengthCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return DashboardSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Profile Strength', style: AppTextStyles.cardLabel),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.trending_up_rounded,
                    color: AppColors.primaryDark, size: 18),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text('${data.percent}%', style: AppTextStyles.bigStat),
              const SizedBox(width: 8),
              const Text('Complete', style: AppTextStyles.bigStatUnit),
            ],
          ),
          const SizedBox(height: 14),
          _ProgressTrack(percent: data.percent),
          const SizedBox(height: 18),
          ...data.checklist.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _ChecklistRow(item: item),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressTrack extends StatelessWidget {
  final int percent;
  const _ProgressTrack({required this.percent});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Container(
            height: 8,
            width: double.infinity,
            color: AppColors.secondarySoft,
            child: Align(
              alignment: Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: (percent / 100).clamp(0.0, 1.0),
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.primary, AppColors.primaryDark],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ChecklistRow extends StatelessWidget {
  final ProfileChecklistItem item;
  const _ChecklistRow({required this.item});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (item.isComplete)
          Container(
            width: 20,
            height: 20,
            decoration: const BoxDecoration(
              color: AppColors.success,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_rounded,
                color: Colors.white, size: 13),
          )
        else
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.border, width: 1.6),
            ),
          ),
        const SizedBox(width: 10),
        Text(
          item.label,
          style: item.isComplete
              ? AppTextStyles.checklistDone
              : AppTextStyles.checklistPending,
        ),
      ],
    );
  }
}