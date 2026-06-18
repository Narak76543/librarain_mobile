import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../../../core/services/notification_service.dart';

class NotificationItem {
  final String title;
  final String body;
  bool isRead;

  NotificationItem({required this.title, required this.body, this.isRead = false});

  Map<String, dynamic> toJson() => {
    'title': title,
    'body': body,
    'isRead': isRead,
  };

  factory NotificationItem.fromJson(Map<String, dynamic> json) => NotificationItem(
    title: json['title'] ?? '',
    body: json['body'] ?? '',
    isRead: json['isRead'] ?? false,
  );
}

class NotificationViewModel extends ChangeNotifier {
  List<NotificationItem> _notifications = [];
  List<NotificationItem> get notifications => _notifications;

  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  StreamSubscription? _sub;

  NotificationViewModel() {
    _loadNotifications();
    _sub = NotificationService.onNotificationReceived.stream.listen((message) {
      if (message is RemoteMessage) {
        _addNotification(message.notification?.title ?? 'Notification', message.notification?.body ?? '');
      } else {
        _addNotification('New Notification', 'You have a new message');
      }
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  Future<void> _loadNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString('saved_notifications');
    if (data != null) {
      final List<dynamic> jsonList = jsonDecode(data);
      _notifications = jsonList.map((j) => NotificationItem.fromJson(j)).toList();
    }
    notifyListeners();
  }

  Future<void> _saveNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final String data = jsonEncode(_notifications.map((n) => n.toJson()).toList());
    await prefs.setString('saved_notifications', data);
    notifyListeners();
  }

  Future<void> _addNotification(String title, String body) async {
    _notifications.insert(0, NotificationItem(title: title, body: body));
    await _saveNotifications();
  }

  Future<void> markAsRead(int index) async {
    if (index >= 0 && index < _notifications.length && !_notifications[index].isRead) {
      _notifications[index].isRead = true;
      await _saveNotifications();
    }
  }

  Future<void> markAllAsRead() async {
    for (var n in _notifications) {
      n.isRead = true;
    }
    await _saveNotifications();
  }

  Future<void> clearUnreadCount() async {
    // This now just marks all as read
    await markAllAsRead();
  }
}
