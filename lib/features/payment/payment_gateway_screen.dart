import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';  // যোগ করুন
import 'models/payment_method.dart';
import 'widgets/payment_widgets.dart';

// Import Your Flows
import 'bkash/bkash_payment_flow.dart';
import 'nagad/nagad_payment_flow.dart';
import 'binance/binance_payment_flow.dart';

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
    this.onPaymentFailed
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
      available: true
    ),
    PaymentMethod(
      id: 'nagad', 
      name: 'Nagad', 
      subtitle: 'Digital Wallet', 
      logoAsset: 'assets/images/nagad.png', 
      primaryColor: Color(0xFFFF6600), 
      secondaryColor: Color(0xFFFFAA55), 
      available: true
    ),
    PaymentMethod(
      id: 'binance', 
      name: 'Binance Pay', 
      subtitle: 'Crypto Payment', 
      logoAsset: 'assets/images/binance.png', 
      primaryColor: Color(0xFFF0B90B), 
      secondaryColor: Color(0xFFFFDA6A), 
      available: true
    ),
  ];

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this, 
      duration: const Duration(milliseconds: 600)
    );
    _slideController = AnimationController(
      vsync: this, 
      duration: const Duration(milliseconds: 500)
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController, 
      curve: Curves.easeOut
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.08), 
      end: Offset.zero
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOut)
    );
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
          purpose: widget.purpose
        ); 
        break;
      case 'nagad': 
        flowScreen = NagadPaymentFlow(
          method: _selectedMethod!, 
          amount: widget.amount, 
          purpose: widget.purpose
        ); 
        break;
      case 'binance': 
        flowScreen = BinancePaymentFlow(
          method: _selectedMethod!, 
          amount: widget.amount, 
          purpose: widget.purpose
        ); 
        break;
      default: 
        return;
    }

    final result = await Navigator.push<bool>(
      context, 
      MaterialPageRoute(builder: (_) => flowScreen)
    );

    if (!mounted) return;
    if (result == true) {
      widget.onPaymentSuccess?.call();
      showDialog(
        context: context, 
        barrierDismissible: false, 
        builder: (_) => const PaymentResultDialog(success: true)
      );
    } else if (result == false) {
      widget.onPaymentFailed?.call();
      showDialog(
        context: context, 
        barrierDismissible: false, 
        builder: (_) => const PaymentResultDialog(success: false)
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // AppBar সরিয়ে দিয়েছি কারণ MainWrapper এর TopBar থাকবে
      // এর পরিবর্তে উপরে একটু স্পেস দিয়েছি যাতে স্ট্যাটাস বারের নিচে থেকে শুরু হয়
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: SafeArea(
            child: Column(
              children: [
                // উপরে এক্সট্রা স্পেস (কারণ MainWrapper এর TopBar আলাদা)
                const SizedBox(height: 8),
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
                        fontWeight: FontWeight.w500
                      )
                    )
                  )
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
                          : null
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 24), 
                  child: ProceedButton(
                    enabled: _selectedMethod != null, 
                    isLoading: _isProcessing, 
                    color: _selectedMethod?.primaryColor ?? const Color(0xFF6C63FF), 
                    onTap: _proceedToPayment
                  )
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
