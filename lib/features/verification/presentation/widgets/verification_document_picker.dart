import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';

typedef VerificationDocumentSelector = Future<PlatformFile?> Function();

class VerificationDocumentPicker extends StatefulWidget {
  const VerificationDocumentPicker({
    super.key,
    this.initialFile,
    this.onChanged,
    this.selector,
  });

  final PlatformFile? initialFile;
  final ValueChanged<PlatformFile?>? onChanged;
  final VerificationDocumentSelector? selector;

  @override
  State<VerificationDocumentPicker> createState() =>
      _VerificationDocumentPickerState();
}

class _VerificationDocumentPickerState
    extends State<VerificationDocumentPicker> {
  PlatformFile? _selectedFile;
  String? _selectionError;
  bool _isSelecting = false;

  @override
  void initState() {
    super.initState();
    _selectedFile = widget.initialFile;
  }

  Future<PlatformFile?> _defaultSelector() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['pdf', 'jpg', 'jpeg', 'png', 'doc', 'docx'],
    );

    if (result == null || result.files.isEmpty) return null;
    return result.files.first;
  }

  Future<void> _selectFile() async {
    if (_isSelecting) return;

    setState(() {
      _isSelecting = true;
      _selectionError = null;
    });

    try {
      final file = await (widget.selector ?? _defaultSelector)();
      if (!mounted) return;

      if (file == null) {
        setState(() {
          _isSelecting = false;
          _selectionError =
              'No file was selected. Try selecting a document again.';
        });
        return;
      }

      final extension =
          file.extension?.toLowerCase() ??
          file.name.split('.').last.toLowerCase();
      const supportedExtensions = {'pdf', 'jpg', 'jpeg', 'png', 'doc', 'docx'};
      if (!supportedExtensions.contains(extension)) {
        setState(() {
          _isSelecting = false;
          _selectionError =
              'Unsupported file type. Choose PDF, JPG, PNG, DOC, or DOCX.';
        });
        return;
      }

      setState(() {
        _selectedFile = file;
        _selectionError = null;
        _isSelecting = false;
      });
      widget.onChanged?.call(file);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isSelecting = false;
        _selectionError =
            'The document could not be selected. Please try again.';
      });
    }
  }

  void _removeFile() {
    setState(() {
      _selectedFile = null;
      _selectionError = null;
    });
    widget.onChanged?.call(null);
  }

  @override
  Widget build(BuildContext context) {
    final file = _selectedFile;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Document',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w800,
            color: AppColors.ink,
          ),
        ),
        const SizedBox(height: AppSizes.xs),
        Container(
          key: const ValueKey('verification-document-picker'),
          padding: const EdgeInsets.all(AppSizes.md),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            border: Border.all(
              color: _selectionError == null
                  ? AppColors.hairline
                  : AppColors.error,
            ),
          ),
          child: file == null
              ? Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: AppSizes.sm,
                  runSpacing: AppSizes.sm,
                  children: [
                    Container(
                      width: AppSizes.iconLg,
                      height: AppSizes.iconLg,
                      decoration: BoxDecoration(
                        color: AppColors.primarySoft,
                        borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                      ),
                      child: const Icon(
                        Icons.upload_file_outlined,
                        color: AppColors.primaryDark,
                        semanticLabel: 'Select document',
                      ),
                    ),
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        minWidth: 0,
                        maxWidth: MediaQuery.sizeOf(context).width - 160,
                      ),
                      child: Text(
                        'No document selected',
                        key: const ValueKey('verification-document-empty'),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.slate,
                        ),
                      ),
                    ),
                    OutlinedButton(
                      key: const ValueKey('verification-document-select'),
                      onPressed: _isSelecting ? null : _selectFile,
                      child: Text(_isSelecting ? 'Selecting...' : 'Select'),
                    ),
                  ],
                )
              : Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: AppSizes.sm,
                  runSpacing: AppSizes.sm,
                  children: [
                    Container(
                      width: AppSizes.iconLg,
                      height: AppSizes.iconLg,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                      ),
                      child: const Icon(
                        Icons.insert_drive_file_outlined,
                        color: AppColors.secondary,
                        semanticLabel: 'Selected document',
                      ),
                    ),
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.sizeOf(context).width - 160,
                      ),
                      child: Text(
                        file.name,
                        key: const ValueKey('verification-document-name'),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.ink,
                        ),
                      ),
                    ),
                    IconButton(
                      key: const ValueKey('verification-document-remove'),
                      tooltip: 'Remove selected document',
                      onPressed: _removeFile,
                      icon: const Icon(Icons.close_rounded),
                    ),
                    IconButton(
                      key: const ValueKey('verification-document-replace'),
                      tooltip: 'Replace selected document',
                      onPressed: _isSelecting ? null : _selectFile,
                      icon: const Icon(Icons.swap_horiz_rounded),
                    ),
                  ],
                ),
        ),
        if (_selectionError != null) ...[
          const SizedBox(height: AppSizes.xs),
          Text(
            _selectionError!,
            key: const ValueKey('verification-document-error'),
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColors.error),
          ),
        ],
      ],
    );
  }
}
