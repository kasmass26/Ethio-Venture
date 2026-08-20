import '../../../connection_requests/domain/entities/connection_request_entity.dart';

/// States for the ConnectionRequestCubit.
sealed class ConnectionRequestState {
  const ConnectionRequestState();
}

class ConnectionRequestInitial extends ConnectionRequestState {
  const ConnectionRequestInitial();
}

class ConnectionRequestLoading extends ConnectionRequestState {
  const ConnectionRequestLoading();
}

/// Loaded state — holds a list of requests (investor or founder view).
class ConnectionRequestLoaded extends ConnectionRequestState {
  const ConnectionRequestLoaded(this.requests);
  final List<ConnectionRequestEntity> requests;
}

/// A single request status check result (used on the founder investors page).
class ConnectionRequestStatusChecked extends ConnectionRequestState {
  const ConnectionRequestStatusChecked({
    required this.otherUserId,
    this.request,
  });
  final String otherUserId;
  final ConnectionRequestEntity? request; // null = no request yet
}

class ConnectionRequestSending extends ConnectionRequestState {
  const ConnectionRequestSending();
}

class ConnectionRequestSent extends ConnectionRequestState {
  const ConnectionRequestSent(this.request);
  final ConnectionRequestEntity request;
}

class ConnectionRequestResponding extends ConnectionRequestState {
  const ConnectionRequestResponding();
}

class ConnectionRequestResponded extends ConnectionRequestState {
  const ConnectionRequestResponded(this.request);
  final ConnectionRequestEntity request;
}

class ConnectionRequestError extends ConnectionRequestState {
  const ConnectionRequestError(this.message);
  final String message;
}
