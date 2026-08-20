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

      // 7. Register FCM token if user is signed in
      if (supabaseClient != null) {
        await registerDeviceTokenInSupabase(supabaseClient);
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
