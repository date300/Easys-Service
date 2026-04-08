 import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import '../models/payment_method.dart';
// import '../widgets/payment_widgets.dart'; // প্রয়োজন না হলে কমেন্ট করে রাখতে পারেন

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
  
  // আপনার দেয়া প্রাপক নম্বর
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
        content: Text('$label কপি করা হয়েছে'),
        backgroundColor: const Color(0xFF87CEEB), // Sky Blue
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _submitTransaction() async {
    final trxId = _trxIdController.text.trim();
    
    if (trxId.isEmpty) {
      setState(() => _errorText = 'অনুগ্রহ করে Transaction ID দিন');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorText = null;
    });

    // এখানে আপনার সার্ভার বা API চেক করার কোড হবে
    await Future.delayed(const Duration(seconds: 2)); 

    setState(() => _isLoading = false);

    if (!mounted) return;
    
    // সফল হলে আগের পেজে ফিরে যাবে
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212), // Charcoal Black
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E1E),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context, null),
        ),
        title: Text(
          '${widget.method.name} Payment',
          style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // পেমেন্ট ইন্সট্রাকশন কার্ড
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF333333)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'পেমেন্ট করার নিয়মঃ',
                      style: TextStyle(color: Color(0xFFFFD700), fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    _buildStepText('১. bKash অ্যাপ বা *247# ডায়াল করে Send Money করুন।'),
                    const SizedBox(height: 15),
                    
                    // প্রাপক নম্বর রো
                    _buildInfoTile('প্রাপক নম্বরঃ', _receiverNumber, Icons.phone_android),
                    const SizedBox(height: 10),
                    
                    // টাকার পরিমাণ রো
                    _buildInfoTile('মোট টাকার পরিমাণঃ', '৳${widget.amount.toStringAsFixed(2)}', Icons.account_balance_wallet, valueColor: const Color(0xFFFFD700)),
                    
                    const SizedBox(height: 15),
                    _buildStepText('২. পিন দিয়ে পেমেন্ট সফল হওয়ার পর নিচের বক্সে Transaction ID দিন।'),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Transaction ID ইনপুট ফিল্ড
              const Text(
                'Transaction ID দিন',
                style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _trxIdController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'যেমন: TX1234ABC',
                  hintStyle: const TextStyle(color: Colors.white24),
                  filled: true,
                  fillColor: const Color(0xFF1E1E1E),
                  prefixIcon: const Icon(Icons.qr_code_scanner, color: Color(0xFF87CEEB)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF333333)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF87CEEB)),
                  ),
                ),
              ),

              // এরর মেসেজ (যদি থাকে)
              if (_errorText != null)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(_errorText!, style: const TextStyle(color: Colors.redAccent, fontSize: 13)),
                ),

              const SizedBox(height: 32),

              // সাবমিট বাটন
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitTransaction,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF87CEEB), // Sky Blue
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.black)
                      : const Text('Submit', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepText(String text) {
    return Text(text, style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.4));
  }

  Widget _buildInfoTile(String label, String value, IconData icon, {Color? valueColor}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF121212),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF87CEEB), size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: Colors.white38, fontSize: 11)),
                Text(value, style: TextStyle(color: valueColor ?? Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.copy, color: Colors.white54, size: 18),
            onPressed: () => _copyToClipboard(value, label),
          )
        ],
      ),
    );
  }
}

