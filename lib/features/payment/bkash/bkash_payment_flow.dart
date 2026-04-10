import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/payment_method.dart';

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
  final _trxIdController = TextEditingController();
  bool _isLoading = false;
  String? _errorText;
  
  static const Color bkashPink = Color(0xFFE2136E);
  static const Color bkashLightPink = Color(0xFFFCE4EC);
  final String _receiverNumber = '01700000000';

  @override
  void dispose() {
    _trxIdController.dispose();
    super.dispose();
  }

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label কপি করা হয়েছে'),
        backgroundColor: bkashPink,
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Future<void> _submitTransaction() async {    final trxId = _trxIdController.text.trim();
    
    if (trxId.isEmpty) {
      setState(() => _errorText = 'দয়া করে একটি Transaction ID দিন');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorText = null;
    });

    await Future.delayed(const Duration(seconds: 2)); 
    setState(() => _isLoading = false);

    if (!mounted) return;
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: bkashPink,
        elevation: 0,
        leading: null,
        automaticallyImplyLeading: false,
        // ✅ লোগো রিমুভ করে সাধারণ টেক্সট টাইটেল
        title: const Text(
          'bKash Payment',
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: bkashPink.withOpacity(0.3)),
                  boxShadow: [                    BoxShadow(
                      color: bkashPink.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: bkashLightPink,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.info_outline, color: bkashPink, size: 20),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'প্রয়োজনীয় নির্দেশাবলী',
                          style: TextStyle(
                            color: bkashPink, 
                            fontSize: 16, 
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildStepText('১. bKash অ্যাপ থেকে অথবা *247# ডায়াল করে Send Money অপশনে যান'),
                    const SizedBox(height: 12),
                    _buildInfoTile('রিসিভার নাম্বার', _receiverNumber, Icons.phone_android),
                    const SizedBox(height: 10),
                    _buildInfoTile('টাকার পরিমাণ', '১৯৯৳', null),
                    const SizedBox(height: 12),
                    _buildStepText('২. পেমেন্ট সম্পন্ন করার পর Transaction ID দিয়ে সাবমিট করুন'),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              const Text(
                'Transaction ID',
                style: TextStyle(
                  color: Colors.black87, 
                  fontSize: 14,                   fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _trxIdController,
                style: const TextStyle(color: Colors.black87, fontSize: 16),
                textCapitalization: TextCapitalization.characters,
                decoration: InputDecoration(
                  hintText: 'যেমন: TX1234ABC',
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  filled: true,
                  fillColor: Colors.grey[50],
                  prefixIcon: const Icon(Icons.confirmation_number, color: bkashPink),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: bkashPink, width: 2),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.red),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
              ),

              if (_errorText != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        _errorText!, 
                        style: const TextStyle(color: Colors.red, fontSize: 13),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 50,                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitTransaction,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: bkashPink,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 2,
                    shadowColor: bkashPink.withOpacity(0.4),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'পেমেন্ট করুন', 
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(width: 8),
                            Icon(Icons.arrow_forward, size: 18),
                          ],
                        ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.verified_user, size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      'নিরাপদ ও নিশ্চিত লেনদেন',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),      ),
    );
  }

  Widget _buildStepText(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 6),
          width: 6,
          height: 6,
          decoration: const BoxDecoration(color: bkashPink, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text, 
            style: TextStyle(color: Colors.grey[700], fontSize: 14, height: 1.5),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoTile(String label, String value, IconData? icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: bkashLightPink.withOpacity(0.3),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: bkashPink.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, color: bkashPink, size: 20),
            const SizedBox(width: 12),
          ] else ...[
            const SizedBox(width: 8),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label, 
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
                const SizedBox(height: 2),                Text(
                  value, 
                  style: const TextStyle(
                    color: Colors.black87, 
                    fontSize: 16, 
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Material(
            color: bkashPink.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () => _copyToClipboard(value, label),
              child: const Padding(
                padding: EdgeInsets.all(8.0),
                child: Icon(Icons.copy, color: bkashPink, size: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
