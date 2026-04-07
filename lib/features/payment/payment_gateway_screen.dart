import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';   // তোমার প্রজেক্টে ^3.1.0 ইন্সটল করাই আছে, কোনো ইস্যু হবে না

// ============================================
//  Payment Method Model
// ============================================
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

// ============================================
//  Payment Gateway Screen
// ============================================
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
    _fadeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _slideController = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _fadeAnimation = CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero)
        .animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));
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

    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => _CustomPaymentFlowScreen(
          method: _selectedMethod!,
          amount: widget.amount,
          purpose: widget.purpose,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.black54, size: 24),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Payment',
          style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.w600, letterSpacing: 0.4),
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
                _AmountCard(amount: widget.amount, purpose: widget.purpose),
                const SizedBox(height: 28),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Select Payment Method',
                      style: TextStyle(color: Colors.black.withOpacity(0.55), fontSize: 13, fontWeight: FontWeight.w500, letterSpacing: 0.5),
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
                      final isSelected = _selectedMethod?.id == method.id;
                      return _PaymentMethodCard(
                        method: method,
                        isSelected: isSelected,
                        onTap: method.available ? () => setState(() => _selectedMethod = method) : null,
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                  child: _ProceedButton(
                    enabled: _selectedMethod != null,
                    isLoading: _isProcessing,
                    color: _selectedMethod?.primaryColor ?? const Color(0xFF6C63FF),
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

// ============================================
//  Amount Card - Lottie Wallet
// ============================================
class _AmountCard extends StatelessWidget {
  final double amount;
  final String purpose;
  const _AmountCard({required this.amount, required this.purpose});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF6C63FF), Color(0xFF9B8FFF)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: const Color(0xFF6C63FF).withOpacity(0.35), blurRadius: 20, offset: const Offset(0, 8))],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(purpose, style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500, letterSpacing: 0.3)),
                const SizedBox(height: 6),
                Text('৳ ${amount.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
              ],
            ),
          ),
          Lottie.asset(
            'assets/lottie/wallet.json',   // তোমার লটি ফাইলের নাম দিয়ে চেঞ্জ করে নিও
            width: 48,
            height: 48,
            fit: BoxFit.contain,
            repeat: true,
          ),
        ],
      ),
    );
  }
}

// ============================================
//  Payment Method Card - লক + Lottie Lock
// ============================================
class _PaymentMethodCard extends StatelessWidget {
  final PaymentMethod method;
  final bool isSelected;
  final VoidCallback? onTap;
  const _PaymentMethodCard({required this.method, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final bool isAvailable = method.available;
    final Color textColor = isAvailable ? (isSelected ? method.primaryColor : Colors.black) : Colors.grey[500]!;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: isAvailable ? (isSelected ? method.primaryColor.withOpacity(0.07) : Colors.white) : Colors.grey[50],
          border: Border.all(color: isAvailable ? (isSelected ? method.primaryColor : const Color(0xFFEEEEEE)) : Colors.grey[300]!, width: isSelected && isAvailable ? 2 : 1.2),
          borderRadius: BorderRadius.circular(16),
          boxShadow: isSelected && isAvailable
              ? [BoxShadow(color: method.primaryColor.withOpacity(0.12), blurRadius: 16, offset: const Offset(0, 4))]
              : [const BoxShadow(color: Color(0x0A000000), blurRadius: 8, offset: Offset(0, 2))],
        ),
        child: Row(
          children: [
            Opacity(
              opacity: isAvailable ? 1.0 : 0.6,
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(color: method.primaryColor.withOpacity(isAvailable ? 0.12 : 0.06), borderRadius: BorderRadius.circular(12)),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(method.logoAsset, fit: BoxFit.contain),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(method.name, style: TextStyle(color: textColor, fontSize: 15, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 2),
                  Text(method.subtitle + (isAvailable ? '' : ' • Locked'), style: TextStyle(color: isAvailable ? Colors.black45 : Colors.grey[400], fontSize: 12, fontWeight: FontWeight.w400)),
                ],
              ),
            ),
            if (!isAvailable)
              Lottie.asset(
                'assets/lottie/lock.json',   // তোমার লক অ্যানিমেশন ফাইল
                width: 28,
                height: 28,
                repeat: true,
              )
            else
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: 22,
                height: 22,
                decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: isSelected ? method.primaryColor : Colors.black26, width: 2), color: isSelected ? method.primaryColor : Colors.transparent),
                child: isSelected ? const Icon(Icons.check_rounded, color: Colors.white, size: 13) : null,
              ),
          ],
        ),
      ),
    );
  }
}

// ============================================
//  Proceed Button
// ============================================
class _ProceedButton extends StatelessWidget {
  final bool enabled;
  final bool isLoading;
  final Color color;
  final VoidCallback onTap;
  const _ProceedButton({required this.enabled, required this.isLoading, required this.color, required this.onTap});

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
            gradient: enabled ? LinearGradient(colors: [color, color.withOpacity(0.75)], begin: Alignment.centerLeft, end: Alignment.centerRight) : const LinearGradient(colors: [Color(0xFFDDDDDD), Color(0xFFDDDDDD)]),
            borderRadius: BorderRadius.circular(16),
            boxShadow: enabled ? [BoxShadow(color: color.withOpacity(0.35), blurRadius: 20, offset: const Offset(0, 8))] : [],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: enabled && !isLoading ? onTap : null,
              borderRadius: BorderRadius.circular(16),
              child: Center(
                child: isLoading
                    ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                    : const Text('Proceed to Payment', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================
//  Custom Payment Flow Screen
// ============================================
enum _PaymentStep { enterNumber, enterOtp, enterPin }

class _CustomPaymentFlowScreen extends StatefulWidget {
  final PaymentMethod method;
  final double amount;
  final String purpose;
  const _CustomPaymentFlowScreen({required this.method, required this.amount, required this.purpose});

  @override
  State<_CustomPaymentFlowScreen> createState() => _CustomPaymentFlowScreenState();
}

class _CustomPaymentFlowScreenState extends State<_CustomPaymentFlowScreen> with SingleTickerProviderStateMixin {
  _PaymentStep _step = _PaymentStep.enterNumber;

  final _numberController = TextEditingController();
  final _otpController = TextEditingController();
  final _pinController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePin = true;
  String? _errorText;
  int _otpResendSeconds = 60;
  Timer? _otpTimer;

  late AnimationController _stepAnimController;
  late Animation<Offset> _stepSlide;

  bool get _isBinance => widget.method.id == 'binance';
  String get _numberLabel => _isBinance ? 'Binance ID / Email' : 'Mobile Number';
  String get _numberHint => _isBinance ? 'Enter your Binance email' : '01XXXXXXXXX';

  @override
  void initState() {
    super.initState();
    _stepAnimController = AnimationController(vsync: this, duration: const Duration(milliseconds: 350));
    _stepSlide = Tween<Offset>(begin: const Offset(0.06, 0), end: Offset.zero).animate(CurvedAnimation(parent: _stepAnimController, curve: Curves.easeOut));
    _stepAnimController.forward();
  }

  @override
  void dispose() {
    _numberController.dispose();
    _otpController.dispose();
    _pinController.dispose();
    _otpTimer?.cancel();
    _stepAnimController.dispose();
    super.dispose();
  }

  void _goToStep(_PaymentStep step) {
    setState(() {
      _step = step;
      _errorText = null;
    });
    _stepAnimController.forward(from: 0);
  }

  void _startOtpTimer() {
    _otpTimer?.cancel();
    setState(() => _otpResendSeconds = 60);
    _otpTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_otpResendSeconds <= 1) {
        t.cancel();
        setState(() => _otpResendSeconds = 0);
      } else {
        setState(() => _otpResendSeconds--);
      }
    });
  }

  Future<void> _sendOtp() async {
    final number = _numberController.text.trim();
    if (number.isEmpty) {
      setState(() => _errorText = 'Please enter your $_numberLabel');
      return;
    }
    if (!_isBinance && number.length < 11) {
      setState(() => _errorText = 'Enter a valid 11-digit mobile number');
      return;
    }
    setState(() { _isLoading = true; _errorText = null; });
    await Future.delayed(const Duration(seconds: 1));
    setState(() => _isLoading = false);
    if (!mounted) return;
    _startOtpTimer();
    _goToStep(_PaymentStep.enterOtp);
  }

  Future<void> _verifyOtp() async {
    final otp = _otpController.text.trim();
    if (otp.length < 6) {
      setState(() => _errorText = 'Please enter the 6-digit OTP');
      return;
    }
    setState(() { _isLoading = true; _errorText = null; });
    await Future.delayed(const Duration(seconds: 1));
    setState(() => _isLoading = false);
    if (!mounted) return;
    _goToStep(_PaymentStep.enterPin);
  }

  Future<void> _confirmPayment() async {
    final pinLength = _isBinance ? 6 : 5;
    final pinValue = _pinController.text.trim();
    if (pinValue.length < pinLength) {
      setState(() => _errorText = 'Please enter your $pinLength-digit PIN');
      return;
    }
    setState(() { _isLoading = true; _errorText = null; });
    await Future.delayed(const Duration(seconds: 1));
    setState(() => _isLoading = false);
    if (!mounted) return;
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.black54, size: 24),
          onPressed: () {
            if (_step == _PaymentStep.enterNumber) {
              Navigator.pop(context, null);
            } else if (_step == _PaymentStep.enterOtp) {
              _goToStep(_PaymentStep.enterNumber);
            } else {
              _goToStep(_PaymentStep.enterOtp);
            }
          },
        ),
        title: Text('${widget.method.name} Payment', style: const TextStyle(color: Colors.black, fontSize: 17, fontWeight: FontWeight.w600)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: SlideTransition(
            position: _stepSlide,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _StepIndicator(current: _step.index, color: widget.method.primaryColor),
                const SizedBox(height: 28),
                _PaymentSummaryHeader(method: widget.method, amount: widget.amount),
                const SizedBox(height: 32),

                if (_step == _PaymentStep.enterNumber) _buildNumberStep()
                else if (_step == _PaymentStep.enterOtp) _buildOtpStep()
                else _buildPinStep(),

                if (_errorText != null) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Lottie.asset('assets/lottie/error.json', width: 22, height: 22, repeat: true),  // তোমার error লটি
                      const SizedBox(width: 6),
                      Expanded(child: Text(_errorText!, style: const TextStyle(color: Colors.red, fontSize: 13))),
                    ],
                  ),
                ],

                const SizedBox(height: 28),
                _ProceedButton(
                  enabled: !_isLoading,
                  isLoading: _isLoading,
                  color: widget.method.primaryColor,
                  onTap: _step == _PaymentStep.enterNumber ? _sendOtp : _step == _PaymentStep.enterOtp ? _verifyOtp : _confirmPayment,
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNumberStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Enter your $_numberLabel', style: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        Text(_isBinance ? 'We will send an OTP to your registered email.' : 'We will send an OTP to this number.', style: TextStyle(color: Colors.black.withOpacity(0.5), fontSize: 13, height: 1.4)),
        const SizedBox(height: 20),
        _PaymentTextField(
          controller: _numberController,
          hint: _numberHint,
          label: _numberLabel,
          keyboardType: _isBinance ? TextInputType.emailAddress : TextInputType.phone,
          inputFormatters: _isBinance ? [] : [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(11)],
          prefixIcon: _isBinance ? Icons.alternate_email_rounded : Icons.phone_android_rounded,
          accentColor: widget.method.primaryColor,
        ),
      ],
    );
  }

  Widget _buildOtpStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Enter OTP', style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        Text('A 6-digit OTP has been sent to ${_numberController.text.trim()}', style: TextStyle(color: Colors.black.withOpacity(0.5), fontSize: 13, height: 1.4)),
        const SizedBox(height: 20),
        _OtpInputRow(controller: _otpController, accentColor: widget.method.primaryColor),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            if (_otpResendSeconds > 0)
              Text('Resend in ${_otpResendSeconds}s', style: TextStyle(color: Colors.black.withOpacity(0.4), fontSize: 12))
            else
              GestureDetector(
                onTap: _startOtpTimer,
                child: Text('Resend OTP', style: TextStyle(color: widget.method.primaryColor, fontSize: 13, fontWeight: FontWeight.w600)),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildPinStep() {
    final pinLength = _isBinance ? 6 : 5;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Enter your ${widget.method.name} PIN', style: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        Text('Enter your $pinLength-digit secret PIN to confirm the payment.', style: TextStyle(color: Colors.black.withOpacity(0.5), fontSize: 13, height: 1.4)),
        const SizedBox(height: 20),
        _PaymentTextField(
          controller: _pinController,
          hint: '?' * pinLength,
          label: 'PIN',
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(pinLength)],
          prefixIcon: Icons.lock_outline_rounded,
          accentColor: widget.method.primaryColor,
          obscureText: _obscurePin,
          suffixIcon: IconButton(
            icon: Icon(_obscurePin ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: Colors.black45, size: 20),
            onPressed: () => setState(() => _obscurePin = !_obscurePin),
          ),
        ),
      ],
    );
  }
}

// Step Indicator, Summary Header, TextField, OTP Row — আগের মতোই (কোনো পরিবর্তন হয়নি)
class _StepIndicator extends StatelessWidget {
  final int current;
  final Color color;
  const _StepIndicator({required this.current, required this.color});

  @override
  Widget build(BuildContext context) {
    final labels = ['Number', 'OTP', 'PIN'];
    return Row(
      children: List.generate(3, (i) {
        final isDone = i < current;
        final isActive = i == current;
        return Expanded(
          child: Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      height: 4,
                      decoration: BoxDecoration(color: isDone || isActive ? color : const Color(0xFFEEEEEE), borderRadius: BorderRadius.circular(4)),
                    ),
                    const SizedBox(height: 6),
                    Text(labels[i], style: TextStyle(fontSize: 11, fontWeight: isActive ? FontWeight.w700 : FontWeight.w400, color: isActive ? color : isDone ? Colors.black45 : Colors.black26)),
                  ],
                ),
              ),
              if (i < 2) const SizedBox(width: 8),
            ],
          ),
        );
      }),
    );
  }
}

class _PaymentSummaryHeader extends StatelessWidget {
  final PaymentMethod method;
  final double amount;
  const _PaymentSummaryHeader({required this.method, required this.amount});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: method.primaryColor.withOpacity(0.07), borderRadius: BorderRadius.circular(16), border: Border.all(color: method.primaryColor.withOpacity(0.2), width: 1)),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(color: method.primaryColor.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
            child: ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.asset(method.logoAsset, fit: BoxFit.contain)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(method.name, style: TextStyle(color: method.primaryColor, fontSize: 14, fontWeight: FontWeight.w700)),
                Text(method.subtitle, style: const TextStyle(color: Colors.black45, fontSize: 12)),
              ],
            ),
          ),
          Text('৳ ${amount.toStringAsFixed(2)}', style: const TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}

class _PaymentTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final String label;
  final TextInputType keyboardType;
  final List<TextInputFormatter> inputFormatters;
  final IconData prefixIcon;
  final Color accentColor;
  final bool obscureText;
  final Widget? suffixIcon;

  const _PaymentTextField({
    required this.controller,
    required this.hint,
    required this.label,
    required this.keyboardType,
    required this.inputFormatters,
    required this.prefixIcon,
    required this.accentColor,
    this.obscureText = false,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      obscureText: obscureText,
      style: const TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        hintText: hint,
        labelText: label,
        hintStyle: TextStyle(color: Colors.black.withOpacity(0.3), fontSize: 14),
        labelStyle: TextStyle(color: accentColor.withOpacity(0.8)),
        prefixIcon: Icon(prefixIcon, color: accentColor, size: 20),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: accentColor.withOpacity(0.04),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: accentColor.withOpacity(0.25), width: 1.2)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: accentColor, width: 1.8)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }
}

class _OtpInputRow extends StatefulWidget {
  final TextEditingController controller;
  final Color accentColor;
  const _OtpInputRow({required this.controller, required this.accentColor});

  @override
  State<_OtpInputRow> createState() => _OtpInputRowState();
}

class _OtpInputRowState extends State<_OtpInputRow> {
  final List<TextEditingController> _controllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  @override
  void dispose() {
    for (final c in _controllers) c.dispose();
    for (final f in _focusNodes) f.dispose();
    super.dispose();
  }

  void _onChanged(String value, int index) {
    if (value.isNotEmpty && index < 5) _focusNodes[index + 1].requestFocus();
    if (value.isEmpty && index > 0) _focusNodes[index - 1].requestFocus();
    widget.controller.text = _controllers.map((c) => c.text).join();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(6, (i) {
        return SizedBox(
          width: 44,
          height: 52,
          child: TextField(
            controller: _controllers[i],
            focusNode: _focusNodes[i],
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(1)],
            style: TextStyle(color: widget.accentColor, fontSize: 20, fontWeight: FontWeight.w700),
            decoration: InputDecoration(
              filled: true,
              fillColor: widget.accentColor.withOpacity(0.06),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: widget.accentColor.withOpacity(0.25), width: 1.2)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: widget.accentColor, width: 2)),
              contentPadding: EdgeInsets.zero,
            ),
            onChanged: (v) => _onChanged(v, i),
          ),
        );
      }),
    );
  }
}

// ============================================
//  Payment Result Dialog - Lottie Success/Failed
// ============================================
class _PaymentResultDialog extends StatelessWidget {
  final bool success;
  const _PaymentResultDialog({required this.success});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Lottie.asset(
              success ? 'assets/lottie/payment_success.json' : 'assets/lottie/payment_failed.json',
              width: 110,
              height: 110,
              repeat: false,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 20),
            Text(success ? 'Payment Successful!' : 'Payment Failed', style: const TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text(
              success ? 'Your payment has been completed successfully.' : 'Something went wrong. Please try again.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.black54, fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: success ? const Color(0xFF22C55E) : const Color(0xFF6C63FF), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), elevation: 0),
                onPressed: () {
                  Navigator.pop(context);
                  if (success) Navigator.pop(context);
                },
                child: Text(success ? 'Done' : 'Try Again', style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
