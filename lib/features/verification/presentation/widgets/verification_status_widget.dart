import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../domain/entities/verification_status.dart';

/// Accessible presentation for a verification request status.
///
/// This widget only presents a status. It does not submit a request, perform
/// review, or infer approval from profile approval state.
class VerificationStatusWidget extends StatelessWidget {
  const VerificationStatusWidget({
    super.key,
    required this.status,
  });

  final VerificationStatus? status;

  VerificationStatus get _effectiveStatus => status ?? VerificationStatus.notSubmitted;

  @override
  Widget build(BuildContext context) {
    final effectiveStatus = _effectiveStatus;
    final presentation = _Presentation.fromStatus(effectiveStatus);
    final isApproved = effectiveStatus.isApproved;

    return Semantics(
      container: true,
      label: '${presentation.title}. ${presentation.explanation}',
      child: Container(
        key: ValueKey('verification-status-${effectiveStatus.value}'),
        padding: const EdgeInsets.all(AppSizes.md),
        decoration: BoxDecoration(
          color: presentation.backgroundColor,
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          border: Border.all(
            color: presentation.borderColor,
            width: 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: AppSizes.iconLg,
              height: AppSizes.iconLg,
              decoration: BoxDecoration(
                color: presentation.iconBackgroundColor,
                borderRadius: BorderRadius.circular(AppSizes.radiusSm),
              ),
              child: Icon(
                presentation.icon,
                size: AppSizes.iconMd,
                color: presentation.iconColor,
                semanticLabel: presentation.title,
              ),
            ),
            const SizedBox(width: AppSizes.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    presentation.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: AppSizes.xs),
                  Text(
                    presentation.explanation,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.slate,
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
            if (isApproved) ...[
              const SizedBox(width: AppSizes.sm),
              Semantics(
                label: 'Verified',
                child: Container(
                  key: const ValueKey('authoritative-verification-badge'),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.sm,
                    vertical: AppSizes.xs,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.verified_rounded,
                        size: AppSizes.iconSm,
                        color: AppColors.secondary,
                        semanticLabel: 'Verified',
                      ),
                      SizedBox(width: AppSizes.xs),
                      Text(
                        'Verified',
                        style: TextStyle(
                          color: AppColors.secondary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Presentation {
  const _Presentation({
    required this.title,
    required this.explanation,
    required this.icon,
    required this.backgroundColor,
    required this.borderColor,
    required this.iconBackgroundColor,
    required this.iconColor,
  });

  final String title;
  final String explanation;
  final IconData icon;
  final Color backgroundColor;
  final Color borderColor;
  final Color iconBackgroundColor;
  final Color iconColor;

  factory _Presentation.fromStatus(VerificationStatus status) {
    switch (status) {
      case VerificationStatus.notSubmitted:
        return _Presentation(
          title: 'Not submitted',
          explanation: 'You have not submitted this verification type yet.',
          icon: Icons.radio_button_unchecked_rounded,
          backgroundColor: AppColors.white,
          borderColor: AppColors.hairline,
          iconBackgroundColor: AppColors.surfaceVariant,
          iconColor: AppColors.slate,
        );
      case VerificationStatus.pending:
        return const _Presentation(
          title: 'Pending',
          explanation: 'Your verification request is waiting for review.',
          icon: Icons.hourglass_top_rounded,
          backgroundColor: AppColors.warningSoft,
          borderColor: Color(0xFFDDBF7A),
          iconBackgroundColor: AppColors.white,
          iconColor: AppColors.warning,
        );
      case VerificationStatus.approved:
        return const _Presentation(
          title: 'Approved',
          explanation: 'Your verification has been approved by an authoritative review.',
          icon: Icons.verified_outlined,
          backgroundColor: AppColors.primarySoft,
          borderColor: AppColors.primary,
          iconBackgroundColor: AppColors.primary,
          iconColor: AppColors.secondary,
        );
      case VerificationStatus.rejected:
        return const _Presentation(
          title: 'Rejected',
          explanation: 'Your verification request was not approved.',
          icon: Icons.cancel_rounded,
          backgroundColor: Color(0xFFFFECEC),
          borderColor: Color(0xFFE9B6B6),
          iconBackgroundColor: AppColors.white,
          iconColor: AppColors.error,
        );
      case VerificationStatus.resubmissionRequired:
        return const _Presentation(
          title: 'Resubmission required',
          explanation: 'Review the feedback and submit the verification again when ready.',
          icon: Icons.refresh_rounded,
          backgroundColor: AppColors.secondarySoft,
          borderColor: AppColors.border,
          iconBackgroundColor: AppColors.white,
          iconColor: AppColors.secondary,
        );
      case VerificationStatus.additionalInfoRequired:
        return const _Presentation(
          title: 'Additional information required',
          explanation: 'More information is needed before the verification can be reviewed.',
          icon: Icons.info_outline_rounded,
          backgroundColor: AppColors.primarySoft,
          borderColor: AppColors.primary,
          iconBackgroundColor: AppColors.white,
          iconColor: AppColors.primaryDark,
        );
    }
  }
}
