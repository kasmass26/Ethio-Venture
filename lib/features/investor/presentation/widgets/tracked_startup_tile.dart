import 'package:ethioventure/core/constants/app_styles.dart';
import 'package:ethioventure/features/investor/presentation/widgets/tracked_startup.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class TrackedStartupTile extends StatelessWidget {
  final TrackedStartup startup;
  final VoidCallback? onTap;

  const TrackedStartupTile({super.key, required this.startup, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _InitialAvatar(name: startup.name),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(startup.name, style: AppTextStyles.investorLocation),
                      const SizedBox(height: 2),
                      Text(
                        startup.fundingGoalLabel,
                        style: AppTextStyles.checklistDone,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('FUNDING PROGRESS', style: AppTextStyles.progressLabel),
                Text('${startup.progressPercent}%',
                    style: AppTextStyles.progressPercent),
              ],
            ),
            const SizedBox(height: 8),
            _ProgressBar(percent: startup.progressPercent),
          ],
        ),
      ),
    );
  }
}

class _InitialAvatar extends StatelessWidget {
  final String name;
  const _InitialAvatar({required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: AppColors.secondarySoft,
        borderRadius: BorderRadius.circular(10),
      ),
      alignment: Alignment.center,
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : '?',
        style: const TextStyle(
          color: AppColors.secondary,
          fontWeight: FontWeight.w800,
          fontSize: 15,
        ),
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  final int percent;
  const _ProgressBar({required this.percent});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Container(
        height: 7,
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
  }
}