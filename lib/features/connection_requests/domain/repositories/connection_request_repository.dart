import '../entities/connection_request_entity.dart';

/// Abstract contract for all connection request data operations.
abstract class ConnectionRequestRepository {
  /// Sends a new connection request from the currently authenticated founder
  /// to the specified investor.
  Future<ConnectionRequestEntity> sendRequest({
    required String investorUserId,
    required String investorProfileId,
    String? message,
  });

  /// Returns all incoming requests for the currently authenticated investor.
  Future<List<ConnectionRequestEntity>> getRequestsForInvestor();

  /// Returns all outgoing requests for the currently authenticated founder.
  Future<List<ConnectionRequestEntity>> getRequestsForFounder();

  /// Accepts or declines a request by [requestId].
  Future<ConnectionRequestEntity> respondToRequest({
    required String requestId,
    required ConnectionRequestStatus status,
  });

  /// Returns the current status of a request between the authenticated user
  /// and [otherUserId], or `null` if no request exists.
  Future<ConnectionRequestEntity?> getRequestBetween({
    required String otherUserId,
  });

  /// Real-time stream of incoming requests for the authenticated investor.
  Stream<List<ConnectionRequestEntity>> subscribeToInvestorRequests();
}
