import '../entities/document_entity.dart';
import '../repositories/document_repository.dart';

/// Use case for retrieving all uploaded pitch decks for a startup.
class GetStartupDocumentsUseCase {
  const GetStartupDocumentsUseCase(this._repository);

  final DocumentRepository _repository;

  Future<List<DocumentEntity>> call({required String startupId}) {
    return _repository.getStartupDocuments(startupId: startupId);
  }
}
