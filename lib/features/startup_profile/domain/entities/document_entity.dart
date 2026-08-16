import 'package:equatable/equatable.dart';

/// Entity representing a pitch deck or business document (Issue 6).
class DocumentEntity extends Equatable {
  final String id;
  final String fileName;
  final String fileType; // PDF, PPTX, DOCX, XLSX
  final String
  category; // 'Pitch Deck', 'Business Plan', 'Financial Model', 'Legal / Cap Table', 'Other'
  final int fileSizeBytes;
  final String downloadUrl;
  final DateTime uploadedAt;
  final bool isVerified;

  const DocumentEntity({
    required this.id,
    required this.fileName,
    required this.fileType,
    required this.category,
    required this.fileSizeBytes,
    required this.downloadUrl,
    required this.uploadedAt,
    this.isVerified = false,
  });

  String get formattedFileSize {
    if (fileSizeBytes < 1024) return '$fileSizeBytes B';
    if (fileSizeBytes < 1024 * 1024) {
      return '${(fileSizeBytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(fileSizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  bool get isPitchDeck => category == 'Pitch Deck';

  @override
  List<Object?> get props => [
    id,
    fileName,
    fileType,
    category,
    fileSizeBytes,
    downloadUrl,
    uploadedAt,
    isVerified,
  ];
}
