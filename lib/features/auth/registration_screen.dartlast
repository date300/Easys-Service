import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';

import '../../main.dart';
import '../../core/services/app_sound_service.dart';

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

  // Responsive breakpoints
  bool _isDesktop(BuildContext ctx) => MediaQuery.of(ctx).size.width >= 1100;
  bool _isTablet(BuildContext ctx) =>
      MediaQuery.of(ctx).size.width >= 600 &&
      MediaQuery.of(ctx).size.width < 1100;

  // Responsive font size - smaller values
  double _fs(BuildContext ctx, double m, double t, double d) {
    if (_isDesktop(ctx)) return d;
    if (_isTablet(ctx)) return t;
    return m;
  }

  // Max width constraints
  double _maxWidth(BuildContext ctx) {
    if (_isDesktop(ctx)) return 400; // Reduced from 480
    if (_isTablet(ctx)) return 450; // Reduced from 520
    return double.infinity;
  }

  // Top section height - smaller
  double _topHeight(BuildContext ctx) {
    if (_isTablet(ctx)) return 140; // Reduced from 170
    return 120.h; // Reduced from 155.h
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
        await AppSoundService.instance.playOtp();
        if (!mounted) return;
        _showSnack(data['message'], Colors.green);
        setState(() => _isOtpSent = true);
      } else {
        await AppSoundService.instance.playError();
        _showSnack(data['message'], Colors.red);
      }
    } catch (_) {
      await AppSoundService.instance.playError();
      _showSnack("Connection error!", Colors.red);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _verifyOtp() async {
    final otp = _otpController.text.trim();
    if (otp.length < 6) {
      await AppSoundService.instance.playError();
      _showSnack("Please enter 6-digit OTP", Colors.red);
      return;
    }
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
        await AppSoundService.instance.playLogin();
        await ref.read(authProvider.notifier).loginWithToken(data['token']);
        if (!mounted) return;
        _showSnack(data['message'], Colors.green);
        context.go('/home');
      } else {
        await AppSoundService.instance.playError();
        _showSnack(data['message'], Colors.red);
      }
    } catch (_) {
      await AppSoundService.instance.playError();
      _showSnack("Connection error!", Colors.red);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnack(String msg, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: GoogleFonts.poppins(fontSize: 12)),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
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

  // Desktop Layout - compact design
  Widget _desktopLayout(BuildContext ctx) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: _maxWidth(ctx)),
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20)),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    color: skyBlue,
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        vertical: 24, horizontal: 24),
                    child: Column(
                      children: [
                        SizedBox(
                          width: 70, // Reduced from 90
                          height: 70,
                          child: _isOtpSent
                              ? Lottie.network(
                                  'https://assets9.lottiefiles.com/packages/lf20_uu0x8lqv.json',
                                  fit: BoxFit.contain,
                                  errorBuilder: (_, __, ___) => const Icon(
                                    Icons.mark_email_read_rounded,
                                    size: 60,
                                    color: Colors.white,
                                  ),
                                )
                              : Lottie.network(
                                  'https://assets2.lottiefiles.com/packages/lf20_vvplpqub.json',
                                  fit: BoxFit.contain,
                                  errorBuilder: (_, __, ___) => const Icon(
                                    Icons.lock_rounded,
                                    size: 60,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _isOtpSent ? 'OTP Verification' : 'Create Account',
                          style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 20), // Reduced from 24
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 20),
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

  // Mobile & Tablet Layout - compact design
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
                  padding: EdgeInsets.symmetric(
                      horizontal: 4.w, vertical: 4.h),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_rounded,
                            color: Colors.white, size: 22),
                        onPressed: () {},
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        _isOtpSent ? 'OTP Verification' : 'Register',
                        style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: _fs(ctx, 18, 20, 22)),
                      ),
                    ],
                  ),
                ),
                Center(
                  child: Padding(
                    padding: EdgeInsets.only(top: 16.h),
                    child: SizedBox(
                      width: isTablet ? 90 : 70.sp, // Reduced sizes
                      height: isTablet ? 90 : 70.sp,
                      child: _isOtpSent
                          ? Lottie.network(
                              'https://assets9.lottiefiles.com/packages/lf20_uu0x8lqv.json',
                              fit: BoxFit.contain,
                              errorBuilder: (_, __, ___) => Icon(
                                Icons.mark_email_read_rounded,
                                size: isTablet ? 85 : 75.sp,
                                color: Colors.white.withOpacity(0.9),
                              ),
                            )
                          : Lottie.network(
                              'https://assets2.lottiefiles.com/packages/lf20_vvplpqub.json',
                              fit: BoxFit.contain,
                              errorBuilder: (_, __, ___) => Icon(
                                Icons.lock_rounded,
                                size: isTablet ? 85 : 75.sp,
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                    ),
                  ),
                ),
                // Decorative dots - smaller
                Positioned(
                    top: 20.h,
                    left: 20.w,
                    child: _dot(8, Colors.white.withOpacity(0.3))),
                Positioned(
                    top: 45.h,
                    right: 30.w,
                    child: _dot(6, Colors.white.withOpacity(0.2))),
                Positioned(
                    bottom: 15.h,
                    left: 45.w,
                    child: _dot(5, Colors.white.withOpacity(0.25))),
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
                topLeft: Radius.circular(24.r), // Reduced from 36.r
                topRight: Radius.circular(24.r),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 15,
                  offset: const Offset(0, -3),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24.r),
                topRight: Radius.circular(24.r),
              ),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.only(
                    left: isTablet ? 32 : 20.w,
                    right: isTablet ? 32 : 20.w,
                    top: 24.h,
                    bottom: 24.h),
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

  // Registration Form - compact fields
  Widget _buildRegForm(BuildContext ctx) {
    final isDesktop = _isDesktop(ctx);
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
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

          _label(ctx, "Affiliate ID (Optional)"),
          _field(ctx, _refController, "Enter your affiliate id",
              optional: true),

          SizedBox(height: isDesktop ? 20 : 20.h),

          SizedBox(
            width: double.infinity,
            height: isDesktop ? 46 : 46.h, // Reduced from 54
            child: _isLoading
                ? const Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                          color: skyBlue, strokeWidth: 2.5),
                    ),
                  )
                : ElevatedButton(
                    onPressed: () {
                      AppSoundService.instance.playTap();
                      _register();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: skyBlue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              isDesktop ? 12 : 12.r)),
                      elevation: 1.5,
                      shadowColor: skyBlue.withOpacity(0.3),
                      padding: EdgeInsets.zero,
                    ),
                    child: Text("Register",
                        style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            fontSize: _fs(ctx, 14, 15, 16))),
                  ),
          ),

          SizedBox(height: isDesktop ? 16 : 16.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Already have an account? ",
                  style: GoogleFonts.poppins(
                      color: Colors.black54,
                      fontSize: _fs(ctx, 12, 12, 13))),
              GestureDetector(
                onTap: () => context.go('/login'),
                child: Text("Login",
                    style: GoogleFonts.poppins(
                        color: skyBlue,
                        fontWeight: FontWeight.w600,
                        fontSize: _fs(ctx, 12, 12, 13))),
              ),
            ],
          ),
          SizedBox(height: isDesktop ? 8 : 8.h),
        ],
      ),
    );
  }

  // OTP Form - compact design
  Widget _buildOtpForm(BuildContext ctx) {
    final isDesktop = _isDesktop(ctx);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(height: isDesktop ? 8 : 8.h),
        Text("We have sent an OTP to",
            style: GoogleFonts.poppins(
                color: Colors.black54, fontSize: _fs(ctx, 13, 13, 14))),
        Text(_emailController.text,
            style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: _fs(ctx, 14, 14, 15),
                color: Colors.black87)),
        SizedBox(height: isDesktop ? 24 : 24.h),
        TextField(
          controller: _otpController,
          keyboardType: TextInputType.number,
          maxLength: 6,
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
              fontSize: isDesktop ? 24 : 24.sp, letterSpacing: 8),
          decoration: InputDecoration(
            hintText: "------",
            counterText: "",
            filled: true,
            fillColor: const Color(0xFFF3F4F6),
            border: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(isDesktop ? 12 : 12.r),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(isDesktop ? 12 : 12.r),
              borderSide: const BorderSide(color: skyBlue, width: 2),
            ),
            contentPadding: EdgeInsets.symmetric(
                vertical: isDesktop ? 16 : 14.h),
          ),
        ),
        SizedBox(height: isDesktop ? 24 : 24.h),
        SizedBox(
          width: double.infinity,
          height: isDesktop ? 46 : 46.h,
          child: _isLoading
              ? const Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                        color: skyBlue, strokeWidth: 2.5),
                  ),
                )
              : ElevatedButton(
                  onPressed: () {
                    AppSoundService.instance.playTap();
                    _verifyOtp();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: skyBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                            isDesktop ? 12 : 12.r)),
                    elevation: 1.5,
                    shadowColor: skyBlue.withOpacity(0.3),
                    padding: EdgeInsets.zero,
                  ),
                  child: Text("Verify & Login",
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: _fs(ctx, 14, 15, 16))),
                ),
        ),
        SizedBox(height: isDesktop ? 12 : 12.h),
        TextButton(
          onPressed: () => setState(() => _isOtpSent = false),
          style: TextButton.styleFrom(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text("Change Email Address",
              style: GoogleFonts.poppins(
                  color: skyBlue, fontSize: _fs(ctx, 12, 12, 13))),
        ),
      ],
    );
  }

  // Helpers - compact sizes
  Widget _label(BuildContext ctx, String text) => Padding(
        padding: EdgeInsets.only(bottom: _isDesktop(ctx) ? 4 : 4.h),
        child: Text(text,
            style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: _fs(ctx, 12, 12, 13),
                color: Colors.black87)),
      );

  Widget _gap(BuildContext ctx) =>
      SizedBox(height: _isDesktop(ctx) ? 12 : 12.h);

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
    final radius = isDesktop ? 10.0 : 10.r;
    final vPad = isDesktop ? 12.0 : 12.h;
    final hPad = isDesktop ? 14.0 : 14.w;

    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      style: GoogleFonts.poppins(fontSize: _fs(ctx, 13, 13, 14)),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.poppins(
            color: Colors.black38, fontSize: _fs(ctx, 12, 12, 13)),
        filled: true,
        fillColor: const Color(0xFFF3F4F6),
        contentPadding: EdgeInsets.symmetric(horizontal: hPad, vertical: vPad),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: const BorderSide(color: skyBlue, width: 1.5),
        ),
        suffixIcon: passField == 0
            ? null
            : IconButton(
                icon: Icon(
                  obscure ? Icons.visibility_off : Icons.visibility,
                  color: Colors.black45,
                  size: isDesktop ? 20 : 18.sp,
                ),
                onPressed: () {
                  AppSoundService.instance.playTap();
                  setState(() {
                    if (passField == 1) {
                      _passVisible = !_passVisible;
                    } else {
                      _confirmPassVisible = !_confirmPassVisible;
                    }
                  });
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
        isDense: true,
      ),
      validator: optional
          ? null
          : (value) {
              if (value == null || value.trim().isEmpty) {
                return "Required";
              }
              if (passField == 2 && value != _passController.text) {
                return "Passwords do not match";
              }
              if (keyboardType == TextInputType.emailAddress &&
                  !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                      .hasMatch(value)) {
                return "Invalid email";
              }
              if (keyboardType == TextInputType.phone &&
                  !RegExp(r'^\+?[\d\s-]{10,}$').hasMatch(value)) {
                return "Invalid mobile";
              }
              return null;
            },
    );
  }

  Widget _dot(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }

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
