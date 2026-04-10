import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';

// আপনার মেইন ফাইলের লোকেশন অনুযায়ী ইমপোর্টটি নিশ্চিত করুন
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
    // এখানে কোনা বাঁকানোর রেডিয়াস নির্ধারণ করা হয়েছে
    final double borderRadiusValue = isMobile ? 32.r : 28;

    return ClipRRect(
      borderRadius: BorderRadius.only(
        bottomLeft: Radius.circular(borderRadiusValue),
        bottomRight: Radius.circular(borderRadiusValue),
      ),
      child: SizedBox(
        height: isMobile ? 65.h : 75,
        child: Stack(
          children: [
            // ১. ব্যাকগ্রাউন্ড এনিমেশন লেয়ার
            Positioned.fill(
              child: Lottie.network(
                'https://lottie.host/81b37365-2244-4861-9c86-13d6a455a5b1/F0mJ3Z9oYv.json',
                fit: BoxFit.cover,
                repeat: true,
              ),
            ),

            // ২. গ্লাস-মর্ফিজম ইফেক্ট (আকাশী কালার ও ব্লার)
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Container(
                  decoration: BoxDecoration(
                    color: skyBlue.withOpacity(0.55),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(borderRadiusValue),
                      bottomRight: Radius.circular(borderRadiusValue),
                    ),
                  ),
                ),
              ),
            ),

            // ৩. মেইন কন্টেন্ট (আইকন ও টাইটেল)
            SafeArea(
              bottom: false,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.w),
                child: Row(
                  children: [
                    // আইফোন স্টাইল ব্যাক বাটন অথবা ড্রয়ার মেনু
                    _buildLeadingIcon(context, ref),

                    // টাইটেল লেবেল
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
                                color: Colors.black12,
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // ডান পাশের অ্যাকশন বাটন বা খালি জায়গা
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

  // --- আইফোন স্টাইল ব্যাক আইকন ও ড্রয়ার লজিক ---
  Widget _buildLeadingIcon(BuildContext context, WidgetRef ref) {
    if (isDetailView) {
      return IconButton(
        icon: const Icon(
          Icons.arrow_back_ios_new_rounded, // লেটেস্ট আইফোন স্টাইল ব্যাক আইকন
          color: Colors.white,
          size: 22,
        ),
        onPressed: () {
          // স্টেট আপডেট
          ref.read(isDetailViewProvider.notifier).state = false;
          ref.read(detailViewTitleProvider.notifier).state = '';

          if (context.canPop()) {
            context.pop();
          } else {
            context.go('/home');
          }
        },
      );
    }

    // ড্রয়ার ওপেন করার মেনু আইকন
    return Builder(
      builder: (ctx) => IconButton(
        icon: const Icon(Icons.menu_open_rounded, color: Colors.white, size: 28),
        onPressed: () => Scaffold.of(ctx).openDrawer(),
      ),
    );
  }

  // --- নোটিফিকেশন আইকন বা প্লেসহোল্ডার ---
  Widget _buildTrailingAction() {
    if (!isDetailView && isLoggedIn) {
      return IconButton(
        onPressed: () {},
        icon: const Icon(Icons.notifications_outlined, color: Colors.white, size: 26),
      );
    }
    // ডিটেইলস পেজে আইকন না থাকলে টাইটেল সেন্টার রাখতে সমান জায়গা রাখা হয়েছে
    return SizedBox(width: 48.w);
  }
}
