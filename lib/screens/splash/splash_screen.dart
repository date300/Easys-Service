import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // স্ট্যাটাস বার ট্রান্সপারেন্ট করার জন্য এটি যোগ করা হয়েছে
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

// আপনার main.dart থেকে authProvider ইমপোর্ট করা হয়েছে
import '../../main.dart'; 

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNext();
  }

  void _navigateToNext() async {
    // ৩ সেকেন্ড স্প্ল্যাশ স্ক্রিন দেখাবে
    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return;

    final isLoggedIn = ref.read(authProvider);

    if (isLoggedIn) {
      context.go('/home'); 
    } else {
      context.go('/registration'); 
    }
  }

  @override
  Widget build(BuildContext context) {
    // AnnotatedRegion ব্যবহার করা হয়েছে যাতে স্ট্যাটাস বার (WiFi, Battery) এর ব্যাকগ্রাউন্ড ট্রান্সপারেন্ট হয়
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent, // উপরের কালো ভাব দূর করবে
        statusBarIconBrightness: Brightness.light, // আইকনগুলো (WiFi/Battery) সাদা রঙের দেখাবে
        systemNavigationBarColor: Color(0xFF1E88E5), // নিচের নেভিগেশন বার কালার (ঐচ্ছিক)
      ),
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF2FB7F3),
                Color(0xFF1E88E5),
              ],
            ),
          ),
          child: Stack(
            children: [
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // আইকনের বদলে আপনার লোগো বসানো হয়েছে
                    Image.asset(
                      'assets/EasyService.png',
                      width: 100.w, // লোগোর সাইজ প্রয়োজন মতো কাস্টমাইজ করে নিতে পারবেন
                      height: 100.w,
                    )
                    .animate()
                    .fadeIn(duration: 800.ms)
                    .scale(begin: const Offset(0.5, 0.5), curve: Curves.elasticOut),
                    
                    SizedBox(height: 16.h),
                    
                    // অ্যাপের নাম
                    Text(
                      "Easy Service",
                      style: GoogleFonts.poppins(
                        fontSize: 30.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1.2,
                      ),
                    ).animate().fadeIn(delay: 400.ms).moveY(begin: 10, end: 0),
                  ],
                ),
              ),
              
              // নিচের ব্র্যান্ডিং
              Positioned(
                bottom: 60.h,
                left: 0,
                right: 0,
                child: Column(
                  children: [
                    Text(
                      "from",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 14.sp,
                        letterSpacing: 1.5,
                      ),
                    ),
                    SizedBox(height: 5.h),
                    Text(
                      "TECH SOLUTION",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 4, 
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

