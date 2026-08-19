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
    return DocumentModel(
      id: (json['id'] ?? json['document_id'] ?? '').toString(),
      startupId: (json['startup_id'] ?? json['startupId'] ?? '').toString(),
      title: (json['title'] ?? 'Pitch Deck').toString(),
      fileUrl: (json['file_url'] ?? json['fileUrl'] ?? '').toString(),
      fileName: (json['file_name'] ?? json['fileName'] ?? 'pitch_deck.pdf').toString(),
      fileType: (json['file_type'] ?? json['fileType'] ?? 'pdf').toString(),
      fileSizeBytes: (json['file_size_bytes'] ?? json['fileSizeBytes'] ?? 2450000) as int,
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
