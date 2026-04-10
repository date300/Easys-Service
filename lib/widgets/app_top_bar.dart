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
    // মোবাইল এবং ডেস্কটপের জন্য আলাদা রেডিয়াস
    final double radius = isMobile ? 32.r : 28;

    return ClipRRect(
      borderRadius: BorderRadius.only(
        bottomLeft: Radius.circular(radius),
        bottomRight: Radius.circular(radius),
      ),
      child: SizedBox(
        // মোবাইল ভিউতে উচ্চতা একটু কম রাখা হয়েছে
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
                      bottomLeft: Radius.circular(radius),
                      bottomRight: Radius.circular(radius),
                    ),
                  ),
                ),
              ),
            ),

            // ৩. মেইন কন্টেন্ট লেয়ার
            SafeArea(
              bottom: false,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.w),
                child: Row(
                  children: [
                    // আইকন সেকশন
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
                          ),
                        ),
                      ),
                    ),

                    // ডান পাশের স্পেস ব্যালেন্স করার জন্য
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

  // --- লিডিং আইকন মেথড (লম্বা অ্যারো আইকন আপডেট করা হয়েছে) ---
  Widget _buildLeadingIcon(BuildContext context, WidgetRef ref) {
    if (isDetailView) {
      return IconButton(
        // এখানে আপনার চাওয়া লম্বা অ্যারো (<--) আইকনটি দেওয়া হয়েছে
        icon: const Icon(
          Icons.arrow_back_rounded, 
          color: Colors.white, 
          size: 26
        ),
        onPressed: () {
          // স্টেট রিসেট করা
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

  Widget _buildTrailingAction() {
    if (!isDetailView && isLoggedIn) {
      return IconButton(
        onPressed: () {},
        icon: const Icon(Icons.notifications_outlined, color: Colors.white, size: 26),
      );
    }
    // ডিটেইলস পেজে টাইটেল মাঝখানে রাখার জন্য ফাঁকা জায়গা
    return SizedBox(width: 48.w);
  }
}
