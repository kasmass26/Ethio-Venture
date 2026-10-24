import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../startup_profile/domain/entities/startup_profile_entity.dart';
import 'startup_selection_bottom_sheet.dart';

class StartupContextChip extends StatelessWidget {
  const StartupContextChip({
    super.key,
    required this.selectedStartup,
    required this.availableStartups,
    required this.onStartupSelected,
    required this.primaryColor,
    required this.softColor,
  });

  final StartupProfileEntity? selectedStartup;
  final List<StartupProfileEntity> availableStartups;
  final ValueChanged<StartupProfileEntity?> onStartupSelected;
  final Color primaryColor;
  final Color softColor;

  @override
  Widget build(BuildContext context) {
    final hasStartup = selectedStartup != null;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: hasStartup ? primaryColor.withValues(alpha: 0.3) : AppColors.border,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: softColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              hasStartup ? Icons.business_rounded : Icons.hub_rounded,
              size: 14,
              color: primaryColor,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Text(
                      hasStartup ? 'Analyzing: ' : 'Context: ',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Flexible(
                      child: Text(
                        hasStartup ? selectedStartup!.startupName : 'General Venture Query',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: hasStartup ? primaryColor : AppColors.textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                if (hasStartup) ...[
                  const SizedBox(height: 1),
                  Text(
                    '${selectedStartup!.industry} · ${selectedStartup!.fundingStage} · \$${selectedStartup!.fundingAmountNeeded.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 10.5,
                      color: AppColors.textSecondary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          InkWell(
            onTap: () {
              StartupSelectionBottomSheet.show(
                context,
                startups: availableStartups,
                selectedStartup: selectedStartup,
                onSelected: onStartupSelected,
                primaryColor: primaryColor,
              );
            },
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: softColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    hasStartup ? 'Change' : 'Select',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: primaryColor,
                    ),
                  ),
                  const SizedBox(width: 2),
                  Icon(Icons.arrow_drop_down, size: 14, color: primaryColor),
                ],
              ),
            ),
          ),
          if (hasStartup) ...[
            const SizedBox(width: 4),
            IconButton(
              icon: const Icon(Icons.close_rounded, size: 14, color: AppColors.textSecondary),
              tooltip: 'Clear startup context',
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              onPressed: () => onStartupSelected(null),
            ),
          ],
        ],
      ),
    );
  }
}
