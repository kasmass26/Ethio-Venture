import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/delete_document_use_case.dart';
import '../../domain/usecases/get_startup_documents_use_case.dart';
import '../../domain/usecases/toggle_document_visibility_use_case.dart';
import '../../domain/usecases/upload_document_use_case.dart';
import 'document_state.dart';

class DocumentCubit extends Cubit<DocumentState> {
  DocumentCubit({
    required UploadDocumentUseCase uploadDocumentUseCase,
    required GetStartupDocumentsUseCase getStartupDocumentsUseCase,
    required DeleteDocumentUseCase deleteDocumentUseCase,
    required ToggleDocumentVisibilityUseCase toggleDocumentVisibilityUseCase,
  })  : _uploadDocumentUseCase = uploadDocumentUseCase,
        _getStartupDocumentsUseCase = getStartupDocumentsUseCase,
        _deleteDocumentUseCase = deleteDocumentUseCase,
        _toggleDocumentVisibilityUseCase = toggleDocumentVisibilityUseCase,
        super(const DocumentInitial());

  final UploadDocumentUseCase _uploadDocumentUseCase;
  final GetStartupDocumentsUseCase _getStartupDocumentsUseCase;
  final DeleteDocumentUseCase _deleteDocumentUseCase;
  final ToggleDocumentVisibilityUseCase _toggleDocumentVisibilityUseCase;

  Future<void> loadDocuments({required String startupId}) async {
    emit(const DocumentLoading());
    try {
      final documents = await _getStartupDocumentsUseCase(startupId: startupId);
      emit(DocumentsLoaded(documents));
    } catch (e) {
      emit(DocumentError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> uploadDocument({
    required String startupId,
    required String title,
    required String filePath,
    required String fileName,
    bool isPrivate = false,
  }) async {
    emit(const DocumentUploading());
    try {
      await _uploadDocumentUseCase(
        startupId: startupId,
        title: title,
        filePath: filePath,
        fileName: fileName,
        isPrivate: isPrivate,
      );
      emit(const DocumentSuccess('Document uploaded successfully!'));
      await loadDocuments(startupId: startupId);
    } catch (e) {
      emit(DocumentError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> deleteDocument({
    required String documentId,
    required String startupId,
  }) async {
    try {
      await _deleteDocumentUseCase(
        documentId: documentId,
        startupId: startupId,
      );
      emit(const DocumentSuccess('Document removed successfully.'));
      await loadDocuments(startupId: startupId);
    } catch (e) {
      emit(DocumentError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> toggleVisibility({
    required String documentId,
    required String startupId,
    required bool isPrivate,
  }) async {
    try {
      await _toggleDocumentVisibilityUseCase(
        documentId: documentId,
        isPrivate: isPrivate,
      );
      await loadDocuments(startupId: startupId);
    } catch (e) {
      emit(DocumentError(e.toString().replaceAll('Exception: ', '')));
    }
  }
}
