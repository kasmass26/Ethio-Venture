import 'package:ethioventure/core/constants/app_styles.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';


class SectionHeader extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onActionTap;
  final bool showArrow;

  const SectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onActionTap,
    this.showArrow = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: Text(title, style: AppTextStyles.sectionTitle)),
          if (actionLabel != null)
            InkWell(
              onTap: onActionTap,
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(actionLabel!, style: AppTextStyles.linkAction),
                    if (showArrow) ...[
                      const SizedBox(width: 3),
                      const Icon(Icons.arrow_forward_rounded,
                          size: 14, color: AppColors.primaryDark),
                    ],
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}