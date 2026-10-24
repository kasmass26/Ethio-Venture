import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/exceptions.dart';
import '../../domain/entities/verification_type.dart';
import '../../domain/usecases/get_current_user_verification_requests.dart';
import '../../domain/usecases/start_verification_request.dart';
import 'verification_state.dart';

class VerificationCubit extends Cubit<VerificationState> {
  VerificationCubit({
    required GetCurrentUserVerificationRequests getCurrentUserRequests,
    required StartVerificationRequest startVerificationRequest,
  }) : _getCurrentUserRequests = getCurrentUserRequests,
       _startVerificationRequest = startVerificationRequest,
       super(const VerificationInitial());

  final GetCurrentUserVerificationRequests _getCurrentUserRequests;
  final StartVerificationRequest _startVerificationRequest;
  bool _isSubmitting = false;

  Future<void> loadRequests() async {
    emit(const VerificationLoading());

    try {
      final requests = await _getCurrentUserRequests();
      if (requests.isEmpty) {
        emit(const VerificationEmpty());
      } else {
        emit(VerificationLoaded(List.unmodifiable(requests)));
      }
    } on AppException catch (error) {
      emit(VerificationError(error.message));
    } catch (error) {
      emit(VerificationError(error.toString()));
    }
  }

  Future<void> startRequest(VerificationType type) async {
    if (_isSubmitting) return;

    _isSubmitting = true;
    emit(const VerificationSubmitting());

    try {
      final request = await _startVerificationRequest(type);
      emit(VerificationSuccess(request));
    } on AppException catch (error) {
      emit(VerificationError(error.message));
    } catch (error) {
      emit(VerificationError(error.toString()));
    } finally {
      _isSubmitting = false;
    }
  }

  Future<void> startVerificationRequest(VerificationType type) =>
      startRequest(type);
}
