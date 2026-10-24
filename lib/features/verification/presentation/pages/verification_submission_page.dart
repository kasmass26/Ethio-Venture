import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../domain/entities/verification_type.dart';
import '../widgets/verification_document_picker.dart';

/// Local form shell for preparing a verification submission.
///
/// It does not validate documents or submit verification requests.
class VerificationSubmissionPage extends StatefulWidget {
  const VerificationSubmissionPage({
    super.key,
    required this.type,
    this.documentSelector,
  });

  final VerificationType type;
  final VerificationDocumentSelector? documentSelector;

  @override
  State<VerificationSubmissionPage> createState() =>
      _VerificationSubmissionPageState();
}

class _VerificationSubmissionPageState
    extends State<VerificationSubmissionPage> {
  PlatformFile? _selectedDocument;
  bool _acknowledged = false;
  bool _validationAttempted = false;

  bool get _hasDocumentError =>
      _validationAttempted && _selectedDocument == null;
  bool get _hasAcknowledgementError => _validationAttempted && !_acknowledged;

  void _checkForm() {
    setState(() => _validationAttempted = true);
  }

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
                    Container(
                      width: AppSizes.iconLg,
                      height: AppSizes.iconLg,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(AppSizes.radiusSm),
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
                    Container(
                      key: const ValueKey('verification-backend-notice'),
                      padding: const EdgeInsets.all(AppSizes.md),
                      decoration: BoxDecoration(
                        color: AppColors.secondarySoft,
                        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
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
                              'The required documents and submission rules must be confirmed with the backend team. This form is a preview only and does not upload files, verify documents, or submit a request.',
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
                    VerificationDocumentPicker(
                      selector: widget.documentSelector,
                      onChanged: (file) {
                        setState(() => _selectedDocument = file);
                      },
                    ),
                    if (_hasDocumentError) ...[
                      const SizedBox(height: AppSizes.xs),
                      Text(
                        'Select a document to complete the form preview.',
                        key: const ValueKey('verification-document-validation'),
                        style: textTheme.bodySmall?.copyWith(
                          color: AppColors.error,
                        ),
                      ),
                    ],
                    const SizedBox(height: AppSizes.lg),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Checkbox(
                          key: const ValueKey('verification-acknowledgement'),
                          activeColor: AppColors.primary,
                          checkColor: AppColors.secondary,
                          value: _acknowledged,
                          onChanged: (value) {
                            setState(() => _acknowledged = value ?? false);
                          },
                        ),
                        const SizedBox(width: AppSizes.xs),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(top: 12),
                                child: Text(
                                  'I understand that this form is not connected to backend submission.',
                                ),
                              ),
                              if (_hasAcknowledgementError) ...[
                                const SizedBox(height: AppSizes.xs),
                                Text(
                                  'Confirm this notice before checking the form.',
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
                    OutlinedButton.icon(
                      key: const ValueKey('verification-check-form'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primaryDark,
                        side: const BorderSide(color: AppColors.primary),
                        minimumSize: const Size.fromHeight(48),
                      ),
                      onPressed: _checkForm,
                      icon: const Icon(Icons.fact_check_outlined),
                      label: const Text('Check Form'),
                    ),
                    const SizedBox(height: AppSizes.sm),
                    FilledButton.icon(
                      key: const ValueKey('verification-submit-placeholder'),
                      onPressed: null,
                      icon: const Icon(Icons.cloud_upload_outlined),
                      label: const Text('Submit Verification (Unavailable)'),
                    ),
                    const SizedBox(height: AppSizes.xs),
                    Text(
                      'Submission is disabled until the backend contract is confirmed.',
                      key: const ValueKey('verification-submit-explanation'),
                      textAlign: TextAlign.center,
                      style: textTheme.bodySmall?.copyWith(
                        color: AppColors.slate,
                      ),
                    ),
                    const SizedBox(height: AppSizes.lg),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        key: const ValueKey(
                          'verification-submission-back-button',
                        ),
                        onPressed: () => Navigator.of(context).pop(),
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
  }
}
