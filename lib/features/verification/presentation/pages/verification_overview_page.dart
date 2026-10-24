import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../domain/entities/verification_type.dart';
import '../cubit/verification_cubit.dart';
import '../cubit/verification_state.dart';
import '../widgets/verification_status_widget.dart';
import '../widgets/verification_type_card.dart';

/// Overview of verification types and the current user's request metadata.
///
/// This page does not upload evidence or infer approval from profile approval.
class VerificationOverviewPage extends StatefulWidget {
  const VerificationOverviewPage({super.key});

  @override
  State<VerificationOverviewPage> createState() =>
      _VerificationOverviewPageState();
}

class _VerificationOverviewPageState extends State<VerificationOverviewPage> {
  VerificationType? _selectedType;

  void _selectType(VerificationType type) {
    setState(() => _selectedType = type);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return BlocProvider<VerificationCubit>(
      create: (_) => sl<VerificationCubit>()..loadRequests(),
      child: Scaffold(
        backgroundColor: AppColors.fog,
        appBar: AppBar(
          title: const Text('Profile Verification'),
          foregroundColor: AppColors.ink,
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
                  ((availableWidth - contentWidth) / 2) +
                  AppSizes.pageHorizontal;
              final crossAxisCount = availableWidth >= 700 ? 2 : 1;

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
                            borderRadius: BorderRadius.circular(
                              AppSizes.radiusLg,
                            ),
                            border: Border.all(color: AppColors.hairline),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(AppSizes.sm),
                                decoration: BoxDecoration(
                                  color: AppColors.primarySoft,
                                  borderRadius: BorderRadius.circular(
                                    AppSizes.radiusMd,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.verified_user_outlined,
                                  color: AppColors.primaryDark,
                                  size: AppSizes.iconLg,
                                ),
                              ),
                              const SizedBox(height: AppSizes.md),
                              Text(
                                'Build trust with verification',
                                style: textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.ink,
                                ),
                              ),
                              const SizedBox(height: AppSizes.sm),
                              Text(
                                'Verification provides additional confidence that a profile belongs to the student, person, business, or investor it represents. It is optional and does not replace your existing profile.',
                                style: textTheme.bodyMedium?.copyWith(
                                  color: AppColors.slate,
                                  height: 1.45,
                                ),
                              ),
                              const SizedBox(height: AppSizes.md),
                              Container(
                                padding: const EdgeInsets.all(AppSizes.md),
                                decoration: BoxDecoration(
                                  color: AppColors.secondarySoft,
                                  borderRadius: BorderRadius.circular(
                                    AppSizes.radiusMd,
                                  ),
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
                                        'Profile approval is separate from verification. Selecting a type only records your choice on this screen; it does not submit a request, approve verification, or create a verified badge.',
                                        style: TextStyle(
                                          color: AppColors.secondary,
                                          height: 1.45,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSizes.lg),
                        BlocBuilder<VerificationCubit, VerificationState>(
                          builder: (context, state) {
                            if (state is VerificationLoading) {
                              return const Padding(
                                padding: EdgeInsets.only(bottom: AppSizes.lg),
                                child: Center(
                                  child: CircularProgressIndicator(
                                    color: AppColors.primary,
                                  ),
                                ),
                              );
                            }
                            if (state is VerificationError) {
                              return Padding(
                                padding: const EdgeInsets.only(
                                  bottom: AppSizes.lg,
                                ),
                                child: Text(
                                  state.message,
                                  key: const ValueKey(
                                    'verification-load-error',
                                  ),
                                  style: textTheme.bodyMedium?.copyWith(
                                    color: AppColors.error,
                                  ),
                                ),
                              );
                            }
                            if (state is VerificationEmpty) {
                              return Padding(
                                padding: const EdgeInsets.only(
                                  bottom: AppSizes.lg,
                                ),
                                child: Text(
                                  'No verification requests submitted yet.',
                                  key: const ValueKey('verification-empty'),
                                  style: textTheme.bodyMedium?.copyWith(
                                    color: AppColors.slate,
                                  ),
                                ),
                              );
                            }
                            if (state is VerificationLoaded) {
                              return Padding(
                                padding: const EdgeInsets.only(
                                  bottom: AppSizes.lg,
                                ),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: state.requests
                                      .map(
                                        (request) => Padding(
                                          padding: const EdgeInsets.only(
                                            bottom: AppSizes.sm,
                                          ),
                                          child: VerificationStatusWidget(
                                            status: request.status,
                                          ),
                                        ),
                                      )
                                      .toList(),
                                ),
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                        Text(
                          'Choose a verification type',
                          style: textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: AppColors.ink,
                          ),
                        ),
                        const SizedBox(height: AppSizes.xs),
                        Text(
                          'Select the type that is most appropriate for your profile and role.',
                          style: textTheme.bodyMedium?.copyWith(
                            color: AppColors.slate,
                          ),
                        ),
                        const SizedBox(height: AppSizes.md),
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: VerificationType.values.length,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: crossAxisCount,
                                mainAxisSpacing: AppSizes.md,
                                crossAxisSpacing: AppSizes.md,
                                mainAxisExtent: 210,
                              ),
                          itemBuilder: (context, index) {
                            final type = VerificationType.values[index];
                            return VerificationTypeCard(
                              type: type,
                              selected: _selectedType == type,
                              onSelected: () => _selectType(type),
                            );
                          },
                        ),
                        const SizedBox(height: AppSizes.lg),
                        if (_selectedType != null)
                          Semantics(
                            liveRegion: true,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Container(
                                  key: const ValueKey(
                                    'selected-verification-type',
                                  ),
                                  padding: const EdgeInsets.all(AppSizes.md),
                                  decoration: BoxDecoration(
                                    color: AppColors.primarySoft,
                                    borderRadius: BorderRadius.circular(
                                      AppSizes.radiusMd,
                                    ),
                                    border: Border.all(
                                      color: AppColors.primary.withValues(
                                        alpha: 0.5,
                                      ),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.check_circle_outline_rounded,
                                        color: AppColors.primaryDark,
                                      ),
                                      const SizedBox(width: AppSizes.sm),
                                      Expanded(
                                        child: Text(
                                          '${_selectedType!.displayLabel} selected. This does not submit or verify anything.',
                                          style: textTheme.bodyMedium?.copyWith(
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.secondary,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: AppSizes.md),
                                FilledButton.icon(
                                  key: const ValueKey('verification-continue'),
                                  style: FilledButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    foregroundColor: AppColors.secondary,
                                    minimumSize: const Size.fromHeight(48),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                        AppSizes.radiusMd,
                                      ),
                                    ),
                                  ),
                                  onPressed: () async {
                                    final submitted =
                                        await Navigator.of(context).pushNamed(
                                          AppConstants
                                              .routeVerificationSubmission,
                                          arguments: _selectedType,
                                        );
                                    if (submitted == true && context.mounted) {
                                      context
                                          .read<VerificationCubit>()
                                          .loadRequests();
                                    }
                                  },
                                  icon: const Icon(Icons.arrow_forward_rounded),
                                  label: const Text('Continue'),
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
      ),
    );
  }
}
