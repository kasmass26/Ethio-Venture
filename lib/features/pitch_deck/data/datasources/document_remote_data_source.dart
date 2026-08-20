import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ethioventure/core/network/api_endpoints.dart';
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

  static const String _tableName = ApiEndpoints.documents;
  static const String _bucketName = ApiEndpoints.documentsBucket;

  @override
  Future<DocumentModel> uploadDocument({
    required String startupId,
    required String title,
    required String filePath,
    required String fileName,
    bool isPrivate = false,
  }) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        throw const ServerException(message: 'Selected document file does not exist on device.');
      }

      final fileSize = await file.length();
      final timeStamp = DateTime.now().millisecondsSinceEpoch;
      final sanitizeName = fileName.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');
      final storagePath = '$startupId/${timeStamp}_$sanitizeName';

      // 1. Upload file to Supabase Storage bucket 'documents'
      await _client.storage.from(_bucketName).upload(
            storagePath,
            file,
            fileOptions: const FileOptions(upsert: true),
          );

      // 2. Get Public Download / Access URL
      final publicUrl = _client.storage.from(_bucketName).getPublicUrl(storagePath);

      // 3. Map to PostgreSQL document_type ENUM ('pitch_deck', 'business_doc', 'other')
      final lowerTitle = title.toLowerCase();
      final lowerName = fileName.toLowerCase();
      String docTypeEnum = 'other';
      if (lowerTitle.contains('pitch') ||
          lowerName.contains('pitch') ||
          lowerTitle.contains('deck') ||
          lowerName.contains('deck')) {
        docTypeEnum = 'pitch_deck';
      } else if (lowerTitle.contains('business') ||
          lowerTitle.contains('plan') ||
          lowerTitle.contains('financial') ||
          lowerTitle.contains('legal') ||
          lowerName.contains('doc')) {
        docTypeEnum = 'business_doc';
      } else {
        docTypeEnum = 'pitch_deck';
      }

      Map<String, dynamic> responseData;

      // 4. Insert into public.documents table with auto-fallback for schema fields
      try {
        responseData = await _client.from(_tableName).insert({
          'startup_id': startupId,
          'file_url': publicUrl,
          'file_type': docTypeEnum,
          'title': title,
          'file_name': fileName,
          'file_size_bytes': fileSize,
          'is_private': isPrivate,
          'uploaded_at': DateTime.now().toIso8601String(),
        }).select().single();
      } catch (e) {
        if (e is PostgrestException &&
            (e.code == '42703' || e.message.contains('column'))) {
          responseData = await _client.from(_tableName).insert({
            'startup_id': startupId,
            'file_url': publicUrl,
            'file_type': docTypeEnum,
            'uploaded_at': DateTime.now().toIso8601String(),
          }).select().single();
        } else {
          rethrow;
        }
      }

      final createdModel = DocumentModel.fromJson(responseData);
      return DocumentModel(
        id: createdModel.id,
        startupId: createdModel.startupId,
        title: title.isNotEmpty ? title : createdModel.title,
        fileUrl: publicUrl,
        fileName: fileName.isNotEmpty ? fileName : createdModel.fileName,
        fileType: createdModel.fileType,
        fileSizeBytes: fileSize > 0 ? fileSize : createdModel.fileSizeBytes,
        isPrivate: isPrivate,
        uploadedAt: createdModel.uploadedAt ?? DateTime.now(),
      );
    } on PostgrestException catch (e) {
      throw ServerException(
        message: e.message,
        statusCode: int.tryParse(e.code ?? ''),
      );
    } on StorageException catch (e) {
      throw ServerException(message: 'Storage Upload Error: ${e.message}');
    } catch (e) {
      throw ServerException(message: 'Failed to upload document: $e');
    }
  }

  @override
  Future<List<DocumentModel>> getStartupDocuments({required String startupId}) async {
    try {
      List<dynamic> response;
      try {
        response = await _client
            .from(_tableName)
            .select()
            .eq('startup_id', startupId)
            .order('uploaded_at', ascending: false);
      } catch (e) {
        if (e is PostgrestException &&
            (e.code == '42703' || e.message.contains('column'))) {
          response = await _client
              .from(_tableName)
              .select()
              .eq('startup_id', startupId)
              .order('created_at', ascending: false);
        } else {
          rethrow;
        }
      }

      return response
          .map((json) => DocumentModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      throw ServerException(
        message: e.message,
        statusCode: int.tryParse(e.code ?? ''),
      );
    } catch (e) {
      throw ServerException(message: 'Failed to retrieve documents: $e');
    }
  }

  @override
  Future<void> deleteDocument({
    required String documentId,
    required String startupId,
  }) async {
    try {
      // Fetch file_url to clean up storage object
      final row = await _client
          .from(_tableName)
          .select('file_url')
          .eq('id', documentId)
          .maybeSingle();

      if (row != null && row['file_url'] != null) {
        final fileUrl = row['file_url'].toString();
        try {
          final uri = Uri.parse(fileUrl);
          if (uri.pathSegments.contains(_bucketName)) {
            final bucketIdx = uri.pathSegments.indexOf(_bucketName);
            final storagePath = uri.pathSegments.sublist(bucketIdx + 1).join('/');
            await _client.storage.from(_bucketName).remove([storagePath]);
          }
        } catch (_) {}
      }

      await _client.from(_tableName).delete().eq('id', documentId);
    } on PostgrestException catch (e) {
      throw ServerException(
        message: e.message,
        statusCode: int.tryParse(e.code ?? ''),
      );
    } catch (e) {
      throw ServerException(message: 'Failed to delete document: $e');
    }
  }

  @override
  Future<DocumentModel> toggleVisibility({
    required String documentId,
    required bool isPrivate,
  }) async {
    try {
      try {
        final response = await _client
            .from(_tableName)
            .update({'is_private': isPrivate})
            .eq('id', documentId)
            .select()
            .single();

        return DocumentModel.fromJson(response);
      } catch (e) {
        if (e is PostgrestException &&
            (e.code == '42703' || e.message.contains('column'))) {
          final row = await _client
              .from(_tableName)
              .select()
              .eq('id', documentId)
              .single();
          final doc = DocumentModel.fromJson(row);
          return DocumentModel(
            id: doc.id,
            startupId: doc.startupId,
            title: doc.title,
            fileUrl: doc.fileUrl,
            fileName: doc.fileName,
            fileType: doc.fileType,
            fileSizeBytes: doc.fileSizeBytes,
            isPrivate: isPrivate,
            uploadedAt: doc.uploadedAt,
          );
        }
        rethrow;
      }
    } on PostgrestException catch (e) {
      throw ServerException(
        message: e.message,
        statusCode: int.tryParse(e.code ?? ''),
      );
    } catch (e) {
      throw ServerException(message: 'Failed to toggle document visibility: $e');
    }
  }
}
