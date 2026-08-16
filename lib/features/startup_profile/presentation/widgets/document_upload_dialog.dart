import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../cubit/document_upload_cubit.dart';
import '../cubit/document_upload_state.dart';

class DocumentUploadDialog extends StatefulWidget {
  final String startupId;
  final Function() onUploadComplete;

  const DocumentUploadDialog({
    super.key,
    required this.startupId,
    required this.onUploadComplete,
  });

  @override
  State<DocumentUploadDialog> createState() => _DocumentUploadDialogState();
}

class _DocumentUploadDialogState extends State<DocumentUploadDialog> {
  final _fileNameController = TextEditingController(
    text: 'EthioVenture_PitchDeck_2025.pdf',
  );
  String _selectedCategory = 'Pitch Deck';
  String _selectedFileType = 'PDF';
  int _simulatedFileSize = 3800000; // 3.8 MB

  final List<String> _categories = [
    'Pitch Deck',
    'Business Plan',
    'Financial Model',
    'Legal / Cap Table',
    'Other',
  ];

  final List<String> _fileTypes = ['PDF', 'PPTX', 'XLSX', 'DOCX'];

  @override
  void dispose() {
    _fileNameController.dispose();
    super.dispose();
  }

  void _triggerUpload() {
    final fileName = _fileNameController.text.trim();
    if (fileName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid document file name.'),
        ),
      );
      return;
    }

    context.read<DocumentUploadCubit>().uploadDocument(
      startupId: widget.startupId,
      category: _selectedCategory,
      fileName: fileName,
      fileType: _selectedFileType,
      fileSizeBytes: _simulatedFileSize,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: BlocConsumer<DocumentUploadCubit, DocumentUploadState>(
            listener: (context, state) {
              if (state is DocumentUploadSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Successfully uploaded ${state.document.fileName}!',
                    ),
                    backgroundColor: AppColors.success,
                  ),
                );
                widget.onUploadComplete();
                Navigator.pop(context);
              } else if (state is DocumentUploadError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: AppColors.error,
                  ),
                );
              }
            },
            builder: (context, state) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Upload Document / Pitch Deck',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const Divider(),
                  const SizedBox(height: 12),

                  // Category Selector
                  Text(
                    'Document Category',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    items: _categories
                        .map(
                          (cat) =>
                              DropdownMenuItem(value: cat, child: Text(cat)),
                        )
                        .toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedCategory = val);
                    },
                  ),
                  const SizedBox(height: 16),

                  // File Name Input
                  Text(
                    'File Name',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _fileNameController,
                    decoration: const InputDecoration(
                      hintText: 'Enter file name (e.g. Series_A_Deck.pdf)',
                      prefixIcon: Icon(Icons.attach_file_rounded),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // File Format Selection
                  Text(
                    'File Format',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: _fileTypes.map((ft) {
                      final isSelected = _selectedFileType == ft;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ChoiceChip(
                          label: Text(ft),
                          selected: isSelected,
                          selectedColor: AppColors.primary,
                          labelStyle: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : (isDark
                                      ? Colors.white
                                      : AppColors.textPrimary),
                          ),
                          onSelected: (selected) {
                            if (selected)
                              setState(() => _selectedFileType = ft);
                          },
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),

                  // Upload Progress Indicator if uploading
                  if (state is DocumentUploading) ...[
                    LinearProgressIndicator(
                      value: state.progress,
                      color: AppColors.primary,
                    ),
                    const SizedBox(height: 12),
                    Center(
                      child: Text(
                        'Uploading document... ${(state.progress * 100).toInt()}%',
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Upload Button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: state is DocumentUploading
                          ? null
                          : _triggerUpload,
                      icon: const Icon(Icons.cloud_upload_rounded),
                      label: const Text('Upload File'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
