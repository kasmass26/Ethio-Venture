import 'package:ethioventure/core/theme/app_colors.dart';
import 'package:ethioventure/core/theme/app_sizes.dart';
import 'package:flutter/material.dart';

/// Multi-select chip selector for target funding stages with icons.
class StageSelector extends StatelessWidget {
  const StageSelector({
    super.key,
    required this.selectedStages,
    required this.onChanged,
    this.errorText,
  });

  final Set<String> selectedStages;
  final ValueChanged<Set<String>> onChanged;
  final String? errorText;

  static const Map<String, IconData> stageIcons = {
    'Pre-Seed': Icons.lightbulb_outlined,
    'Seed': Icons.nature_outlined,
    'Series A': Icons.rocket_launch_outlined,
    'Series B+': Icons.corporate_fare_outlined,
  };

  static List<String> get availableStages => stageIcons.keys.toList();

  void _toggleStage(String stage) {
    final updated = Set<String>.from(selectedStages);
    if (updated.contains(stage)) {
      updated.remove(stage);
    } else {
      updated.add(stage);
    }
    onChanged(updated);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: AppSizes.sm,
          runSpacing: AppSizes.sm,
          children: stageIcons.entries.map((entry) {
            final stage = entry.key;
            final icon = entry.value;
            final isSelected = selectedStages.contains(stage);

            return InkWell(
              onTap: () => _toggleStage(stage),
              borderRadius: BorderRadius.circular(12),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 11,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFFD97706)
                      : (isDark
                          ? AppColors.surfaceDark
                          : AppColors.surfaceVariant),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? Colors.transparent
                        : (isDark ? AppColors.borderDark : AppColors.border),
                    width: 1.5,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: const Color(0xFFD97706).withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isSelected ? Icons.bolt_rounded : icon,
                      size: 17,
                      color: isSelected
                          ? Colors.white
                          : (isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondary),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      stage,
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight:
                            isSelected ? FontWeight.w800 : FontWeight.w600,
                        color: isSelected
                            ? Colors.white
                            : (isDark
                                ? AppColors.textPrimaryDark
                                : AppColors.textPrimary),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
        if (errorText != null) ...[
          const SizedBox(height: AppSizes.xs),
          Text(
            errorText!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: isDark ? const Color(0xFFFFB4AB) : AppColors.error,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }
}
