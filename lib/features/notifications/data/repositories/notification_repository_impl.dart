import '../datasources/notification_remote_data_source.dart';
import '../../domain/entities/notification_entity.dart';
import '../../domain/repositories/notification_repository.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationRemoteDataSource remoteDataSource;

  NotificationRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<NotificationEntity>> getNotifications() {
    return remoteDataSource.getNotifications();
  }

  @override
  Future<void> markAsRead(String notificationId) {
    return remoteDataSource.markAsRead(notificationId);
  }

  @override
  Future<void> sendNotification({
    required String recipientUserId,
    required String title,
    required String body,
    required String type,
    Map<String, dynamic>? data,
  }) {
    return remoteDataSource.sendNotification(
      recipientUserId: recipientUserId,
      title: title,
      body: body,
      type: type,
      data: data,
    );
  }
}
