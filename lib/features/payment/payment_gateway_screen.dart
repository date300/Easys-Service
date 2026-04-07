import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';

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

  const PaymentMethod({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.logoAsset,
    required this.primaryColor,
    required this.secondaryColor,
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
    ),
    PaymentMethod(
      id: 'nagad',
      name: 'Nagad',
      subtitle: 'Digital Wallet',
      logoAsset: 'assets/images/nagad.png',
      primaryColor: Color(0xFFFF6600),
      secondaryColor: Color(0xFFFFAA55),
    ),
    PaymentMethod(
      id: 'binance',
      name: 'Binance Pay',
      subtitle: 'Crypto Payment',
      logoAsset: 'assets/images/binance.png',
      primaryColor: Color(0xFFF0B90B),
      secondaryColor: Color(0xFFFFDA6A),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _slideController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _fadeAnimation =
        CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(
        CurvedAnimation(parent: _slideController, curve: Curves.easeOut));
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
    await Future.delayed(const Duration(milliseconds: 400)); // mock delay
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
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.black54, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Payment',
          style: TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.4),
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
                      style: TextStyle(
                          color: Colors.black.withOpacity(0.55),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.5),
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
                        onTap: () => setState(() => _selectedMethod = method),
                      );
                    },
                  ),
                ),
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

// ============================================
//  Custom Payment Flow Screen
//  Step 1: Enter number/ID
//  Step 2: Enter OTP
//  Step 3: Enter PIN / Confirm
// ============================================
enum _PaymentStep { enterNumber, enterOtp, enterPin }

class _CustomPaymentFlowScreen extends StatefulWidget {
  final PaymentMethod method;
  final double amount;
  final String purpose;

  const _CustomPaymentFlowScreen({
    required this.method,
    required this.amount,
    required this.purpose,
  });

  @override
  State<_CustomPaymentFlowScreen> createState() =>
      _CustomPaymentFlowScreenState();
}

class _CustomPaymentFlowScreenState extends State<_CustomPaymentFlowScreen>
    with SingleTickerProviderStateMixin {
  _PaymentStep _step = _PaymentStep.enterNumber;
  final _numberController = TextEditingController();
  final _otpController = TextEditingController();
  final _pinController = TextEditingController();
  bool _isLoading = false;
  String? _errorText;
  int _otpResendSeconds = 30;
  bool _obscurePin = true;

  late AnimationController _stepAnimController;
  late Animation<Offset> _stepSlide;

  @override
  void initState() {
    super.initState();
    _stepAnimController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 350));
    _stepSlide = Tween<Offset>(
      begin: const Offset(0.12, 0),
      end: Offset.zero,
    ).animate(
        CurvedAnimation(parent: _stepAnimController, curve: Curves.easeOut));
    _stepAnimController.forward();
  }

  @override
  void dispose() {
    _numberController.dispose();
    _otpController.dispose();
    _pinController.dispose();
    _stepAnimController.dispose();
    super.dispose();
  }

  void _goToStep(_PaymentStep next) {
    setState(() {
      _step = next;
      _errorText = null;
    });
    _stepAnimController.forward(from: 0);
    if (next == _PaymentStep.enterOtp) _startOtpTimer();
  }

  void _startOtpTimer() async {
    _otpResendSeconds = 30;
    while (_otpResendSeconds > 0) {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return;
      setState(() => _otpResendSeconds--);
    }
  }

  bool get _isBinance => widget.method.id == 'binance';

  String get _numberLabel =>
      _isBinance ? 'Binance Email / Pay ID' : 'Mobile Number';

  String get _numberHint =>
      _isBinance ? 'example@email.com' : '01XXXXXXXXX';

  // --------------------------------------------------
  //  Step 1: Send OTP request to your backend
  // --------------------------------------------------
  Future<void> _sendOtp() async {
    if (_numberController.text.trim().isEmpty) {
      setState(() => _errorText = 'Please enter your $_numberLabel');
      return;
    }
    setState(() {
      _isLoading = true;
      _errorText = null;
    });

    // TODO: Replace with your real API call
    // Example:
    // final response = await http.post(
    //   Uri.parse('https://yourbackend.com/payment/${widget.method.id}/send-otp'),
    //   body: {'number': _numberController.text.trim(), 'amount': widget.amount.toString()},
    // );
    // if (response.statusCode != 200) { setState(() => _errorText = 'Failed to send OTP'); return; }

    await Future.delayed(const Duration(seconds: 1)); // mock delay

    setState(() => _isLoading = false);
    _goToStep(_PaymentStep.enterOtp);
  }

  // --------------------------------------------------
  //  Step 2: Verify OTP with your backend
  // --------------------------------------------------
  Future<void> _verifyOtp() async {
    if (_otpController.text.trim().length < 4) {
      setState(() => _errorText = 'Enter the OTP you received');
      return;
    }
    setState(() {
      _isLoading = true;
      _errorText = null;
    });

    // TODO: Replace with your real API call
    // Example:
    // final response = await http.post(
    //   Uri.parse('https://yourbackend.com/payment/${widget.method.id}/verify-otp'),
    //   body: {'otp': _otpController.text.trim(), 'number': _numberController.text.trim()},
    // );
    // if (response.statusCode != 200) { setState(() => _errorText = 'Invalid OTP'); return; }

    await Future.delayed(const Duration(seconds: 1)); // mock delay

    setState(() => _isLoading = false);
    _goToStep(_PaymentStep.enterPin);
  }

  // --------------------------------------------------
  //  Step 3: Confirm payment with PIN via your backend
  // --------------------------------------------------
  Future<void> _confirmPayment() async {
    final pinValue = _pinController.text.trim();
    if (pinValue.length < (_isBinance ? 6 : 5)) {
      setState(() => _errorText =
          _isBinance ? 'Enter your 6-digit PIN' : 'Enter your 5-digit PIN');
      return;
    }
    setState(() {
      _isLoading = true;
      _errorText = null;
    });

    // TODO: Replace with your real API call
    // Example:
    // final response = await http.post(
    //   Uri.parse('https://yourbackend.com/payment/${widget.method.id}/confirm'),
    //   body: {
    //     'number': _numberController.text.trim(),
    //     'pin': pinValue,
    //     'amount': widget.amount.toString(),
    //     'purpose': widget.purpose,
    //   },
    // );
    // final success = response.statusCode == 200;
    // Navigator.pop(context, success);
    // return;

    await Future.delayed(const Duration(seconds: 1)); // mock delay

    setState(() => _isLoading = false);
    if (!mounted) return;
    Navigator.pop(context, true); // mock success
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
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.black54, size: 20),
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
        title: Text(
          '${widget.method.name} Payment',
          style: const TextStyle(
              color: Colors.black, fontSize: 17, fontWeight: FontWeight.w600),
        ),
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
                // Step indicator
                _StepIndicator(
                  current: _step.index,
                  color: widget.method.primaryColor,
                ),
                const SizedBox(height: 28),

                // Method logo + amount summary
                _PaymentSummaryHeader(
                    method: widget.method, amount: widget.amount),
                const SizedBox(height: 32),

                // Step content
                if (_step == _PaymentStep.enterNumber)
                  _buildNumberStep()
                else if (_step == _PaymentStep.enterOtp)
                  _buildOtpStep()
                else
                  _buildPinStep(),

                if (_errorText != null) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.error_outline,
                          color: Colors.red, size: 15),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          _errorText!,
                          style:
                              const TextStyle(color: Colors.red, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: 28),
                _ProceedButton(
                  enabled: !_isLoading,
                  isLoading: _isLoading,
                  color: widget.method.primaryColor,
                  onTap: _step == _PaymentStep.enterNumber
                      ? _sendOtp
                      : _step == _PaymentStep.enterOtp
                          ? _verifyOtp
                          : _confirmPayment,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --------------------------------------------------
  //  Step 1 UI: Enter mobile number / Binance ID
  // --------------------------------------------------
  Widget _buildNumberStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Enter your $_numberLabel',
          style: const TextStyle(
              color: Colors.black, fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 6),
        Text(
          _isBinance
              ? 'We will send an OTP to your registered email.'
              : 'We will send an OTP to this number.',
          style: TextStyle(
              color: Colors.black.withOpacity(0.5), fontSize: 13, height: 1.4),
        ),
        const SizedBox(height: 20),
        _PaymentTextField(
          controller: _numberController,
          hint: _numberHint,
          label: _numberLabel,
          keyboardType: _isBinance
              ? TextInputType.emailAddress
              : TextInputType.phone,
          inputFormatters: _isBinance
              ? []
              : [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(11),
                ],
          prefixIcon: _isBinance
              ? Icons.alternate_email_rounded
              : Icons.phone_android_rounded,
          accentColor: widget.method.primaryColor,
        ),
      ],
    );
  }

  // --------------------------------------------------
  //  Step 2 UI: Enter OTP
  // --------------------------------------------------
  Widget _buildOtpStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Enter OTP',
          style: TextStyle(
              color: Colors.black, fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 6),
        Text(
          'A 6-digit OTP has been sent to ${_numberController.text.trim()}',
          style: TextStyle(
              color: Colors.black.withOpacity(0.5), fontSize: 13, height: 1.4),
        ),
        const SizedBox(height: 20),
        _OtpInputRow(
          controller: _otpController,
          accentColor: widget.method.primaryColor,
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            if (_otpResendSeconds > 0)
              Text(
                'Resend in ${_otpResendSeconds}s',
                style: TextStyle(
                    color: Colors.black.withOpacity(0.4), fontSize: 12),
              )
            else
              GestureDetector(
                onTap: () {
                  // TODO: call send OTP API again
                  _startOtpTimer();
                },
                child: Text(
                  'Resend OTP',
                  style: TextStyle(
                      color: widget.method.primaryColor,
                      fontSize: 13,
                      fontWeight: FontWeight.w600),
                ),
              ),
          ],
        ),
      ],
    );
  }

  // --------------------------------------------------
  //  Step 3 UI: Enter PIN
  // --------------------------------------------------
  Widget _buildPinStep() {
    final pinLength = _isBinance ? 6 : 5;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Enter your ${widget.method.name} PIN',
          style: const TextStyle(
              color: Colors.black, fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 6),
        Text(
          'Enter your $pinLength-digit secret PIN to confirm the payment.',
          style: TextStyle(
              color: Colors.black.withOpacity(0.5), fontSize: 13, height: 1.4),
        ),
        const SizedBox(height: 20),
        _PaymentTextField(
          controller: _pinController,
          hint: '••••• ',
          label: 'PIN',
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(pinLength),
          ],
          prefixIcon: Icons.lock_outline_rounded,
          accentColor: widget.method.primaryColor,
          obscureText: _obscurePin,
          suffixIcon: IconButton(
 
