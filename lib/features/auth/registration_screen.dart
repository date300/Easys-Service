import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:go_router/go_router.dart';

import '../../main.dart';

class RegistrationScreen extends ConsumerStatefulWidget {
  const RegistrationScreen({super.key});

  @override
  ConsumerState<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends ConsumerState<RegistrationScreen> {
  // iOS-style premium colors
  static const Color skyBlue       = Color(0xFF007AFF); // iOS blue
  static const Color _bgLight      = Color(0xFFF2F2F7); // iOS system background
  static const Color _fieldBg      = Color(0xFFFFFFFF);
  static const Color _fieldBorder  = Color(0xFFD1D1D6);
  static const Color _labelColor   = Color(0xFF1C1C1E);
  static const Color _hintColor    = Color(0xFFAEAEB2);
  static const Color _subtextColor = Color(0xFF6D6D72);

  final _formKey               = GlobalKey<FormState>();
  final _nameController        = TextEditingController();
  final _mobileController      = TextEditingController();
  final _emailController       = TextEditingController();
  final _passController        = TextEditingController();
  final _confirmPassController = TextEditingController();
  final _refController         = TextEditingController();
  final _otpController         = TextEditingController();

  bool _isLoading          = false;
  bool _isOtpSent          = false;
  bool _passVisible        = false;
  bool _confirmPassVisible = false;

  bool _isDesktop(BuildContext ctx) => MediaQuery.of(ctx).size.width >= 1100;
  bool _isTablet(BuildContext ctx) =>
      MediaQuery.of(ctx).size.width >= 600 &&
      MediaQuery.of(ctx).size.width < 1100;

  double _fs(BuildContext ctx, double m, double t, double d) {
    if (_isDesktop(ctx)) return d;
    if (_isTablet(ctx)) return t;
    return m;
  }

  double _maxWidth(BuildContext ctx) {
    if (_isDesktop(ctx)) return 480;
    if (_isTablet(ctx)) return 520;
    return double.infinity;
  }

  double _topHeight(BuildContext ctx) {
    if (_isTablet(ctx)) return 240;
    return 220.h;
  }

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
          "mobile": _mobileController.text.trim(),
          "email": _emailController.text.trim(),
          "password": _passController.text,
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
        _showSnack(data['message'], const Color(0xFF34C759));
        setState(() => _isOtpSent = true);
      } else {
        HapticFeedback.heavyImpact();
        _showSnack(data['message'], const Color(0xFFFF3B30));
      }
    } catch (_) {
      _showSnack("নেটওয়ার্ক সমস্যা হয়েছে!", const Color(0xFFFF3B30));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _verifyOtp() async {
    final otp = _otpController.text.trim();
    if (otp.length < 6) {
      _showSnack("সঠিক ৬ সংখ্যার OTP দিন", const Color(0xFFFF3B30));
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
          "otp": otp,
        }),
      );
      final data = jsonDecode(response.body);
      if (data['status'] == "success") {
        await ref.read(authProvider.notifier).loginWithToken(data['token']);
        if (!mounted) return;
        HapticFeedback.heavyImpact();
        _showSnack(data['message'], const Color(0xFF34C759));
        context.go('/home');
      } else {
        HapticFeedback.heavyImpact();
        _showSnack(data['message'], const Color(0xFFFF3B30));
      }
    } catch (_) {
      _showSnack("নেটওয়ার্ক সমস্যা হয়েছে!", const Color(0xFFFF3B30));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnack(String msg, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg,
            style: GoogleFonts.poppins(
                color: Colors.white, fontWeight: FontWeight.w500)),
        backgroundColor: color,
        behavior:        SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        margin:    const EdgeInsets.all(16),
        elevation: 0,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor:          Colors.transparent,
      statusBarBrightness:     Brightness.dark,
      statusBarIconBrightness: Brightness.light,
    ));

    final isDesktop = _isDesktop(context);
    final isTablet  = _isTablet(context);

    return Scaffold(
      backgroundColor: skyBlue,
      body: isDesktop
          ? _desktopLayout(context)
          : _mobileTabletLayout(context, isTablet),
    );
  }

  // ── Desktop ────────────────────────────────────────────────────────────────
  Widget _desktopLayout(BuildContext ctx) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF007AFF), Color(0xFF0055D4)],
          begin:  Alignment.topLeft,
          end:    Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 40),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: _maxWidth(ctx)),
            child: Container(
              decoration: BoxDecoration(
                color:        Colors.white,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color:      Colors.black.withOpacity(0.16),
                    blurRadius: 48,
                    offset:     const Offset(0, 20),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: Column(
                  children: [
                    // Header
                    Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF007AFF), Color(0xFF0055D4)],
                          begin:  Alignment.topLeft,
                          end:    Alignment.bottomRight,
                        ),
                      ),
                      width:   double.infinity,
                      padding: const EdgeInsets.symmetric(
                          vertical: 36, horizontal: 32),
                      child: Column(
                        children: [
                          // Frosted icon
                          Container(
                            width:  80,
                            height: 80,
                            decoration: BoxDecoration(
                              color:  Colors.white.withOpacity(0.2),
                              shape:  BoxShape.circle,
                              border: Border.all(
                                  color: Colors.white.withOpacity(0.4),
                                  width: 1.5),
                            ),
                            child: Icon(
                              _isOtpSent
                                  ? Icons.mark_email_read_rounded
                                  : Icons.person_add_alt_1_rounded,
                              size:  38,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            _isOtpSent ? 'OTP Verification' : 'Create Account',
                            style: GoogleFonts.poppins(
                                color:      Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize:   24),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 28),
                      child: _isOtpSent
                          ? _buildOtpForm(ctx)
                          : _buildRegForm(ctx),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Mobile & Tablet ────────────────────────────────────────────────────────
  Widget _mobileTabletLayout(BuildContext ctx, bool isTablet) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF007AFF), Color(0xFF0055D4)],
          begin:  Alignment.topLeft,
          end:    Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          SafeArea(
            bottom: false,
            child: SizedBox(
              height: _topHeight(ctx),
              child: Stack(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: 8.w, vertical: 8.h),
                    child: Row(
                      children: [
                        // iOS-style back button
                        GestureDetector(
                          onTap: () {
                            HapticFeedback.selectionClick();
                            if (context.canPop()) context.pop();
                          },
                          child: Container(
                            width:  38.w,
                            height: 38.w,
                            decoration: BoxDecoration(
                              color:  Colors.white.withOpacity(0.2),
                              shape:  BoxShape.circle,
                              border: Border.all(
                                  color: Colors.white.withOpacity(0.35),
                                  width: 1),
                            ),
                            child: const Icon(
                                Icons.arrow_back_ios_new_rounded,
                                color: Colors.white,
                                size:  16),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Text(
                          _isOtpSent ? 'OTP Verification' : 'Register',
                          style: GoogleFonts.poppins(
                              color:      Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize:   _fs(ctx, 20, 22, 24)),
                        ),
                      ],
                    ),
                  ),
                  Center(
                    child: Padding(
                      padding: EdgeInsets.only(top: 30.h),
                      // Frosted circle icon (আগের plain icon-এর জায়গায়)
                      child: Container(
                        width:  isTablet ? 90 : 80.w,
                        height: isTablet ? 90 : 80.w,
                        decoration: BoxDecoration(
                          color:  Colors.white.withOpacity(0.2),
                          shape:  BoxShape.circle,
                          border: Border.all(
                              color: Colors.white.withOpacity(0.4),
                              width: 1.5),
                        ),
                        child: Icon(
                          _isOtpSent
                              ? Icons.mark_email_read_rounded
                              : Icons.person_add_alt_1_rounded,
                          size:  isTablet ? 44 : 38.sp,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  // Decorative dots (original)
                  Positioned(
                      top:  30.h,
                      left: 30.w,
                      child: _dot(10, Colors.white.withOpacity(0.3))),
                  Positioned(
                      top:   60.h,
                      right: 40.w,
                      child: _dot(8, Colors.white.withOpacity(0.2))),
                  Positioned(
                      bottom: 20.h,
                      left:   60.w,
                      child: _dot(6, Colors.white.withOpacity(0.25))),
                ],
              ),
            ),
          ),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: _bgLight,
                borderRadius: BorderRadius.only(
                  topLeft:  Radius.circular(32.r),
                  topRight: Radius.circular(32.r),
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft:  Radius.circular(32.r),
                  topRight: Radius.circular(32.r),
                ),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.symmetric(
                      horizontal: isTablet ? 40 : 24.w, vertical: 28.h),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: _maxWidth(ctx)),
                      child: _isOtpSent
                          ? _buildOtpForm(ctx)
                          : _buildRegForm(ctx),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Registration Form ──────────────────────────────────────────────────────
  Widget _buildRegForm(BuildContext ctx) {
    final isDesktop = _isDesktop(ctx);
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _label(ctx, "Full Name"),
          _field(ctx, _nameController, "Enter your full name",
              keyboardType: TextInputType.name,
              prefixIcon: Icons.person_outline_rounded),
          _gap(ctx),

          _label(ctx, "Mobile Number"),
          _field(ctx, _mobileController, "Enter your mobile number",
              keyboardType: TextInputType.phone,
              prefixIcon: Icons.phone_outlined),
          _gap(ctx),

          _label(ctx, "Email Address"),
          _field(ctx, _emailController, "Enter your email address",
              keyboardType: TextInputType.emailAddress,
              prefixIcon: Icons.mail_outline_rounded),
          _gap(ctx),

          _label(ctx, "Password"),
          _field(ctx, _passController, "Enter your password",
              passField: 1, prefixIcon: Icons.lock_outline_rounded),
          _gap(ctx),

          _label(ctx, "Confirm Password"),
          _field(ctx, _confirmPassController, "Enter your password",
              passField: 2, prefixIcon: Icons.lock_outline_rounded),
          _gap(ctx),

          _label(ctx, "Affiliate ID (Optional)"),
          _field(ctx, _refController, "Enter your affiliate id",
              optional: true, prefixIcon: Icons.card_giftcard_outlined),

          SizedBox(height: isDesktop ? 28 : 28.h),

          SizedBox(
            width:  double.infinity,
            height: isDesktop ? 52 : 52.h,
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                        color: skyBlue, strokeWidth: 2.5))
                : ElevatedButton(
                    onPressed: _register,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: skyBlue,
                      foregroundColor: Colors.white,
                      elevation:   0,
                      shadowColor: skyBlue.withOpacity(0.4),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              isDesktop ? 14 : 14.r)),
                    ).copyWith(
                      elevation: WidgetStateProperty.resolveWith((s) =>
                          s.contains(WidgetState.pressed) ? 0 : 4),
                      shadowColor: WidgetStateProperty.all(
                          skyBlue.withOpacity(0.35)),
                    ),
                    child: Text("Register",
                        style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            fontSize:   _fs(ctx, 15, 16, 17))),
                  ),
          ),

          SizedBox(height: isDesktop ? 20 : 20.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Already have an account? ",
                  style: GoogleFonts.poppins(
                      color:    _subtextColor,
                      fontSize: _fs(ctx, 13, 13, 14))),
              GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  context.go('/login');
                },
                child: Text("Login",
                    style: GoogleFonts.poppins(
                        color:      skyBlue,
                        fontWeight: FontWeight.bold,
                        fontSize:   _fs(ctx, 13, 13, 14))),
              ),
            ],
          ),
          SizedBox(height: isDesktop ? 10 : 10.h),
        ],
      ),
    );
  }

  // ── OTP Form ───────────────────────────────────────────────────────────────
  Widget _buildOtpForm(BuildContext ctx) {
    final isDesktop = _isDesktop(ctx);
    return Column(
      children: [
        SizedBox(height: isDesktop ? 10 : 10.h),
        Text("We have sent an OTP to",
            style: GoogleFonts.poppins(
                color: _subtextColor, fontSize: _fs(ctx, 14, 14, 15))),
        Text(_emailController.text,
            style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize:   _fs(ctx, 15, 15, 16),
                color:      _labelColor)),
        SizedBox(height: isDesktop ? 30 : 30.h),
        // OTP field with iOS card look
        Container(
          decoration: BoxDecoration(
            color:        _fieldBg,
            borderRadius: BorderRadius.circular(isDesktop ? 14 : 14.r),
            border: Border.all(color: _fieldBorder, width: 1),
            boxShadow: [
              BoxShadow(
                  color:      Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset:     const Offset(0, 2)),
            ],
          ),
          child: TextField(
            controller:      _otpController,
            keyboardType:    TextInputType.number,
            maxLength:       6,
            textAlign:       TextAlign.center,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: GoogleFonts.poppins(
                fontSize:      isDesktop ? 28 : 28.sp,
                letterSpacing: 12,
                fontWeight:    FontWeight.w600,
                color:         _labelColor),
            decoration: InputDecoration(
              hintText:    "------",
              hintStyle:   GoogleFonts.poppins(
                  color:    _hintColor,
                  fontSize: isDesktop ? 24 : 22.sp),
              counterText: "",
              filled:      true,
              fillColor:   Colors.transparent,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(isDesktop ? 14 : 14.r),
                borderSide:   BorderSide.none,
              ),
            ),
          ),
        ),
        SizedBox(height: isDesktop ? 30 : 30.h),
        SizedBox(
          width:  double.infinity,
          height: isDesktop ? 52 : 52.h,
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                      color: skyBlue, strokeWidth: 2.5))
              : ElevatedButton(
                  onPressed: _verifyOtp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: skyBlue,
                    foregroundColor: Colors.white,
                    elevation:   0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                            isDesktop ? 14 : 14.r)),
                  ).copyWith(
                    elevation: WidgetStateProperty.resolveWith((s) =>
                        s.contains(WidgetState.pressed) ? 0 : 4),
                    shadowColor: WidgetStateProperty.all(
                        skyBlue.withOpacity(0.35)),
                  ),
                  child: Text("Verify & Login",
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize:   _fs(ctx, 15, 16, 17))),
                ),
        ),
        SizedBox(height: isDesktop ? 16 : 16.h),
        TextButton(
          onPressed: () => setState(() => _isOtpSent = false),
          style: TextButton.styleFrom(foregroundColor: skyBlue),
          child: Text("Change Email Address",
              style: GoogleFonts.poppins(
                  color:      skyBlue,
                  fontWeight: FontWeight.w500,
                  fontSize:   _fs(ctx, 13, 13, 14))),
        ),
      ],
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────
  Widget _label(BuildContext ctx, String text) => Padding(
        padding:
            EdgeInsets.only(bottom: _isDesktop(ctx) ? 6 : 6.h, left: 2),
        child: Text(text,
            style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize:   _fs(ctx, 13, 13, 14),
                color:      _labelColor)),
      );

  Widget _gap(BuildContext ctx) =>
      SizedBox(height: _isDesktop(ctx) ? 14 : 14.h);

  Widget _field(
    BuildContext ctx,
    TextEditingController controller,
    String hint, {
    int passField              = 0,
    TextInputType keyboardType = TextInputType.text,
    bool optional              = false,
    IconData? prefixIcon,
  }) {
    final obscure = passField == 1
        ? !_passVisible
        : passField == 2
            ? !_confirmPassVisible
            : false;
    final isDesktop = _isDesktop(ctx);
    final radius    = isDesktop ? 12.0 : 12.r;
    final vPad      = isDesktop ? 15.0 : 14.h;
    final hPad      = isDesktop ? 16.0 : 16.w;

    return Container(
      decoration: BoxDecoration(
        color:        _fieldBg,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: _fieldBorder, width: 1),
        boxShadow: [
          BoxShadow(
              color:      Colors.black.withOpacity(0.04),
              blurRadius: 6,
              offset:     const Offset(0, 2)),
        ],
      ),
      child: TextFormField(
        controller:   controller,
        obscureText:  obscure,
        keyboardType: keyboardType,
        style: GoogleFonts.poppins(
            fontSize:   _fs(ctx, 13, 13, 14),
            color:      _labelColor,
            fontWeight: FontWeight.w400),
        decoration: InputDecoration(
          hintText:  hint,
          hintStyle: GoogleFonts.poppins(
              color: _hintColor, fontSize: _fs(ctx, 13, 13, 14)),
          filled:    true,
          fillColor: Colors.transparent,
          contentPadding:
              EdgeInsets.symmetric(horizontal: hPad, vertical: vPad),
          prefixIcon: prefixIcon != null
              ? Icon(prefixIcon,
                  color: _hintColor, size: _fs(ctx, 18, 19, 20))
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radius),
            borderSide:   BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radius),
            borderSide: const BorderSide(color: skyBlue, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radius),
            borderSide: const BorderSide(
                color: Color(0xFFFF3B30), width: 1.2),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radius),
            borderSide: const BorderSide(
                color: Color(0xFFFF3B30), width: 1.5),
          ),
          suffixIcon: passField != 0
              ? IconButton(
                  icon: Icon(
                    passField == 1
                        ? (_passVisible
                            ? Icons.visibility_rounded
                            : Icons.visibility_off_rounded)
                        : (_confirmPassVisible
                            ? Icons.visibility_rounded
                            : Icons.visibility_off_rounded),
                    color: _hintColor,
                    size:  _fs(ctx, 20, 21, 22),
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
        ),
        validator: (value) {
          if (!optional && (value == null || value.isEmpty)) {
            return "$hint is required";
          }
          if (passField == 2 && value != _passController.text) {
            return "Passwords do not match";
          }
          return null;
        },
      ),
    );
  }

  Widget _dot(double size, Color color) => Container(
        width:  size,
        height: size,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      );

  @override
  void dispose() {
    _nameController.dispose();
    _mobileController.dispose();
    _emailController.dispose();
    _passController.dispose();
    _confirmPassController.dispose();
    _refController.dispose();
    _otpController.dispose();
    super.dispose();
  }
}
