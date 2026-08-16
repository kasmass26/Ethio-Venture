import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/upload_document_usecase.dart';
import 'document_upload_state.dart';

class DocumentUploadCubit extends Cubit<DocumentUploadState> {
  final UploadDocumentUseCase uploadDocumentUseCase;

  DocumentUploadCubit({required this.uploadDocumentUseCase})
    : super(const DocumentUploadInitial());

  Future<void> uploadDocument({
    required String startupId,
    required String category,
    required String fileName,
    required String fileType,
    required int fileSizeBytes,
  }) async {
    // Validate file size limit (e.g. max 25MB)
    if (fileSizeBytes > 25 * 1024 * 1024) {
      emit(
        const DocumentUploadError(
          'File size exceeds maximum allowed limit of 25MB.',
        ),
      );
      return;
    }

    emit(const DocumentUploading(0.2));
    await Future.delayed(const Duration(milliseconds: 200));
    emit(const DocumentUploading(0.6));

    final result = await uploadDocumentUseCase(
      UploadDocumentParams(
        startupId: startupId,
        category: category,
        fileName: fileName,
        fileType: fileType,
        fileSizeBytes: fileSizeBytes,
      ),
    );

    result.fold(
      (failure) => emit(DocumentUploadError(failure.message)),
      (document) => emit(DocumentUploadSuccess(document)),
    );
  }

  void reset() {
    emit(const DocumentUploadInitial());
  }
}
