import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../domain/entities/verification_type.dart';
import '../cubit/verification_cubit.dart';
import '../cubit/verification_state.dart';
import '../widgets/verification_document_picker.dart';

/// Submission page for a single verification type.
///
/// This page is pushed from [VerificationOverviewPage] with a
/// [VerificationType] argument.  It creates its own [VerificationCubit]
/// (via GetIt) so it owns its submission lifecycle independently of the
/// overview page's cubit.
///
/// On success it pops with `true` so the overview page can refresh.
class VerificationSubmissionPage extends StatelessWidget {
  const VerificationSubmissionPage({
    super.key,
    required this.type,
    this.documentSelector,
  });

  final VerificationType type;

  /// Injectable selector for tests — defaults to the real [FilePicker].
  final VerificationDocumentSelector? documentSelector;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<VerificationCubit>(
      create: (_) => sl<VerificationCubit>(),
      child: _SubmissionView(
        type: type,
        documentSelector: documentSelector,
      ),
    );
  }
}

// ── Main view ─────────────────────────────────────────────────────────────────

class _SubmissionView extends StatefulWidget {
  const _SubmissionView({required this.type, this.documentSelector});

  final VerificationType type;
  final VerificationDocumentSelector? documentSelector;

  @override
  State<_SubmissionView> createState() => _SubmissionViewState();
}

class _SubmissionViewState extends State<_SubmissionView> {
  PlatformFile? _selectedDocument;
  bool _acknowledged = false;
  bool _validationAttempted = false;

  bool get _hasDocumentError =>
      _validationAttempted && _selectedDocument == null;
  bool get _hasAcknowledgementError =>
      _validationAttempted && !_acknowledged;

  void _checkForm() => setState(() => _validationAttempted = true);

  void _handleSubmit(BuildContext context) {
    setState(() => _validationAttempted = true);

    if (_selectedDocument == null || !_acknowledged) return;

    final bytes = _selectedDocument!.bytes;
    if (bytes == null || bytes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Could not read the selected file. Please select it again.',
          ),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    context.read<VerificationCubit>().submitWithDocument(
      type: widget.type,
      fileBytes: bytes,
      filename: _selectedDocument!.name,
      fileSizeBytes: _selectedDocument!.size > 0
          ? _selectedDocument!.size
          : bytes.length,
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return BlocConsumer<VerificationCubit, VerificationState>(
      listener: (context, state) {
        if (state is VerificationSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Verification request submitted successfully.'),
              backgroundColor: AppColors.primary,
            ),
          );
          // Pop with true so the overview page refreshes its request list.
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
        final cubit = context.read<VerificationCubit>();
        final isRunning =
            state is VerificationSubmitting || state is VerificationUploading;
        final storageReady = cubit.canSubmitWithDocument;

        return Scaffold(
          backgroundColor: AppColors.fog,
          appBar: AppBar(
            foregroundColor: AppColors.ink,
            title: const Text('Verification Submission'),
            leading: IconButton(
              key: const ValueKey('verification-submission-back'),
              tooltip: 'Back to verification overview',
              onPressed:
                  isRunning ? null : () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_back_rounded),
            ),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(
                AppSizes.pageHorizontal,
                AppSizes.lg,
                AppSizes.pageHorizontal,
                AppSizes.xl,
              ),
              child: Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: AppSizes.maxContentWidth,
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(AppSizes.lg),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                      border: Border.all(color: AppColors.hairline),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // ── Header ─────────────────────────────────────────
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
                          widget.type.displayLabel,
                          key: const ValueKey('submission-verification-type'),
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

                        // ── Storage notice ─────────────────────────────────
                        if (!storageReady) ...[
                          Container(
                            key: const ValueKey('verification-backend-notice'),
                            padding: const EdgeInsets.all(AppSizes.md),
                            decoration: BoxDecoration(
                              color: AppColors.secondarySoft,
                              borderRadius:
                                  BorderRadius.circular(AppSizes.radiusMd),
                              border:
                                  Border.all(color: AppColors.border),
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
                                    'Secure document storage is not configured yet. '
                                    'Submission is disabled until the storage bucket '
                                    'is set up in the Supabase Dashboard.',
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
                        ],

                        // ── Document picker ────────────────────────────────
                        VerificationDocumentPicker(
                          selector: widget.documentSelector,
                          onChanged: (file) {
                            setState(() => _selectedDocument = file);
                          },
                        ),
                        if (_hasDocumentError) ...[
                          const SizedBox(height: AppSizes.xs),
                          Text(
                            'Select a document before submitting.',
                            key: const ValueKey(
                              'verification-document-validation',
                            ),
                            style: textTheme.bodySmall
                                ?.copyWith(color: AppColors.error),
                          ),
                        ],
                        const SizedBox(height: AppSizes.lg),

                        // ── Acknowledgement ────────────────────────────────
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Checkbox(
                              key: const ValueKey(
                                'verification-acknowledgement',
                              ),
                              activeColor: AppColors.primary,
                              checkColor: AppColors.secondary,
                              value: _acknowledged,
                              onChanged: isRunning
                                  ? null
                                  : (v) => setState(
                                        () => _acknowledged = v ?? false,
                                      ),
                            ),
                            const SizedBox(width: AppSizes.xs),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  const Padding(
                                    padding: EdgeInsets.only(top: 12),
                                    child: Text(
                                      'I confirm that the selected document '
                                      'belongs to me and is accurate.',
                                    ),
                                  ),
                                  if (_hasAcknowledgementError) ...[
                                    const SizedBox(height: AppSizes.xs),
                                    Text(
                                      'You must acknowledge before submitting.',
                                      key: const ValueKey(
                                        'verification-acknowledgement-validation',
                                      ),
                                      style: textTheme.bodySmall?.copyWith(
                                        color: AppColors.error,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSizes.md),

                        // ── Check form button ──────────────────────────────
                        OutlinedButton.icon(
                          key: const ValueKey('verification-check-form'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primaryDark,
                            side: const BorderSide(
                              color: AppColors.primary,
                            ),
                            minimumSize: const Size.fromHeight(48),
                          ),
                          onPressed: isRunning ? null : _checkForm,
                          icon: const Icon(Icons.fact_check_outlined),
                          label: const Text('Check Form'),
                        ),
                        const SizedBox(height: AppSizes.sm),

                        // ── Submit button ──────────────────────────────────
                        FilledButton.icon(
                          key: const ValueKey('verification-submit-button'),
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.secondary,
                            minimumSize: const Size.fromHeight(48),
                          ),
                          onPressed: (isRunning || !storageReady)
                              ? null
                              : () => _handleSubmit(context),
                          icon: isRunning
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.secondary,
                                  ),
                                )
                              : const Icon(Icons.cloud_upload_outlined),
                          label: Text(
                            isRunning
                                ? 'Uploading…'
                                : 'Submit Verification',
                          ),
                        ),

                        const SizedBox(height: AppSizes.sm),

                        // ── Back button ────────────────────────────────────
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            key: const ValueKey(
                              'verification-submission-back-button',
                            ),
                            onPressed:
                                isRunning
                                    ? null
                                    : () => Navigator.of(context).pop(),
                            icon: const Icon(Icons.arrow_back_rounded),
                            label: const Text('Back to Overview'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
