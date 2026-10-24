import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';

/// Entry point from a profile to the verification overview.
///
/// This card only navigates to the overview. It does not represent a
/// verification status or imply that the profile has been verified.
class VerificationEntryCard extends StatelessWidget {
  const VerificationEntryCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Profile Verification. Explore verification options.',
      child: InkWell(
        key: const ValueKey('profile-verification-entry'),
        onTap: () => Navigator.pushNamed(
          context,
          AppConstants.routeVerificationOverview,
        ),
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        child: Container(
          padding: const EdgeInsets.all(AppSizes.md),
          decoration: BoxDecoration(
            color: AppColors.primarySoft,
            borderRadius: BorderRadius.circular(AppSizes.radiusLg),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.55)),
          ),
          child: Row(
            children: [
              Container(
                width: AppSizes.iconLg,
                height: AppSizes.iconLg,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                ),
                child: const Icon(
                  Icons.verified_user_outlined,
                  color: AppColors.secondary,
                  size: AppSizes.iconMd,
                  semanticLabel: 'Profile verification',
                ),
              ),
              const SizedBox(width: AppSizes.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Profile Verification',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.ink,
                      ),
                    ),
                    const SizedBox(height: AppSizes.xs),
                    Text(
                      'Explore optional verification for your profile.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.slate,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSizes.sm),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                color: AppColors.primaryDark,
                size: AppSizes.iconSm,
                semanticLabel: 'Open verification overview',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
