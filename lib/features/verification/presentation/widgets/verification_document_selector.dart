import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';

class VerificationDocumentValidator {
  static const int maxFileSizeBytes = 10 * 1024 * 1024;
  static const Set<String> allowedExtensions = {'jpg', 'jpeg', 'png', 'pdf'};

  static String? validate(PlatformFile file) {
    final extension = file.name.contains('.')
        ? file.name.split('.').last.toLowerCase()
        : null;
    if (extension == null || !allowedExtensions.contains(extension)) {
      return 'Choose a JPG, PNG, or PDF file.';
    }

    final size = file.size > 0 ? file.size : (file.bytes?.length ?? 0);
    if (size <= 0) {
      return 'The selected file is empty.';
    }
    if (size > maxFileSizeBytes) {
      return 'The selected file must be 10 MB or smaller.';
    }
    return null;
  }
}

typedef VerificationDocumentPicker = Future<void> Function();

class VerificationDocumentSelector extends StatelessWidget {
  const VerificationDocumentSelector({
    super.key,
    required this.onPick,
    required this.onRemove,
    this.selectedFile,
    this.error,
  });

  final VerificationDocumentPicker onPick;
  final VoidCallback onRemove;
  final PlatformFile? selectedFile;
  final String? error;

  static Future<PlatformFile?> pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: VerificationDocumentValidator.allowedExtensions
          .toList(),
      withData: true,
      allowMultiple: false,
    );
    if (result == null || result.files.isEmpty) return null;
    return result.files.first;
  }

  String _formattedSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    if (selectedFile != null) {
      final size = selectedFile!.size > 0
          ? selectedFile!.size
          : (selectedFile!.bytes?.length ?? 0);
      return Container(
        key: const ValueKey('verification-selected-document'),
        padding: const EdgeInsets.all(AppSizes.md),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          border: Border.all(color: AppColors.primary),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.description_outlined,
              color: AppColors.primaryDark,
            ),
            const SizedBox(width: AppSizes.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    selectedFile!.name,
                    key: const ValueKey('verification-selected-document-name'),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.ink,
                    ),
                  ),
                  Text(
                    _formattedSize(size),
                    style: textTheme.bodySmall?.copyWith(
                      color: AppColors.slate,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              key: const ValueKey('verification-replace-document'),
              tooltip: 'Replace document',
              onPressed: () async {
                await onPick();
              },
              icon: const Icon(Icons.swap_horiz_rounded),
            ),
            IconButton(
              key: const ValueKey('verification-remove-document'),
              tooltip: 'Remove document',
              onPressed: onRemove,
              icon: const Icon(Icons.close_rounded, color: AppColors.error),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        OutlinedButton.icon(
          key: const ValueKey('verification-select-document'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primaryDark,
            minimumSize: const Size.fromHeight(48),
            side: BorderSide(
              color: error == null ? AppColors.border : AppColors.error,
            ),
          ),
          onPressed: () async {
            await onPick();
          },
          icon: const Icon(Icons.attach_file_rounded),
          label: const Text('Select image or PDF'),
        ),
        if (error != null) ...[
          const SizedBox(height: AppSizes.xs),
          Text(
            error!,
            key: const ValueKey('verification-document-error'),
            style: textTheme.bodySmall?.copyWith(color: AppColors.error),
          ),
        ],
      ],
    );
  }
}
