import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../network/dio_client.dart';

// ── Background handler — must be top level function ───────
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint('Background message: ${message.notification?.title}');
  final prefs = await SharedPreferences.getInstance();
  final String? data = prefs.getString('saved_notifications');
  List<dynamic> jsonList = data != null ? jsonDecode(data) : [];
  jsonList.insert(0, {
    'title': message.notification?.title ?? 'Notification',
    'body': message.notification?.body ?? '',
    'isRead': false,
  });
  await prefs.setString('saved_notifications', jsonEncode(jsonList));
}

class NotificationService {
  static final _messaging = FirebaseMessaging.instance;
  static final _localNotifications = FlutterLocalNotificationsPlugin();
  
  // Stream to notify UI of new foreground messages
  static final onNotificationReceived = StreamController<dynamic>.broadcast();

  // Channel for Android
  static const _channel = AndroidNotificationChannel(
    'bookstore_channel',
    'BookStore Notifications',
    description: 'Order updates and alerts',
    importance: Importance.high,
  );

  static Future<void> initialize() async {
    // ── 1. Request permission ──────────────────────────────
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
    debugPrint('Permission: ${settings.authorizationStatus}');

    // ── 2. Setup local notifications ──────────────────────
    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(_channel);

    await _localNotifications.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      ),
      onDidReceiveNotificationResponse: (details) {
        _handlePayload(details.payload);
      },
    );

    // ── 3. Get + save FCM token ───────────────────────────
    final token = await _messaging.getToken();
    debugPrint('FCM Token: $token');
    if (token != null) await _saveToken(token);

    // Refresh token listener
    _messaging.onTokenRefresh.listen(_saveToken);

    // ── 4. Foreground messages ────────────────────────────
    FirebaseMessaging.onMessage.listen((message) {
      debugPrint('Foreground: ${message.notification?.title}');
      _showLocalNotification(message);
      onNotificationReceived.add(message);
    });

    // ── 5. Background tap ─────────────────────────────────
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      debugPrint('Tapped from background: ${message.data}');
      _handleData(message.data);
    });

    // ── 6. Terminated tap ─────────────────────────────────
    final initial = await _messaging.getInitialMessage();
    if (initial != null) {
      debugPrint('Tapped from terminated: ${initial.data}');
      _handleData(initial.data);
    }
  }

  // ── Save token to backend ──────────────────────────────
  static Future<void> _saveToken(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final oldToken = prefs.getString('fcm_token');
      if (oldToken == token) return; // already saved

      await DioClient.instance.dio.post(
        '/api/v1/users/me/fcm-token',
        data: {'fcm_token': token},
      );
      await prefs.setString('fcm_token', token);
      debugPrint('FCM token saved to backend ✅');
    } catch (e) {
      debugPrint('Failed to save FCM token: $e');
    }
  }

  // ============ show notification in foreground ───────────────────
  static void _showLocalNotification(RemoteMessage message) {
    final notification = message.notification;
    if (notification == null) return;

    _localNotifications.show(
      id: notification.hashCode,
      title: notification.title,
      body: notification.body,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          channelDescription: _channel.description,
          importance:         Importance.high,
          priority:           Priority.high,
          icon:               '@mipmap/ic_launcher',
        ),
      ),
      payload: message.data.toString(),
    );
  }

  // ── Handle notification tap ────────────────────────────
  static void _handleData(Map<String, dynamic> data) {
    final type = data['type'] as String?;
    final orderId = data['order_id'] as String?;

    switch (type) {
      case 'order_confirmed':
      case 'order_status':
        if (orderId != null) {
          // Navigate to order summary
          // Use your router here
          debugPrint('→ Navigate to order: $orderId');
        }
        break;

      case 'password_reset':
        // Navigate to login
        debugPrint('→ Navigate to login');
        break;
    }
  }

  static void _handlePayload(String? payload) {
    if (payload == null) return;
    debugPrint('Local notification tapped: $payload');
  }

  // ── Call this after logout to clear token ─────────────
  static Future<void> clearToken() async {
    try {
      await DioClient.instance.dio.delete('/api/v1/users/me/fcm-token');
      await _messaging.deleteToken();
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('fcm_token');
    } catch (e) {
      debugPrint('Failed to clear FCM token: $e');
    }
  }
}
