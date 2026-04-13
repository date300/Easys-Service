import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../main.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();

    _navigateToNext();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _navigateToNext() async {
    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return;

    final isLoggedIn = ref.read(authProvider);

    if (isLoggedIn) {
      context.go('/home');
    } else {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    // 🔥 DYNAMIC THEME COLORS
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Light Mode: আকাশী (Sky Blue) Gradient
    // Dark Mode: Pure Dark (Black/Grey) - কোনো Sky Blue নয়
    final gradientColors = isDark 
        ? const [Color(0xFF121212), Color(0xFF1E1E1E)]  // 🔥 Pure Dark
        : const [Color(0xFF2FB7F3), Color(0xFF1E88E5)]; // 🔥 আকাশী Sky Blue
    
    final navBarColor = isDark ? const Color(0xFF121212) : const Color(0xFF1E88E5);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: navBarColor,  // 🔥 DYNAMIC
      ),
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: gradientColors,  // 🔥 DYNAMIC
            ),
          ),
          child: Stack(
            children: [
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Logo Animation
                    SizedBox(
                      width: 120.w,
                      height: 120.w,
                      child: AnimatedBuilder(
                        animation: _rotationController,
                        builder: (context, child) {
                          return CustomPaint(
                            size: Size(120.w, 120.w),
                            painter: RotatingBorderPainter(
                              rotation: _rotationController.value,
                              isDark: isDark,  // 🔥 PASS THEME
                            ),
                            child: Center(
                              child: Container(
                                width: 85.w,
                                height: 85.w,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isDark 
                                      ? const Color(0xFF2C2C2C)  // 🔥 Dark mode: dark grey
                                      : Colors.white.withOpacity(0.1), // Light mode: transparent white
                                ),
                                child: Center(
                                  child: Image.asset(
                                    'assets/ultra5G.png',
                                    width: 65.w,
                                    height: 65.w,
                                  )
                                      .animate()
                                      .fadeIn(duration: 800.ms)
                                      .scale(
                                          begin: const Offset(0.5, 0.5),
                                          curve: Curves.elasticOut),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    SizedBox(height: 20.h),

                    Text(
                      "Easy Service",
                      style: GoogleFonts.poppins(
                        fontSize: 22.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        letterSpacing: 1.0,
                      ),
                    ).animate().fadeIn(delay: 400.ms).moveY(begin: 10, end: 0),

                    SizedBox(height: 30.h),

                    // Loading Dots
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(3, (index) {
                        return AnimatedBuilder(
                          animation: _pulseController,
                          builder: (context, child) {
                            final double delay = index * 0.3;
                            double value = (_pulseController.value - delay) % 1.0;
                            double scale = 0.6 + (0.4 * (1 - (value * 2 - 1).abs()));
                            double opacity = 0.4 + (0.6 * scale);

                            return Container(
                              margin: EdgeInsets.symmetric(horizontal: 4.w),
                              width: 10.w,
                              height: 10.w,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(opacity),
                                shape: BoxShape.circle,
                              ),
                              transform: Matrix4.identity()..scale(scale),
                            );
                          },
                        );
                      }),
                    ).animate().fadeIn(delay: 600.ms),
                  ],
                ),
              ),

              Positioned(
                bottom: 45.h,
                left: 0,
                right: 0,
                child: Column(
                  children: [
                    Text(
                      "from",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 10.sp,
                        letterSpacing: 1.2,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      "Target Win",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 2.5,
                      ),
                    ),
                  ],
                ).animate().fadeIn(delay: 800.ms).slideY(begin: 0.5, end: 0),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Rotating Border Painter with Dark Mode Support
class RotatingBorderPainter extends CustomPainter {
  final double rotation;
  final bool isDark;  // 🔥 THEME PARAMETER

  RotatingBorderPainter({
    required this.rotation,
    this.isDark = false,  // 🔥 DEFAULT LIGHT
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 5;

    // 🔥 DYNAMIC COLORS - Pure white for both modes, but different opacity
    final borderColor = isDark 
        ? Colors.white.withOpacity(0.5)  // Dark mode: dimmer white
        : Colors.white.withOpacity(0.8);  // Light mode: brighter white
    
    final dotColor = isDark
        ? Colors.white.withOpacity(0.7)   // Dark mode: dimmer
        : Colors.white;                   // Light mode: pure white

    final paint = Paint()
      ..color = borderColor  // 🔥 DYNAMIC
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final path = Path();
    final segments = 8;

    for (int i = 0; i < segments; i++) {
      final startAngle = (2 * pi * i / segments) + (rotation * 2 * pi);
      final endAngle = startAngle + (pi / segments * 1.2);

      final startX = center.dx + radius * 0.85 * cos(startAngle);
      final startY = center.dy + radius * 0.85 * sin(startAngle);
      final endX = center.dx + radius * cos(endAngle);
      final endY = center.dy + radius * sin(endAngle);

      if (i == 0) {
        path.moveTo(startX, startY);
      } else {
        path.lineTo(startX, startY);
      }

      path.quadraticBezierTo(
        center.dx + radius * 1.1 * cos((startAngle + endAngle) / 2),
        center.dy + radius * 1.1 * sin((startAngle + endAngle) / 2),
        endX,
        endY,
      );
    }

    path.close();
    canvas.drawPath(path, paint);

    // Outer Dots
    final dotPaint = Paint()
      ..color = dotColor  // 🔥 DYNAMIC
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 4; i++) {
      final angle = (2 * pi * i / 4) + (rotation * 2 * pi * 1.5);
      final dotX = center.dx + (radius + 15) * cos(angle);
      final dotY = center.dy + (radius + 15) * sin(angle);

      canvas.drawCircle(Offset(dotX, dotY), 4, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
