import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../domain/entities/verification_type.dart';

/// Shell page for the verification submission flow.
///
/// Submission and document handling are intentionally not implemented here.
class VerificationSubmissionPage extends StatelessWidget {
  const VerificationSubmissionPage({
    super.key,
    required this.type,
  });

  final VerificationType type;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.fog,
      appBar: AppBar(
        foregroundColor: AppColors.ink,
        title: const Text('Verification Submission'),
        leading: IconButton(
          key: const ValueKey('verification-submission-back'),
          tooltip: 'Back to verification overview',
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final availableWidth = constraints.maxWidth;
            final contentWidth = availableWidth.clamp(
              0.0,
              AppSizes.maxContentWidth,
            );
            final horizontalPadding =
                ((availableWidth - contentWidth) / 2) + AppSizes.pageHorizontal;

            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                AppSizes.lg,
                horizontalPadding,
                AppSizes.xl,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: contentWidth),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(AppSizes.lg),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                          border: Border.all(color: AppColors.hairline),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: AppSizes.iconLg,
                              height: AppSizes.iconLg,
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius:
                                    BorderRadius.circular(AppSizes.radiusSm),
                              ),
                              child: const Icon(
                                Icons.description_outlined,
                                color: AppColors.secondary,
                                size: AppSizes.iconMd,
                              ),
                            ),
                            const SizedBox(height: AppSizes.md),
                            Text(
                              type.displayLabel,
                              key: const ValueKey('submission-verification-type'),
                              style: textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: AppColors.ink,
                              ),
                            ),
                            const SizedBox(height: AppSizes.sm),
                            Text(
                              type.description,
                              style: textTheme.bodyMedium?.copyWith(
                                color: AppColors.slate,
                                height: 1.45,
                              ),
                            ),
                            const SizedBox(height: AppSizes.md),
                            Container(
                              key: const ValueKey('verification-backend-notice'),
                              padding: const EdgeInsets.all(AppSizes.md),
                              decoration: BoxDecoration(
                                color: AppColors.secondarySoft,
                                borderRadius:
                                    BorderRadius.circular(AppSizes.radiusMd),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: const Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.info_outline_rounded,
                                    color: AppColors.secondary,
                                    size: AppSizes.iconMd,
                                  ),
                                  SizedBox(width: AppSizes.sm),
                                  Expanded(
                                    child: Text(
                                      'The submission process is not yet connected to the backend. You can review the selected type here, but documents and verification requests cannot be submitted yet.',
                                      style: TextStyle(
                                        color: AppColors.secondary,
                                        height: 1.45,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: AppSizes.lg),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                key: const ValueKey('verification-submission-back-button'),
                                onPressed: () => Navigator.of(context).pop(),
                                icon: const Icon(Icons.arrow_back_rounded),
                                label: const Text('Back to Overview'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
