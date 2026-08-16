import 'package:equatable/equatable.dart';
import '../../domain/entities/document_entity.dart';

abstract class DocumentUploadState extends Equatable {
  const DocumentUploadState();

  @override
  List<Object?> get props => [];
}

class DocumentUploadInitial extends DocumentUploadState {
  const DocumentUploadInitial();
}

class DocumentUploading extends DocumentUploadState {
  final double progress; // 0.0 to 1.0

  const DocumentUploading(this.progress);

  @override
  List<Object?> get props => [progress];
}

class DocumentUploadSuccess extends DocumentUploadState {
  final DocumentEntity document;

  const DocumentUploadSuccess(this.document);

  @override
  List<Object?> get props => [document];
}

class DocumentUploadError extends DocumentUploadState {
  final String message;

  const DocumentUploadError(this.message);

  @override
  List<Object?> get props => [message];
}
