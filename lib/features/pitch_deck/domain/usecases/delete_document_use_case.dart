import '../repositories/document_repository.dart';

/// Use case for removing an uploaded pitch deck or document.
class DeleteDocumentUseCase {
  const DeleteDocumentUseCase(this._repository);

  final DocumentRepository _repository;

  Future<void> call({
    required String documentId,
    required String startupId,
  }) {
    return _repository.deleteDocument(
      documentId: documentId,
      startupId: startupId,
    );
  }
}
