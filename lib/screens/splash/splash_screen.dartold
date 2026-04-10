import 'package:flutter/material.dart';
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
    // ৩ সেকেন্ড স্প্ল্যাশ স্ক্রিন দেখাবে (এনিমেশনগুলো সুন্দরভাবে শেষ হওয়ার জন্য)
    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return;

    // রিভারপড থেকে লগইন স্ট্যাটাস চেক করা হচ্ছে
    final isLoggedIn = ref.read(authProvider);

    if (isLoggedIn) {
      context.go('/home'); // লগইন থাকলে হোমে যাবে
    } else {
      context.go('/registration'); // লগইন না থাকলে রেজিস্ট্রেশন স্ক্রিনে যাবে
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF2FB7F3), // আপনার দেয়া টপ কালার
              Color(0xFF1E88E5), // আপনার দেয়া বটম কালার
            ],
          ),
        ),
        child: Stack(
          children: [
            // মাঝখানে লোগো এবং নাম
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // লোগো আইকন (সাদা)
                  Icon(
                    Icons.bolt_rounded, 
                    size: 90.w,
                    color: Colors.white,
                  )
                  .animate()
                  .fadeIn(duration: 800.ms)
                  .scale(begin: const Offset(0.5, 0.5), curve: Curves.elasticOut),
                  
                  SizedBox(height: 12.h),
                  
                  // অ্যাপের নাম (সাদা)
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
            
            // নিচের ব্র্যান্ডিং (সাদা)
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
                      letterSpacing: 4, // প্রিমিয়াম লুকের জন্য স্পেসিং
                    ),
                  ),
                ],
              ).animate().fadeIn(delay: 800.ms).slideY(begin: 0.5, end: 0),
            ),
          ],
        ),
      ),
    );
  }
}
