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
  });

  final String startupId;

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  void _showUploadDialog(BuildContext context) {
    final titleController = TextEditingController();
    final fileNameController = TextEditingController(text: 'PitchDeck_EthioPay_2026.pdf');
    bool isPrivate = false;

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Row(
                children: [
                  Icon(Icons.upload_file, color: AppColors.emerald),
                  SizedBox(width: AppSizes.xs),
                  Text('Upload Pitch Deck / Document'),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Document Title *',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: AppSizes.xs),
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      hintText: 'e.g. EthioPay Pitch Deck 2026',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: AppSizes.md),
                  Text(
                    'File Name',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: AppSizes.xs),
                  TextField(
                    controller: fileNameController,
                    decoration: const InputDecoration(
                      hintText: 'e.g. pitch_deck.pdf',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.picture_as_pdf, color: AppColors.coral),
                    ),
                  ),
                  const SizedBox(height: AppSizes.md),
                  SwitchListTile(
                    title: const Text('Private (Matched Investors Only)'),
                    subtitle: const Text('Restrict visibility to verified investors'),
                    value: isPrivate,
                    activeThumbColor: AppColors.emerald,
                    onChanged: (val) {
                      setState(() {
                        isPrivate = val;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    final title = titleController.text.trim();
                    if (title.isNotEmpty) {
                      Navigator.pop(dialogContext);
                      context.read<DocumentCubit>().uploadDocument(
                            startupId: startupId,
                            title: title,
                            filePath: fileNameController.text.trim(),
                            fileName: fileNameController.text.trim(),
                            isPrivate: isPrivate,
                          );
                    }
                  },
                  icon: const Icon(Icons.cloud_upload),
                  label: const Text('Upload Document'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.emerald,
                    foregroundColor: AppColors.white,
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
                    const Icon(Icons.folder_special_outlined,
                        size: 20, color: AppColors.emerald),
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
                IconButton(
                  icon: const Icon(Icons.add_circle_outline,
                      color: AppColors.emerald),
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
                      backgroundColor: AppColors.emerald,
                    ),
                  );
                }
              },
              builder: (context, state) {
                if (state is DocumentLoading || state is DocumentUploading) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(AppSizes.md),
                      child: CircularProgressIndicator(color: AppColors.emerald),
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
              color: AppColors.emeraldTint,
              borderRadius: BorderRadius.circular(AppSizes.radiusSm),
            ),
            child: Icon(
              doc.fileType.toLowerCase() == 'pdf'
                  ? Icons.picture_as_pdf
                  : Icons.description,
              color: AppColors.emerald,
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
                              : AppColors.emerald,
                        ),
                      ),
                      backgroundColor: doc.isPrivate
                          ? AppColors.violetTint
                          : AppColors.emeraldTint,
                      visualDensity: VisualDensity.compact,
                      side: BorderSide.none,
                    ),
                  ],
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: AppColors.slate),
            onSelected: (action) {
              if (action == 'view') {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Opening ${doc.fileName}...'),
                    backgroundColor: AppColors.emerald,
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
                    Icon(Icons.delete_outline, color: AppColors.coral, size: 18),
                    SizedBox(width: 8),
                    Text('Remove Document', style: TextStyle(color: AppColors.coral)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
