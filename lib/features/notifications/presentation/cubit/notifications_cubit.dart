import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/notification_repository.dart';
import 'notifications_state.dart';

class NotificationsCubit extends Cubit<NotificationsState> {
  final NotificationRepository repository;

  NotificationsCubit({required this.repository}) : super(NotificationsInitial());

  Future<void> loadNotifications() async {
    emit(NotificationsLoading());
    try {
      final list = await repository.getNotifications();
      final unreadCount = list.where((n) => !n.isRead).length;
      emit(NotificationsLoaded(notifications: list, unreadCount: unreadCount));
    } catch (e) {
      emit(NotificationsError('Failed to load notifications: $e'));
    }
  }

  Future<void> markAsRead(String id) async {
    try {
      await repository.markAsRead(id);
      await loadNotifications();
    } catch (e) {
      // keep current state
    }
  }
}
