import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';

// ─────────────────────────────────────────────
//  Payment Method Model
// ─────────────────────────────────────────────
class PaymentMethod {
  final String id;
  final String name;
  final String subtitle;
  final String logoAsset; // e.g. 'assets/images/bkash.png'
  final Color primaryColor;
  final Color secondaryColor;
  final String url; // Your backend payment initiation URL

  const PaymentMethod({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.logoAsset,
    required this.primaryColor,
    required this.secondaryColor,
    required this.url,
  });
}

// ─────────────────────────────────────────────
//  Payment Gateway Screen
// ─────────────────────────────────────────────
class PaymentGatewayScreen extends StatefulWidget {
  /// Amount to be paid (in BDT or USD for Binance)
  final double amount;

  /// Purpose label shown on screen
  final String purpose;

  /// Called when payment is confirmed successful
  final VoidCallback? onPaymentSuccess;

  /// Called when payment fails or is cancelled
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

  // ── Replace URLs with your real backend endpoints ──
  final List<PaymentMethod> _methods = const [
    PaymentMethod(
      id: 'bkash',
      name: 'bKash',
      subtitle: 'মোবাইল ব্যাংকিং',
      logoAsset: 'assets/images/bkash.png',
      primaryColor: Color(0xFFE2136E),
      secondaryColor: Color(0xFFFF6DAE),
      url: 'https://yourbackend.com/payment/bkash/init',
    ),
    PaymentMethod(
      id: 'nagad',
      name: 'Nagad',
      subtitle: 'ডিজিটাল ওয়ালেট',
      logoAsset: 'assets/images/nagad.png',
      primaryColor: Color(0xFFFF6600),
      secondaryColor: Color(0xFFFFAA55),
      url: 'https://yourbackend.com/payment/nagad/init',
    ),
    PaymentMethod(
      id: 'binance',
      name: 'Binance Pay',
      subtitle: 'Crypto Payment',
      logoAsset: 'assets/images/binance.png',
      primaryColor: Color(0xFFF0B90B),
      secondaryColor: Color(0xFFFFDA6A),
      url: 'https://yourbackend.com/payment/binance/init',
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

  // ─────────────────────────────────────────────
  //  Open WebView for selected payment
  // ─────────────────────────────────────────────
  Future<void> _proceedToPayment() async {
    if (_selectedMethod == null) return;

    setState(() => _isProcessing = true);

    // Build the payment URL with amount param
    final uri = Uri.parse(_selectedMethod!.url).replace(
      queryParameters: {
        'amount': widget.amount.toStringAsFixed(2),
        'purpose': widget.purpose,
      },
    );

    setState(() => _isProcessing = false);

    if (!mounted) return;

    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => _PaymentWebViewScreen(
          url: uri.toString(),
          methodName: _selectedMethod!.name,
          primaryColor: _selectedMethod!.primaryColor,
          // Define your success/failure redirect URLs to match below
          successUrlPattern: 'yourbackend.com/payment/success',
          failureUrlPattern: 'yourbackend.com/payment/fail',
        ),
      ),
    );

    if (!mounted) return;

    if (result == true) {
      widget.onPaymentSuccess?.call();
      _showResultDialog(success: true);
    } else if (result == false) {
      widget.onPaymentFailed?.call();
      _showResultDialog(success: false);
    }
  }

  void _showResultDialog({required bool success}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _PaymentResultDialog(success: success),
    );
  }

  // ─────────────────────────────────────────────
  //  Build
  // ─────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F14),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.white70, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Payment',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.4,
          ),
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
                // ── Amount Card ──
                _AmountCard(
                  amount: widget.amount,
                  purpose: widget.purpose,
                ),

                const SizedBox(height: 28),

                // ── Section Label ──
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'পেমেন্ট মাধ্যম বেছে নিন',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.55),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                // ── Payment Method Cards ──
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    itemCount: _methods.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 14),
                    itemBuilder: (context, index) {
                      final method = _methods[index];
                      final isSelected = _selectedMethod?.id == method.id;
                      return _PaymentMethodCard(
                        method: method,
                        isSelected: isSelected,
                        onTap: () =>
                            setState(() => _selectedMethod = method),
                      );
                    },
                  ),
                ),

                // ── Proceed Button ──
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                  child: _ProceedButton(
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

// ─────────────────────────────────────────────
//  Amount Card Widget
// ─────────────────────────────────────────────
class _AmountCard extends StatelessWidget {
  final double amount;
  final String purpose;

  const _AmountCard({required this.amount, required this.purpose});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E1E2E), Color(0xFF16162A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.08),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFF6C63FF).withOpacity(0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.receipt_long_rounded,
              color: Color(0xFF6C63FF),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  purpose,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '৳ ${amount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFF22C55E).withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'Secure',
              style: TextStyle(
                color: Color(0xFF22C55E),
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Payment Method Card Widget
// ─────────────────────────────────────────────
class _PaymentMethodCard extends StatelessWidget {
  final PaymentMethod method;
  final bool isSelected;
  final VoidCallback onTap;

  const _PaymentMethodCard({
    required this.method,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: isSelected
            ? method.primaryColor.withOpacity(0.12)
            : const Color(0xFF1A1A26),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isSelected
              ? method.primaryColor.withOpacity(0.7)
              : Colors.white.withOpacity(0.07),
          width: isSelected ? 1.8 : 1,
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: method.primaryColor.withOpacity(0.18),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                )
              ]
            : [],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            child: Row(
              children: [
                // Logo placeholder (replace with Image.asset)
                _MethodLogo(method: method),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        method.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        method.subtitle,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.45),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected
                        ? method.primaryColor
                        : Colors.transparent,
                    border: Border.all(
                      color: isSelected
                          ? method.primaryColor
                          : Colors.white.withOpacity(0.25),
                      width: 2,
                    ),
                  ),
                  child: isSelected
                      ? const Icon(Icons.check,
                          color: Colors.white, size: 13)
                      : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Method Logo (Icon fallback, replace with Image.asset)
// ─────────────────────────────────────────────
class _MethodLogo extends StatelessWidget {
  final PaymentMethod method;
  const _MethodLogo({required this.method});

  IconData get _icon {
    switch (method.id) {
      case 'bkash':
        return Icons.phone_android_rounded;
      case 'nagad':
        return Icons.account_balance_wallet_rounded;
      case 'binance':
        return Icons.currency_bitcoin_rounded;
      default:
        return Icons.payment_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [method.primaryColor, method.secondaryColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      // Swap the Icon below with Image.asset(method.logoAsset) once you
      // add the real logos to assets/images/
      child: Icon(_icon, color: Colors.white, size: 26),
    );
  }
}

// ─────────────────────────────────────────────
//  Proceed Button
// ─────────────────────────────────────────────
class _ProceedButton extends StatelessWidget {
  final bool enabled;
  final bool isLoading;
  final Color color;
  final VoidCallback onTap;

  const _ProceedButton({
    required this.enabled,
    required this.isLoading,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: enabled ? 1.0 : 0.4,
      duration: const Duration(milliseconds: 250),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: enabled
                ? LinearGradient(
                    colors: [color, color.withOpacity(0.75)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  )
                : const LinearGradient(
                    colors: [Color(0xFF2A2A3A), Color(0xFF2A2A3A)]),
            borderRadius: BorderRadius.circular(16),
            boxShadow: enabled
                ? [
                    BoxShadow(
                      color: color.withOpacity(0.35),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    )
                  ]
                : [],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: enabled && !isLoading ? onTap : null,
              borderRadius: BorderRadius.circular(16),
              child: Center(
                child: isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : const Text(
                        'পেমেন্ট করুন →',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  WebView Screen
// ─────────────────────────────────────────────
class _PaymentWebViewScreen extends StatefulWidget {
  final String url;
  final String methodName;
  final Color primaryColor;
  final String successUrlPattern;
  final String failureUrlPattern;

  const _PaymentWebViewScreen({
    required this.url,
    required this.methodName,
    required this.primaryColor,
    required this.successUrlPattern,
    required this.failureUrlPattern,
  });

  @override
  State<_PaymentWebViewScreen> createState() => _PaymentWebViewScreenState();
}

class _PaymentWebViewScreenState extends State<_PaymentWebViewScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  int _loadingProgress = 0;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) => setState(() => _isLoading = true),
          onPageFinished: (_) => setState(() {
            _isLoading = false;
            _loadingProgress = 100;
          }),
          onProgress: (progress) =>
              setState(() => _loadingProgress = progress),
          onNavigationRequest: (request) {
            final url = request.url.toLowerCase();

            if (url.contains(widget.successUrlPattern.toLowerCase())) {
              Navigator.pop(context, true); // success
              return NavigationDecision.prevent;
            }
            if (url.contains(widget.failureUrlPattern.toLowerCase())) {
              Navigator.pop(context, false); // failed
              return NavigationDecision.prevent
