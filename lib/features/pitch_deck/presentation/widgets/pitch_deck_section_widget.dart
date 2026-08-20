import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ethioventure/core/theme/app_colors.dart';
import 'package:ethioventure/core/theme/app_sizes.dart';
import '../cubit/document_cubit.dart';
import '../cubit/document_state.dart';
import '../../domain/entities/document_entity.dart';

class PitchDeckSectionWidget extends StatelessWidget {
  const PitchDeckSectionWidget({
    super.key,
    required this.startupId,
    this.isFounder = true,
  });

  final String startupId;
  final bool isFounder;

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  void _showUploadDialog(BuildContext parentContext) {
    final documentCubit = parentContext.read<DocumentCubit>();
    final titleController = TextEditingController();
    String? selectedFilePath;
    String? selectedFileName;
    int? selectedFileSize;
    String? validationError;
    bool isPrivate = false;

    showDialog<void>(
      context: parentContext,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            Future<void> pickRealFile() async {
              try {
                final result = await FilePicker.platform.pickFiles(
                  type: FileType.custom,
                  allowedExtensions: ['pdf', 'doc', 'docx', 'ppt', 'pptx'],
                );

                if (result != null && result.files.isNotEmpty) {
                  final file = result.files.first;
                  setState(() {
                    selectedFilePath = file.path;
                    selectedFileName = file.name;
                    selectedFileSize = file.size;
                    validationError = null;

                    if (titleController.text.trim().isEmpty) {
                      final nameWithoutExt = file.name.contains('.')
                          ? file.name.substring(0, file.name.lastIndexOf('.'))
                          : file.name;
                      titleController.text = nameWithoutExt
                          .replaceAll('_', ' ')
                          .replaceAll('-', ' ');
                    }
                  });
                }
              } catch (_) {}
            }

            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: const Row(
                children: [
                  Icon(Icons.cloud_upload_outlined, color: AppColors.primary, size: 26),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Upload Pitch Deck / Document',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Visual File Drop / Browse Container
                    InkWell(
                      onTap: pickRealFile,
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          vertical: 20,
                          horizontal: 16,
                        ),
                        decoration: BoxDecoration(
                          color: selectedFilePath != null
                              ? AppColors.primarySoft.withValues(alpha: 0.4)
                              : AppColors.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: selectedFilePath != null
                                ? AppColors.primary
                                : AppColors.border,
                            width: selectedFilePath != null ? 1.8 : 1.2,
                          ),
                        ),
                        child: selectedFilePath == null
                            ? Column(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: const BoxDecoration(
                                      color: AppColors.primarySoft,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.file_upload_outlined,
                                      color: AppColors.primaryDark,
                                      size: 30,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  const Text(
                                    'Choose File from Device',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    'Supports PDF, DOCX, PPTX (Max 25MB)',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              )
                            : Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: AppColors.primarySoft,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(
                                      (selectedFileName ?? '').endsWith('.pdf')
                                          ? Icons.picture_as_pdf
                                          : Icons.description,
                                      color: AppColors.primaryDark,
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          selectedFileName ?? 'Selected File',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 13,
                                            color: AppColors.textPrimary,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        if (selectedFileSize != null)
                                          Text(
                                            _formatFileSize(selectedFileSize!),
                                            style: const TextStyle(
                                              fontSize: 11,
                                              color: AppColors.textSecondary,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  TextButton(
                                    onPressed: pickRealFile,
                                    child: const Text('Change'),
                                  ),
                                ],
                              ),
                      ),
                    ),
                    if (validationError != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        validationError!,
                        style: const TextStyle(
                          color: AppColors.coral,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    const Text(
                      'Document Title *',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: titleController,
                      decoration: InputDecoration(
                        hintText: 'e.g. Investor Pitch Deck 2026',
                        hintStyle: const TextStyle(fontSize: 13),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text(
                        'Private Document',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      subtitle: const Text(
                        'Only verified matched investors can view',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      value: isPrivate,
                      activeThumbColor: AppColors.primary,
                      onChanged: (val) {
                        setState(() {
                          isPrivate = val;
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    final title = titleController.text.trim();
                    if (selectedFilePath == null) {
                      setState(() {
                        validationError =
                            'Please select a document file from your device first.';
                      });
                      return;
                    }
                    if (title.isEmpty) {
                      setState(() {
                        validationError =
                            'Please enter a title for your document.';
                      });
                      return;
                    }

                    Navigator.pop(dialogContext);
                    documentCubit.uploadDocument(
                      startupId: startupId,
                      title: title,
                      filePath: selectedFilePath!,
                      fileName: selectedFileName ?? 'Document.pdf',
                      isPrivate: isPrivate,
                    );
                  },
                  icon: const Icon(Icons.cloud_upload_outlined, size: 18),
                  label: const Text('Upload Document'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
      ),
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.folder_special_outlined,
                      size: 20,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: AppSizes.sm),
                    Text(
                      'Pitch Decks & Documents',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.ink,
                      ),
                    ),
                  ],
                ),
                if (isFounder)
                  IconButton(
                    icon: const Icon(
                      Icons.add_circle_outline,
                      color: AppColors.primary,
                    ),
                    tooltip: 'Upload New Document',
                    onPressed: () => _showUploadDialog(context),
                  ),
              ],
            ),
            const Divider(height: AppSizes.lg),
            BlocConsumer<DocumentCubit, DocumentState>(
              listener: (context, state) {
                if (state is DocumentSuccess) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: AppColors.primary,
                    ),
                  );
                }
              },
              builder: (context, state) {
                if (state is DocumentLoading || state is DocumentUploading) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(AppSizes.md),
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    ),
                  );
                }

                if (state is DocumentsLoaded) {
                  if (state.documents.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: AppSizes.sm),
                      child: Text(
                        'No pitch decks uploaded yet. Click + to upload your business documents.',
                        style: TextStyle(color: AppColors.slate),
                      ),
                    );
                  }

                  return Column(
                    children: state.documents.map((doc) {
                      return _buildDocumentTile(context, doc);
                    }).toList(),
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentTile(BuildContext context, DocumentEntity doc) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.sm),
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(color: AppColors.fog),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSizes.sm),
            decoration: BoxDecoration(
              color: AppColors.primaryTint,
              borderRadius: BorderRadius.circular(AppSizes.radiusSm),
            ),
            child: Icon(
              doc.fileType.toLowerCase() == 'pdf'
                  ? Icons.picture_as_pdf
                  : Icons.description,
              color: AppColors.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: AppSizes.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  doc.title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: AppSizes.xs),
                Wrap(
                  spacing: AppSizes.xs,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      doc.fileName,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.slate,
                      ),
                    ),
                    const Text('•', style: TextStyle(color: AppColors.slate)),
                    Text(
                      _formatFileSize(doc.fileSizeBytes),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.slate,
                      ),
                    ),
                    const SizedBox(width: AppSizes.xs),
                    Chip(
                      label: Text(
                        doc.isPrivate ? 'Private' : 'Public',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: doc.isPrivate
                              ? AppColors.violet
                              : AppColors.primary,
                        ),
                      ),
                      backgroundColor: doc.isPrivate
                          ? AppColors.violetTint
                          : AppColors.primaryTint,
                      visualDensity: VisualDensity.compact,
                      side: BorderSide.none,
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (isFounder)
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: AppColors.slate),
              onSelected: (action) {
                if (action == 'view') {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Opening ${doc.fileName}...'),
                      backgroundColor: AppColors.primary,
                    ),
                  );
                } else if (action == 'toggle') {
                  context.read<DocumentCubit>().toggleVisibility(
                    documentId: doc.id,
                    startupId: startupId,
                    isPrivate: !doc.isPrivate,
                  );
                } else if (action == 'delete') {
                  context.read<DocumentCubit>().deleteDocument(
                    documentId: doc.id,
                    startupId: startupId,
                  );
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'view',
                  child: Row(
                    children: [
                      Icon(Icons.remove_red_eye_outlined, size: 18),
                      SizedBox(width: 8),
                      Text('View / Download'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'toggle',
                  child: Row(
                    children: [
                      Icon(
                        doc.isPrivate ? Icons.lock_open : Icons.lock_outline,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(doc.isPrivate ? 'Make Public' : 'Make Private'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(
                        Icons.delete_outline,
                        color: AppColors.coral,
                        size: 18,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Remove Document',
                        style: TextStyle(color: AppColors.coral),
                      ),
                    ],
                  ),
                ),
              ],
            )
          else
            IconButton(
              icon: const Icon(Icons.remove_red_eye_outlined, color: AppColors.primary),
              tooltip: 'View / Download Document',
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Opening ${doc.fileName}...'),
                    backgroundColor: AppColors.primary,
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
