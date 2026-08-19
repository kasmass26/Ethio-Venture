import '../../domain/entities/document_entity.dart';

sealed class DocumentState {
  const DocumentState();
}

final class DocumentInitial extends DocumentState {
  const DocumentInitial();
}

final class DocumentLoading extends DocumentState {
  const DocumentLoading();
}

final class DocumentUploading extends DocumentState {
  const DocumentUploading();
}

final class DocumentsLoaded extends DocumentState {
  const DocumentsLoaded(this.documents);

  final List<DocumentEntity> documents;
}

final class DocumentSuccess extends DocumentState {
  const DocumentSuccess(this.message);

  final String message;
}

final class DocumentError extends DocumentState {
  const DocumentError(this.message);

  final String message;
}
