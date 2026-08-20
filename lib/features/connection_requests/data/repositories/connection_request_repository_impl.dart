import '../../domain/entities/connection_request_entity.dart';
import '../../domain/repositories/connection_request_repository.dart';
import '../datasources/connection_request_remote_data_source.dart';

class ConnectionRequestRepositoryImpl implements ConnectionRequestRepository {
  ConnectionRequestRepositoryImpl({required this.remoteDataSource});

  final ConnectionRequestRemoteDataSource remoteDataSource;

  @override
  Future<ConnectionRequestEntity> sendRequest({
    required String investorUserId,
    required String investorProfileId,
    String? message,
  }) async {
    final model = await remoteDataSource.sendRequest(
      investorUserId: investorUserId,
      investorProfileId: investorProfileId,
      message: message,
    );

    // Notify the investor
    await remoteDataSource.sendInAppNotification(
      recipientUserId: investorUserId,
      title: '📬 New Connection Request',
      body: 'A founder wants to connect with you.',
      type: 'connection_request',
      data: {'request_id': model.id},
    );

    return model;
  }

  @override
  Future<List<ConnectionRequestEntity>> getRequestsForInvestor() =>
      remoteDataSource.getRequestsForInvestor();

  @override
  Future<List<ConnectionRequestEntity>> getRequestsForFounder() =>
      remoteDataSource.getRequestsForFounder();

  @override
  Future<ConnectionRequestEntity> respondToRequest({
    required String requestId,
    required ConnectionRequestStatus status,
  }) async {
    final model = await remoteDataSource.respondToRequest(
      requestId: requestId,
      status: status,
    );

    // Notify the founder
    final isAccepted = status == ConnectionRequestStatus.accepted;
    await remoteDataSource.sendInAppNotification(
      recipientUserId: model.founderUserId,
      title: isAccepted ? '🎉 Connection Accepted!' : '❌ Connection Declined',
      body: isAccepted
          ? 'Your connection request was accepted. You can now send a message!'
          : 'Your connection request was declined by the investor.',
      type: isAccepted ? 'connection_accepted' : 'connection_declined',
      data: {'request_id': requestId},
    );

    return model;
  }

  @override
  Future<ConnectionRequestEntity?> getRequestBetween({
    required String otherUserId,
  }) =>
      remoteDataSource.getRequestBetween(otherUserId: otherUserId);

  @override
  Stream<List<ConnectionRequestEntity>> subscribeToInvestorRequests() =>
      remoteDataSource.subscribeToInvestorRequests();
}
