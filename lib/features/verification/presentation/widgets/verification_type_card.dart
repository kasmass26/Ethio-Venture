import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../domain/entities/verification_type.dart';

/// Selectable card used by the verification-type selection overview.
class VerificationTypeCard extends StatelessWidget {
  const VerificationTypeCard({
    super.key,
    required this.type,
    required this.selected,
    required this.onSelected,
  });

  final VerificationType type;
  final bool selected;
  final VoidCallback onSelected;

  IconData get _icon {
    switch (type) {
      case VerificationType.student:
        return Icons.school_outlined;
      case VerificationType.identity:
        return Icons.badge_outlined;
      case VerificationType.business:
        return Icons.business_outlined;
      case VerificationType.investor:
        return Icons.account_balance_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final borderColor = selected ? AppColors.primary : AppColors.hairline;

    return Semantics(
      button: true,
      selected: selected,
      label: '${type.displayLabel}. ${type.description}',
      child: InkWell(
        onTap: onSelected,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          constraints: const BoxConstraints(minHeight: 210),
          padding: const EdgeInsets.all(AppSizes.md),
          decoration: BoxDecoration(
            color: selected ? AppColors.primarySoft : AppColors.white,
            borderRadius: BorderRadius.circular(AppSizes.radiusLg),
            border: Border.all(
              color: borderColor,
              width: selected ? 2 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: AppSizes.iconLg,
                    height: AppSizes.iconLg,
                    decoration: BoxDecoration(
                      color: selected
                          ? AppColors.primary
                          : AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                    ),
                    child: Icon(
                      _icon,
                      size: AppSizes.iconMd,
                      color: selected ? AppColors.white : AppColors.secondary,
                    ),
                  ),
                  const Spacer(),
                  if (selected)
                    const Icon(
                      Icons.check_circle_rounded,
                      color: AppColors.primaryDark,
                      size: AppSizes.iconMd,
                      semanticLabel: 'Selected',
                    ),
                ],
              ),
              const SizedBox(height: AppSizes.md),
              Text(
                type.displayLabel,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink,
                ),
              ),
              const SizedBox(height: AppSizes.xs),
              Text(
                type.description,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.slate,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
