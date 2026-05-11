import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../main.dart';

// ==========================================
// 1. PAYMENT METHOD MODEL
// ==========================================

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
}

// ==========================================
// 2. AUTH HELPER
// ==========================================

class AuthHelper {
  static const String _tokenKey = 'jwt_token';

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  static Future<int?> getUserId() async {
    final token = await getToken();
    if (token == null || token.isEmpty) return null;

    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;

      final normalized = base64Url.normalize(parts[1]);
      final payload = jsonDecode(utf8.decode(base64Url.decode(normalized)));

      final id = payload['userId'] ?? payload['id'] ?? payload['sub'] ?? payload['user_id'];
      return id is int ? id : int.tryParse(id.toString());
    } catch (e) {
      debugPrint('JWT Decode Error: $e');
      return null;
    }
  }
}

// ==========================================
// 3. API SERVICE
// ==========================================

class PaymentApiService {
  static const String _baseUrl = 'https://easy.ltcminematrix.com/api';

  static Future<Map<String, dynamic>> submitPayment({
    required int userId,
    required String method,
    required double amount,
    required String trxId,
    required String senderInfo,
    required String purpose,
  }) async {
    final token = await AuthHelper.getToken();
    if (token == null) {
      throw Exception('Authentication required. Please login again.');
    }

    final response = await http.post(
      Uri.parse('$_baseUrl/payment/submit'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'userId': userId,
        'method': method,
        'amount': amount,
        'trxId': trxId.trim(),
        'senderInfo': senderInfo.trim(),
        'purpose': purpose,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 201 && data['status'] == 'success') {
      return data;
    } else if (response.statusCode == 400) {
      throw Exception(data['message'] ?? 'Invalid request');
    } else if (response.statusCode == 401) {
      throw Exception('Session expired. Please login again.');
    } else {
      throw Exception(data['message'] ?? data['error'] ?? 'Payment submission failed');
    }
  }
}

// ==========================================
// 4. UI COMPONENTS
// ==========================================

class AmountCard extends StatelessWidget {
  final double amount;
  final String purpose;

  const AmountCard({super.key, required this.amount, required this.purpose});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6C63FF), Color(0xFF4A44D6)],
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
            ? (isDark ? const Color(0xFF252525) : Colors.white)
            : (isDark ? const Color(0xFF2A2A2A) : Colors.grey.shade50),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected
              ? method.primaryColor
              : enabled
                  ? (isDark ? const Color(0xFF3A3A3A) : Colors.grey.shade200)
                  : (isDark ? const Color(0xFF2A2A2A) : Colors.grey.shade100),
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
                      : (isDark ? const Color(0xFF2A2A2A) : Colors.grey.shade100),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    method.name[0],
                    style: TextStyle(
                      color: enabled
                          ? method.primaryColor
                          : (isDark ? Colors.grey.shade600 : Colors.grey),
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
                            ? (isDark ? Colors.white : Colors.black87)
                            : (isDark ? Colors.grey.shade600 : Colors.grey),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      method.available ? method.subtitle : 'Coming Soon',
                      style: TextStyle(
                        fontSize: 12,
                        color: enabled
                            ? (isDark ? Colors.grey.shade400 : Colors.black45)
                            : (isDark ? Colors.grey.shade500 : Colors.grey.shade400),
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
                    color: isDark ? const Color(0xFF3A3A3A) : Colors.grey.shade100,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isDark ? const Color(0xFF4A4A4A) : Colors.grey.shade300,
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
    final isBinance = color == const Color(0xFFF0B90B);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: enabled && !isLoading ? onTap : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: isBinance ? Colors.black : Colors.white,
          disabledBackgroundColor: isDark ? const Color(0xFF2A2A2A) : Colors.grey.shade300,
          disabledForegroundColor: isDark ? Colors.grey.shade600 : Colors.grey.shade500,
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

class PaymentResultDialog extends StatelessWidget {
  final bool success;
  final String? message;

  const PaymentResultDialog({super.key, required this.success, this.message});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
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
                    ? (isDark ? const Color(0xFF1F3D1F) : Colors.green.shade50)
                    : (isDark ? const Color(0xFF3D1F1F) : Colors.red.shade50),
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
                color: isDark ? Colors.white : Colors.black,
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
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  if (success) {
                    context.pop(true);
                  }
                },
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

// ==========================================
// 5. BKASH PAYMENT FLOW
// ==========================================

class BkashPaymentFlow extends StatefulWidget {
  final PaymentMethod method;
  final double amount;
  final String purpose;

  const BkashPaymentFlow({
    super.key,
    required this.method,
    required this.amount,
    required this.purpose,
  });

  @override
  State<BkashPaymentFlow> createState() => _BkashPaymentFlowState();
}

class _BkashPaymentFlowState extends State<BkashPaymentFlow> {
  final _formKey = GlobalKey<FormState>();
  final _trxIdController = TextEditingController();
  final _senderController = TextEditingController();
  bool _isLoading = false;

  final String _merchantNumber = '01XXXXXXXXX';

  @override
  void dispose() {
    _trxIdController.dispose();
    _senderController.dispose();
    super.dispose();
  }

  String get _apiPurpose {
    final p = widget.purpose.toLowerCase();
    if (p.contains('verification')) return 'verification';
    if (p.contains('voucher')) return 'voucher';
    return 'verification';
  }

  Future<void> _submitPayment() async {
    if (!_formKey.currentState!.validate()) return;

    final userId = await AuthHelper.getUserId();
    if (userId == null) {
      _showSnackBar('User not found. Please login again.', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      await PaymentApiService.submitPayment(
        userId: userId,
        method: widget.method.id,
        amount: widget.amount,
        trxId: _trxIdController.text.trim(),
        senderInfo: _senderController.text.trim(),
        purpose: _apiPurpose,
      );

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar(
          e.toString().replaceAll('Exception: ', ''),
          isError: true,
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String msg, {bool isError = false}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError
            ? (isDark ? const Color(0xFFB71C1C) : Colors.red.shade700)
            : (isDark ? const Color(0xFF1B5E20) : Colors.green.shade700),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Future<void> _copyToClipboard(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (mounted) {
      _showSnackBar('Copied: $text');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: widget.method.primaryColor,
        elevation: 0,
        title: const Text('bKash Payment'),
        centerTitle: true,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [widget.method.primaryColor, widget.method.secondaryColor],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Payable Amount',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '\u09F3 ${widget.amount.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            Text(
              'Merchant Details',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black,
                  ),
            ),
            const SizedBox(height: 12),
            _buildDetailTile(
              icon: Icons.phone_android,
              label: 'bKash Number',
              value: _merchantNumber,
              onCopy: () => _copyToClipboard(_merchantNumber),
            ),
            _buildDetailTile(
              icon: Icons.payment,
              label: 'Payment Type',
              value: 'Send Money',
            ),
            const SizedBox(height: 28),
            Text(
              'Instructions',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black,
                  ),
            ),
            const SizedBox(height: 12),
            _buildInstructionTile('1', 'Open bKash App'),
            _buildInstructionTile('2', 'Tap "Send Money"'),
            _buildInstructionTile('3', 'Enter number: $_merchantNumber'),
            _buildInstructionTile('4', 'Amount: \u09F3${widget.amount.toStringAsFixed(2)}'),
            _buildInstructionTile('5', 'Enter TrxID and submit below'),
            const SizedBox(height: 28),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _trxIdController,
                    decoration: _inputDecoration(
                      'Transaction ID (TrxID)',
                      Icons.confirmation_number_outlined,
                    ),
                    textCapitalization: TextCapitalization.characters,
                    textInputAction: TextInputAction.next,
                    style: TextStyle(color: isDark ? Colors.white : Colors.black),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'TrxID is required';
                      }
                      if (v.trim().length < 5) {
                        return 'Invalid TrxID';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _senderController,
                    decoration: _inputDecoration(
                      'Your bKash Number',
                      Icons.phone_android_outlined,
                    ),
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.done,
                    style: TextStyle(color: isDark ? Colors.white : Colors.black),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Sender number is required';
                      }
                      if (!RegExp(r'^01[3-9]\d{8}$').hasMatch(v.trim())) {
                        return 'Enter valid Bangladeshi number';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitPayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.method.primaryColor,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: widget.method.primaryColor.withOpacity(0.3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 3,
                  shadowColor: widget.method.primaryColor.withOpacity(isDark ? 0.3 : 0.4),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation(Colors.white),
                        ),
                      )
                    : const Text(
                        'Submit Payment',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.3,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailTile({
    required IconData icon,
    required String label,
    required String value,
    VoidCallback? onCopy,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF252525) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? const Color(0xFF3A3A3A) : Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: isDark ? Colors.grey.shade300 : Colors.grey.shade600),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 11, color: isDark ? Colors.grey.shade500 : Colors.grey.shade500),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
              ],
            ),
          ),
          if (onCopy != null)
            IconButton(
              onPressed: onCopy,
              icon: const Icon(Icons.copy, size: 18),
              color: const Color(0xFFE2136E),
              tooltip: 'Copy',
            ),
        ],
      ),
    );
  }

  Widget _buildInstructionTile(String number, String text) {
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
              color: const Color(0xFFE2136E).withOpacity(isDark ? 0.2 : 0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  color: Color(0xFFE2136E),
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
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: isDark ? Colors.grey.shade500 : Colors.grey),
      prefixIcon: Icon(icon, color: isDark ? Colors.grey.shade400 : Colors.grey),
      filled: true,
      fillColor: isDark ? const Color(0xFF252525) : Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: isDark ? const Color(0xFF3A3A3A) : Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: isDark ? const Color(0xFF3A3A3A) : Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE2136E), width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 1),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }
}

// ==========================================
// 6. NAGAD PAYMENT FLOW
// ==========================================

class NagadPaymentFlow extends StatefulWidget {
  final PaymentMethod method;
  final double amount;
  final String purpose;

  const NagadPaymentFlow({
    super.key,
    required this.method,
    required this.amount,
    required this.purpose,
  });

  @override
  State<NagadPaymentFlow> createState() => _NagadPaymentFlowState();
}

class _NagadPaymentFlowState extends State<NagadPaymentFlow> {
  final _formKey = GlobalKey<FormState>();
  final _trxIdController = TextEditingController();
  final _senderController = TextEditingController();
  bool _isLoading = false;

  final String _merchantNumber = '01XXXXXXXXX';

  @override
  void dispose() {
    _trxIdController.dispose();
    _senderController.dispose();
    super.dispose();
  }

  String get _apiPurpose {
    final p = widget.purpose.toLowerCase();
    if (p.contains('verification')) return 'verification';
    if (p.contains('voucher')) return 'voucher';
    return 'verification';
  }

  Future<void> _submitPayment() async {
    if (!_formKey.currentState!.validate()) return;

    final userId = await AuthHelper.getUserId();
    if (userId == null) {
      _showSnackBar('User not found. Please login again.', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      await PaymentApiService.submitPayment(
        userId: userId,
        method: widget.method.id,
        amount: widget.amount,
        trxId: _trxIdController.text.trim(),
        senderInfo: _senderController.text.trim(),
        purpose: _apiPurpose,
      );

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar(
          e.toString().replaceAll('Exception: ', ''),
          isError: true,
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String msg, {bool isError = false}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError
            ? (isDark ? const Color(0xFFB71C1C) : Colors.red.shade700)
            : (isDark ? const Color(0xFF1B5E20) : Colors.green.shade700),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Future<void> _copyToClipboard(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (mounted) {
      _showSnackBar('Copied: $text');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: widget.method.primaryColor,
        elevation: 0,
        title: const Text('Nagad Payment'),
        centerTitle: true,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [widget.method.primaryColor, widget.method.secondaryColor],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Payable Amount',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '\u09F3 ${widget.amount.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            Text(
              'Merchant Details',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black,
                  ),
            ),
            const SizedBox(height: 12),
            _buildDetailTile(
              icon: Icons.phone_android,
              label: 'Nagad Number',
              value: _merchantNumber,
              onCopy: () => _copyToClipboard(_merchantNumber),
            ),
            _buildDetailTile(
              icon: Icons.payment,
              label: 'Payment Type',
              value: 'Send Money',
            ),
            const SizedBox(height: 28),
            Text(
              'Instructions',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black,
                  ),
            ),
            const SizedBox(height: 12),
            _buildInstructionTile('1', 'Open Nagad App'),
            _buildInstructionTile('2', 'Tap "Send Money"'),
            _buildInstructionTile('3', 'Enter number: $_merchantNumber'),
            _buildInstructionTile('4', 'Amount: \u09F3${widget.amount.toStringAsFixed(2)}'),
            _buildInstructionTile('5', 'Enter TrxID and submit below'),
            const SizedBox(height: 28),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _trxIdController,
                    decoration: _inputDecoration(
                      'Transaction ID (TrxID)',
                      Icons.confirmation_number_outlined,
                    ),
                    textCapitalization: TextCapitalization.characters,
                    textInputAction: TextInputAction.next,
                    style: TextStyle(color: isDark ? Colors.white : Colors.black),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'TrxID is required';
                      }
                      if (v.trim().length < 5) {
                        return 'Invalid TrxID';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _senderController,
                    decoration: _inputDecoration(
                      'Your Nagad Number',
                      Icons.phone_android_outlined,
                    ),
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.done,
                    style: TextStyle(color: isDark ? Colors.white : Colors.black),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Sender number is required';
                      }
                      if (!RegExp(r'^01[3-9]\d{8}$').hasMatch(v.trim())) {
                        return 'Enter valid Bangladeshi number';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitPayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.method.primaryColor,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: widget.method.primaryColor.withOpacity(0.3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 3,
                  shadowColor: widget.method.primaryColor.withOpacity(isDark ? 0.3 : 0.4),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation(Colors.white),
                        ),
                      )
                    : const Text(
                        'Submit Payment',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.3,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailTile({
    required IconData icon,
    required String label,
    required String value,
    VoidCallback? onCopy,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF252525) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? const Color(0xFF3A3A3A) : Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: isDark ? Colors.grey.shade300 : Colors.grey.shade600),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 11, color: isDark ? Colors.grey.shade500 : Colors.grey.shade500),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
              ],
            ),
          ),
          if (onCopy != null)
            IconButton(
              onPressed: onCopy,
              icon: const Icon(Icons.copy, size: 18),
              color: const Color(0xFFFF6600),
              tooltip: 'Copy',
            ),
        ],
      ),
    );
  }

  Widget _buildInstructionTile(String number, String text) {
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
              color: const Color(0xFFFF6600).withOpacity(isDark ? 0.2 : 0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  color: Color(0xFFFF6600),
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
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: isDark ? Colors.grey.shade500 : Colors.grey),
      prefixIcon: Icon(icon, color: isDark ? Colors.grey.shade400 : Colors.grey),
      filled: true,
      fillColor: isDark ? const Color(0xFF252525) : Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: isDark ? const Color(0xFF3A3A3A) : Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: isDark ? const Color(0xFF3A3A3A) : Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFFF6600), width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 1),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }
}

// ==========================================
// 7. BINANCE PAYMENT FLOW
// ==========================================

class BinancePaymentFlow extends StatefulWidget {
  final PaymentMethod method;
  final double amount;
  final String purpose;

  const BinancePaymentFlow({
    super.key,
    required this.method,
    required this.amount,
    required this.purpose,
  });

  @override
  State<BinancePaymentFlow> createState() => _BinancePaymentFlowState();
}

class _BinancePaymentFlowState extends State<BinancePaymentFlow> {
  final _formKey = GlobalKey<FormState>();
  final _trxIdController = TextEditingController();
  final _senderController = TextEditingController();
  bool _isLoading = false;

  final String _walletAddress = '0xXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX';

  @override
  void dispose() {
    _trxIdController.dispose();
    _senderController.dispose();
    super.dispose();
  }

  String get _apiPurpose {
    final p = widget.purpose.toLowerCase();
    if (p.contains('verification')) return 'verification';
    if (p.contains('voucher')) return 'voucher';
    return 'verification';
  }

  Future<void> _submitPayment() async {
    if (!_formKey.currentState!.validate()) return;

    final userId = await AuthHelper.getUserId();
    if (userId == null) {
      _showSnackBar('User not found. Please login again.', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      await PaymentApiService.submitPayment(
        userId: userId,
        method: widget.method.id,
        amount: widget.amount,
        trxId: _trxIdController.text.trim(),
        senderInfo: _senderController.text.trim(),
        purpose: _apiPurpose,
      );

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar(
          e.toString().replaceAll('Exception: ', ''),
          isError: true,
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String msg, {bool isError = false}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError
            ? (isDark ? const Color(0xFFB71C1C) : Colors.red.shade700)
            : (isDark ? const Color(0xFF1B5E20) : Colors.green.shade700),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Future<void> _copyToClipboard(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (mounted) {
      _showSnackBar('Copied: $text');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: widget.method.primaryColor,
        elevation: 0,
        title: const Text('Binance Pay'),
        centerTitle: true,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [widget.method.primaryColor, widget.method.secondaryColor],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Payable Amount',
                    style: TextStyle(color: Colors.black54, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '\u09F3 ${widget.amount.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            Text(
              'Wallet Details',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black,
                  ),
            ),
            const SizedBox(height: 12),
            _buildDetailTile(
              icon: Icons.account_balance_wallet,
              label: 'USDT (BEP20) Address',
              value: _walletAddress,
              onCopy: () => _copyToClipboard(_walletAddress),
            ),
            _buildDetailTile(
              icon: Icons.paid,
              label: 'Network',
              value: 'BEP20 (BSC)',
            ),
            const SizedBox(height: 28),
            Text(
              'Instructions',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black,
                  ),
            ),
            const SizedBox(height: 12),
            _buildInstructionTile('1', 'Open Binance App'),
            _buildInstructionTile('2', 'Go to Withdraw -> USDT'),
            _buildInstructionTile('3', 'Select BEP20 (BSC) Network'),
            _buildInstructionTile('4', 'Paste wallet address above'),
            _buildInstructionTile('5', 'Enter amount and send'),
            _buildInstructionTile('6', 'Copy TxID and submit below'),
            const SizedBox(height: 28),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _trxIdController,
                    decoration: _inputDecoration(
                      'Transaction Hash (TxID)',
                      Icons.confirmation_number_outlined,
                    ),
                    textCapitalization: TextCapitalization.characters,
                    textInputAction: TextInputAction.next,
                    style: TextStyle(color: isDark ? Colors.white : Colors.black),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'TxID is required';
                      }
                      if (v.trim().length < 10) {
                        return 'Invalid TxID';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _senderController,
                    decoration: _inputDecoration(
                      'Your Binance Email / UID',
                      Icons.email_outlined,
                    ),
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.done,
                    style: TextStyle(color: isDark ? Colors.white : Colors.black),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Sender info is required';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitPayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF0B90B),
                  foregroundColor: Colors.black,
                  disabledBackgroundColor: const Color(0xFFF0B90B).withOpacity(0.3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 3,
                  shadowColor: const Color(0xFFF0B90B).withOpacity(isDark ? 0.3 : 0.4),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation(Colors.black),
                        ),
                      )
                    : const Text(
                        'Submit Payment',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.3,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailTile({
    required IconData icon,
    required String label,
    required String value,
    VoidCallback? onCopy,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF252525) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? const Color(0xFF3A3A3A) : Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: isDark ? Colors.grey.shade300 : Colors.grey.shade600),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 11, color: isDark ? Colors.grey.shade500 : Colors.grey.shade500),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
              ],
            ),
          ),
          if (onCopy != null)
            IconButton(
              onPressed: onCopy,
              icon: const Icon(Icons.copy, size: 18),
              color: const Color(0xFFF0B90B),
              tooltip: 'Copy',
            ),
        ],
      ),
    );
  }

  Widget _buildInstructionTile(String number, String text) {
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
              color: const Color(0xFFF0B90B).withOpacity(isDark ? 0.2 : 0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  color: Color(0xFFF0B90B),
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
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: isDark ? Colors.grey.shade500 : Colors.grey),
      prefixIcon: Icon(icon, color: isDark ? Colors.grey.shade400 : Colors.grey),
      filled: true,
      fillColor: isDark ? const Color(0xFF252525) : Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: isDark ? const Color(0xFF3A3A3A) : Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: isDark ? const Color(0xFF3A3A3A) : Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFF0B90B), width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 1),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }
}

// ==========================================
// 8. MAIN SCREEN - PaymentGatewayScreen
// ==========================================

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
  ConsumerState<PaymentGatewayScreen> createState() => _PaymentGatewayScreenState();
}

class _PaymentGatewayScreenState extends ConsumerState<PaymentGatewayScreen>
    with TickerProviderStateMixin {
  PaymentMethod? _selectedMethod;
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
      primaryColor: Color(0xFFE2136E),
      secondaryColor: Color(0xFFFF6DAE),
      available: true,
    ),
    PaymentMethod(
      id: 'nagad',
      name: 'Nagad',
      subtitle: 'Digital Wallet',
      logoAsset: 'assets/images/nagad.png',
      primaryColor: Color(0xFFFF6600),
      secondaryColor: Color(0xFFFFAA55),
      available: true,
    ),
    PaymentMethod(
      id: 'binance',
      name: 'Binance Pay',
      subtitle: 'Crypto Payment',
      logoAsset: 'assets/images/binance.png',
      primaryColor: Color(0xFFF0B90B),
      secondaryColor: Color(0xFFFFDA6A),
      available: true,
    ),
  ];

  @override
  void initState() {
    super.initState();

    // Set detail view for AppTopBar back button and title
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
    if (_selectedMethod == null) return;

    setState(() => _isProcessing = true);
    await Future.delayed(const Duration(milliseconds: 400));
    setState(() => _isProcessing = false);
    if (!mounted) return;

    Widget flowScreen;
    switch (_selectedMethod!.id) {
      case 'bkash':
        flowScreen = BkashPaymentFlow(
          method: _selectedMethod!,
          amount: widget.amount,
          purpose: widget.purpose,
        );
        break;
      case 'nagad':
        flowScreen = NagadPaymentFlow(
          method: _selectedMethod!,
          amount: widget.amount,
          purpose: widget.purpose,
        );
        break;
      case 'binance':
        flowScreen = BinancePaymentFlow(
          method: _selectedMethod!,
          amount: widget.amount,
          purpose: widget.purpose,
        );
        break;
      default:
        return;
    }

    // Push payment flow as full screen outside MainWrapper
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0D0D0D) : Colors.white,
      // No AppBar - MainWrapper/AppTopBar handles it via isDetailViewProvider
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
                        color: isDark ? Colors.grey.shade400 : Colors.black.withOpacity(0.55),
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
                        isSelected: _selectedMethod?.id == method.id,
                        onTap: method.available
                            ? () => setState(() => _selectedMethod = method)
                            : null,
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                  child: ProceedButton(
                    enabled: _selectedMethod != null,
                    isLoading: _isProcessing,
                    color: _selectedMethod?.primaryColor ??
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

