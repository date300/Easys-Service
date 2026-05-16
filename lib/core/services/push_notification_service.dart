import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint, defaultTargetPlatform;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../firebase_options.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await PushNotificationService.instance.showLocalNotification(message);
}

class NotificationEvent {
  final String? title;
  final String? body;
  final Map<String, dynamic> data;
  final bool isBackground;

  NotificationEvent({
    this.title,
    this.body,
    required this.data,
    this.isBackground = false,
  });
}

class PushNotificationService {
  static final PushNotificationService instance =
      PushNotificationService._internal();
  factory PushNotificationService() => instance;
  PushNotificationService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  final StreamController<NotificationEvent> _onMessageController =
      StreamController<NotificationEvent>.broadcast();
  final StreamController<NotificationEvent> _onTapController =
      StreamController<NotificationEvent>.broadcast();
  final StreamController<int> _unreadCountController =
      StreamController<int>.broadcast();

  bool _initialized = false;
  String? _fcmToken;

  Stream<NotificationEvent> get onMessage => _onMessageController.stream;
  Stream<NotificationEvent> get onTap => _onTapController.stream;
  Stream<int> get unreadCountStream => _unreadCountController.stream;

  Future<void> initialize() async {
    if (_initialized) return;

    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    await _requestPermissions();
    await _setupLocalNotifications();

    _fcmToken = await _messaging.getToken();
    debugPrint('FCM Token: $_fcmToken');
    if (_fcmToken != null) await _sendTokenToBackend(_fcmToken!);

    _messaging.onTokenRefresh.listen((token) async {
      _fcmToken = token;
      await _sendTokenToBackend(token);
    });

    FirebaseMessaging.onMessage.listen((message) {
      _onMessageController.add(NotificationEvent(
        title: message.notification?.title,
        body: message.notification?.body,
        data: message.data,
        isBackground: false,
      ));
      _incrementUnreadCount();
      showLocalNotification(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      _onTapController.add(NotificationEvent(
        title: message.notification?.title,
        body: message.notification?.body,
        data: message.data,
        isBackground: true,
      ));
      _clearUnreadCount();
    });

    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _onTapController.add(NotificationEvent(
        title: initialMessage.notification?.title,
        body: initialMessage.notification?.body,
        data: initialMessage.data,
        isBackground: true,
      ));
      _clearUnreadCount();
    }

    _initialized = true;
  }

  Future<void> _requestPermissions() async {
    if (kIsWeb) return;

    if (defaultTargetPlatform == TargetPlatform.iOS) {
      await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );
      await _messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      final androidPlugin = _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      await androidPlugin?.requestNotificationsPermission();
    }
  }

  Future<void> _setupLocalNotifications() async {
    if (kIsWeb) return;

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const initSettings =
        InitializationSettings(android: androidSettings, iOS: iosSettings);

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (response) {
        if (response.payload != null && response.payload!.isNotEmpty) {
          final data = jsonDecode(response.payload!);
          _onTapController.add(
              NotificationEvent(data: data, isBackground: true));
          _clearUnreadCount();
        }
      },
    );

    const channel = AndroidNotificationChannel(
      'easy_service_main',
      'Easy Service Main Channel',
      description: 'Primary notification channel for Easy Service',
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
      showBadge: true,
    );

    final androidPlugin = _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.createNotificationChannel(channel);
  }

  Future<void> showLocalNotification(RemoteMessage message) async {
    if (kIsWeb) return;

    final notification = message.notification;
    if (notification == null) return;

    const androidDetails = AndroidNotificationDetails(
      'easy_service_main',
      'Easy Service Main Channel',
      channelDescription: 'Primary notification channel for Easy Service',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
      showWhen: true,
      enableVibration: true,
      playSound: true,
      icon: '@mipmap/ic_launcher',
      largeIcon: DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
      styleInformation: BigTextStyleInformation(''),
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details =
        NotificationDetails(android: androidDetails, iOS: iosDetails);

    await _localNotifications.show(
      message.hashCode,
      notification.title,
      notification.body,
      details,
      payload: jsonEncode(message.data),
    );
  }

  void _incrementUnreadCount() => _unreadCountController.add(1);
  void _clearUnreadCount() => _unreadCountController.add(0);

  Future<void> _sendTokenToBackend(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jwt = prefs.getString('jwt_token');
      if (jwt == null || jwt.isEmpty) return;

      await http.post(
        Uri.parse('https://api.easysarvice.com/api/user/fcm-token'),
        headers: {
          'Authorization': 'Bearer $jwt',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'fcm_token': token,
          'device_type': kIsWeb ? 'web' : 'mobile',
        }),
      );
      debugPrint('FCM token synced to backend');
    } catch (e) {
      debugPrint('FCM token sync failed: $e');
    }
  }

  Future<void> subscribeToTopic(String topic) async {
    await _messaging.subscribeToTopic(topic);
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    await _messaging.unsubscribeFromTopic(topic);
  }

  Future<void> deleteToken() async {
    await _messaging.deleteToken();
  }

  void dispose() {
    _onMessageController.close();
    _onTapController.close();
    _unreadCountController.close();
  }
}
