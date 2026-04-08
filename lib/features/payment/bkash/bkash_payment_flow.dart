import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import '../models/payment_method.dart';

class BkashPaymentFlow extends StatefulWidget {
  final PaymentMethod method;
  final double amount;
  final String purpose;

  const BkashPaymentFlow({
    super.key, 
    required this.method, 
    required this.amount, 
    required this.purpose
  });

  @override
  State<BkashPaymentFlow> createState() => _BkashPaymentFlowState();
}

class _BkashPaymentFlowState extends State<BkashPaymentFlow> with SingleTickerProviderStateMixin {
  final _trxIdController = TextEditingController();
  bool _isLoading = false;
  String? _errorText;
  
  // bKash Brand Color
  static const Color bkashPink = Color(0xFFE2136E);
  static const Color bkashLightPink = Color(0xFFFCE4EC);
  final String _receiverNumber = '01576584250';

  @override
  void dispose() {
    _trxIdController.dispose();
    super.dispose();
  }

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label কপি হয়েছে'),
        backgroundColor: bkashPink,
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Future<void> _submitTransaction() async {
    final trxId = _trxIdController.text.trim();
    
    if (trxId.isEmpty) {
      setState(() => _errorText = 'দয়া করে Transaction ID দিন');
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
      backgroundColor: Colors.white, // White Background
      appBar: AppBar(
        backgroundColor: bkashPink, // bKash Pink
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context, null),
        ),
        title: Text(
          '${widget.method.name} Payment',
          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // bKash Style Instructions Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: bkashPink.withOpacity(0.3)),
                  boxShadow: [
                    BoxShadow(
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
                          'পেমেন্ট নির্দেশনা',
                          style: TextStyle(
                            color: bkashPink, 
                            fontSize: 16, 
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildStepText('১. bKash অ্যাপে যান বা *247# ডায়াল করুন এবং Send Money সিলেক্ট করুন'),
                    const SizedBox(height: 12),
                    
                    // Receiver Number Tile
                    _buildInfoTile('প্রাপক নম্বর', _receiverNumber, Icons.phone_android),
                    const SizedBox(height: 10),
                    
                    // Amount Tile
                    _buildInfoTile('টাকার পরিমাণ', '৳${widget.amount.toStringAsFixed(2)}', Icons.account_balance_wallet),
                    
                    const SizedBox(height: 12),
                    _buildStepText('২. পেমেন্ট সম্পন্ন হলে Transaction ID নিচে বসান'),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Transaction ID Input Section
              const Text(
                'Transaction ID',
                style: TextStyle(
                  color: Colors.black87, 
                  fontSize: 14, 
                  fontWeight: FontWeight.w600,
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

              // Error Text
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

              // Submit Button (bKash Style)
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitTransaction,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: bkashPink, // bKash Pink
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
                              'কনফার্ম করুন', 
                              style: TextStyle(
                                fontSize: 16, 
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(width: 8),
                            Icon(Icons.arrow_forward, size: 18),
                          ],
                        ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Security Note
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.verified_user, size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      'নিরাপদ পেমেন্ট গ্যারান্টি',
                      style: TextStyle(
                        color: Colors.grey[600], 
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
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
          decoration: const BoxDecoration(
            color: bkashPink,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text, 
            style: TextStyle(
              color: Colors.grey[700], 
              fontSize: 14, 
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoTile(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: bkashLightPink.withOpacity(0.3),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: bkashPink.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Icon(icon, color: bkashPink, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label, 
                  style: TextStyle(
                    color: Colors.grey[600], 
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
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
