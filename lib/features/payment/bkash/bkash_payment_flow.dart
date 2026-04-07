import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import '../models/payment_method.dart';
import '../widgets/payment_widgets.dart';

enum BkashPaymentStep { enterNumber, enterOtp, enterPin }

class BkashPaymentFlow extends StatefulWidget {
  final PaymentMethod method;
  final double amount;
  final String purpose;

  const BkashPaymentFlow({super.key, required this.method, required this.amount, required this.purpose});

  @override
  State<BkashPaymentFlow> createState() => _BkashPaymentFlowState();
}

class _BkashPaymentFlowState extends State<BkashPaymentFlow> with SingleTickerProviderStateMixin {
  BkashPaymentStep _step = BkashPaymentStep.enterNumber;
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

  @override
  void initState() {
    super.initState();
    _stepAnimController = AnimationController(vsync: this, duration: const Duration(milliseconds: 350));
    _stepSlide = Tween<Offset>(begin: const Offset(0.06, 0), end: Offset.zero).animate(CurvedAnimation(parent: _stepAnimController, curve: Curves.easeOut));
    _stepAnimController.forward();
  }

  @override
  void dispose() {
    _numberController.dispose(); _otpController.dispose(); _pinController.dispose(); _otpTimer?.cancel(); _stepAnimController.dispose();
    super.dispose();
  }

  void _goToStep(BkashPaymentStep step) {
    setState(() { _step = step; _errorText = null; });
    _stepAnimController.forward(from: 0);
  }

  void _startOtpTimer() {
    _otpTimer?.cancel();
    setState(() => _otpResendSeconds = 60);
    _otpTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_otpResendSeconds <= 1) { t.cancel(); setState(() => _otpResendSeconds = 0); } 
      else { setState(() => _otpResendSeconds--); }
    });
  }

  Future<void> _sendOtp() async {
    final number = _numberController.text.trim();
    if (number.length < 11) { setState(() => _errorText = 'Enter a valid 11-digit bKash number'); return; }
    setState(() { _isLoading = true; _errorText = null; });
    await Future.delayed(const Duration(seconds: 1)); // API Call Here
    setState(() => _isLoading = false);
    if (!mounted) return;
    _startOtpTimer();
    _goToStep(BkashPaymentStep.enterOtp);
  }

  Future<void> _verifyOtp() async {
    if (_otpController.text.trim().length < 6) { setState(() => _errorText = 'Enter the 6-digit OTP'); return; }
    setState(() { _isLoading = true; _errorText = null; });
    await Future.delayed(const Duration(seconds: 1)); // API Call Here
    setState(() => _isLoading = false);
    if (!mounted) return;
    _goToStep(BkashPaymentStep.enterPin);
  }

  Future<void> _confirmPayment() async {
    if (_pinController.text.trim().length < 5) { setState(() => _errorText = 'Enter your 5-digit PIN'); return; }
    setState(() { _isLoading = true; _errorText = null; });
    await Future.delayed(const Duration(seconds: 1)); // API Call Here
    setState(() => _isLoading = false);
    if (!mounted) return;
    Navigator.pop(context, true); // Return success
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white, elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_rounded, color: Colors.black54), onPressed: () {
          if (_step == BkashPaymentStep.enterNumber) Navigator.pop(context, null);
          else if (_step == BkashPaymentStep.enterOtp) _goToStep(BkashPaymentStep.enterNumber);
          else _goToStep(BkashPaymentStep.enterOtp);
        }),
        title: Text('${widget.method.name} Payment', style: const TextStyle(color: Colors.black, fontSize: 17, fontWeight: FontWeight.w600)), centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: SlideTransition(
            position: _stepSlide,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                StepIndicator(current: _step.index, color: widget.method.primaryColor),
                const SizedBox(height: 28),
                PaymentSummaryHeader(method: widget.method, amount: widget.amount),
                const SizedBox(height: 32),
                if (_step == BkashPaymentStep.enterNumber) _buildNumberStep()
                else if (_step == BkashPaymentStep.enterOtp) _buildOtpStep()
                else _buildPinStep(),
                if (_errorText != null) Padding(padding: const EdgeInsets.only(top: 12), child: Row(children: [Lottie.asset('assets/lottie/error.json', width: 22, height: 22), const SizedBox(width: 6), Expanded(child: Text(_errorText!, style: const TextStyle(color: Colors.red, fontSize: 13)))])),
                const SizedBox(height: 28),
                ProceedButton(enabled: !_isLoading, isLoading: _isLoading, color: widget.method.primaryColor, onTap: _step == BkashPaymentStep.enterNumber ? _sendOtp : _step == BkashPaymentStep.enterOtp ? _verifyOtp : _confirmPayment),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNumberStep() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Enter bKash Number', style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w600)), const SizedBox(height: 6),
      Text('We will send an OTP to this number.', style: TextStyle(color: Colors.black.withOpacity(0.5), fontSize: 13)), const SizedBox(height: 20),
      PaymentTextField(controller: _numberController, hint: '01XXXXXXXXX', label: 'Mobile Number', keyboardType: TextInputType.phone, inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(11)], prefixIcon: Icons.phone_android, accentColor: widget.method.primaryColor),
    ]);
  }

  Widget _buildOtpStep() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Enter OTP', style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w600)), const SizedBox(height: 6),
      Text('A 6-digit OTP has been sent to ${_numberController.text.trim()}', style: TextStyle(color: Colors.black.withOpacity(0.5), fontSize: 13)), const SizedBox(height: 20),
      OtpInputRow(controller: _otpController, accentColor: widget.method.primaryColor), const SizedBox(height: 16),
      Row(mainAxisAlignment: MainAxisAlignment.end, children: [
        if (_otpResendSeconds > 0) Text('Resend in ${_otpResendSeconds}s', style: TextStyle(color: Colors.black.withOpacity(0.4), fontSize: 12))
        else GestureDetector(onTap: _startOtpTimer, child: Text('Resend OTP', style: TextStyle(color: widget.method.primaryColor, fontSize: 13, fontWeight: FontWeight.w600))),
      ]),
    ]);
  }

  Widget _buildPinStep() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Enter bKash PIN', style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w600)), const SizedBox(height: 6),
      Text('Enter your 5-digit secret PIN.', style: TextStyle(color: Colors.black.withOpacity(0.5), fontSize: 13)), const SizedBox(height: 20),
      PaymentTextField(controller: _pinController, hint: '?????', label: 'PIN', keyboardType: TextInputType.number, inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(5)], prefixIcon: Icons.lock_outline, accentColor: widget.method.primaryColor, obscureText: _obscurePin, suffixIcon: IconButton(icon: Icon(_obscurePin ? Icons.visibility_off : Icons.visibility, color: Colors.black45), onPressed: () => setState(() => _obscurePin = !_obscurePin))),
    ]);
  }
}
