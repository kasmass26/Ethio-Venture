import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/document_entity.dart';
import '../repositories/startup_profile_repository.dart';

class UploadDocumentParams extends Equatable {
  final String startupId;
  final String category;
  final String fileName;
  final String fileType;
  final int fileSizeBytes;

  const UploadDocumentParams({
    required this.startupId,
    required this.category,
    required this.fileName,
    required this.fileType,
    required this.fileSizeBytes,
  });

  @override
  List<Object?> get props => [
    startupId,
    category,
    fileName,
    fileType,
    fileSizeBytes,
  ];
}

class UploadDocumentUseCase
    implements UseCase<DocumentEntity, UploadDocumentParams> {
  final StartupProfileRepository repository;

  UploadDocumentUseCase(this.repository);

  @override
  Future<Either<Failure, DocumentEntity>> call(UploadDocumentParams params) {
    return repository.uploadDocument(
      startupId: params.startupId,
      category: params.category,
      fileName: params.fileName,
      fileType: params.fileType,
      fileSizeBytes: params.fileSizeBytes,
    );
  }
}
