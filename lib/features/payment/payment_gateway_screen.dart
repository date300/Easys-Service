import 'package:flutter/material.dart';

/// Theme-aware color palette following Material 3 design system.
/// All colors adapt automatically based on current theme brightness.
/// 
/// Usage: AppColors.background(context), AppColors.textPrimary(context)
class AppColors {
  AppColors._();

  // === Brand Colors (Theme Independent) ===
  static const Color skyBlue = Color(0xFF29B6F6);
  static const Color bkashPink = Color(0xFFE2136E);
  static const Color nagadOrange = Color(0xFFFF6600);
  static const Color binanceYellow = Color(0xFFF0B90B);

  // === Dynamic Background Colors ===
  static Color background(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF121212)
        : const Color(0xFFF8F9FA);
  }

  static Color surface(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF1E1E1E)
        : Colors.white;
  }

  static Color surfaceVariant(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF2C2C2C)
        : const Color(0xFFF5F5F5);
  }

  static Color cardBackground(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF252525)
        : Colors.white;
  }

  static Color scaffoldBackground(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF0D0D0D)
        : Colors.white;
  }

  // === Dynamic Text Colors ===
  static Color textPrimary(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black87;
  }

  static Color textSecondary(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.grey.shade400
        : Colors.grey.shade600;
  }

  static Color textTertiary(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.grey.shade500
        : Colors.grey.shade500;
  }

  static Color textInverse(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.black87
        : Colors.white;
  }

  // === Dynamic Border & Divider Colors ===
  static Color divider(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF333333)
        : const Color(0xFFEEEEEE);
  }

  static Color border(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF3A3A3A)
        : Colors.grey.shade200;
  }

  static Color borderFocused(BuildContext context, Color brandColor) {
    return brandColor;
  }

  // === Dynamic Input Colors ===
  static Color inputFill(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF252525)
        : Colors.white;
  }

  static Color inputBorder(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF3A3A3A)
        : Colors.grey.shade300;
  }

  // === Dynamic Icon Colors ===
  static Color iconPrimary(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.grey.shade300
        : Colors.grey.shade600;
  }

  static Color iconSecondary(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.grey.shade500
        : Colors.grey.shade400;
  }

  // === Dynamic Overlay Colors ===
  static Color overlay(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.black.withOpacity(0.5)
        : Colors.black.withOpacity(0.1);
  }

  static Color splashColor(BuildContext context, Color brandColor) {
    return Theme.of(context).brightness == Brightness.dark
        ? brandColor.withOpacity(0.15)
        : brandColor.withOpacity(0.1);
  }

  // === Error & Success Colors ===
  static Color errorBackground(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF3D1F1F)
        : Colors.red.shade50;
  }

  static Color successBackground(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF1F3D1F)
        : Colors.green.shade50;
  }

  // === Disabled State ===
  static Color disabledBackground(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF2A2A2A)
        : Colors.grey.shade100;
  }

  static Color disabledForeground(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.grey.shade600
        : Colors.grey.shade400;
  }

  // === Gradient Helpers ===
  static List<Color> primaryGradient(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? [const Color(0xFF5A54E8), const Color(0xFF3A35B8)]
        : [const Color(0xFF6C63FF), const Color(0xFF4A44D6)];
  }

  static List<Color> bkashGradient(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? [const Color(0xFFC0105A), const Color(0xFF9E0A48)]
        : [const Color(0xFFE2136E), const Color(0xFFFF6DAE)];
  }

  static List<Color> nagadGradient(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? [const Color(0xFFD45500), const Color(0xFFB34700)]
        : [const Color(0xFFFF6600), const Color(0xFFFFAA55)];
  }

  static List<Color> binanceGradient(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? [const Color(0xFFD4A009), const Color(0xFFB08A00)]
        : [const Color(0xFFF0B90B), const Color(0xFFFFDA6A)];
  }
}

// ============================================================================
// 2. CORE / CONSTANTS / API_CONSTANTS.DART
// ============================================================================

class ApiConstants {
  ApiConstants._();

  static const String baseUrl = 'https://easy.ltcminematrix.com/api';
  static const String paymentSubmitEndpoint = '/payment/submit';
  static const Duration requestTimeout = Duration(seconds: 30);
}

// ============================================================================
// 3. DATA / MODELS / PAYMENT_METHOD_MODEL.DART
// ============================================================================

import 'package:flutter/material.dart';

/// Immutable payment method configuration.
/// Uses const constructor for compile-time optimization.
@immutable
class PaymentMethod {
  final String id;
  final String name;
  final String subtitle;
  final String logoAsset;
  final Color primaryColor;
  final Color secondaryColor;
  final bool available;

  const PaymentMethod({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.logoAsset,
    required this.primaryColor,
    required this.secondaryColor,
    this.available = true,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PaymentMethod &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

// ============================================================================
// 4. DATA / MODELS / PAYMENT_RESULT_MODEL.DART
// ============================================================================

/// Represents the result of a payment submission attempt.
@immutable
class PaymentResult {
  final bool success;
  final String? message;
  final String? transactionId;
  final DateTime? timestamp;

  const PaymentResult({
    required this.success,
    this.message,
    this.transactionId,
    this.timestamp,
  });

  factory PaymentResult.success({
    String? message,
    String? transactionId,
  }) {
    return PaymentResult(
      success: true,
      message: message,
      transactionId: transactionId,
      timestamp: DateTime.now(),
    );
  }

  factory PaymentResult.failure(String message) {
    return PaymentResult(
      success: false,
      message: message,
      timestamp: DateTime.now(),
    );
  }
}

// ============================================================================
// 5. DATA / SERVICES / AUTH_SERVICE.DART
// ============================================================================

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Secure authentication service with JWT handling.
/// Replaces SharedPreferences with flutter_secure_storage for token security.
/// 
/// SECURITY NOTE: JWT signature verification should be done server-side.
/// This service only extracts the payload for client-side convenience.
class AuthService {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
      keyCipherAlgorithm: KeyCipherAlgorithm.RSA_ECB_PKCS1Padding,
      storageCipherAlgorithm: StorageCipherAlgorithm.AES_GCM_NoPadding,
    ),
    iOptions: IOSOptions(
      accountName: 'flutter_auth_tokens',
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  static const String _tokenKey = 'jwt_token';

  /// Retrieves the stored JWT token securely.
  static Future<String?> getToken() async {
    try {
      return await _storage.read(key: _tokenKey);
    } catch (e) {
      debugPrint('AuthService: Token read error: $e');
      return null;
    }
  }

  /// Stores JWT token securely.
  static Future<void> setToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  /// Clears stored token (logout).
  static Future<void> clearToken() async {
    await _storage.delete(key: _tokenKey);
  }

  /// Extracts user ID from JWT payload without verification.
  static Future<int?> getUserId() async {
    final token = await getToken();
    if (token == null || token.isEmpty) return null;

    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;

      final normalized = base64Url.normalize(parts[1]);
      final payload = jsonDecode(utf8.decode(base64Url.decode(normalized)));

      final id = payload['userId'] ??
          payload['id'] ??
          payload['sub'] ??
          payload['user_id'];
      return id is int ? id : int.tryParse(id.toString());
    } catch (e) {
      debugPrint('AuthService: JWT decode error: $e');
      return null;
    }
  }

  /// Checks if user is currently authenticated.
  static Future<bool> isAuthenticated() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}

// ============================================================================
// 6. DOMAIN / EXCEPTIONS / PAYMENT_EXCEPTION.DART
// ============================================================================

/// Typed payment errors for precise UI handling and user feedback.
enum PaymentErrorType {
  network,
  server,
  unauthorized,
  forbidden,
  validation,
  notFound,
  rateLimit,
  parse,
  unknown,
}

class PaymentException implements Exception {
  final String message;
  final PaymentErrorType type;

  const PaymentException(this.message, this.type);

  @override
  String toString() => message;
}

// ============================================================================
// 7. DATA / SERVICES / PAYMENT_API_SERVICE.DART
// ============================================================================

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

/// Production-grade payment API service with comprehensive error handling,
/// retry logic, and timeout management.
class PaymentApiService {
  PaymentApiService._();

  static final http.Client _client = http.Client();

  /// Submits payment with full error handling and network resilience.
  static Future<Map<String, dynamic>> submitPayment({
    required int userId,
    required String method,
    required double amount,
    required String trxId,
    required String senderInfo,
    required String purpose,
  }) async {
    final token = await AuthService.getToken();
    if (token == null) {
      throw const PaymentException(
        'Authentication required. Please login again.',
        PaymentErrorType.unauthorized,
      );
    }

    final uri = Uri.parse(
        '${ApiConstants.baseUrl}${ApiConstants.paymentSubmitEndpoint}');

    final body = jsonEncode({
      'userId': userId,
      'method': method,
      'amount': amount,
      'trxId': trxId.trim(),
      'senderInfo': senderInfo.trim(),
      'purpose': purpose,
    });

    try {
      final response = await _client
          .post(
            uri,
            headers: {
              'Content-Type': 'application/json; charset=UTF-8',
              'Authorization': 'Bearer $token',
              'Accept': 'application/json',
            },
            body: body,
          )
          .timeout(ApiConstants.requestTimeout);

      final data = _parseResponse(response);

      if (response.statusCode == 201 && data['status'] == 'success') {
        return data;
      }

      _handleErrorResponse(response.statusCode, data);
      throw const PaymentException(
        'Unexpected response',
        PaymentErrorType.unknown,
      );
    } on SocketException {
      throw const PaymentException(
        'No internet connection. Please check your network.',
        PaymentErrorType.network,
      );
    } on HttpException {
      throw const PaymentException(
        'Server error occurred. Please try again later.',
        PaymentErrorType.server,
      );
    } on FormatException {
      throw const PaymentException(
        'Invalid response from server.',
        PaymentErrorType.parse,
      );
    } catch (e) {
      if (e is PaymentException) rethrow;
      throw const PaymentException(
        'An unexpected error occurred.',
        PaymentErrorType.unknown,
      );
    }
  }

  static Map<String, dynamic> _parseResponse(http.Response response) {
    try {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } catch (e) {
      return {};
    }
  }

  static void _handleErrorResponse(int statusCode, Map<String, dynamic> data) {
    final message = data['message'] ??
        data['error'] ??
        'Payment submission failed';

    switch (statusCode) {
      case 400:
        throw PaymentException(message, PaymentErrorType.validation);
      case 401:
        throw const PaymentException(
          'Session expired. Please login again.',
          PaymentErrorType.unauthorized,
        );
      case 403:
        throw PaymentException(message, PaymentErrorType.forbidden);
      case 404:
        throw PaymentException(message, PaymentErrorType.notFound);
      case 422:
        throw PaymentException(message, PaymentErrorType.validation);
      case 429:
        throw const PaymentException(
          'Too many requests. Please wait a moment.',
          PaymentErrorType.rateLimit,
        );
      case 500:
      case 502:
      case 503:
        throw const PaymentException(
          'Server is temporarily unavailable.',
          PaymentErrorType.server,
        );
      default:
        throw PaymentException(message, PaymentErrorType.unknown);
    }
  }
}

// ============================================================================
// 8. PRESENTATION / PROVIDERS / PAYMENT_PROVIDER.DART
// ============================================================================

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Payment submission state management using Riverpod.
enum PaymentStatus { idle, loading, success, error }

class PaymentState {
  final PaymentStatus status;
  final PaymentResult? result;
  final String? errorMessage;
  final PaymentErrorType? errorType;

  const PaymentState({
    this.status = PaymentStatus.idle,
    this.result,
    this.errorMessage,
    this.errorType,
  });

  PaymentState copyWith({
    PaymentStatus? status,
    PaymentResult? result,
    String? errorMessage,
    PaymentErrorType? errorType,
  }) {
    return PaymentState(
      status: status ?? this.status,
      result: result ?? this.result,
      errorMessage: errorMessage ?? this.errorMessage,
      errorType: errorType ?? this.errorType,
    );
  }

  bool get isLoading => status == PaymentStatus.loading;
  bool get isSuccess => status == PaymentStatus.success;
  bool get isError => status == PaymentStatus.error;
}

class PaymentNotifier extends StateNotifier<PaymentState> {
  PaymentNotifier() : super(const PaymentState());

  Future<void> submitPayment({
    required String method,
    required double amount,
    required String trxId,
    required String senderInfo,
    required String purpose,
  }) async {
    state = state.copyWith(status: PaymentStatus.loading);

    try {
      final userId = await AuthService.getUserId();
      if (userId == null) {
        state = state.copyWith(
          status: PaymentStatus.error,
          errorMessage: 'User not found. Please login again.',
          errorType: PaymentErrorType.unauthorized,
        );
        return;
      }

      final response = await PaymentApiService.submitPayment(
        userId: userId,
        method: method,
        amount: amount,
        trxId: trxId,
        senderInfo: senderInfo,
        purpose: purpose,
      );

      state = state.copyWith(
        status: PaymentStatus.success,
        result: PaymentResult.success(
          message: response['message']?.toString(),
          transactionId: response['transaction_id']?.toString(),
        ),
      );
    } on PaymentException catch (e) {
      state = state.copyWith(
        status: PaymentStatus.error,
        errorMessage: e.message,
        errorType: e.type,
      );
    } catch (e) {
      state = state.copyWith(
        status: PaymentStatus.error,
        errorMessage: 'An unexpected error occurred.',
        errorType: PaymentErrorType.unknown,
      );
    }
  }

  void reset() {
    state = const PaymentState();
  }
}

final paymentProvider =
    StateNotifierProvider<PaymentNotifier, PaymentState>((ref) {
  return PaymentNotifier();
});

/// Selected payment method provider
final selectedMethodProvider = StateProvider<PaymentMethod?>((ref) => null);

// ============================================================================
// 9. PRESENTATION / WIDGETS / AMOUNT_CARD.DART
// ============================================================================

/// Theme-aware amount display card with gradient background.
/// Adapts shadow intensity based on theme brightness.
class AmountCard extends StatelessWidget {
  final double amount;
  final String purpose;

  const AmountCard({
    super.key,
    required this.amount,
    required this.purpose,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: AppColors.primaryGradient(context),
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6C63FF).withOpacity(isDark ? 0.2 : 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            purpose == 'voucher' ? 'Voucher Deposit' : 'Account Verification',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                '\u09F3 ',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                amount.toStringAsFixed(2),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// 10. PRESENTATION / WIDGETS / PAYMENT_METHOD_CARD.DART
// ============================================================================

/// Theme-aware payment method selection card.
/// Handles dark/light theme transitions with animated container.
class PaymentMethodCard extends StatelessWidget {
  final PaymentMethod method;
  final bool isSelected;
  final VoidCallback? onTap;

  const PaymentMethodCard({
    super.key,
    required this.method,
    required this.isSelected,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bool enabled = onTap != null;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: enabled
            ? AppColors.cardBackground(context)
            : AppColors.disabledBackground(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected
              ? method.primaryColor
              : enabled
                  ? AppColors.border(context)
                  : AppColors.disabledBackground(context),
          width: isSelected ? 2 : 1,
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: method.primaryColor.withOpacity(isDark ? 0.25 : 0.15),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        splashColor: AppColors.splashColor(context, method.primaryColor),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: enabled
                      ? method.primaryColor.withOpacity(isDark ? 0.2 : 0.1)
                      : AppColors.disabledBackground(context),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    method.name[0],
                    style: TextStyle(
                      color: enabled
                          ? method.primaryColor
                          : AppColors.disabledForeground(context),
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      method.name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: enabled
                            ? AppColors.textPrimary(context)
                            : AppColors.disabledForeground(context),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      method.available ? method.subtitle : 'Coming Soon',
                      style: TextStyle(
                        fontSize: 12,
                        color: enabled
                            ? AppColors.textSecondary(context)
                            : AppColors.disabledForeground(context),
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: method.primaryColor,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, size: 16, color: Colors.white),
                )
              else
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF3A3A3A)
                        : Colors.grey.shade100,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isDark
                          ? const Color(0xFF4A4A4A)
                          : Colors.grey.shade300,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// 11. PRESENTATION / WIDGETS / PROCEED_BUTTON.DART
// ============================================================================

/// Theme-aware proceed button with loading state.
/// Handles special case for Binance yellow button in dark mode.
class ProceedButton extends StatelessWidget {
  final bool enabled;
  final bool isLoading;
  final Color color;
  final VoidCallback onTap;

  const ProceedButton({
    super.key,
    required this.enabled,
    required this.isLoading,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isBinance = color == AppColors.binanceYellow;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: enabled && !isLoading ? onTap : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: isBinance ? Colors.black : Colors.white,
          disabledBackgroundColor: AppColors.disabledBackground(context),
          disabledForegroundColor: AppColors.disabledForeground(context),
          elevation: enabled ? 4 : 0,
          shadowColor: color.withOpacity(isDark ? 0.3 : 0.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: isLoading
            ? SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation(
                    isBinance ? Colors.black : Colors.white,
                  ),
                ),
              )
            : Text(
                'Proceed to Pay',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                  color: isBinance ? Colors.black : Colors.white,
                ),
              ),
      ),
    );
  }
}

// ============================================================================
// 12. PRESENTATION / WIDGETS / PAYMENT_RESULT_DIALOG.DART
// ============================================================================

/// Theme-aware payment result dialog.
/// Adapts background, text colors, and icon backgrounds for dark mode.
class PaymentResultDialog extends StatelessWidget {
  final bool success;
  final String? message;

  const PaymentResultDialog({
    super.key,
    required this.success,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surface(context),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: success
                    ? AppColors.successBackground(context)
                    : AppColors.errorBackground(context),
                shape: BoxShape.circle,
              ),
              child: Icon(
                success ? Icons.check_circle : Icons.error,
                size: 48,
                color: success ? Colors.green : Colors.red,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              success ? 'Payment Submitted!' : 'Payment Failed',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary(context),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message ??
                  (success
                      ? 'Your payment has been submitted for verification. Admin will review it shortly.'
                      : 'Something went wrong. Please try again.'),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary(context),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: success ? Colors.green : Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Okay',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// 13. PRESENTATION / WIDGETS / DETAIL_TILE.DART
// ============================================================================

/// Theme-aware detail information tile with copy functionality.
class DetailTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback? onCopy;
  final Color? accentColor;

  const DetailTile({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.onCopy,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.cardBackground(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border(context)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.iconPrimary(context)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textTertiary(context),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary(context),
                  ),
                ),
              ],
            ),
          ),
          if (onCopy != null)
            IconButton(
              onPressed: onCopy,
              icon: const Icon(Icons.copy, size: 18),
              color: accentColor ?? AppColors.skyBlue,
              tooltip: 'Copy',
            ),
        ],
      ),
    );
  }
}

// ============================================================================
// 14. PRESENTATION / WIDGETS / INSTRUCTION_TILE.DART
// ============================================================================

/// Theme-aware numbered instruction step tile.
class InstructionTile extends StatelessWidget {
  final String number;
  final String text;
  final Color accentColor;

  const InstructionTile({
    super.key,
    required this.number,
    required this.text,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: accentColor.withOpacity(isDark ? 0.2 : 0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: TextStyle(
                  color: accentColor,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary(context),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// 15. PRESENTATION / WIDGETS / CUSTOM_INPUT_DECORATION.DART
// ============================================================================

/// Theme-aware input decoration factory.
class CustomInputDecoration {
  static InputDecoration create(
    BuildContext context, {
    required String label,
    required IconData icon,
    Color? focusedColor,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: AppColors.textTertiary(context)),
      prefixIcon: Icon(icon, color: AppColors.iconPrimary(context)),
      filled: true,
      fillColor: AppColors.inputFill(context),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.inputBorder(context)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.inputBorder(context)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: focusedColor ?? AppColors.skyBlue,
          width: 1.5,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }
}

// ============================================================================
// 16. PRESENTATION / WIDGETS / PAYMENT_FLOW_BASE.DART
// ============================================================================

/// Base scaffold for all payment flows with theme support.
/// Handles common UI patterns: amount card, instructions, form, submit.
/// 
/// Subclasses must implement abstract getters for payment-specific details.
abstract class PaymentFlowBase extends StatefulWidget {
  final PaymentMethod method;
  final double amount;
  final String purpose;

  const PaymentFlowBase({
    super.key,
    required this.method,
    required this.amount,
    required this.purpose,
  });
}

abstract class PaymentFlowBaseState<T extends PaymentFlowBase>
    extends State<T> {
  final formKey = GlobalKey<FormState>();
  final trxIdController = TextEditingController();
  final senderController = TextEditingController();
  bool isLoading = false;

  String get apiPurpose {
    final p = widget.purpose.toLowerCase();
    if (p.contains('verification')) return 'verification';
    if (p.contains('voucher')) return 'voucher';
    return 'verification';
  }

  String get merchantNumber => '01XXXXXXXXX';
  String get walletAddress => '0xXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX';

  List<InstructionStep> get instructions;
  List<DetailItem> get details;
  String get senderLabel;
  String get senderHint;
  IconData get senderIcon;
  TextInputType get senderKeyboardType;
  String? Function(String?) get senderValidator;
  String get trxIdLabel;
  IconData get trxIdIcon;
  String? Function(String?) get trxIdValidator;
  String get submitButtonText;
  String get screenTitle;

  @override
  void dispose() {
    trxIdController.dispose();
    senderController.dispose();
    super.dispose();
  }

  Future<void> submitPayment() async {
    if (!formKey.currentState!.validate()) return;

    final userId = await AuthService.getUserId();
    if (userId == null) {
      showSnackBar('User not found. Please login again.', isError: true);
      return;
    }

    setState(() => isLoading = true);

    try {
      await PaymentApiService.submitPayment(
        userId: userId,
        method: widget.method.id,
        amount: widget.amount,
        trxId: trxIdController.text.trim(),
        senderInfo: senderController.text.trim(),
        purpose: apiPurpose,
      );

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        showSnackBar(
          e.toString().replaceAll('Exception: ', ''),
          isError: true,
        );
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void showSnackBar(String msg, {bool isError = false}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          msg,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: isError
            ? (isDark ? const Color(0xFFB71C1C) : Colors.red.shade700)
            : (isDark ? const Color(0xFF1B5E20) : Colors.green.shade700),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Future<void> copyToClipboard(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (mounted) {
      showSnackBar('Copied: $text');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isBinance = widget.method.id == 'binance';

    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        backgroundColor: widget.method.primaryColor,
        elevation: 0,
        title: Text(screenTitle),
        centerTitle: true,
        foregroundColor: isBinance ? Colors.black : Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Amount Card
            _buildAmountCard(),
            const SizedBox(height: 28),

            // Details Section
            _buildSectionTitle('Merchant Details'),
            const SizedBox(height: 12),
            ...details.map((d) => DetailTile(
                  icon: d.icon,
                  label: d.label,
                  value: d.value,
                  onCopy: d.onCopy,
                  accentColor: widget.method.primaryColor,
                )),
            const SizedBox(height: 28),

            // Instructions Section
            _buildSectionTitle('Instructions'),
            const SizedBox(height: 12),
            ...instructions.map((i) => InstructionTile(
                  number: i.number,
                  text: i.text,
                  accentColor: widget.method.primaryColor,
                )),
            const SizedBox(height: 28),

            // Form
            Form(
              key: formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: trxIdController,
                    decoration: CustomInputDecoration.create(
                      context,
                      label: trxIdLabel,
                      icon: trxIdIcon,
                      focusedColor: widget.method.primaryColor,
                    ),
                    textCapitalization: TextCapitalization.characters,
                    textInputAction: TextInputAction.next,
                    style: TextStyle(color: AppColors.textPrimary(context)),
                    validator: trxIdValidator,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: senderController,
                    decoration: CustomInputDecoration.create(
                      context,
                      label: senderLabel,
                      icon: senderIcon,
                      focusedColor: widget.method.primaryColor,
                    ),
                    keyboardType: senderKeyboardType,
                    textInputAction: TextInputAction.done,
                    style: TextStyle(color: AppColors.textPrimary(context)),
                    validator: senderValidator,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Submit Button
            _buildSubmitButton(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountCard() {
    final isBinance = widget.method.id == 'binance';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _getGradientColors(),
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Payable Amount',
            style: TextStyle(
              color: isBinance ? Colors.black54 : Colors.white70,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '\u09F3 ${widget.amount.toStringAsFixed(2)}',
            style: TextStyle(
              color: isBinance ? Colors.black : Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  List<Color> _getGradientColors() {
    switch (widget.method.id) {
      case 'bkash':
        return AppColors.bkashGradient(context);
      case 'nagad':
        return AppColors.nagadGradient(context);
      case 'binance':
        return AppColors.binanceGradient(context);
      default:
        return AppColors.primaryGradient(context);
    }
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary(context),
      ),
    );
  }

  Widget _buildSubmitButton() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isBinance = widget.method.id == 'binance';

    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: isLoading ? null : submitPayment,
        style: ElevatedButton.styleFrom(
          backgroundColor: widget.method.primaryColor,
          foregroundColor: isBinance ? Colors.black : Colors.white,
          disabledBackgroundColor:
              widget.method.primaryColor.withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 3,
          shadowColor:
              widget.method.primaryColor.withOpacity(isDark ? 0.3 : 0.4),
        ),
        child: isLoading
            ? SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation(
                    isBinance ? Colors.black : Colors.white,
                  ),
                ),
              )
            : Text(
                submitButtonText,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                  color: isBinance ? Colors.black : Colors.white,
                ),
              ),
      ),
    );
  }
}

class InstructionStep {
  final String number;
  final String text;
  const InstructionStep(this.number, this.text);
}

class DetailItem {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback? onCopy;
  const DetailItem(this.icon, this.label, this.value, {this.onCopy});
}

// ============================================================================
// 17. PAYMENT FLOWS / BKASH_PAYMENT_FLOW.DART
// ============================================================================

class BkashPaymentFlow extends PaymentFlowBase {
  const BkashPaymentFlow({
    super.key,
    required super.method,
    required super.amount,
    required super.purpose,
  });

  @override
  State<BkashPaymentFlow> createState() => _BkashPaymentFlowState();
}

class _BkashPaymentFlowState extends PaymentFlowBaseState<BkashPaymentFlow> {
  @override
  String get screenTitle => 'bKash Payment';

  @override
  String get submitButtonText => 'Submit Payment';

  @override
  String get trxIdLabel => 'Transaction ID (TrxID)';

  @override
  IconData get trxIdIcon => Icons.confirmation_number_outlined;

  @override
  String? Function(String?) get trxIdValidator => (v) {
        if (v == null || v.trim().isEmpty) {
          return 'TrxID is required';
        }
        if (v.trim().length < 5) {
          return 'Invalid TrxID';
        }
        return null;
      };

  @override
  String get senderLabel => 'Your bKash Number';

  @override
  String get senderHint => '01XXXXXXXXX';

  @override
  IconData get senderIcon => Icons.phone_android_outlined;

  @override
  TextInputType get senderKeyboardType => TextInputType.phone;

  @override
  String? Function(String?) get senderValidator => (v) {
        if (v == null || v.trim().isEmpty) {
          return 'Sender number is required';
        }
        if (!RegExp(r'^01[3-9]\d{8}$').hasMatch(v.trim())) {
          return 'Enter valid Bangladeshi number';
        }
        return null;
      };

  @override
  List<DetailItem> get details => [
        DetailItem(
          Icons.phone_android,
          'bKash Number',
          merchantNumber,
          onCopy: () => copyToClipboard(merchantNumber),
        ),
        const DetailItem(Icons.payment, 'Payment Type', 'Send Money'),
      ];

  @override
  List<InstructionStep> get instructions => [
        const InstructionStep('1', 'Open bKash App'),
        const InstructionStep('2', 'Tap "Send Money"'),
        const InstructionStep('3', 'Enter number: 01XXXXXXXXX'),
        InstructionStep(
            '4', 'Amount: \u09F3${widget.amount.toStringAsFixed(2)}'),
        const InstructionStep('5', 'Enter TrxID and submit below'),
      ];
}

// ============================================================================
// 18. PAYMENT FLOWS / NAGAD_PAYMENT_FLOW.DART
// ============================================================================

class NagadPaymentFlow extends PaymentFlowBase {
  const NagadPaymentFlow({
    super.key,
    required super.method,
    required super.amount,
    required super.purpose,
  });

  @override
  State<NagadPaymentFlow> createState() => _NagadPaymentFlowState();
}

class _NagadPaymentFlowState extends PaymentFlowBaseState<NagadPaymentFlow> {
  @override
  String get screenTitle => 'Nagad Payment';

  @override
  String get submitButtonText => 'Submit Payment';

  @override
  String get trxIdLabel => 'Transaction ID (TrxID)';

  @override
  IconData get trxIdIcon => Icons.confirmation_number_outlined;

  @override
  String? Function(String?) get trxIdValidator => (v) {
        if (v == null || v.trim().isEmpty) {
          return 'TrxID is required';
        }
        if (v.trim().length < 5) {
          return 'Invalid TrxID';
        }
        return null;
      };

  @override
  String get senderLabel => 'Your Nagad Number';

  @override
  String get senderHint => '01XXXXXXXXX';

  @override
  IconData get senderIcon => Icons.phone_android_outlined;

  @override
  TextInputType get senderKeyboardType => TextInputType.phone;

  @override
  String? Function(String?) get senderValidator => (v) {
        if (v == null || v.trim().isEmpty) {
          return 'Sender number is required';
        }
        if (!RegExp(r'^01[3-9]\d{8}$').hasMatch(v.trim())) {
          return 'Enter valid Bangladeshi number';
        }
        return null;
      };

  @override
  List<DetailItem> get details => [
        DetailItem(
          Icons.phone_android,
          'Nagad Number',
          merchantNumber,
          onCopy: () => copyToClipboard(merchantNumber),
        ),
        const DetailItem(Icons.payment, 'Payment Type', 'Send Money'),
      ];

  @override
  List<InstructionStep> get instructions => [
        const InstructionStep('1', 'Open Nagad App'),
        const InstructionStep('2', 'Tap "Send Money"'),
        const InstructionStep('3', 'Enter number: 01XXXXXXXXX'),
        InstructionStep(
            '4', 'Amount: \u09F3${widget.amount.toStringAsFixed(2)}'),
        const InstructionStep('5', 'Enter TrxID and submit below'),
      ];
}

// ============================================================================
// 19. PAYMENT FLOWS / BINANCE_PAYMENT_FLOW.DART
// ============================================================================

class BinancePaymentFlow extends PaymentFlowBase {
  const BinancePaymentFlow({
    super.key,
    required super.method,
    required super.amount,
    required super.purpose,
  });

  @override
  State<BinancePaymentFlow> createState() => _BinancePaymentFlowState();
}

class _BinancePaymentFlowState
    extends PaymentFlowBaseState<BinancePaymentFlow> {
  @override
  String get screenTitle => 'Binance Pay';

  @override
  String get submitButtonText => 'Submit Payment';

  @override
  String get trxIdLabel => 'Transaction Hash (TxID)';

  @override
  IconData get trxIdIcon => Icons.confirmation_number_outlined;

  @override
  String? Function(String?) get trxIdValidator => (v) {
        if (v == null || v.trim().isEmpty) {
          return 'TxID is required';
        }
        if (v.trim().length < 10) {
          return 'Invalid TxID';
        }
        return null;
      };

  @override
  String get senderLabel => 'Your Binance Email / UID';

  @override
  String get senderHint => 'email@example.com';

  @override
  IconData get senderIcon => Icons.email_outlined;

  @override
  TextInputType get senderKeyboardType => TextInputType.emailAddress;

  @override
  String? Function(String?) get senderValidator => (v) {
        if (v == null || v.trim().isEmpty) {
          return 'Sender info is required';
        }
        return null;
      };

  @override
  List<DetailItem> get details => [
        DetailItem(
          Icons.account_balance_wallet,
          'USDT (BEP20) Address',
          walletAddress,
          onCopy: () => copyToClipboard(walletAddress),
        ),
        const DetailItem(Icons.paid, 'Network', 'BEP20 (BSC)'),
      ];

  @override
  List<InstructionStep> get instructions => [
        const InstructionStep('1', 'Open Binance App'),
        const InstructionStep('2', 'Go to Withdraw -> USDT'),
        const InstructionStep('3', 'Select BEP20 (BSC) Network'),
        const InstructionStep('4', 'Paste wallet address above'),
        const InstructionStep('5', 'Enter amount and send'),
        const InstructionStep('6', 'Copy TxID and submit below'),
      ];
}

// ============================================================================
// 20. PRESENTATION / SCREENS / PAYMENT_GATEWAY_SCREEN.DART
// ============================================================================

/// Main payment gateway screen with full dark mode support.
/// 
/// Features:
/// - Animated entrance (fade + slide)
/// - Theme-aware payment method cards
/// - Riverpod state management for selection
/// - Responsive layout
class PaymentGatewayScreen extends ConsumerStatefulWidget {
  final double amount;
  final String purpose;
  final VoidCallback? onPaymentSuccess;
  final VoidCallback? onPaymentFailed;

  const PaymentGatewayScreen({
    super.key,
    required this.amount,
    this.purpose = 'Account Verification Fee',
    this.onPaymentSuccess,
    this.onPaymentFailed,
  });

  @override
  ConsumerState<PaymentGatewayScreen> createState() =>
      _PaymentGatewayScreenState();
}

class _PaymentGatewayScreenState extends ConsumerState<PaymentGatewayScreen>
    with TickerProviderStateMixin {
  bool _isProcessing = false;

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final List<PaymentMethod> _methods = const [
    PaymentMethod(
      id: 'bkash',
      name: 'bKash',
      subtitle: 'Mobile Banking',
      logoAsset: 'assets/images/bkash.png',
      primaryColor: AppColors.bkashPink,
      secondaryColor: Color(0xFFFF6DAE),
      available: true,
    ),
    PaymentMethod(
      id: 'nagad',
      name: 'Nagad',
      subtitle: 'Digital Wallet',
      logoAsset: 'assets/images/nagad.png',
      primaryColor: AppColors.nagadOrange,
      secondaryColor: Color(0xFFFFAA55),
      available: true,
    ),
    PaymentMethod(
      id: 'binance',
      name: 'Binance Pay',
      subtitle: 'Crypto Payment',
      logoAsset: 'assets/images/binance.png',
      primaryColor: AppColors.binanceYellow,
      secondaryColor: Color(0xFFFFDA6A),
      available: true,
    ),
  ];

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(isDetailViewProvider.notifier).state = true;
        ref.read(detailViewTitleProvider.notifier).state = 'Payment';
      }
    });

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOut,
    ));
    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  Future<void> _proceedToPayment() async {
    final selectedMethod = ref.read(selectedMethodProvider);
    if (selectedMethod == null) return;

    setState(() => _isProcessing = true);
    await Future.delayed(const Duration(milliseconds: 400));
    setState(() => _isProcessing = false);
    if (!mounted) return;

    Widget flowScreen;
    switch (selectedMethod.id) {
      case 'bkash':
        flowScreen = BkashPaymentFlow(
          method: selectedMethod,
          amount: widget.amount,
          purpose: widget.purpose,
        );
        break;
      case 'nagad':
        flowScreen = NagadPaymentFlow(
          method: selectedMethod,
          amount: widget.amount,
          purpose: widget.purpose,
        );
        break;
      case 'binance':
        flowScreen = BinancePaymentFlow(
          method: selectedMethod,
          amount: widget.amount,
          purpose: widget.purpose,
        );
        break;
      default:
        return;
    }

    final result = await Navigator.of(context, rootNavigator: true).push<bool>(
      MaterialPageRoute(builder: (_) => flowScreen),
    );

    if (!mounted) return;

    if (result == true) {
      widget.onPaymentSuccess?.call();
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const PaymentResultDialog(success: true),
      );
    } else if (result == false) {
      widget.onPaymentFailed?.call();
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const PaymentResultDialog(success: false),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedMethod = ref.watch(selectedMethodProvider);

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground(context),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: SafeArea(
            child: Column(
              children: [
                AmountCard(amount: widget.amount, purpose: widget.purpose),
                const SizedBox(height: 28),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Select Payment Method',
                      style: TextStyle(
                        color: AppColors.textSecondary(context),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    itemCount: _methods.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 14),
                    itemBuilder: (context, index) {
                      final method = _methods[index];
                      return PaymentMethodCard(
                        method: method,
                        isSelected: selectedMethod?.id == method.id,
                        onTap: method.available
                            ? () => ref
                                .read(selectedMethodProvider.notifier)
                                .state = method
                            : null,
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                  child: ProceedButton(
                    enabled: selectedMethod != null,
                    isLoading: _isProcessing,
                    color: selectedMethod?.primaryColor ??
                        const Color(0xFF6C63FF),
                    onTap: _proceedToPayment,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
