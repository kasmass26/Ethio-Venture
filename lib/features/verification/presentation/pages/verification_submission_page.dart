import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../domain/entities/verification_type.dart';
import '../cubit/verification_cubit.dart';
import '../cubit/verification_state.dart';
import '../widgets/verification_document_selector.dart';

/// Page for selecting supporting evidence and submitting request metadata.
///
/// Evidence selection is local-only until a private verification storage
/// backend and document-reference schema are implemented.
class VerificationSubmissionPage extends StatefulWidget {
  const VerificationSubmissionPage({
    super.key,
    required this.type,
    this.documentPicker,
  });

  final VerificationType type;
  final Future<PlatformFile?> Function()? documentPicker;

  @override
  State<VerificationSubmissionPage> createState() =>
      _VerificationSubmissionPageState();
}

class _VerificationSubmissionPageState
    extends State<VerificationSubmissionPage> {
  PlatformFile? _selectedFile;
  String? _documentError;

  Future<void> _pickDocument() async {
    final file =
        await (widget.documentPicker?.call() ??
            VerificationDocumentSelector.pickFile());
    if (file == null) return;

    final error = VerificationDocumentValidator.validate(file);
    setState(() {
      _documentError = error;
      _selectedFile = error == null ? file : null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return BlocProvider<VerificationCubit>(
      create: (_) => sl<VerificationCubit>(),
      child: Scaffold(
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
                  ((availableWidth - contentWidth) / 2) +
                  AppSizes.pageHorizontal;

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
                                width: AppSizes.iconLg,
                                height: AppSizes.iconLg,
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(
                                    AppSizes.radiusSm,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.description_outlined,
                                  color: AppColors.secondary,
                                  size: AppSizes.iconMd,
                                ),
                              ),
                              const SizedBox(height: AppSizes.md),
                              Text(
                                widget.type.displayLabel,
                                key: const ValueKey(
                                  'submission-verification-type',
                                ),
                                style: textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.ink,
                                ),
                              ),
                              const SizedBox(height: AppSizes.sm),
                              Text(
                                widget.type.description,
                                style: textTheme.bodyMedium?.copyWith(
                                  color: AppColors.slate,
                                  height: 1.45,
                                ),
                              ),
                              const SizedBox(height: AppSizes.md),
                              Container(
                                key: const ValueKey(
                                  'verification-submission-notice',
                                ),
                                padding: const EdgeInsets.all(AppSizes.md),
                                decoration: BoxDecoration(
                                  color: AppColors.secondarySoft,
                                  borderRadius: BorderRadius.circular(
                                    AppSizes.radiusMd,
                                  ),
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
                                        'Select an image or PDF for review preparation. Secure document storage is not configured yet, so this submission will not upload or store the selected file.',
                                        style: TextStyle(
                                          color: AppColors.secondary,
                                          height: 1.45,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: AppSizes.md),
                              VerificationDocumentSelector(
                                selectedFile: _selectedFile,
                                error: _documentError,
                                onPick: _pickDocument,
                                onRemove: () => setState(() {
                                  _selectedFile = null;
                                  _documentError = null;
                                }),
                              ),
                              const SizedBox(height: AppSizes.lg),
                              const SizedBox(height: AppSizes.lg),
                              BlocConsumer<
                                VerificationCubit,
                                VerificationState
                              >(
                                listener: (context, state) {
                                  if (state is VerificationSuccess) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Verification request submitted as pending.',
                                        ),
                                        backgroundColor: AppColors.success,
                                      ),
                                    );
                                    Navigator.of(context).pop(true);
                                  } else if (state is VerificationError) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(state.message),
                                        backgroundColor: AppColors.error,
                                      ),
                                    );
                                  }
                                },
                                builder: (context, state) {
                                  final isSubmitting =
                                      state is VerificationSubmitting;
                                  return SizedBox(
                                    width: double.infinity,
                                    child: FilledButton.icon(
                                      key: const ValueKey(
                                        'verification-submit-button',
                                      ),
                                      style: FilledButton.styleFrom(
                                        backgroundColor: AppColors.primary,
                                        foregroundColor: AppColors.secondary,
                                        minimumSize: const Size.fromHeight(48),
                                      ),
                                      onPressed:
                                          isSubmitting || _selectedFile == null
                                          ? null
                                          : () {
                                              context
                                                  .read<VerificationCubit>()
                                                  .startVerificationRequest(
                                                    widget.type,
                                                  );
                                            },
                                      icon: isSubmitting
                                          ? const SizedBox.square(
                                              dimension: 18,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: AppColors.secondary,
                                              ),
                                            )
                                          : const Icon(Icons.send_rounded),
                                      label: Text(
                                        isSubmitting
                                            ? 'Submitting...'
                                            : 'Submit Request',
                                      ),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: AppSizes.sm),
                              SizedBox(
                                width: double.infinity,
                                child: OutlinedButton.icon(
                                  key: const ValueKey(
                                    'verification-submission-back-button',
                                  ),
                                  onPressed: () =>
                                      Navigator.of(context).pop(false),
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
      ),
    );
  }
}
