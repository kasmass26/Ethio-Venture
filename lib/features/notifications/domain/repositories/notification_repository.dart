import '../entities/notification_entity.dart';

abstract class NotificationRepository {
  Future<List<NotificationEntity>> getNotifications();
  Future<void> markAsRead(String notificationId);
  Future<void> sendNotification({
    required String recipientUserId,
    required String title,
    required String body,
    required String type,
    Map<String, dynamic>? data,
  });
}
