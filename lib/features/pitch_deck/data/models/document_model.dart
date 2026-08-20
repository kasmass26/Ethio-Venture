import '../../domain/entities/document_entity.dart';

/// Data model representing an uploaded Pitch Deck or Document in the Data Layer.
class DocumentModel extends DocumentEntity {
  const DocumentModel({
    required super.id,
    required super.startupId,
    required super.title,
    required super.fileUrl,
    required super.fileName,
    required super.fileType,
    required super.fileSizeBytes,
    super.isPrivate = false,
    super.uploadedAt,
  });

  factory DocumentModel.fromJson(Map<String, dynamic> json) {
    final fileUrl = (json['file_url'] ?? json['fileUrl'] ?? '').toString();
    final rawFileName = json['file_name'] ?? json['fileName'];

    String fileName = rawFileName != null ? rawFileName.toString() : '';
    if (fileName.isEmpty && fileUrl.isNotEmpty) {
      try {
        final uri = Uri.parse(fileUrl);
        if (uri.pathSegments.isNotEmpty) {
          fileName = uri.pathSegments.last;
          if (fileName.contains('_')) {
            final parts = fileName.split('_');
            if (parts.length > 1 && int.tryParse(parts[0]) != null) {
              fileName = parts.sublist(1).join('_');
            }
          }
        }
      } catch (_) {}
    }
    if (fileName.isEmpty) fileName = 'Document.pdf';

    final rawTitle = json['title'];
    final rawFileType = (json['file_type'] ?? json['fileType'] ?? '').toString();
    
    String title = '';
    if (rawTitle != null && rawTitle.toString().trim().isNotEmpty) {
      title = rawTitle.toString().trim();
    } else if (rawFileType == 'pitch_deck') {
      title = 'Pitch Deck';
    } else if (rawFileType == 'business_doc') {
      title = 'Business Document';
    } else {
      final nameWithoutExt = fileName.contains('.')
          ? fileName.substring(0, fileName.lastIndexOf('.'))
          : fileName;
      title = nameWithoutExt.replaceAll('_', ' ').replaceAll('-', ' ');
    }

    final ext = fileName.contains('.') ? fileName.split('.').last : 'pdf';
    final fileType = rawFileType.isNotEmpty ? rawFileType : ext;

    return DocumentModel(
      id: (json['id'] ?? json['document_id'] ?? '').toString(),
      startupId: (json['startup_id'] ?? json['startupId'] ?? '').toString(),
      title: title.isEmpty ? 'Document' : title,
      fileUrl: fileUrl,
      fileName: fileName,
      fileType: fileType,
      fileSizeBytes: (json['file_size_bytes'] ?? json['fileSizeBytes'] ?? 0) as int,
      isPrivate: (json['is_private'] ?? json['isPrivate'] ?? false) as bool,
      uploadedAt: json['uploaded_at'] != null
          ? DateTime.tryParse(json['uploaded_at'].toString())
          : (json['created_at'] != null
              ? DateTime.tryParse(json['created_at'].toString())
              : DateTime.now()),
    );
  }

  factory DocumentModel.fromEntity(DocumentEntity entity) {
    return DocumentModel(
      id: entity.id,
      startupId: entity.startupId,
      title: entity.title,
      fileUrl: entity.fileUrl,
      fileName: entity.fileName,
      fileType: entity.fileType,
      fileSizeBytes: entity.fileSizeBytes,
      isPrivate: entity.isPrivate,
      uploadedAt: entity.uploadedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'startup_id': startupId,
      'title': title,
      'file_url': fileUrl,
      'file_name': fileName,
      'file_type': fileType,
      'file_size_bytes': fileSizeBytes,
      'is_private': isPrivate,
    };
  }
}
