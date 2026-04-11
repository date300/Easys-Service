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

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  static const Color skyBlue = Color(0xFF29B6F6);

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passController = TextEditingController();

  bool _isLoading = false;
  bool _passVisible = false;

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
    if (_isTablet(ctx)) return 170;
    return 155.h;
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final response = await http.post(
        Uri.parse("https://easy.ltcminematrix.com/api/auth/login"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": _emailController.text.trim(),
          "password": _passController.text,
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

  // ── Desktop ──────────────────────────────────────────────────
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
                        SizedBox(
                          width: 90,
                          height: 90,
                          child: Lottie.network(
                            'https://assets2.lottiefiles.com/packages/lf20_vvplpqub.json',
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.lock_rounded,
                              size: 80,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Welcome Back',
                          style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 24),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Sign in to your account',
                          style: GoogleFonts.poppins(
                              color: Colors.white70,
                              fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 28),
                    child: _buildLoginForm(ctx),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Mobile & Tablet ──────────────────────────────────────────
  Widget _mobileTabletLayout(BuildContext ctx, bool isTablet) {
    return Column(
      children: [
        SafeArea(
          bottom: false,
          child: SizedBox(
            height: _topHeight(ctx),
            child: Stack(
              children: [
                // ✅ Back button এবং Title ঠিক করা হয়েছে
                Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: 12.w, vertical: 8.h),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: () {
                            if (context.canPop()) {
                              context.pop();
                            } else {
                              context.go('/'); // অথবা আপনার ডিফল্ট রুট
                            }
                          },
                          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
                        ),
                        Text(
                          'Login',
                          style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: _fs(ctx, 20, 22, 24)),
                        ),
                      ],
                    ),
                  ),
                ),
                Center(
                  child: Padding(
                    padding: EdgeInsets.only(top: 20.h),
                    child: SizedBox(
                      width: isTablet ? 115 : 90.sp,
                      height: isTablet ? 115 : 90.sp,
                      child: Lottie.network(
                        'https://assets2.lottiefiles.com/packages/lf20_vvplpqub.json',
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => Icon(
                          Icons.lock_rounded,
                          size: isTablet ? 110 : 95.sp,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
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
                topLeft: Radius.circular(36.r),
                topRight: Radius.circular(36.r),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 20,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(36.r),
                topRight: Radius.circular(36.r),
              ),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.only(
                    left: isTablet ? 40 : 24.w,
                    right: isTablet ? 40 : 24.w,
                    top: 32.h,
                    bottom: 40.h),
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: _maxWidth(ctx)),
                    child: _buildLoginForm(ctx),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── Login Form ───────────────────────────────────────────────
  Widget _buildLoginForm(BuildContext ctx) {
    final isDesktop = _isDesktop(ctx);
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _label(ctx, "Email Address"),
          _fieldEmail(ctx),
          _gap(ctx),

          _label(ctx, "Password"),
          _fieldPassword(ctx),

          SizedBox(height: isDesktop ? 10 : 10.h),

          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: () {
                // TODO: forgot password route
              },
              child: Text(
                "Forgot Password?",
                style: GoogleFonts.poppins(
                    color: skyBlue,
                    fontSize: _fs(ctx, 12, 13, 13),
                    fontWeight: FontWeight.w500),
              ),
            ),
          ),

          SizedBox(height: isDesktop ? 28 : 28.h),

          SizedBox(
            width: double.infinity,
            height: isDesktop ? 54 : 54.h,
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: skyBlue))
                : ElevatedButton(
                    onPressed: () {
                      AppSoundService.instance.playTap();
                      _login();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: skyBlue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              isDesktop ? 16 : 16.r)),
                      elevation: 2,
                      shadowColor: skyBlue.withOpacity(0.4),
                    ),
                    child: Text("Login",
                        style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            fontSize: _fs(ctx, 15, 16, 17))),
                  ),
          ),

          SizedBox(height: isDesktop ? 20 : 20.h),

          // ✅ Fixed Route: '/registration' → '/register'
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Don't have an account? ",
                  style: GoogleFonts.poppins(
                      color: Colors.black54,
                      fontSize: _fs(ctx, 13, 13, 14))),
              GestureDetector(
                onTap: () => context.go('/register'),
                child: Text("Register",
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

  // ── Helpers ──────────────────────────────────────────────────
  Widget _label(BuildContext ctx, String text) => Padding(
        padding: EdgeInsets.only(bottom: _isDesktop(ctx) ? 6 : 6.h),
        child: Text(text,
            style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: _fs(ctx, 13, 13, 14),
                color: Colors.black87)),
      );

  Widget _gap(BuildContext ctx) =>
      SizedBox(height: _isDesktop(ctx) ? 16 : 16.h);

  Widget _fieldEmail(BuildContext ctx) {
    final isDesktop = _isDesktop(ctx);
    final radius = isDesktop ? 14.0 : 14.r;
    final vPad = isDesktop ? 16.0 : 15.h;
    final hPad = isDesktop ? 18.0 : 16.w;

    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      style: GoogleFonts.poppins(fontSize: _fs(ctx, 13, 13, 14)),
      decoration: InputDecoration(
        hintText: "Enter your email address",
        hintStyle: GoogleFonts.poppins(
            color: Colors.black38, fontSize: _fs(ctx, 13, 13, 14)),
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
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return "Email is required";
        if (!value.contains('@')) return "Enter a valid email";
        return null;
      },
    );
  }

  Widget _fieldPassword(BuildContext ctx) {
    final isDesktop = _isDesktop(ctx);
    final radius = isDesktop ? 14.0 : 14.r;
    final vPad = isDesktop ? 16.0 : 15.h;
    final hPad = isDesktop ? 18.0 : 16.w;

    return TextFormField(
      controller: _passController,
      obscureText: !_passVisible,
      style: GoogleFonts.poppins(fontSize: _fs(ctx, 13, 13, 14)),
      decoration: InputDecoration(
        hintText: "Enter your password",
        hintStyle: GoogleFonts.poppins(
            color: Colors.black38, fontSize: _fs(ctx, 13, 13, 14)),
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
        suffixIcon: IconButton(
          icon: Icon(
            _passVisible
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
            color: Colors.black38,
            size: _fs(ctx, 20, 21, 22),
          ),
          onPressed: () => setState(() => _passVisible = !_passVisible),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return "Password is required";
        if (value.length < 6) return "Password must be at least 6 characters";
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
    _emailController.dispose();
    _passController.dispose();
    super.dispose();
  }
}
