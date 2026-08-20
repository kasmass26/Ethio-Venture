import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ethioventure/core/config/app_config.dart';
import 'package:ethioventure/core/error/exceptions.dart';
import '../models/document_model.dart';

abstract interface class DocumentRemoteDataSource {
  Future<DocumentModel> uploadDocument({
    required String startupId,
    required String title,
    required String filePath,
    required String fileName,
    bool isPrivate = false,
  });

  Future<List<DocumentModel>> getStartupDocuments({required String startupId});

  Future<void> deleteDocument({
    required String documentId,
    required String startupId,
  });

  Future<DocumentModel> toggleVisibility({
    required String documentId,
    required bool isPrivate,
  });
}

class DocumentRemoteDataSourceImpl implements DocumentRemoteDataSource {
  const DocumentRemoteDataSourceImpl(this._client);

  final SupabaseClient _client;

  static const String _tableName = 'startup_documents';

  // Sample documents list for fallback - starts empty
  static final List<DocumentModel> _sampleDocuments = [];

  @override
  Future<DocumentModel> uploadDocument({
    required String startupId,
    required String title,
    required String filePath,
    required String fileName,
    bool isPrivate = false,
  }) async {
    final documentId = 'doc_${DateTime.now().millisecondsSinceEpoch}';

    final fileType = fileName.split('.').last.toLowerCase();
    final dummyUrl = 'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf';

    final model = DocumentModel(
      id: documentId,
      startupId: startupId,
      title: title,
      fileUrl: dummyUrl,
      fileName: fileName,
      fileType: fileType.isEmpty ? 'pdf' : fileType,
      fileSizeBytes: 2450000,
      isPrivate: isPrivate,
      uploadedAt: DateTime.now(),
    );

    try {
      await _client.from(_tableName).insert(model.toJson());
    } catch (_) {}

    _sampleDocuments.add(model);
    return model;
  }

  @override
  Future<List<DocumentModel>> getStartupDocuments({required String startupId}) async {
    try {
      final response = await _client
          .from(_tableName)
          .select()
          .eq('startup_id', startupId)
          .order('created_at', ascending: false);

      if (response.isNotEmpty) {
        return response
            .map((json) => DocumentModel.fromJson(json))
            .toList();
      }
    } catch (_) {}

    // Return only sample documents that match the current startup
    return _sampleDocuments.where((doc) => doc.startupId == startupId).toList();
  }

  @override
  Future<void> deleteDocument({
    required String documentId,
    required String startupId,
  }) async {
    try {
      await _client.from(_tableName).delete().eq('id', documentId);
    } catch (_) {}

    _sampleDocuments.removeWhere((doc) => doc.id == documentId);
  }

  @override
  Future<DocumentModel> toggleVisibility({
    required String documentId,
    required bool isPrivate,
  }) async {
    final index = _sampleDocuments.indexWhere((doc) => doc.id == documentId);
    if (index != -1) {
      final existing = _sampleDocuments[index];
      final updated = DocumentModel(
        id: existing.id,
        startupId: existing.startupId,
        title: existing.title,
        fileUrl: existing.fileUrl,
        fileName: existing.fileName,
        fileType: existing.fileType,
        fileSizeBytes: existing.fileSizeBytes,
        isPrivate: isPrivate,
        uploadedAt: existing.uploadedAt,
      );
      _sampleDocuments[index] = updated;

      try {
        await _client
            .from(_tableName)
            .update({'is_private': isPrivate})
            .eq('id', documentId);
      } catch (_) {}

      return updated;
    }

    throw const ServerException(message: 'Document not found');
  }
}
