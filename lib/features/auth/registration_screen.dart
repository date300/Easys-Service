import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:ui';
import 'package:go_router/go_router.dart';

import '../../main.dart';

class RegistrationScreen extends ConsumerStatefulWidget {
  const RegistrationScreen({super.key});

  @override
  ConsumerState<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends ConsumerState<RegistrationScreen>
    with TickerProviderStateMixin {
  // ─── Brand Colors ──────────────────────────────────────────────────────────
  static const Color _primary   = Color(0xFF007AFF); // iOS Blue
  static const Color _bg        = Color(0xFF0A0A0F); // Near black
  static const Color _surface   = Color(0xFF12121A);
  static const Color _card      = Color(0xFF1C1C28);
  static const Color _border    = Color(0xFF2A2A3A);
  static const Color _textPrim  = Color(0xFFF5F5F7); // Apple text white
  static const Color _textSec   = Color(0xFF8E8E93); // iOS secondary label
  static const Color _accent    = Color(0xFF0A84FF); // iOS blue accent
  static const Color _success   = Color(0xFF30D158); // iOS green

  // ─── Controllers ───────────────────────────────────────────────────────────
  final _formKey             = GlobalKey<FormState>();
  final _nameController      = TextEditingController();
  final _mobileController    = TextEditingController();
  final _emailController     = TextEditingController();
  final _passController      = TextEditingController();
  final _confirmPassController = TextEditingController();
  final _refController       = TextEditingController();
  final _otpController       = TextEditingController();

  // ─── State ─────────────────────────────────────────────────────────────────
  bool _isLoading          = false;
  bool _isOtpSent          = false;
  bool _passVisible        = false;
  bool _confirmPassVisible = false;
  int  _focusedField       = -1;

  // ─── Animation Controllers ─────────────────────────────────────────────────
  late final AnimationController _fadeCtrl;
  late final AnimationController _slideCtrl;
  late final AnimationController _pulseCtrl;
  late final AnimationController _shimmerCtrl;

  late final Animation<double>  _fadeAnim;
  late final Animation<Offset>  _slideAnim;
  late final Animation<double>  _pulseAnim;
  late final Animation<double>  _shimmerAnim;

  // ─── Responsive Helpers ────────────────────────────────────────────────────
  bool _isDesktop(BuildContext ctx) => MediaQuery.of(ctx).size.width >= 1100;
  bool _isTablet(BuildContext ctx)  =>
      MediaQuery.of(ctx).size.width >= 600 &&
      MediaQuery.of(ctx).size.width < 1100;

  double _fs(BuildContext ctx, double m, double t, double d) {
    if (_isDesktop(ctx)) return d;
    if (_isTablet(ctx))  return t;
    return m;
  }

  double _maxWidth(BuildContext ctx) {
    if (_isDesktop(ctx)) return 460;
    if (_isTablet(ctx))  return 500;
    return double.infinity;
  }

  // ─── Lifecycle ─────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();

    _fadeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900));
    _slideCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    _pulseCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2000))
      ..repeat(reverse: true);
    _shimmerCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1800))
      ..repeat();

    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
            begin: const Offset(0, 0.06), end: Offset.zero)
        .animate(CurvedAnimation(parent: _slideCtrl, curve: Curves.easeOutCubic));
    _pulseAnim = Tween<double>(begin: 0.85, end: 1.0)
        .animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));
    _shimmerAnim = Tween<double>(begin: -1.5, end: 1.5)
        .animate(CurvedAnimation(parent: _shimmerCtrl, curve: Curves.easeInOut));

    _fadeCtrl.forward();
    _slideCtrl.forward();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _slideCtrl.dispose();
    _pulseCtrl.dispose();
    _shimmerCtrl.dispose();
    _nameController.dispose();
    _mobileController.dispose();
    _emailController.dispose();
    _passController.dispose();
    _confirmPassController.dispose();
    _refController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  // ─── API Calls ─────────────────────────────────────────────────────────────
  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    HapticFeedback.lightImpact();
    setState(() => _isLoading = true);
    try {
      final response = await http.post(
        Uri.parse("https://easy.ltcminematrix.com/api/auth/register"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "full_name": _nameController.text.trim(),
          "mobile":    _mobileController.text.trim(),
          "email":     _emailController.text.trim(),
          "password":  _passController.text,
          "confirm_password": _confirmPassController.text,
          "referral_code": _refController.text.trim().isEmpty
              ? null
              : _refController.text.trim(),
        }),
      );
      final data = jsonDecode(response.body);
      if (data['status'] == "success") {
        if (!mounted) return;
        HapticFeedback.mediumImpact();
        _showSnack(data['message'], _success);
        setState(() => _isOtpSent = true);
        _fadeCtrl.reset();
        _slideCtrl.reset();
        _fadeCtrl.forward();
        _slideCtrl.forward();
      } else {
        HapticFeedback.heavyImpact();
        _showSnack(data['message'], Colors.redAccent);
      }
    } catch (_) {
      _showSnack("নেটওয়ার্ক সমস্যা হয়েছে!", Colors.redAccent);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _verifyOtp() async {
    final otp = _otpController.text.trim();
    if (otp.length < 6) {
      _showSnack("সঠিক ৬ সংখ্যার OTP দিন", Colors.redAccent);
      return;
    }
    HapticFeedback.lightImpact();
    setState(() => _isLoading = true);
    try {
      final response = await http.post(
        Uri.parse("https://easy.ltcminematrix.com/api/auth/verify-otp"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": _emailController.text.trim(),
          "otp":   otp,
        }),
      );
      final data = jsonDecode(response.body);
      if (data['status'] == "success") {
        await ref.read(authProvider.notifier).loginWithToken(data['token']);
        if (!mounted) return;
        HapticFeedback.heavyImpact();
        _showSnack(data['message'], _success);
        context.go('/home');
      } else {
        HapticFeedback.heavyImpact();
        _showSnack(data['message'], Colors.redAccent);
      }
    } catch (_) {
      _showSnack("নেটওয়ার্ক সমস্যা হয়েছে!", Colors.redAccent);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnack(String msg, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg,
            style: GoogleFonts.inter(
                color: Colors.white,
                fontWeight: FontWeight.w500,
                fontSize: 14)),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        margin: const EdgeInsets.all(16),
        elevation: 0,
      ),
    );
  }

  // ─── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor:       Colors.transparent,
      statusBarBrightness:  Brightness.dark,
      statusBarIconBrightness: Brightness.light,
    ));

    return Scaffold(
      backgroundColor: _bg,
      body: Stack(
        children: [
          // Ambient background glow
          _buildAmbientBg(),
          // Main content
          _isDesktop(context)
              ? _desktopLayout(context)
              : _mobileTabletLayout(context),
        ],
      ),
    );
  }

  // ─── Ambient Background ────────────────────────────────────────────────────
  Widget _buildAmbientBg() {
    return AnimatedBuilder(
      animation: _pulseAnim,
      builder: (_, __) => Stack(
        children: [
          // Top-left glow
          Positioned(
            top:  -120,
            left: -80,
            child: Transform.scale(
              scale: _pulseAnim.value,
              child: Container(
                width:  380,
                height: 380,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(colors: [
                    _primary.withOpacity(0.18),
                    Colors.transparent,
                  ]),
                ),
              ),
            ),
          ),
          // Bottom-right glow
          Positioned(
            bottom: -100,
            right:  -60,
            child: Transform.scale(
              scale: 1.2 - (_pulseAnim.value - 0.85),
              child: Container(
                width:  300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(colors: [
                    const Color(0xFF5E5CE6).withOpacity(0.13),
                    Colors.transparent,
                  ]),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Desktop Layout ────────────────────────────────────────────────────────
  Widget _desktopLayout(BuildContext ctx) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: _maxWidth(ctx)),
          child: FadeTransition(
            opacity: _fadeAnim,
            child: SlideTransition(
              position: _slideAnim,
              child: _buildCard(ctx),
            ),
          ),
        ),
      ),
    );
  }

  // ─── Mobile/Tablet Layout ──────────────────────────────────────────────────
  Widget _mobileTabletLayout(BuildContext ctx) {
    final isTablet = _isTablet(ctx);
    return Column(
      children: [
        // Top hero area
        _buildTopHero(ctx, isTablet),
        // Form card — expands to fill remaining space
        Expanded(
          child: FadeTransition(
            opacity: _fadeAnim,
            child: SlideTransition(
              position: _slideAnim,
              child: Container(
                decoration: const BoxDecoration(
                  color: _surface,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                ),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.symmetric(
                    horizontal: isTablet ? 40 : 24.w,
                    vertical:   isTablet ? 32 : 28.h,
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: _maxWidth(ctx)),
                    child: _isOtpSent ? _buildOtpForm(ctx) : _buildRegForm(ctx),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ─── Top Hero (Mobile/Tablet) ──────────────────────────────────────────────
  Widget _buildTopHero(BuildContext ctx, bool isTablet) {
    return Container(
      color: _bg,
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: isTablet ? 220 : 200.h,
          child: Stack(
            children: [
              // Back button
              Positioned(
                top: 8,
                left: 4,
                child: _buildBackButton(ctx),
              ),
              // Center icon + title
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: isTablet ? 20 : 24.h),
                    // Animated icon container
                    AnimatedBuilder(
                      animation: _pulseAnim,
                      builder: (_, __) => Transform.scale(
                        scale: _pulseAnim.value,
                        child: Container(
                          width:  isTablet ? 72 : 68.w,
                          height: isTablet ? 72 : 68.w,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [Color(0xFF0A84FF), Color(0xFF5E5CE6)],
                              begin: Alignment.topLeft,
                              end:   Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color:  _primary.withOpacity(0.4),
                                blurRadius: 24,
                                spreadRadius: 4,
                              ),
                            ],
                          ),
                          child: Icon(
                            _isOtpSent
                                ? Icons.mark_email_read_rounded
                                : Icons.person_add_alt_1_rounded,
                            color: Colors.white,
                            size: isTablet ? 34 : 32.sp,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: isTablet ? 14 : 14.h),
                    Text(
                      _isOtpSent ? 'Verify OTP' : 'Create Account',
                      style: GoogleFonts.inter(
                        color:      _textPrim,
                        fontWeight: FontWeight.w700,
                        fontSize:   _fs(ctx, 22, 24, 26),
                        letterSpacing: -0.5,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      _isOtpSent
                          ? 'Enter the code sent to your email'
                          : 'Join us — it takes less than a minute',
                      style: GoogleFonts.inter(
                        color:    _textSec,
                        fontSize: _fs(ctx, 13, 13, 14),
                        fontWeight: FontWeight.w400,
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

  // ─── Back Button ───────────────────────────────────────────────────────────
  Widget _buildBackButton(BuildContext ctx) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        if (context.canPop()) context.pop();
      },
      child: Container(
        margin: EdgeInsets.all(8.w),
        width:  40.w,
        height: 40.w,
        decoration: BoxDecoration(
          color:        _card,
          shape:        BoxShape.circle,
          border: Border.all(color: _border, width: 1),
        ),
        child: const Icon(Icons.arrow_back_ios_new_rounded,
            color: _textPrim, size: 16),
      ),
    );
  }

  // ─── Desktop Card ──────────────────────────────────────────────────────────
  Widget _buildCard(BuildContext ctx) {
    return Container(
      decoration: BoxDecoration(
        color:        _card,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: _border, width: 1),
        boxShadow: [
          BoxShadow(
            color:      Colors.black.withOpacity(0.5),
            blurRadius: 60,
            spreadRadius: 10,
          ),
          BoxShadow(
            color:      _primary.withOpacity(0.06),
            blurRadius: 80,
            spreadRadius: 20,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Card header
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF0A84FF), Color(0xFF5E5CE6)],
                  begin: Alignment.topLeft,
                  end:   Alignment.bottomRight,
                ),
              ),
              padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 40),
              child: Column(
                children: [
                  AnimatedBuilder(
                    animation: _pulseAnim,
                    builder: (_, __) => Transform.scale(
                      scale: _pulseAnim.value,
                      child: Container(
                        width:  72,
                        height: 72,
                        decoration: BoxDecoration(
                          color:  Colors.white.withOpacity(0.15),
                          shape:  BoxShape.circle,
                          border: Border.all(
                              color: Colors.white.withOpacity(0.3), width: 1.5),
                        ),
                        child: Icon(
                          _isOtpSent
                              ? Icons.mark_email_read_rounded
                              : Icons.person_add_alt_1_rounded,
                          color: Colors.white,
                          size:  36,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    _isOtpSent ? 'Verify OTP' : 'Create Account',
                    style: GoogleFonts.inter(
                      color:      Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize:   24,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _isOtpSent
                        ? 'Enter the 6-digit code sent to your email'
                        : 'Join us — it takes less than a minute',
                    style: GoogleFonts.inter(
                      color:    Colors.white.withOpacity(0.75),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            // Card body
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 32),
              child: _isOtpSent ? _buildOtpForm(ctx) : _buildRegForm(ctx),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Registration Form ─────────────────────────────────────────────────────
  Widget _buildRegForm(BuildContext ctx) {
    final isDesktop = _isDesktop(ctx);
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _label(ctx, "Full Name"),
          _premiumField(ctx, _nameController, "John Appleseed",
              icon: Icons.person_outline_rounded, index: 0),
          _gap(ctx),

          _label(ctx, "Mobile Number"),
          _premiumField(ctx, _mobileController, "+880 1X XX XX XXXX",
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              index: 1),
          _gap(ctx),

          _label(ctx, "Email Address"),
          _premiumField(ctx, _emailController, "hello@example.com",
              icon: Icons.mail_outline_rounded,
              keyboardType: TextInputType.emailAddress,
              index: 2),
          _gap(ctx),

          _label(ctx, "Password"),
          _premiumField(ctx, _passController, "Create a strong password",
              icon: Icons.lock_outline_rounded, passField: 1, index: 3),
          _gap(ctx),

          _label(ctx, "Confirm Password"),
          _premiumField(ctx, _confirmPassController, "Repeat your password",
              icon: Icons.lock_outline_rounded, passField: 2, index: 4),
          _gap(ctx),

          _label(ctx, "Affiliate ID", optional: true),
          _premiumField(ctx, _refController, "Enter referral code (optional)",
              icon: Icons.card_giftcard_rounded,
              optional: true,
              index: 5),

          SizedBox(height: isDesktop ? 32 : 28.h),

          // Register Button
          _primaryButton(
            ctx:       ctx,
            label:     "Create Account",
            onTap:     _register,
            isLoading: _isLoading,
          ),

          SizedBox(height: isDesktop ? 22 : 20.h),

          // Login link
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Already have an account?  ",
                    style: GoogleFonts.inter(
                        color:    _textSec,
                        fontSize: _fs(ctx, 13, 13, 14))),
                GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    context.go('/login');
                  },
                  child: Text("Sign In",
                      style: GoogleFonts.inter(
                        color:      _accent,
                        fontWeight: FontWeight.w600,
                        fontSize:   _fs(ctx, 13, 13, 14),
                      )),
                ),
              ],
            ),
          ),
          SizedBox(height: isDesktop ? 8 : 8.h),
        ],
      ),
    );
  }

  // ─── OTP Form ──────────────────────────────────────────────────────────────
  Widget _buildOtpForm(BuildContext ctx) {
    final isDesktop = _isDesktop(ctx);
    return Column(
      children: [
        SizedBox(height: isDesktop ? 8 : 8.h),

        // Email display pill
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color:        _card,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _border),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.mail_outline_rounded, color: _accent, size: 16),
              const SizedBox(width: 8),
              Text(_emailController.text,
                  style: GoogleFonts.inter(
                    color:      _textPrim,
                    fontWeight: FontWeight.w500,
                    fontSize:   _fs(ctx, 13, 13, 14),
                  )),
            ],
          ),
        ),

        SizedBox(height: isDesktop ? 32 : 28.h),

        // OTP input
        _otpInputField(ctx),

        SizedBox(height: isDesktop ? 32 : 28.h),

        // Verify Button
        _primaryButton(
          ctx:       ctx,
          label:     "Verify & Continue",
          onTap:     _verifyOtp,
          isLoading: _isLoading,
        ),

        SizedBox(height: isDesktop ? 20 : 18.h),

        // Change email
        GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            setState(() => _isOtpSent = false);
            _fadeCtrl.reset();
            _slideCtrl.reset();
            _fadeCtrl.forward();
            _slideCtrl.forward();
          },
          child: Text("Change Email Address",
              style: GoogleFonts.inter(
                color:      _accent,
                fontWeight: FontWeight.w500,
                fontSize:   _fs(ctx, 13, 13, 14),
              )),
        ),
        SizedBox(height: isDesktop ? 8 : 8.h),
      ],
    );
  }

  // ─── OTP Input Field ───────────────────────────────────────────────────────
  Widget _otpInputField(BuildContext ctx) {
    final isDesktop = _isDesktop(ctx);
    return Container(
      decoration: BoxDecoration(
        color:        _card,
        borderRadius: BorderRadius.circular(isDesktop ? 18 : 16.r),
        border: Border.all(
          color:  _focusedField == 99 ? _accent : _border,
          width:  _focusedField == 99 ? 1.5 : 1,
        ),
        boxShadow: _focusedField == 99
            ? [
                BoxShadow(
                  color:      _accent.withOpacity(0.15),
                  blurRadius: 16,
                  spreadRadius: 2,
                )
              ]
            : [],
      ),
      child: Focus(
        onFocusChange: (v) =>
            setState(() => _focusedField = v ? 99 : -1),
        child: TextField(
          controller:   _otpController,
          keyboardType: TextInputType.number,
          maxLength:    6,
          textAlign:    TextAlign.center,
          style: GoogleFonts.inter(
            color:         _textPrim,
            fontSize:      isDesktop ? 30 : 28.sp,
            fontWeight:    FontWeight.w700,
            letterSpacing: 14,
          ),
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: InputDecoration(
            hintText:        "——————",
            hintStyle:       GoogleFonts.inter(
                color: _textSec.withOpacity(0.5),
                fontSize: isDesktop ? 26 : 24.sp,
                letterSpacing: 10),
            counterText:     "",
            filled:          true,
            fillColor:       Colors.transparent,
            contentPadding:  EdgeInsets.symmetric(
                vertical: isDesktop ? 20 : 18.h),
            border:          OutlineInputBorder(
              borderRadius: BorderRadius.circular(isDesktop ? 18 : 16.r),
              borderSide:   BorderSide.none,
            ),
          ),
        ),
      ),
    );
  }

  // ─── Primary Button ────────────────────────────────────────────────────────
  Widget _primaryButton({
    required BuildContext ctx,
    required String label,
    required VoidCallback onTap,
    required bool isLoading,
  }) {
    final isDesktop = _isDesktop(ctx);
    return SizedBox(
      width:  double.infinity,
      height: isDesktop ? 54 : 52.h,
      child: isLoading
          ? Center(
              child: SizedBox(
                width:  24,
                height: 24,
                child: CircularProgressIndicator(
                  color:       _accent,
                  strokeWidth: 2.5,
                ),
              ),
            )
          : GestureDetector(
              onTap: onTap,
              child: AnimatedBuilder(
                animation: _shimmerAnim,
                builder: (_, __) => Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: const [Color(0xFF0A84FF), Color(0xFF5E5CE6)],
                      begin:  Alignment.centerLeft,
                      end:    Alignment.centerRight,
                    ),
                    borderRadius:
                        BorderRadius.circular(isDesktop ? 16 : 14.r),
                    boxShadow: [
                      BoxShadow(
                        color:      _primary.withOpacity(0.4),
                        blurRadius: 20,
                        offset:     const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      // Shimmer sweep
                      ClipRRect(
                        borderRadius:
                            BorderRadius.circular(isDesktop ? 16 : 14.r),
                        child: Align(
                          alignment: Alignment(_shimmerAnim.value, 0),
                          child: Container(
                            width:  80,
                            height: double.infinity,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.white.withOpacity(0.0),
                                  Colors.white.withOpacity(0.12),
                                  Colors.white.withOpacity(0.0),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      Center(
                        child: Text(
                          label,
                          style: GoogleFonts.inter(
                            color:      Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize:   _fs(ctx, 15, 16, 16),
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  // ─── Premium Text Field ────────────────────────────────────────────────────
  Widget _premiumField(
    BuildContext ctx,
    TextEditingController controller,
    String hint, {
    required IconData icon,
    int passField               = 0,
    TextInputType keyboardType  = TextInputType.text,
    bool optional               = false,
    required int index,
  }) {
    final isDesktop = _isDesktop(ctx);
    final isFocused = _focusedField == index;
    final obscure = passField == 1
        ? !_passVisible
        : passField == 2
            ? !_confirmPassVisible
            : false;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color:        _card,
        borderRadius: BorderRadius.circular(isDesktop ? 16 : 14.r),
        border: Border.all(
          color: isFocused ? _accent : _border,
          width: isFocused ? 1.5   : 1.0,
        ),
        boxShadow: isFocused
            ? [
                BoxShadow(
                  color:      _accent.withOpacity(0.15),
                  blurRadius: 16,
                  spreadRadius: 2,
                )
              ]
            : [],
      ),
      child: Focus(
        onFocusChange: (v) =>
            setState(() => _focusedField = v ? index : -1),
        child: TextFormField(
          controller:     controller,
          obscureText:    obscure,
          keyboardType:   keyboardType,
          style: GoogleFonts.inter(
              color:      _textPrim,
              fontSize:   _fs(ctx, 14, 14, 14.5),
              fontWeight: FontWeight.w400),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.inter(
                color:    _textSec.withOpacity(0.6),
                fontSize: _fs(ctx, 13, 13, 14)),
            filled:    true,
            fillColor: Colors.transparent,
            contentPadding: EdgeInsets.symmetric(
              horizontal: isDesktop ? 16 : 16.w,
              vertical:   isDesktop ? 16 : 15.h,
            ),
            prefixIcon: Icon(icon,
                color: isFocused ? _accent : _textSec,
                size:  isDesktop ? 19 : 19.sp),
            suffixIcon: passField != 0
                ? IconButton(
                    icon: Icon(
                      (passField == 1 ? _passVisible : _confirmPassVisible)
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: _textSec,
                      size:  isDesktop ? 19 : 19.sp,
                    ),
                    onPressed: () => setState(() {
                      if (passField == 1) {
                        _passVisible = !_passVisible;
                      } else {
                        _confirmPassVisible = !_confirmPassVisible;
                      }
                    }),
                  )
                : null,
            border: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(isDesktop ? 16 : 14.r),
              borderSide: BorderSide.none,
            ),
          ),
          validator: (value) {
            if (!optional && (value == null || value.isEmpty)) {
              return "This field is required";
            }
            if (passField == 2 && value != _passController.text) {
              return "Passwords do not match";
            }
            return null;
          },
        ),
      ),
    );
  }

  // ─── Helpers ───────────────────────────────────────────────────────────────
  Widget _label(BuildContext ctx, String text, {bool optional = false}) {
    return Padding(
      padding: EdgeInsets.only(
          bottom: _isDesktop(ctx) ? 8 : 8.h, left: 2),
      child: Row(
        children: [
          Text(
            text,
            style: GoogleFonts.inter(
              color:      _textPrim,
              fontWeight: FontWeight.w600,
              fontSize:   _fs(ctx, 13, 13, 13.5),
            ),
          ),
          if (optional) ...[
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color:        _border,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text("optional",
                  style: GoogleFonts.inter(
                      color:    _textSec,
                      fontSize: 10,
                      fontWeight: FontWeight.w500)),
            ),
          ],
        ],
      ),
    );
  }

  Widget _gap(BuildContext ctx) =>
      SizedBox(height: _isDesktop(ctx) ? 16 : 14.h);
}
