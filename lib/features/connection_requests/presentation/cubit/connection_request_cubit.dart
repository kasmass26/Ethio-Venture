import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/connection_request_entity.dart';
import '../../domain/repositories/connection_request_repository.dart';
import 'connection_request_state.dart';

class ConnectionRequestCubit extends Cubit<ConnectionRequestState> {
  ConnectionRequestCubit({required ConnectionRequestRepository repository})
      : _repository = repository,
        super(const ConnectionRequestInitial());

  final ConnectionRequestRepository _repository;
  StreamSubscription<List<ConnectionRequestEntity>>? _realtimeSubscription;

  // ── Investor: Load and subscribe to incoming requests ─────────────────────

  void loadInvestorRequests() {
    emit(const ConnectionRequestLoading());
    _realtimeSubscription?.cancel();
    _realtimeSubscription = _repository.subscribeToInvestorRequests().listen(
      (requests) {
        emit(ConnectionRequestLoaded(requests));
      },
      onError: (e) {
        developer.log(
          'Error loading investor requests: $e',
          name: 'ConnectionRequestCubit.loadInvestorRequests',
        );
        emit(ConnectionRequestError(e.toString()));
      },
    );
  }

  // ── Founder: Load outgoing requests ───────────────────────────────────────

  Future<void> loadFounderRequests() async {
    emit(const ConnectionRequestLoading());
    try {
      final requests = await _repository.getRequestsForFounder();
      emit(ConnectionRequestLoaded(requests));
    } catch (e) {
      developer.log(
        'Error loading founder requests: $e',
        name: 'ConnectionRequestCubit.loadFounderRequests',
      );
      emit(ConnectionRequestError(e.toString()));
    }
  }

  // ── Check status between current user and another user ────────────────────

  Future<void> checkRequestStatus({required String otherUserId}) async {
    try {
      final request =
          await _repository.getRequestBetween(otherUserId: otherUserId);
      emit(ConnectionRequestStatusChecked(
        otherUserId: otherUserId,
        request: request,
      ));
    } catch (e) {
      developer.log(
        'Error checking request status: $e',
        name: 'ConnectionRequestCubit.checkRequestStatus',
      );
      emit(ConnectionRequestStatusChecked(
        otherUserId: otherUserId,
        request: null,
      ));
    }
  }

  // ── Send a connection request ──────────────────────────────────────────────

  Future<void> sendRequest({
    required String investorUserId,
    required String investorProfileId,
    String? message,
  }) async {
    emit(const ConnectionRequestSending());
    try {
      final request = await _repository.sendRequest(
        investorUserId: investorUserId,
        investorProfileId: investorProfileId,
        message: message,
      );
      emit(ConnectionRequestSent(request));
    } catch (e) {
      developer.log(
        'Error sending connection request: $e',
        name: 'ConnectionRequestCubit.sendRequest',
      );
      emit(ConnectionRequestError(
          e.toString().replaceAll('Exception: ', '')));
    }
  }

  // ── Respond (accept / decline) ────────────────────────────────────────────

  Future<void> respondToRequest({
    required String requestId,
    required ConnectionRequestStatus status,
  }) async {
    emit(const ConnectionRequestResponding());
    try {
      final request = await _repository.respondToRequest(
        requestId: requestId,
        status: status,
      );
      emit(ConnectionRequestResponded(request));
      // Reload list so the UI reflects the new status immediately
      loadInvestorRequests();
    } catch (e) {
      developer.log(
        'Error responding to request: $e',
        name: 'ConnectionRequestCubit.respondToRequest',
      );
      emit(ConnectionRequestError(
          e.toString().replaceAll('Exception: ', '')));
    }
  }

  @override
  Future<void> close() {
    _realtimeSubscription?.cancel();
    return super.close();
  }
}
