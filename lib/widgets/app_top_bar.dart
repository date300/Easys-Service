import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';

// আপনার মেইন ফাইলের লোকেশন অনুযায়ী নিচের ইমপোর্টটি নিশ্চিত করুন
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
    return ClipRRect(
      child: SizedBox(
        height: isMobile ? 65.h : 70, 
        child: Stack(
          children: [
            // ১. ব্যাকগ্রাউন্ড এনিমেশন (Lottie)
            Positioned.fill(
              child: Lottie.network(
                'https://lottie.host/81b37365-2244-4861-9c86-13d6a455a5b1/F0mJ3Z9oYv.json',
                fit: BoxFit.cover,
                repeat: true,
              ),
            ),

            // ২. গ্লাস-মর্ফিজম ইফেক্ট (Blur + Overlay)
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  color: skyBlue.withOpacity(0.45),
                ),
              ),
            ),

            // ৩. কন্টেন্ট লেয়ার
            SafeArea(
              bottom: false,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.w),
                child: Row(
                  children: [
                    // বাম পাশের আইকন: ডিটেইল ভিউ হলে 'Back', নাহলে 'Menu'
                    _buildLeadingIcon(context, ref),
                    
                    // মাঝখানের টাইটেল
                    Expanded(
                      child: Center(
                        child: Text(
                          isDetailView ? detailTitle : 'Easy Service',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: isMobile ? 18.sp : 20,
                            letterSpacing: 0.5,
                            shadows: const [
                              Shadow(
                                color: Colors.black26,
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // ডান পাশের স্পেস বা নোটিফিকেশন আইকন (সমান্তরাল রাখার জন্য)
                    _buildTrailingAction(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- হেল্পার মেথড: লিডিং আইকন (Back/Menu) ---
  Widget _buildLeadingIcon(BuildContext context, WidgetRef ref) {
    if (isDetailView) {
      return IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 22),
        onPressed: () {
          // স্টেট রিসেট করা
          ref.read(isDetailViewProvider.notifier).state = false;
          ref.read(detailViewTitleProvider.notifier).state = '';
          
          // পেজ থেকে ব্যাক করা
          if (context.canPop()) {
            context.pop();
          } else {
            context.go('/home'); // যদি পপ করার কিছু না থাকে তবে হোমে যাবে
          }
        },
      );
    }

    return Builder(
      builder: (ctx) => IconButton(
        icon: const Icon(Icons.menu_open_rounded, color: Colors.white, size: 28),
        onPressed: () => Scaffold.of(ctx).openDrawer(),
      ),
    );
  }

  // --- হেল্পার মেথড: ট্রেইলিং আইকন (Notifications/Empty) ---
  Widget _buildTrailingAction() {
    if (!isDetailView && isLoggedIn) {
      return IconButton(
        onPressed: () {},
        icon: const Icon(Icons.notifications_outlined, color: Colors.white, size: 26),
      );
    }
    // ডিটেইল ভিউতে টাইটেল সেন্টারে রাখার জন্য ডানপাশে সমপরিমাণ খালি জায়গা
    return SizedBox(width: 48.w);
  }
}
