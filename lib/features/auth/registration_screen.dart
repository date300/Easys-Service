import 'package:flutter/material.dart';
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
  static const Color skyBlue = Color(0xFF29B6F6);

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _emailController = TextEditingController();
  final _passController = TextEditingController();
  final _confirmPassController = TextEditingController();
  final _refController = TextEditingController();
  final _otpController = TextEditingController();

  bool _isLoading = false;
  bool _isOtpSent = false;
  bool _passVisible = false;
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
        _showSnack(data['message'], Colors.green);
        setState(() => _isOtpSent = true);
      } else {
        _showSnack(data['message'], Colors.red);
      }
    } catch (_) {
      _showSnack("সার্ভার সংযোগ ব্যর্থ হয়েছে!", Colors.red);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _verifyOtp() async {
    final otp = _otpController.text.trim();
    if (otp.length < 6) {
      _showSnack("সঠিক ৬ সংখ্যার OTP দিন", Colors.red);
      return;
    }
    setState(() => _isLoading = true);
    try {
      final response = await http.post(
        Uri.parse("https://easy.ltcminematrix.com/api/verify-otp"),
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
        _showSnack(data['message'], Colors.green);
        context.go('/home');
      } else {
        _showSnack(data['message'], Colors.red);
      }
    } catch (_) {
      _showSnack("সার্ভার সংযোগ ব্যর্থ হয়েছে!", Colors.red);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnack(String msg, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg), backgroundColor: color));
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = _isDesktop(context);
    final isTablet = _isTablet(context);

    return Scaffold(
      backgroundColor: skyBlue,
      body: isDesktop
          ? _desktopLayout(context)
          : _mobileTabletLayout(context, isTablet),
    );
  }

  // ── Desktop ──────────────────────────────────────────────────────
  Widget _desktopLayout(BuildContext ctx) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: _maxWidth(ctx)),
          child: Card(
            elevation: 10,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28)),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: Column(
                children: [
                  Container(
                    color: skyBlue,
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        vertical: 36, horizontal: 32),
                    child: Column(
                      children: [
                        Icon(
                          _isOtpSent
                              ? Icons.mark_email_read_rounded
                              : Icons.lock_rounded,
                          size: 80,
                          color: Colors.white.withOpacity(0.9),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _isOtpSent ? 'OTP Verification' : 'Create Account',
                          style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 24),
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
    );
  }

  // ── Mobile & Tablet ──────────────────────────────────────────────
  Widget _mobileTabletLayout(BuildContext ctx, bool isTablet) {
    return Column(
      children: [
        SafeArea(
          bottom: false,
          child: SizedBox(
            height: _topHeight(ctx),
            child: Stack(
              children: [
                Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_rounded,
                            color: Colors.white),
                        onPressed: () {},
                      ),
                      Text(
                        _isOtpSent ? 'OTP Verification' : 'Register',
                        style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: _fs(ctx, 20, 22, 24)),
                      ),
                    ],
                  ),
                ),
                Center(
                  child: Padding(
                    padding: EdgeInsets.only(top: 30.h),
                    child: Icon(
                      _isOtpSent
                          ? Icons.mark_email_read_rounded
                          : Icons.lock_rounded,
                      size: isTablet ? 110 : 95.sp,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ),
                Positioned(
                    top: 30.h,
                    left: 30.w,
                    child: _dot(10, Colors.white.withOpacity(0.3))),
                Positioned(
                    top: 60.h,
                    right: 40.w,
                    child: _dot(8, Colors.white.withOpacity(0.2))),
                Positioned(
                    bottom: 20.h,
                    left: 60.w,
                    child: _dot(6, Colors.white.withOpacity(0.25))),
              ],
            ),
          ),
        ),
        Expanded(
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(32.r),
                topRight: Radius.circular(32.r),
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(32.r),
                topRight: Radius.circular(32.r),
              ),
              child: SingleChildScrollView(
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
    );
  }

  // ── Registration Form ────────────────────────────────────────────
  Widget _buildRegForm(BuildContext ctx) {
    final isDesktop = _isDesktop(ctx);
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _label(ctx, "Full Name"),
          _field(ctx, _nameController, "Enter your full name",
              keyboardType: TextInputType.name),
          _gap(ctx),

          _label(ctx, "Mobile Number"),
          _field(ctx, _mobileController, "Enter your mobile number",
              keyboardType: TextInputType.phone),
          _gap(ctx),

          _label(ctx, "Email Address"),
          _field(ctx, _emailController, "Enter your email address",
              keyboardType: TextInputType.emailAddress),
          _gap(ctx),

          _label(ctx, "Password"),
          _field(ctx, _passController, "Enter your password", passField: 1),
          _gap(ctx),

          _label(ctx, "Confirm Password"),
          _field(ctx, _confirmPassController, "Enter your password",
              passField: 2),
          _gap(ctx),

          // Affiliate ID — Optional
          _label(ctx, "Affiliate ID (Optional)"),
          _field(ctx, _refController, "Enter your affiliate id",
              optional: true),

          SizedBox(height: isDesktop ? 28 : 28.h),

          SizedBox(
            width: double.infinity,
            height: isDesktop ? 52 : 52.h,
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: skyBlue))
                : ElevatedButton(
                    onPressed: _register,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: skyBlue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              isDesktop ? 14 : 14.r)),
                      elevation: 0,
                    ),
                    child: Text("Register",
                        style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            fontSize: _fs(ctx, 15, 16, 17))),
                  ),
          ),

          SizedBox(height: isDesktop ? 20 : 20.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Already have an account? ",
                  style: GoogleFonts.poppins(
                      color: Colors.black54,
                      fontSize: _fs(ctx, 13, 13, 14))),
              GestureDetector(
                onTap: () => context.go('/login'),
                child: Text("Login",
                    style: GoogleFonts.poppins(
                        color: skyBlue,
                        fontWeight: FontWeight.bold,
                        fontSize: _fs(ctx, 13, 13, 14))),
              ),
            ],
          ),
          SizedBox(height: isDesktop ? 10 : 10.h),
        ],
      ),
    );
  }

  // ── OTP Form ─────────────────────────────────────────────────────
  Widget _buildOtpForm(BuildContext ctx) {
    final isDesktop = _isDesktop(ctx);
    return Column(
      children: [
        SizedBox(height: isDesktop ? 10 : 10.h),
        Text("We have sent an OTP to",
            style: GoogleFonts.poppins(
                color: Colors.black54, fontSize: _fs(ctx, 14, 14, 15))),
        Text(_emailController.text,
            style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: _fs(ctx, 15, 15, 16),
                color: Colors.black87)),
        SizedBox(height: isDesktop ? 30 : 30.h),
        TextField(
          controller: _otpController,
          keyboardType: TextInputType.number,
          maxLength: 6,
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
              fontSize: isDesktop ? 28 : 28.sp, letterSpacing: 12),
          decoration: InputDecoration(
            hintText: "------",
            counterText: "",
            filled: true,
            fillColor: const Color(0xFFF3F4F6),
            border: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(isDesktop ? 14 : 14.r),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        SizedBox(height: isDesktop ? 30 : 30.h),
        SizedBox(
          width: double.infinity,
          height: isDesktop ? 52 : 52.h,
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: skyBlue))
              : ElevatedButton(
                  onPressed: _verifyOtp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: skyBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                            isDesktop ? 14 : 14.r)),
                    elevation: 0,
                  ),
                  child: Text("Verify & Login",
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: _fs(ctx, 15, 16, 17))),
                ),
        ),
        SizedBox(height: isDesktop ? 16 : 16.h),
        TextButton(
          onPressed: () => setState(() => _isOtpSent = false),
          child: Text("Change Email Address",
              style: GoogleFonts.poppins(
                  color: skyBlue, fontSize: _fs(ctx, 13, 13, 14))),
        ),
      ],
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────
  Widget _label(BuildContext ctx, String text) => Padding(
        padding: EdgeInsets.only(bottom: _isDesktop(ctx) ? 6 : 6.h),
        child: Text(text,
            style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: _fs(ctx, 13, 13, 14),
                color: Colors.black87)),
      );

  Widget _gap(BuildContext ctx) =>
      SizedBox(height: _isDesktop(ctx) ? 14 : 14.h);

  Widget _field(
    BuildContext ctx,
    TextEditingController controller,
    String hint, {
    int passField = 0,
    TextInputType keyboardType = TextInputType.text,
    bool optional = false,
  }) {
    final obscure = passField == 1
        ? !_passVisible
        : passField == 2
            ? !_confirmPassVisible
            : false;
    final isDesktop = _isDesktop(ctx);
    final radius = isDesktop ? 12.0 : 12.r;
    final vPad = isDesktop ? 15.0 : 14.h;
    final hPad = isDesktop ? 16.0 : 16.w;

    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      style: GoogleFonts.poppins(fontSize: _fs(ctx, 13, 13, 14)),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.poppins(
            color: Colors.black38, fontSize: _fs(ctx, 13, 13, 14)),
        filled: true,
        fillColor: const Color(0xFFF3F4F6),
        contentPadding:
            EdgeInsets.symmetric(horizontal: hPad, vertical: vPad),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: BorderSide.none,
        ),
        suffixIcon: passField != 0
            ? IconButton(
                icon: Icon(
                  passField == 1
                      ? (_passVisible
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined)
                      : (_confirmPassVisible
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined),
                  color: Colors.black38,
                  size: _fs(ctx, 20, 21, 22),
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
    );
  }

  Widget _dot(double size, Color color) => Container(
        width: size,
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
