import '../entities/document_entity.dart';

/// Abstract domain repository interface for Pitch Deck & Business Document Management.
abstract interface class DocumentRepository {
  /// Uploads a new pitch deck or document for a specific startup.
  Future<DocumentEntity> uploadDocument({
    required String startupId,
    required String title,
    required String filePath,
    required String fileName,
    bool isPrivate = false,
  });

  /// Retrieves all pitch decks and documents belonging to a startup.
  Future<List<DocumentEntity>> getStartupDocuments({required String startupId});

  /// Deletes a document from storage and database.
  Future<void> deleteDocument({
    required String documentId,
    required String startupId,
  });

  /// Toggles document privacy visibility (Public vs Private to matched investors).
  Future<DocumentEntity> toggleVisibility({
    required String documentId,
    required bool isPrivate,
  });
}
