import '../entities/document_entity.dart';
import '../repositories/document_repository.dart';

/// Use case for toggling document visibility (Public vs Matched Investors Only).
class ToggleDocumentVisibilityUseCase {
  const ToggleDocumentVisibilityUseCase(this._repository);

  final DocumentRepository _repository;

  Future<DocumentEntity> call({
    required String documentId,
    required bool isPrivate,
  }) {
    return _repository.toggleVisibility(
      documentId: documentId,
      isPrivate: isPrivate,
    );
  }
}
