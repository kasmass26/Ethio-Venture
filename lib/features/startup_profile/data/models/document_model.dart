import '../../domain/entities/document_entity.dart';

class DocumentModel extends DocumentEntity {
  const DocumentModel({
    required super.id,
    required super.fileName,
    required super.fileType,
    required super.category,
    required super.fileSizeBytes,
    required super.downloadUrl,
    required super.uploadedAt,
    super.isVerified,
  });

  factory DocumentModel.fromJson(Map<String, dynamic> json) {
    return DocumentModel(
      id: json['id'] as String,
      fileName: json['fileName'] as String,
      fileType: json['fileType'] as String? ?? 'PDF',
      category: json['category'] as String? ?? 'Pitch Deck',
      fileSizeBytes: json['fileSizeBytes'] as int? ?? 1024000,
      downloadUrl: json['downloadUrl'] as String? ?? '',
      uploadedAt: json['uploadedAt'] != null
          ? DateTime.parse(json['uploadedAt'] as String)
          : DateTime.now(),
      isVerified: json['isVerified'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fileName': fileName,
      'fileType': fileType,
      'category': category,
      'fileSizeBytes': fileSizeBytes,
      'downloadUrl': downloadUrl,
      'uploadedAt': uploadedAt.toIso8601String(),
      'isVerified': isVerified,
    };
  }

  factory DocumentModel.fromEntity(DocumentEntity entity) {
    return DocumentModel(
      id: entity.id,
      fileName: entity.fileName,
      fileType: entity.fileType,
      category: entity.category,
      fileSizeBytes: entity.fileSizeBytes,
      downloadUrl: entity.downloadUrl,
      uploadedAt: entity.uploadedAt,
      isVerified: entity.isVerified,
    );
  }
}
