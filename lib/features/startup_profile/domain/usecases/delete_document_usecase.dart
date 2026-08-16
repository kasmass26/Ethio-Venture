import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/startup_profile_repository.dart';

class DeleteDocumentParams extends Equatable {
  final String startupId;
  final String documentId;

  const DeleteDocumentParams({
    required this.startupId,
    required this.documentId,
  });

  @override
  List<Object?> get props => [startupId, documentId];
}

class DeleteDocumentUseCase implements UseCase<void, DeleteDocumentParams> {
  final StartupProfileRepository repository;

  DeleteDocumentUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(DeleteDocumentParams params) {
    return repository.deleteDocument(
      startupId: params.startupId,
      documentId: params.documentId,
    );
  }
}
