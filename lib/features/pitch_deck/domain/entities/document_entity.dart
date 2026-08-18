/// Pure domain entity representing an uploaded Pitch Deck or Business Document.
class DocumentEntity {
  const DocumentEntity({
    required this.id,
    required this.startupId,
    required this.title,
    required this.fileUrl,
    required this.fileName,
    required this.fileType,
    required this.fileSizeBytes,
    this.isPrivate = false,
    this.uploadedAt,
  });

  final String id;
  final String startupId;
  final String title;
  final String fileUrl;
  final String fileName;
  final String fileType;
  final int fileSizeBytes;
  final bool isPrivate;
  final DateTime? uploadedAt;
}
