import 'dart:ui'; // BackdropFilter এবং ImageFilter এর জন্য
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart'; // Lottie প্যাকেজ ইম্পোর্ট করা হলো

// Import your providers — adjust path as needed
import '../main.dart';

class AppTopBar extends ConsumerWidget {
  final bool isDetailView;
  final String detailTitle;
  final bool isMobile;
  final bool isLoggedIn;

  static const Color skyBlue = Color(0xFF29B6F6);

  const AppTopBar({
    super.key,
    required this.isDetailView,
    required this.detailTitle,
    required this.isMobile,
    required this.isLoggedIn,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      height: isMobile ? 56.h : 60,
      width: double.infinity,
      // Stack ব্যবহার করা হয়েছে যেন একটার ওপর আরেকটা লেয়ার বসানো যায়
      child: Stack(
        fit: StackFit.expand,
        children: [
          // ১. সবার নিচে Lottie অ্যানিমেশন (আপনার লিংকটি এখানে বসাবেন)
          Lottie.network(
            'https://assets9.lottiefiles.com/packages/lf20_bwmio3bw.json', // এখানে আপনার Lottie লিংক দিন
            fit: BoxFit.cover, // যেন পুরো টপ বার জুড়ে থাকে
          ),

          // ২. আকাশী কালার এবং ঝাপসা (Blur) ইফেক্ট লেয়ার
          ClipRRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0), // ব্লার/ঝাপসা করার পরিমাণ
              child: Container(
                color: skyBlue.withOpacity(0.4), // আকাশী কালার স্বচ্ছ (Opacity) করে দেওয়া হয়েছে
              ),
            ),
          ),

          // ৩. সবার ওপর আপনার আইকন এবং টেক্সট
          Row(
            children: [
              SizedBox(width: 8.w),
              if (isDetailView)
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios_rounded,
                      color: Colors.white, size: 24),
                  onPressed: () {
                    ref.read(isDetailViewProvider.notifier).state = false;
                    ref.read(detailViewTitleProvider.notifier).state = '';
                    context.go('/home');
                  },
                )
              else
                Builder(
                  builder: (ctx) => IconButton(
                    icon: const Icon(Icons.menu_open_rounded,
                        color: Colors.white, size: 28),
                    onPressed: () => Scaffold.of(ctx).openDrawer(),
                  ),
                ),
              SizedBox(width: 8.w),
              Expanded(
                child: Center(
                  child: Text(
                    isDetailView ? detailTitle : 'Easy Service',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: isMobile ? 20.sp : 20,
                    ),
                  ),
                ),
              ),
              if (!isDetailView && isLoggedIn)
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.notifications_outlined, color: Colors.white),
                )
              else
                SizedBox(width: 48.w),
            ],
          ),
        ],
      ),
    );
  }
}

