import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

// ─────────────────────────────────────────────
//  AuthService — JWT decode + verification check
//  Usage: await AuthService.isVerified()
// ─────────────────────────────────────────────
class AuthService {
  static const String _tokenKey = 'jwt_token';

  /// SharedPreferences থেকে JWT token নিয়ে আসে
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  /// JWT token এর payload decode করে Map হিসেবে return করে
  /// Token না থাকলে null return করে
  static Future<Map<String, dynamic>?> decodeToken() async {
    final token = await getToken();
    if (token == null || token.isEmpty) return null;

    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;

      // Base64 padding ঠিক করা
      String payload = parts[1];
      switch (payload.length % 4) {
        case 2:
          payload += '==';
          break;
        case 3:
          payload += '=';
          break;
      }

      final decoded = utf8.decode(base64Url.decode(payload));
      return jsonDecode(decoded) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  /// Account verified কিনা check করে
  /// JWT payload এ is_verified: true/false থাকলে সেটা দেখে
  static Future<bool> isVerified() async {
    final payload = await decodeToken();
    if (payload == null) return false;

    // Backend এ field name যদি আলাদা হয় তাহলে এখানে পরিবর্তন করো
    return payload['is_verified'] == true ||
        payload['isVerified'] == true ||
        payload['verified'] == true;
  }

  /// Token expired কিনা check করে
  static Future<bool> isTokenExpired() async {
    final payload = await decodeToken();
    if (payload == null) return true;

    final exp = payload['exp'];
    if (exp == null) return false;

    final expDate =
        DateTime.fromMillisecondsSinceEpoch((exp as int) * 1000);
    return DateTime.now().isAfter(expDate);
  }

  /// User logged in এবং token valid কিনা
  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    if (token == null || token.isEmpty) return false;
    return !(await isTokenExpired());
  }

  /// JWT থেকে যেকোনো field এর value নিয়ে আসো
  /// Example: AuthService.getField('full_name')
  static Future<dynamic> getField(String key) async {
    final payload = await decodeToken();
    return payload?[key];
  }
}
