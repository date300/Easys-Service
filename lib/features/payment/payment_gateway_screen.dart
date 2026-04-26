import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// ═══════════════════════════════════════════════════════════════
// ১. মডেল
// ═══════════════════════════════════════════════════════════════
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

// ═══════════════════════════════════════════════════════════════
// ২. JWT & AUTH HELPER
// ═══════════════════════════════════════════════════════════════
class AuthHelper {
  static const String _tokenKey = 'jwt_token'; // আপনার স্টোরেজ কী অনুযায়ী চেঞ্জ করুন

  /// SharedPreferences থেকে JWT টোকেন নেয়
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  /// JWT পে-লোড ডিকোড করে userId বের করে
  static Future<int?> getUserId() async {
    final token = await getToken();
    if (token == null || token.isEmpty) return null;

    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;

      final normalized = base64Url.normalize(parts[1]);
      final payload = jsonDecode(utf8.decode(base64Url.decode(normalized)));

      // আপনার JWT স্ট্রাকচার অনুযায়ী যেকোনো একটি ক্লেইম হবে
      final id = payload['userId'] ??
          payload['id'] ??
          payload['sub'] ??
          payload['user_id'];
      return id is int ? id : int.tryParse(id.toString());
    } catch (e) {
      debugPrint('JWT Decode Error: $e');
      return null;
    }
  }
}

// ═══════════════════════════════════════════════════════════════
// ৩. API SERVICE
// ═══════════════════════════════════════════════════════════════
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
      throw Exception('অনুগ্রহ করে আবার লগইন করুন। JWT টোকেন পাওয়া যায়নি।');
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

    if (response.statusCode == 201 && data['success'] == true) {
      return data;
    } else if (response.statusCode == 400) {
      throw Exception(data['message'] ?? 'অবৈধ অনুরোধ।');
    } else if (response.statusCode == 401) {
      throw Exception('সেশন মেয়াদোত্তীর্ণ। আবার লগইন করুন।');
    } else {
      throw Exception(data['message'] ?? data['error'] ?? 'সার্ভার ত্রুটি হয়েছে।');
    }
  }
}

// ═══════════════════════════════════════════════════════════════
// ৪. উইজেটসমূহ
// ═══════════════════════════════════════════════════════════════

class AmountCard extends StatelessWidget {
  final double amount;
  final String purpose;

  const AmountCard({super.key, required this.amount, required this.purpose});

  @override
  Widget build(BuildContext context) {
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
            color: const Color(0xFF6C63FF).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            purpose,
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
                '৳ ',
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
    final bool enabled = onTap != null;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: enabled ? Colors.white : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected
              ? method.primaryColor
              : enabled
                  ? Colors.grey.shade200
                  : Colors.grey.shade100,
          width: isSelected ? 2 : 1,
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: method.primaryColor.withOpacity(0.15),
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
                      ? method.primaryColor.withOpacity(0.1)
                      : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    method.name[0],
                    style: TextStyle(
                      color: enabled ? method.primaryColor : Colors.grey,
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
                        color: enabled ? Colors.black87 : Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      method.available ? method.subtitle : 'Coming Soon',
                      style: TextStyle(
                        fontSize: 12,
                        color: enabled ? Colors.black45 : Colors.grey.shade400,
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
                    color: Colors.grey.shade100,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey.shade300),
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
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: enabled && !isLoading ? onTap : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          disabledBackgroundColor: Colors.grey.shade300,
          disabledForegroundColor: Colors.grey.shade500,
          elevation: enabled ? 4 : 0,
          shadowColor: color.withOpacity(0.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation(Colors.white),
                ),
              )
            : const Text(
                'Proceed to Pay',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
              ),
      ),
    );
  }
}

class PaymentResultDialog extends StatelessWidget {
  final bool success;

  const PaymentResultDialog({super.key, required this.success});

  @override
  Widget build(BuildContext context) {
    return Dialog(
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
                color: success ? Colors.green.shade50 : Colors.red.shade50,
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
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              success
                  ? 'আপনার পেমেন্ট রিকোয়েস্ট গ্রহণ করা হয়েছে। অ্যাডমিন অনুমোদনের পর আপডেট পাবেন।'
                  : 'কোনো সমস্যা হয়েছে। আবার চেষ্টা করুন।',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // dialog close
                  Navigator.pop(context); // back to previous screen
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

// ═══════════════════════════════════════════════════════════════
// ৫. BKASH PAYMENT FLOW (API ইন্টিগ্রেটেড)
// ═══════════════════════════════════════════════════════════════
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

  // ⚠️ এখানে আপনার মার্চেন্ট bKash নম্বর দিন
  final String _merchantNumber = '01XXXXXXXXX';

  @override
  void dispose() {
    _trxIdController.dispose();
    _senderController.dispose();
    super.dispose();
  }

  /// UI-তে দেখানো purpose কে API-র জন্য ম্যাপ করা
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
      _showSnackBar('ইউজার আইডি পাওয়া যায়নি। আবার লগইন করুন।', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      await PaymentApiService.submitPayment(
        userId: userId,
        method: widget.method.id, // 'bkash'
        amount: widget.amount,
        trxId: _trxIdController.text.trim(),
        senderInfo: _senderController.text.trim(),
        purpose: _apiPurpose,
      );

      if (mounted) {
        Navigator.pop(context, true); // success = true
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? Colors.red.shade700 : Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Future<void> _copyToClipboard(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (mounted) {
      _showSnackBar('কপি করা হয়েছে: $text');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
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
            // ── Amount Card ──
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
                    '৳ ${widget.amount.toStringAsFixed(2)}',
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

            // ── Merchant Info ──
            Text(
              'Merchant Details',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
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

            // ── Instructions ──
            Text(
              'Instructions',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            _buildInstructionTile('1', 'bKash App খুলুন।'),
            _buildInstructionTile('2', '"Send Money" তে যান।'),
            _buildInstructionTile('3', 'নম্বরে টাকা পাঠান: $_merchantNumber'),
            _buildInstructionTile('4', 'Amount: ৳${widget.amount.toStringAsFixed(2)}'),
            _buildInstructionTile('5', 'নিচে TrxID এবং আপনার নম্বর লিখুন।'),
            const SizedBox(height: 28),

            // ── Form ──
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
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'TrxID দিন';
                      }
                      if (v.trim().length < 5) {
                        return 'সঠিক TrxID দিন';
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
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'সেন্ডার নম্বর দিন';
                      }
                      if (!RegExp(r'^01[3-9]\d{8}$').hasMatch(v.trim())) {
                        return 'সঠিক বাংলাদেশি মোবাইল নম্বর দিন';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // ── Submit Button ──
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitPayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.method.primaryColor,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.pink.shade100,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 3,
                  shadowColor: widget.method.primaryColor.withOpacity(0.4),
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
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey.shade600),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: const Color(0xFFE2136E).withOpacity(0.1),
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
                color: Colors.grey.shade700,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Colors.grey),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
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

// ═══════════════════════════════════════════════════════════════
// ৬. NAGAD & BINANCE (Placeholder — একই ফরম্যাটে এক্সটেন্ড করুন)
// ═══════════════════════════════════════════════════════════════
class NagadPaymentFlow extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nagad Payment'),
        backgroundColor: method.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Text(
          'Nagad integration coming soon...',
          style: TextStyle(color: Colors.grey.shade600),
        ),
      ),
    );
  }
}

class BinancePaymentFlow extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Binance Pay'),
        backgroundColor: method.primaryColor,
        foregroundColor: Colors.black,
      ),
      body: Center(
        child: Text(
          'Binance Pay integration coming soon...',
          style: TextStyle(color: Colors.grey.shade600),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// ৭. MAIN SCREEN — PaymentGatewayScreen
// ═══════════════════════════════════════════════════════════════
class PaymentGatewayScreen extends StatefulWidget {
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
  State<PaymentGatewayScreen> createState() => _PaymentGatewayScreenState();
}

class _PaymentGatewayScreenState extends State<PaymentGatewayScreen>
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
      available: false,
    ),
    PaymentMethod(
      id: 'binance',
      name: 'Binance Pay',
      subtitle: 'Crypto Payment',
      logoAsset: 'assets/images/binance.png',
      primaryColor: Color(0xFFF0B90B),
      secondaryColor: Color(0xFFFFDA6A),
      available: false,
    ),
  ];

  @override
  void initState() {
    super.initState();
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

    final result = await Navigator.push<bool>(
      context,
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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black87,
        title: const Text(
          'Payment',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
      ),
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
                        color: Colors.black.withOpacity(0.55),
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
