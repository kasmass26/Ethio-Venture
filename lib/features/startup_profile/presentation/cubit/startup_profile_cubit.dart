import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/startup_profile_entity.dart';
import '../../domain/usecases/create_startup_profile.dart';
import '../../domain/usecases/get_startup_profile.dart';
import '../../domain/usecases/update_startup_profile.dart';
import 'startup_profile_state.dart';

/// Cubit managing UI states and business actions for Startup Profile Management.
class StartupProfileCubit extends Cubit<StartupProfileState> {
  StartupProfileCubit({
    required CreateStartupProfileUseCase createStartupProfileUseCase,
    required GetStartupProfileUseCase getStartupProfileUseCase,
    required UpdateStartupProfileUseCase updateStartupProfileUseCase,
  })  : _createStartupProfile = createStartupProfileUseCase,
        _getStartupProfile = getStartupProfileUseCase,
        _updateStartupProfile = updateStartupProfileUseCase,
        super(const StartupProfileInitial());

  final CreateStartupProfileUseCase _createStartupProfile;
  final GetStartupProfileUseCase _getStartupProfile;
  final UpdateStartupProfileUseCase _updateStartupProfile;

  /// Loads the startup profile for the given [userId].
  Future<void> loadProfile(String userId) async {
    emit(const StartupProfileLoading());
    try {
      final profile = await _getStartupProfile(userId);
      if (profile == null) {
        emit(const StartupProfileEmpty());
      } else {
        emit(StartupProfileLoaded(profile));
      }
    } catch (e) {
      emit(StartupProfileError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  /// Creates a new startup profile.
  Future<void> createProfile(StartupProfileEntity profile) async {
    emit(const StartupProfileSubmitting());
    try {
      final createdProfile = await _createStartupProfile(profile);
      emit(StartupProfileSuccess(
        createdProfile,
        'Startup profile created successfully!',
      ));
    } catch (e) {
      emit(StartupProfileError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  /// Updates an existing startup profile.
  Future<void> updateProfile(StartupProfileEntity profile) async {
    emit(const StartupProfileSubmitting());
    try {
      final updatedProfile = await _updateStartupProfile(profile);
      emit(StartupProfileSuccess(
        updatedProfile,
        'Startup profile updated successfully!',
      ));
    } catch (e) {
      emit(StartupProfileError(e.toString().replaceAll('Exception: ', '')));
    }
  }
}
