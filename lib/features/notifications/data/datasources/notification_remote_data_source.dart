import 'dart:async';
import 'dart:developer' as developer;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/network/api_endpoints.dart';
import '../models/notification_model.dart';

class NotificationRemoteDataSource {
  final SupabaseClient _client;

  NotificationRemoteDataSource({required SupabaseClient supabaseClient})
      : _client = supabaseClient;

  /// Fetches notifications for the current authenticated user.
  Future<List<NotificationModel>> getNotifications() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return [];

    try {
      final response = await _client
          .from(ApiEndpoints.notifications)
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((item) => NotificationModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      developer.log(
        'Error fetching notifications: $e',
        name: 'NotificationRemoteDataSource.getNotifications',
      );
      return [];
    }
  }

  /// Marks a specific notification as read.
  Future<void> markAsRead(String notificationId) async {
    try {
      await _client
          .from(ApiEndpoints.notifications)
          .update({'is_read': true})
          .eq('id', notificationId);
    } catch (e) {
      developer.log(
        'Error marking notification as read: $e',
        name: 'NotificationRemoteDataSource.markAsRead',
      );
    }
  }

  /// Creates a notification entry in Supabase database for a given user.
  Future<void> sendNotification({
    required String recipientUserId,
    required String title,
    required String body,
    required String type,
    Map<String, dynamic>? data,
  }) async {
    try {
      await _client.from(ApiEndpoints.notifications).insert({
        'user_id': recipientUserId,
        'title': title,
        'body': body,
        'type': type,
        'is_read': false,
        'data': data,
      });

      // Optionally call Edge Function if configured
      try {
        await _client.functions.invoke(
          ApiEndpoints.sendNotificationFunction,
          body: {
            'user_id': recipientUserId,
            'title': title,
            'body': body,
            'data': data,
          },
        );
      } catch (_) {
        // Edge function may not be deployed locally/remotely, fallback silently
      }
    } catch (e) {
      developer.log(
        'Error sending notification in Supabase: $e',
        name: 'NotificationRemoteDataSource.sendNotification',
      );
    }
  }
}
