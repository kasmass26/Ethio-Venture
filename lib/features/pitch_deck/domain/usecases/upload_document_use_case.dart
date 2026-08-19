import '../entities/document_entity.dart';
import '../repositories/document_repository.dart';

/// Use case for uploading a pitch deck or business document.
class UploadDocumentUseCase {
  const UploadDocumentUseCase(this._repository);

  final DocumentRepository _repository;

  Future<DocumentEntity> call({
    required String startupId,
    required String title,
    required String filePath,
    required String fileName,
    bool isPrivate = false,
  }) {
    return _repository.uploadDocument(
      startupId: startupId,
      title: title,
      filePath: filePath,
      fileName: fileName,
      isPrivate: isPrivate,
    );
  }
}
