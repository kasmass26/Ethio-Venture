import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../network/api_endpoints.dart';
import '../routing/app_router.dart';
import '../../core/constants/app_constants.dart';

/// Top-level background messaging handler for FCM.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  developer.log(
    'Handling background message: ${message.messageId}',
    name: 'firebaseMessagingBackgroundHandler',
  );
}

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    description: 'This channel is used for important message notifications.',
    importance: Importance.high,
  );

  bool _initialized = false;

  // Tracks the Supabase Realtime channel for in-app notifications so we can
  // cleanly remove it on logout.
  RealtimeChannel? _notificationChannel;

  // Stream controller that broadcasts the unread notification count so that
  // bottom-nav badges can stay up to date without polling.
  final StreamController<int> _unreadCountController =
      StreamController<int>.broadcast();

  /// A broadcast stream of unread notification counts.
  /// Bottom-nav widgets listen to this to update their badge.
  Stream<int> get unreadCountStream => _unreadCountController.stream;

  /// Current cached unread count (for immediate reads after login).
  int _cachedUnreadCount = 0;
  int get cachedUnreadCount => _cachedUnreadCount;

  /// Initializes FCM and flutter_local_notifications.
  Future<void> initialize({SupabaseClient? supabaseClient}) async {
    if (_initialized) return;

    try {
      // 1. Setup background message handler
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

      // 2. Request Notification Permissions
      final messaging = FirebaseMessaging.instance;
      final settings = await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      developer.log(
        'User granted notification permission: ${settings.authorizationStatus}',
        name: 'NotificationService.initialize',
      );

      // 3. Local Notifications Initialization
      const androidInitSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      const darwinInitSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const initSettings = InitializationSettings(
        android: androidInitSettings,
        iOS: darwinInitSettings,
      );

      await _localNotificationsPlugin.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationTap,
      );

      // 4. Create Android Notification Channel
      final androidPlatform = _localNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      if (androidPlatform != null) {
        await androidPlatform.createNotificationChannel(_channel);
        await androidPlatform.requestNotificationsPermission();
      }

      // 5. Setup FCM Foreground Message Handler
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        developer.log(
          'Foreground message received: ${message.notification?.title}',
          name: 'NotificationService.onMessage',
        );

        final notification = message.notification;
        if (notification != null) {
          showLocalNotification(
            id: notification.hashCode,
            title: notification.title ?? 'New Message',
            body: notification.body ?? '',
            payload: jsonEncode(message.data),
          );
        }
      });

      // 6. Setup FCM App Open Handler (Background tap)
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        developer.log(
          'Message opened from background state: ${message.data}',
          name: 'NotificationService.onMessageOpenedApp',
        );
        _handleNotificationPayload(jsonEncode(message.data));
      });

      // 7. Register FCM token and start realtime subscription if user is already signed in.
      if (supabaseClient != null &&
          supabaseClient.auth.currentUser != null) {
        await onUserLoggedIn(supabaseClient);
      }

      // Listen for token refresh
      messaging.onTokenRefresh.listen((token) {
        if (supabaseClient != null) {
          registerDeviceTokenInSupabase(supabaseClient, tokenOverride: token);
        }
      });

      _initialized = true;
    } catch (e, stackTrace) {
      developer.log(
        'Failed to initialize NotificationService: $e',
        name: 'NotificationService.initialize',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Call this immediately after a user successfully logs in or registers.
  ///
  /// Registers the FCM device token and starts a Supabase Realtime channel
  /// that triggers local notifications whenever a new notification row is
  /// inserted for the current user — even when the chat screen is closed.
  Future<void> onUserLoggedIn(SupabaseClient supabaseClient) async {
    await registerDeviceTokenInSupabase(supabaseClient);
    await _subscribeToInAppNotifications(supabaseClient);
  }

  /// Tears down the Realtime notification subscription.
  /// Call this on logout so the channel is cleaned up.
  Future<void> onUserLoggedOut(SupabaseClient supabaseClient) async {
    await _unsubscribeFromInAppNotifications(supabaseClient);
    _cachedUnreadCount = 0;
    if (!_unreadCountController.isClosed) {
      _unreadCountController.add(0);
    }
  }

  /// Subscribes to the `notifications` table for the current user via Supabase
  /// Realtime. When a new row arrives (i.e. the other party sent a message),
  /// a local notification is shown immediately — regardless of which screen
  /// the recipient is currently viewing.
  Future<void> _subscribeToInAppNotifications(
      SupabaseClient supabaseClient) async {
    final userId = supabaseClient.auth.currentUser?.id;
    if (userId == null) return;

    // Remove any stale subscription first.
    await _unsubscribeFromInAppNotifications(supabaseClient);

    developer.log(
      'Starting Realtime notification subscription for user $userId',
      name: 'NotificationService._subscribeToInAppNotifications',
    );

    // Fetch initial unread count.
    await _refreshUnreadCount(supabaseClient, userId);

    _notificationChannel = supabaseClient
        .channel('user_notifications_$userId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: ApiEndpoints.notifications,
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: userId,
          ),
          callback: (payload) async {
            developer.log(
              'Realtime: new notification received for user $userId',
              name: 'NotificationService._subscribeToInAppNotifications',
            );

            final newRow = payload.newRecord;
            final title = newRow['title']?.toString() ?? 'New Message';
            final body = newRow['body']?.toString() ?? '';
            final data = newRow['data'];
            final type = newRow['type']?.toString() ?? 'message';

            // Show a local notification immediately.
            showLocalNotification(
              id: (newRow['id']?.toString() ?? title).hashCode,
              title: title,
              body: body,
              payload: data != null ? jsonEncode(data) : null,
            );

            // Update unread badge count.
            _cachedUnreadCount++;
            if (!_unreadCountController.isClosed) {
              _unreadCountController.add(_cachedUnreadCount);
            }

            developer.log(
              'Local notification shown for type=$type, title=$title',
              name: 'NotificationService._subscribeToInAppNotifications',
            );
          },
        )
        .subscribe((status, [error]) {
      developer.log(
        'Notification channel status: $status${error != null ? ', error: $error' : ''}',
        name: 'NotificationService._subscribeToInAppNotifications',
      );
    });
  }

  Future<void> _unsubscribeFromInAppNotifications(
      SupabaseClient supabaseClient) async {
    if (_notificationChannel != null) {
      try {
        await supabaseClient.removeChannel(_notificationChannel!);
      } catch (_) {}
      _notificationChannel = null;
    }
  }

  /// Fetches the current unread notification count from Supabase and broadcasts it.
  Future<void> _refreshUnreadCount(
      SupabaseClient supabaseClient, String userId) async {
    try {
      final response = await supabaseClient
          .from(ApiEndpoints.notifications)
          .select('id')
          .eq('user_id', userId)
          .eq('is_read', false);

      final count = (response as List).length;
      _cachedUnreadCount = count;
      if (!_unreadCountController.isClosed) {
        _unreadCountController.add(count);
      }
    } catch (e) {
      developer.log(
        'Error fetching unread count: $e',
        name: 'NotificationService._refreshUnreadCount',
      );
    }
  }

  /// Refresh the unread count from the outside (e.g. after marking as read).
  Future<void> refreshUnreadCount(SupabaseClient supabaseClient) async {
    final userId = supabaseClient.auth.currentUser?.id;
    if (userId == null) return;
    await _refreshUnreadCount(supabaseClient, userId);
  }

  /// Displays a local notification using flutter_local_notifications.
  Future<void> showLocalNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'high_importance_channel',
      'High Importance Notifications',
      channelDescription:
          'This channel is used for important message notifications.',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotificationsPlugin.show(
      id,
      title,
      body,
      platformDetails,
      payload: payload,
    );
  }

  /// Registers/updates the current user's FCM device token in Supabase `device_tokens` table.
  Future<void> registerDeviceTokenInSupabase(
    SupabaseClient supabaseClient, {
    String? tokenOverride,
  }) async {
    try {
      final user = supabaseClient.auth.currentUser;
      if (user == null) return;

      final token = tokenOverride ?? await FirebaseMessaging.instance.getToken();
      if (token == null || token.isEmpty) return;

      developer.log(
        'Registering FCM device token for user ${user.id}',
        name: 'NotificationService.registerDeviceTokenInSupabase',
      );

      await supabaseClient.from(ApiEndpoints.deviceTokens).upsert(
        {
          'user_id': user.id,
          'token': token,
          'device_type': defaultTargetPlatform.name,
          'updated_at': DateTime.now().toIso8601String(),
        },
        onConflict: 'token',
      );
    } on PostgrestException catch (e) {
      if (e.code == 'PGRST205' || e.message.contains('device_tokens')) {
        developer.log(
          'Notice: Supabase table "device_tokens" does not exist yet. Please run the SQL schema migration in Supabase SQL Editor.',
          name: 'NotificationService.registerDeviceTokenInSupabase',
        );
      } else {
        developer.log(
          'PostgrestException registering FCM token: ${e.message} (code: ${e.code})',
          name: 'NotificationService.registerDeviceTokenInSupabase',
        );
      }
    } catch (e) {
      developer.log(
        'Error registering FCM token in Supabase: $e',
        name: 'NotificationService.registerDeviceTokenInSupabase',
      );
    }
  }


  void _onNotificationTap(NotificationResponse response) {
    if (response.payload != null && response.payload!.isNotEmpty) {
      _handleNotificationPayload(response.payload!);
    }
  }

  void _handleNotificationPayload(String rawPayload) {
    try {
      final Map<String, dynamic> data = jsonDecode(rawPayload);
      final conversationId = data['conversation_id']?.toString() ??
          data['conversationId']?.toString();

      if (conversationId != null && conversationId.isNotEmpty) {
        AppRouter.navigatorKey.currentState?.pushNamed(
          AppConstants.routeChat,
          arguments: conversationId,
        );
      }
    } catch (e) {
      developer.log(
        'Failed to parse notification payload: $e',
        name: 'NotificationService._handleNotificationPayload',
      );
    }
  }
}
