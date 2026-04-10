import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import '../main.dart'; // পাথ ঠিক আছে কি না দেখে নিন

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
    final double radius = isMobile ? 32.r : 28;

    return ClipRRect(
      borderRadius: BorderRadius.only(
        bottomLeft: Radius.circular(radius),
        bottomRight: Radius.circular(radius),
      ),
      child: SizedBox(
        height: isMobile ? 65.h : 75,
        child: Stack(
          children: [
            // ১. ব্যাকগ্রাউন্ড এনিমেশন
            Positioned.fill(
              child: Lottie.network(
                'https://lottie.host/81b37365-2244-4861-9c86-13d6a455a5b1/F0mJ3Z9oYv.json',
                fit: BoxFit.cover,
                repeat: true,
              ),
            ),
            // ২. গ্লাস ইফেক্ট
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
            // ৩. কন্টেন্ট
            SafeArea(
              bottom: false,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.w),
                child: Row(
                  children: [
                    _buildLeadingIcon(context, ref),
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
                          ),
                        ),
                      ),
                    ),
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

  Widget _buildLeadingIcon(BuildContext context, WidgetRef ref) {
    if (isDetailView) {
      return IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 22),
        onPressed: () {
          ref.read(isDetailViewProvider.notifier).state = false;
          ref.read(detailViewTitleProvider.notifier).state = '';
          if (context.canPop()) context.pop(); else context.go('/home');
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

  Widget _buildTrailingAction() {
    if (!isDetailView && isLoggedIn) {
      return IconButton(
        onPressed: () {},
        icon: const Icon(Icons.notifications_outlined, color: Colors.white, size: 26),
      );
    }
    return SizedBox(width: 48.w);
  }
}
