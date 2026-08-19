import '../../domain/entities/document_entity.dart';
import '../../domain/repositories/document_repository.dart';
import '../datasources/document_remote_data_source.dart';

class DocumentRepositoryImpl implements DocumentRepository {
  const DocumentRepositoryImpl(this._remoteDataSource);

  final DocumentRemoteDataSource _remoteDataSource;

  @override
  Future<DocumentEntity> uploadDocument({
    required String startupId,
    required String title,
    required String filePath,
    required String fileName,
    bool isPrivate = false,
  }) {
    return _remoteDataSource.uploadDocument(
      startupId: startupId,
      title: title,
      filePath: filePath,
      fileName: fileName,
      isPrivate: isPrivate,
    );
  }

  @override
  Future<List<DocumentEntity>> getStartupDocuments({required String startupId}) {
    return _remoteDataSource.getStartupDocuments(startupId: startupId);
  }

  @override
  Future<void> deleteDocument({
    required String documentId,
    required String startupId,
  }) {
    return _remoteDataSource.deleteDocument(
      documentId: documentId,
      startupId: startupId,
    );
  }

  @override
  Future<DocumentEntity> toggleVisibility({
    required String documentId,
    required bool isPrivate,
  }) {
    return _remoteDataSource.toggleVisibility(
      documentId: documentId,
      isPrivate: isPrivate,
    );
  }
}
