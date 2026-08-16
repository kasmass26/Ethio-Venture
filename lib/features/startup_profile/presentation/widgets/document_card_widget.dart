import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/document_entity.dart';

class DocumentCardWidget extends StatelessWidget {
  final DocumentEntity document;
  final VoidCallback? onViewTap;
  final VoidCallback? onDeleteTap;

  const DocumentCardWidget({
    super.key,
    required this.document,
    this.onViewTap,
    this.onDeleteTap,
  });

  IconData _getFileIcon() {
    switch (document.fileType.toUpperCase()) {
      case 'PDF':
        return Icons.picture_as_pdf_rounded;
      case 'PPTX':
      case 'PPT':
        return Icons.slideshow_rounded;
      case 'XLSX':
      case 'XLS':
      case 'CSV':
        return Icons.table_chart_rounded;
      default:
        return Icons.description_rounded;
    }
  }

  Color _getCategoryColor() {
    switch (document.category) {
      case 'Pitch Deck':
        return AppColors.primary;
      case 'Business Plan':
        return AppColors.secondary;
      case 'Financial Model':
        return AppColors.success;
      default:
        return AppColors.primaryLight;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final catColor = _getCategoryColor();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isDark ? Colors.white10 : AppColors.border),
      ),
      child: Row(
        children: [
          // Icon Box
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: catColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(_getFileIcon(), color: catColor, size: 28),
          ),
          const SizedBox(width: 14),

          // File Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: catColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        document.category,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: catColor,
                        ),
                      ),
                    ),
                    if (document.isVerified) ...[
                      const SizedBox(width: 6),
                      const Icon(
                        Icons.verified_rounded,
                        size: 14,
                        color: AppColors.success,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  document.fileName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${document.formattedFileSize} • Uploaded ${document.uploadedAt.day}/${document.uploadedAt.month}/${document.uploadedAt.year}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          // Actions (View & Delete)
          IconButton(
            icon: const Icon(Icons.download_rounded, color: AppColors.primary),
            tooltip: 'Download / View',
            onPressed: onViewTap,
          ),
          IconButton(
            icon: const Icon(
              Icons.delete_outline_rounded,
              color: AppColors.error,
            ),
            tooltip: 'Delete Document',
            onPressed: onDeleteTap,
          ),
        ],
      ),
    );
  }
}
