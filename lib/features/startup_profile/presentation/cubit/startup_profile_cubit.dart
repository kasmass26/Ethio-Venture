import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/startup_profile_entity.dart';
import '../../domain/usecases/create_startup_profile_usecase.dart';
import '../../domain/usecases/delete_document_usecase.dart';
import '../../domain/usecases/get_startup_profile_usecase.dart';
import '../../domain/usecases/update_startup_profile_usecase.dart';
import 'startup_profile_state.dart';

class StartupProfileCubit extends Cubit<StartupProfileState> {
  final CreateStartupProfileUseCase createStartupProfileUseCase;
  final GetStartupProfileUseCase getStartupProfileUseCase;
  final UpdateStartupProfileUseCase updateStartupProfileUseCase;
  final DeleteDocumentUseCase deleteDocumentUseCase;

  StartupProfileCubit({
    required this.createStartupProfileUseCase,
    required this.getStartupProfileUseCase,
    required this.updateStartupProfileUseCase,
    required this.deleteDocumentUseCase,
  }) : super(const StartupProfileInitial());

  Future<void> fetchProfile([String id = 'st_01']) async {
    emit(const StartupProfileLoading());

    final result = await getStartupProfileUseCase(id);

    result.fold(
      (failure) => emit(StartupProfileError(failure.message)),
      (profile) => emit(StartupProfileLoaded(profile)),
    );
  }

  Future<void> createProfile(StartupProfileEntity profile) async {
    emit(const StartupProfileCreating());

    final result = await createStartupProfileUseCase(profile);

    result.fold(
      (failure) => emit(StartupProfileError(failure.message)),
      (createdProfile) => emit(StartupProfileLoaded(createdProfile)),
    );
  }

  Future<void> updateProfile(StartupProfileEntity updatedProfile) async {
    if (state is StartupProfileLoaded) {
      final current = (state as StartupProfileLoaded).profile;
      emit(StartupProfileUpdating(current));
    }

    final result = await updateStartupProfileUseCase(updatedProfile);

    result.fold(
      (failure) => emit(StartupProfileError(failure.message)),
      (profile) => emit(StartupProfileLoaded(profile)),
    );
  }

  Future<void> deleteDocument(String startupId, String documentId) async {
    if (state is StartupProfileLoaded) {
      final currentProfile = (state as StartupProfileLoaded).profile;

      final result = await deleteDocumentUseCase(
        DeleteDocumentParams(startupId: startupId, documentId: documentId),
      );

      result.fold((failure) => emit(StartupProfileError(failure.message)), (_) {
        final updatedDocs = currentProfile.documents
            .where((doc) => doc.id != documentId)
            .toList();
        emit(
          StartupProfileLoaded(currentProfile.copyWith(documents: updatedDocs)),
        );
      });
    }
  }
}
