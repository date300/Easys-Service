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

  // Responsive breakpoints
  bool _isDesktop(BuildContext ctx) => MediaQuery.of(ctx).size.width >= 1100;
  bool _isTablet(BuildContext ctx) =>
      MediaQuery.of(ctx).size.width >= 600 &&
      MediaQuery.of(ctx).size.width < 1100;

  // Responsive font size
  double _fs(BuildContext ctx, double m, double t, double d) {
    if (_isDesktop(ctx)) return d;
    if (_isTablet(ctx)) return t;
    return m;
  }

  // Max width constraints
  double _maxWidth(BuildContext ctx) {
    if (_isDesktop(ctx)) return 400;
    if (_isTablet(ctx)) return 450;
    return double.infinity;
  }

  // Top section height
  double _topHeight(BuildContext ctx) {
    if (_isTablet(ctx)) return 140;
    return 120.h;
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    
    try {
      final response = await http.post(
        Uri.parse("https://easysarvice.com/api/auth/login"),
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
        
        // Navigate to home
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
    
    // 🔥 DYNAMIC SNACKBAR
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          msg, 
          style: GoogleFonts.poppins(fontSize: 12),
        ),
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : color,
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
    
    // 🔥 DYNAMIC THEME COLORS
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scaffoldBg = isDark ? const Color(0xFF121212) : skyBlue;
    final cardBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subTextColor = isDark ? Colors.grey.shade400 : Colors.black54;
    final hintColor = isDark ? Colors.grey.shade500 : Colors.black38;
    final fieldBg = isDark ? const Color(0xFF2C2C2C) : const Color(0xFFF3F4F6);
    final shadowColor = isDark ? Colors.black.withOpacity(0.3) : Colors.black.withOpacity(0.08);

    return Scaffold(
      backgroundColor: scaffoldBg,  // 🔥 DYNAMIC
      body: isDesktop
          ? _desktopLayout(context, isDark, cardBg, textColor, subTextColor, fieldBg, shadowColor)
          : _mobileTabletLayout(context, isTablet, isDark, cardBg, textColor, subTextColor, hintColor, fieldBg, shadowColor),
    );
  }

  // Desktop Layout
  Widget _desktopLayout(
    BuildContext ctx,
    bool isDark,
    Color cardBg,
    Color textColor,
    Color subTextColor,
    Color fieldBg,
    Color shadowColor,
  ) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: _maxWidth(ctx)),
          child: Card(
            elevation: isDark ? 0 : 8,
            color: cardBg,  // 🔥 DYNAMIC
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: isDark ? const BorderSide(color: Color(0xFF333333)) : BorderSide.none,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    color: skyBlue,  // Header always skyBlue
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      vertical: 24, 
                      horizontal: 24,
                    ),
                    child: Column(
                      children: [
                        SizedBox(
                          width: 70,
                          height: 70,
                          child: Lottie.network(
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
                          'Welcome Back',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Login to your account',
                          style: GoogleFonts.poppins(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24, 
                      vertical: 20,
                    ),
                    child: _buildLoginForm(
                      ctx, 
                      isDark, 
                      textColor, 
                      subTextColor, 
                      fieldBg,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Mobile & Tablet Layout
  Widget _mobileTabletLayout(
    BuildContext ctx,
    bool isTablet,
    bool isDark,
    Color cardBg,
    Color textColor,
    Color subTextColor,
    Color hintColor,
    Color fieldBg,
    Color shadowColor,
  ) {
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
                    horizontal: 4.w, 
                    vertical: 4.h,
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.arrow_back_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                        onPressed: () => context.pop(),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        'Login',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: _fs(ctx, 18, 20, 22),
                        ),
                      ),
                    ],
                  ),
                ),
                Center(
                  child: Padding(
                    padding: EdgeInsets.only(top: 16.h),
                    child: SizedBox(
                      width: isTablet ? 90 : 70.sp,
                      height: isTablet ? 90 : 70.sp,
                      child: Lottie.network(
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
                // Decorative dots
                Positioned(
                  top: 20.h,
                  left: 20.w,
                  child: _dot(8, Colors.white.withOpacity(0.3)),
                ),
                Positioned(
                  top: 45.h,
                  right: 30.w,
                  child: _dot(6, Colors.white.withOpacity(0.2)),
                ),
                Positioned(
                  bottom: 15.h,
                  left: 45.w,
                  child: _dot(5, Colors.white.withOpacity(0.25)),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: cardBg,  // 🔥 DYNAMIC
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24.r),
                topRight: Radius.circular(24.r),
              ),
              boxShadow: [
                BoxShadow(
                  color: shadowColor,  // 🔥 DYNAMIC
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
                  bottom: 24.h,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: _maxWidth(ctx)),
                    child: _buildLoginForm(
                      ctx, 
                      isDark, 
                      textColor, 
                      subTextColor, 
                      fieldBg,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Login Form
  Widget _buildLoginForm(
    BuildContext ctx,
    bool isDark,
    Color textColor,
    Color subTextColor,
    Color fieldBg,
  ) {
    final isDesktop = _isDesktop(ctx);
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _label(ctx, "Email Address", textColor),
          _field(
            ctx, 
            _emailController, 
            "Enter your email address",
            keyboardType: TextInputType.emailAddress,
            isDark: isDark,
            textColor: textColor,
            fieldBg: fieldBg,
          ),
          _gap(ctx),

          _label(ctx, "Password", textColor),
          _field(
            ctx, 
            _passController, 
            "Enter your password", 
            passField: true,
            isDark: isDark,
            textColor: textColor,
            fieldBg: fieldBg,
          ),
          
          SizedBox(height: isDesktop ? 8 : 8.h),
          
          // Forgot Password
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: () {
                AppSoundService.instance.playTap();
                context.go('/forgot-password');
              },
              child: Text(
                "Forgot Password?",
                style: GoogleFonts.poppins(
                  color: skyBlue,
                  fontWeight: FontWeight.w500,
                  fontSize: _fs(ctx, 12, 12, 13),
                ),
              ),
            ),
          ),

          SizedBox(height: isDesktop ? 24 : 24.h),

          SizedBox(
            width: double.infinity,
            height: isDesktop ? 46 : 46.h,
            child: _isLoading
                ? Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: skyBlue, 
                        strokeWidth: 2.5,
                      ),
                    ),
                  )
                : ElevatedButton(
                    onPressed: () {
                      AppSoundService.instance.playTap();
                      _login();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: skyBlue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(isDesktop ? 12 : 12.r),
                      ),
                      elevation: isDark ? 0 : 1.5,
                      shadowColor: skyBlue.withOpacity(0.3),
                      padding: EdgeInsets.zero,
                    ),
                    child: Text(
                      "Login",
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: _fs(ctx, 14, 15, 16),
                      ),
                    ),
                  ),
          ),

          SizedBox(height: isDesktop ? 16 : 16.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Don't have an account? ",
                style: GoogleFonts.poppins(
                  color: subTextColor,  // 🔥 DYNAMIC
                  fontSize: _fs(ctx, 12, 12, 13),
                ),
              ),
              GestureDetector(
                onTap: () => context.go('/registration'),
                child: Text(
                  "Register",
                  style: GoogleFonts.poppins(
                    color: skyBlue,
                    fontWeight: FontWeight.w600,
                    fontSize: _fs(ctx, 12, 12, 13),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: isDesktop ? 8 : 8.h),
        ],
      ),
    );
  }

  // Helpers
  Widget _label(BuildContext ctx, String text, Color textColor) => Padding(
        padding: EdgeInsets.only(bottom: _isDesktop(ctx) ? 4 : 4.h),
        child: Text(
          text,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: _fs(ctx, 12, 12, 13),
            color: textColor,  // 🔥 DYNAMIC
          ),
        ),
      );

  Widget _gap(BuildContext ctx) =>
      SizedBox(height: _isDesktop(ctx) ? 12 : 12.h);

  Widget _field(
    BuildContext ctx,
    TextEditingController controller,
    String hint, {
    bool passField = false,
    TextInputType keyboardType = TextInputType.text,
    required bool isDark,
    required Color textColor,
    required Color fieldBg,
  }) {
    final obscure = passField ? !_passVisible : false;
    final isDesktop = _isDesktop(ctx);
    final radius = isDesktop ? 10.0 : 10.r;
    final vPad = isDesktop ? 12.0 : 12.h;
    final hPad = isDesktop ? 14.0 : 14.w;

    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      style: GoogleFonts.poppins(
        fontSize: _fs(ctx, 13, 13, 14),
        color: textColor,  // 🔥 DYNAMIC
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.poppins(
          color: isDark ? Colors.grey.shade500 : Colors.black38,  // 🔥 DYNAMIC
          fontSize: _fs(ctx, 12, 12, 13),
        ),
        filled: true,
        fillColor: fieldBg,  // 🔥 DYNAMIC
        contentPadding: EdgeInsets.symmetric(
          horizontal: hPad, 
          vertical: vPad,
        ),
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
          borderSide: BorderSide(
            color: skyBlue, 
            width: 1.5,
          ),
        ),
        suffixIcon: passField
            ? IconButton(
                icon: Icon(
                  obscure ? Icons.visibility_off : Icons.visibility,
                  color: isDark ? Colors.grey.shade400 : Colors.black45,  // 🔥 DYNAMIC
                  size: isDesktop ? 20 : 18.sp,
                ),
                onPressed: () {
                  AppSoundService.instance.playTap();
                  setState(() => _passVisible = !_passVisible);
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              )
            : null,
        isDense: true,
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return "Required";
        }
        if (keyboardType == TextInputType.emailAddress &&
            !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
          return "Invalid email";
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
    _emailController.dispose();
    _passController.dispose();
    super.dispose();
  }
}
