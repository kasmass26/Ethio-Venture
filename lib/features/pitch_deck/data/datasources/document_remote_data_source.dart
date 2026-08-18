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

  static final List<DocumentModel> _sampleDocuments = [
    DocumentModel(
      id: 'doc-101',
      startupId: '4cfeca7d-e2fb-4a85-8985-7b0cc8a0f99d',
      title: 'EthioPay Official Investor Pitch Deck 2026',
      fileUrl: 'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf',
      fileName: 'EthioPay_PitchDeck_2026.pdf',
      fileType: 'pdf',
      fileSizeBytes: 2450000,
      isPrivate: false,
      uploadedAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    DocumentModel(
      id: 'doc-102',
      startupId: '4cfeca7d-e2fb-4a85-8985-7b0cc8a0f99d',
      title: 'EthioPay Executive Business Plan & Financial Model',
      fileUrl: 'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf',
      fileName: 'EthioPay_BusinessPlan.pdf',
      fileType: 'pdf',
      fileSizeBytes: 3820000,
      isPrivate: true,
      uploadedAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];

  SupabaseClient _getAnonClient() {
    try {
      final config = AppConfig.fromEnvironment();
      return SupabaseClient(
        config.supabaseUrl,
        config.supabasePublishableKey,
      );
    } catch (_) {
      return _client;
    }
  }

  @override
  Future<DocumentModel> uploadDocument({
    required String startupId,
    required String title,
    required String filePath,
    required String fileName,
    bool isPrivate = false,
  }) async {
    final client = _getAnonClient();
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
      await client.from(_tableName).insert(model.toJson());
    } catch (_) {}

    _sampleDocuments.add(model);
    return model;
  }

  @override
  Future<List<DocumentModel>> getStartupDocuments({required String startupId}) async {
    final client = _getAnonClient();

    try {
      final response = await client
          .from(_tableName)
          .select()
          .order('created_at', ascending: false);

      if (response.isNotEmpty) {
        return response
            .map((json) => DocumentModel.fromJson(json))
            .toList();
      }
    } catch (_) {}

    return List.from(_sampleDocuments);
  }

  @override
  Future<void> deleteDocument({
    required String documentId,
    required String startupId,
  }) async {
    final client = _getAnonClient();

    try {
      await client.from(_tableName).delete().eq('id', documentId);
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
        final client = _getAnonClient();
        await client
            .from(_tableName)
            .update({'is_private': isPrivate})
            .eq('id', documentId);
      } catch (_) {}

      return updated;
    }

    throw const ServerException(message: 'Document not found');
  }
}
