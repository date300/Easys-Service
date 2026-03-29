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

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    const String apiUrl = "https://easy.ltcminematrix.com/api/register";
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(data['message']),
              backgroundColor: Colors.green),
        );
        setState(() => _isOtpSent = true);
      } else {
        _showError(data['message']);
      }
    } catch (_) {
      _showError("সার্ভার সংযোগ ব্যর্থ হয়েছে!");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _verifyOtp() async {
    final otp = _otpController.text.trim();
    if (otp.length < 6) {
      _showError("সঠিক ৬ সংখ্যার OTP দিন");
      return;
    }
    setState(() => _isLoading = true);
    const String apiUrl = "https://easy.ltcminematrix.com/api/verify-otp";
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": _emailController.text.trim(),
          "otp": otp,
        }),
      );
      final data = jsonDecode(response.body);
      if (data['status'] == "success") {
        final token = data['token'];
        await ref.read(authProvider.notifier).loginWithToken(token);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(data['message']),
              backgroundColor: Colors.green),
        );
        context.go('/home');
      } else {
        _showError(data['message']);
      }
    } catch (_) {
      _showError("সার্ভার সংযোগ ব্যর্থ হয়েছে!");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: Colors.red));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: skyBlue,
      body: Column(
        children: [
          // ── Top section (Sky Blue) ──────────────────────────────
          SafeArea(
            bottom: false,
            child: SizedBox(
              height: 220.h,
              child: Stack(
                children: [
                  // Back button + Title
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
                              fontSize: 20.sp),
                        ),
                      ],
                    ),
                  ),
                  // Illustration
                  Center(
                    child: Padding(
                      padding: EdgeInsets.only(top: 30.h),
                      child: Icon(
                        _isOtpSent
                            ? Icons.mark_email_read_rounded
                            : Icons.lock_rounded,
                        size: 100.sp,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ),
                  // Decorative circles
                  Positioned(
                    top: 30.h,
                    left: 30.w,
                    child: _circle(10, Colors.white.withOpacity(0.3)),
                  ),
                  Positioned(
                    top: 60.h,
                    right: 40.w,
                    child: _circle(8, Colors.white.withOpacity(0.2)),
                  ),
                  Positioned(
                    bottom: 20.h,
                    left: 60.w,
                    child: _circle(6, Colors.white.withOpacity(0.25)),
                  ),
                ],
              ),
            ),
          ),

          // ── Bottom white card ───────────────────────────────────
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
                  padding:
                      EdgeInsets.symmetric(horizontal: 24.w, vertical: 28.h),
                  child:
                      _isOtpSent ? _buildOtpForm() : _buildRegistrationForm(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _circle(double size, Color color) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      );

  Widget _buildRegistrationForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _fieldLabel("Full Name"),
          _buildTextField(_nameController, "Enter your full name",
              keyboardType: TextInputType.name),
          SizedBox(height: 14.h),

          _fieldLabel("Mobile Number"),
          _buildTextField(_mobileController, "Enter your mobile number",
              keyboardType: TextInputType.phone),
          SizedBox(height: 14.h),

          _fieldLabel("Email Address"),
          _buildTextField(_emailController, "Enter your email address",
              keyboardType: TextInputType.emailAddress),
          SizedBox(height: 14.h),

          _fieldLabel("Password"),
          _buildTextField(_passController, "Enter your password",
              isPassword: true, isPassField: 1),
          SizedBox(height: 14.h),

          _fieldLabel("Confirm Password"),
          _buildTextField(_confirmPassController, "Enter your password",
              isPassword: true, isPassField: 2),
          SizedBox(height: 14.h),

          _fieldLabel("Affiliate ID"),
          _buildTextField(_refController, "Enter your affiliate id"),
          SizedBox(height: 28.h),

          SizedBox(
            width: double.infinity,
            height: 52.h,
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: skyBlue))
                : ElevatedButton(
                    onPressed: _register,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: skyBlue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14.r)),
                      elevation: 0,
                    ),
                    child: Text(
                      "Register",
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold, fontSize: 16.sp),
                    ),
                  ),
          ),
          SizedBox(height: 20.h),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Already have an account? ",
                  style: GoogleFonts.poppins(
                      color: Colors.black54, fontSize: 13.sp)),
              GestureDetector(
                onTap: () => context.go('/login'),
                child: Text("Login",
                    style: GoogleFonts.poppins(
                        color: skyBlue,
                        fontWeight: FontWeight.bold,
                        fontSize: 13.sp)),
              ),
            ],
          ),
          SizedBox(height: 10.h),
        ],
      ),
    );
  }

  Widget _buildOtpForm() {
    return Column(
      children: [
        SizedBox(height: 10.h),
        Text(
          "We have sent an OTP to",
          style: GoogleFonts.poppins(color: Colors.black54, fontSize: 14.sp),
        ),
        Text(
          _emailController.text,
          style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              fontSize: 15.sp,
              color: Colors.black87),
        ),
        SizedBox(height: 30.h),

        TextField(
          controller: _otpController,
          keyboardType: TextInputType.number,
          maxLength: 6,
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(fontSize: 28.sp, letterSpacing: 12),
          decoration: InputDecoration(
            hintText: "------",
            counterText: "",
            filled: true,
            fillColor: const Color(0xFFF3F4F6),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14.r),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        SizedBox(height: 30.h),

        SizedBox(
          width: double.infinity,
          height: 52.h,
          child: _isLoading
              ? const Center(child: CircularProgressIndicator(color: skyBlue))
              : ElevatedButton(
                  onPressed: _verifyOtp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: skyBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14.r)),
                    elevation: 0,
                  ),
                  child: Text("Verify & Login",
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold, fontSize: 16.sp)),
                ),
        ),
        SizedBox(height: 16.h),

        TextButton(
          onPressed: () => setState(() => _isOtpSent = false),
          child: Text("Change Email Address",
              style: GoogleFonts.poppins(color: skyBlue, fontSize: 13.sp)),
        ),
      ],
    );
  }

  Widget _fieldLabel(String label) {
    return Padding(
      padding: EdgeInsets.only(bottom: 6.h),
      child: Text(
        label,
        style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 13.sp,
            color: Colors.black87),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hint, {
    bool isPassword = false,
    int isPassField = 0, // 1 = password, 2 = confirm
    TextInputType keyboardType = TextInputType.text,
    bool optional = false,
  }) {
    final obscure = isPassField == 1
        ? !_passVisible
        : isPassField == 2
            ? !_confirmPassVisible
            : isPassword;

    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      style: GoogleFonts.poppins(fontSize: 13.sp),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.poppins(
            color: Colors.black38, fontSize: 13.sp),
        filled: true,
        fillColor: const Color(0xFFF3F4F6),
        contentPadding:
            EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide.none,
        ),
        suffixIcon: isPassField != 0
            ? IconButton(
                icon: Icon(
                  isPassField == 1
                      ? (_passVisible
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_off_outlined)
                      : (_confirmPassVisible
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_off_outlined),
                  color: Colors.black38,
                  size: 20.sp,
                ),
                onPressed: () {
                  setState(() {
                    if (isPassField == 1) {
                      _passVisible = !_passVisible;
                    } else {
                      _confirmPassVisible = !_confirmPassVisible;
                    }
                  });
                },
              )
            : null,
      ),
      validator: (value) {
        if (!optional && (value == null || value.isEmpty)) {
          return "$hint is required";
        }
        if (isPassField == 2 && value != _passController.text) {
          return "Passwords do not match";
        }
        return null;
      },
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
