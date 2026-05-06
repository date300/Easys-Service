import 'dart:convert';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

// ============================================================
// NOTIFICATION SERVICE
// অ্যাপ খোলা বা বন্ধ — দুই অবস্থায়ই heads-up notification দেখাবে
// ============================================================

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const String _channelId = 'ltc_channel';
  static const String _channelName = 'Easy Service Notifications';
  static const String _baseUrl = 'https://easy.ltcminematrix.com/api';

  // ✅ একবার init করলেই হবে — main() থেকে call করো
  static Future<void> init() async {
    // Android 13+ এ notification permission নাও
    await Permission.notification.request();

    // Plugin initialize
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);
    await _plugin.initialize(initSettings);

    // ✅ HIGH importance channel তৈরি করো
    // এই channel ছাড়া heads-up notification আসবে না
    const channel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: 'Balance update ও অন্যান্য গুরুত্বপূর্ণ notifications',
      importance: Importance.high, // এটাই স্ক্রিনের উপরে দেখায়
    );

    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  // ✅ যেকোনো জায়গা থেকে call করে notification দেখাও
  static Future<void> show({
    required String title,
    required String body,
    int? id,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      importance: Importance.high, // ✅ heads-up এর জন্য আবশ্যক
      priority: Priority.high,     // ✅ heads-up এর জন্য আবশ্যক
      playSound: true,
      enableVibration: true,
    );

    await _plugin.show(
      id ?? DateTime.now().millisecondsSinceEpoch % 100000,
      title,
      body,
      const NotificationDetails(android: androidDetails),
    );
  }

  // ✅ Background polling — নতুন notification আছে কিনা check করো
  // Workmanager এই function কে call করবে
  static Future<void> checkAndNotify() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token');

      // Login না করলে check করার দরকার নেই
      if (token == null || token.isEmpty) return;

      final lastSeenId = prefs.getInt('last_notif_id') ?? 0;

      final response = await http
          .get(
            Uri.parse('$_baseUrl/user/notifications?limit=5&offset=0'),
            headers: {'Authorization': 'Bearer $token'},
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) return;

      final body = jsonDecode(response.body);
      final List data = body['data'] ?? [];

      if (data.isEmpty) return;

      // সবচেয়ে নতুন notification এর id
      final latestId = data.first['id'] as int;

      if (latestId <= lastSeenId) return; // নতুন কিছু নেই

      // নতুন notifications গুলো দেখাও
      for (final item in data) {
        final id = item['id'] as int;
        if (id <= lastSeenId) break;

        final source = (item['source'] ?? 'system').toString().toLowerCase();
        final title = _getTitleFromSource(source);
        final message = item['message_en']?.toString() ?? 'নতুন আপডেট';

        await show(title: title, body: message, id: id);
      }

      // সর্বশেষ দেখা id সেভ করো
      await prefs.setInt('last_notif_id', latestId);
    } catch (_) {
      // Background এ error হলে চুপ থাকো
    }
  }

  // Source থেকে বাংলা/ইংরেজি title বের করো
  static String _getTitleFromSource(String source) {
    if (source.contains('referral')) return '💰 Referral Commission';
    if (source.contains('matrix')) return '🎯 Matrix Bonus';
    if (source.contains('royalty')) return '👑 Royalty Income';
    return '📢 Easy Service';
  }
}
