import 'package:ethioventure/core/error/exceptions.dart';
import 'package:ethioventure/features/investor_profile/domain/entities/investor_profile_entity.dart';
import 'package:ethioventure/features/investor_profile/domain/usecases/create_investor_profile.dart';
import 'package:ethioventure/features/investor_profile/domain/usecases/delete_investor_profile.dart';
import 'package:ethioventure/features/investor_profile/domain/usecases/get_investor_profile.dart';
import 'package:ethioventure/features/investor_profile/domain/usecases/update_investor_profile.dart';
import 'package:ethioventure/features/investor_profile/presentation/cubit/investor_profile_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class InvestorProfileCubit extends Cubit<InvestorProfileState> {
  InvestorProfileCubit({
    required GetInvestorProfile getInvestorProfile,
    required CreateInvestorProfile createInvestorProfile,
    required UpdateInvestorProfile updateInvestorProfile,
    required DeleteInvestorProfile deleteInvestorProfile,
  })  : _getInvestorProfile = getInvestorProfile,
        _createInvestorProfile = createInvestorProfile,
        _updateInvestorProfile = updateInvestorProfile,
        _deleteInvestorProfile = deleteInvestorProfile,
        super(const InvestorProfileInitial());

  final GetInvestorProfile _getInvestorProfile;
  final CreateInvestorProfile _createInvestorProfile;
  final UpdateInvestorProfile _updateInvestorProfile;
  final DeleteInvestorProfile _deleteInvestorProfile;

  /// Loads the investor profile for the currently authenticated user.
  Future<void> loadProfile() async {
    emit(const InvestorProfileLoading());
    try {
      final profile = await _getInvestorProfile();
      if (profile == null) {
        emit(const InvestorProfileEmpty());
      } else {
        emit(InvestorProfileLoaded(profile));
      }
    } on AppException catch (e) {
      emit(InvestorProfileError(e.message));
    } catch (e) {
      emit(InvestorProfileError(e.toString()));
    }
  }

  /// Alias for [loadProfile].
  Future<void> loadInvestorProfile() => loadProfile();

  /// Creates a new investor profile.
  Future<void> createProfile(InvestorProfileEntity profile) async {
    emit(const InvestorProfileSaving());
    try {
      final newProfile = await _createInvestorProfile(profile);
      emit(InvestorProfileLoaded(newProfile));
    } on AppException catch (e) {
      emit(InvestorProfileError(e.message));
    } catch (e) {
      emit(InvestorProfileError(e.toString()));
    }
  }

  /// Alias for [createProfile].
  Future<void> createInvestorProfile(InvestorProfileEntity profile) =>
      createProfile(profile);

  /// Updates an existing investor profile.
  Future<void> updateProfile(InvestorProfileEntity profile) async {
    emit(const InvestorProfileSaving());
    try {
      final updatedProfile = await _updateInvestorProfile(profile);
      emit(InvestorProfileLoaded(updatedProfile));
    } on AppException catch (e) {
      emit(InvestorProfileError(e.message));
    } catch (e) {
      emit(InvestorProfileError(e.toString()));
    }
  }

  /// Alias for [updateProfile].
  Future<void> updateInvestorProfile(InvestorProfileEntity profile) =>
      updateProfile(profile);

  /// Deletes the investor profile for the currently authenticated user.
  Future<void> deleteProfile() async {
    emit(const InvestorProfileSaving());
    try {
      await _deleteInvestorProfile();
      emit(const InvestorProfileDeleted());
    } on AppException catch (e) {
      emit(InvestorProfileError(e.message));
    } catch (e) {
      emit(InvestorProfileError(e.toString()));
    }
  }

  /// Alias for [deleteProfile].
  Future<void> deleteInvestorProfile() => deleteProfile();
}
