import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';

import '../main.dart';

class AppTopBar extends ConsumerWidget {
  final bool isDetailView;
  final String detailTitle;
  final bool isMobile;
  final bool isLoggedIn;

  static const Color skyBlue = Color(0xFF29B6F6);
  static const Color darkHeader = Color(0xFF1E1E1E);

  const AppTopBar({
    super.key,
    required this.isDetailView,
    required this.detailTitle,
    required this.isMobile,
    required this.isLoggedIn,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final double radius = isMobile ? 16.r : 14; // ছোট রেডিয়াস

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final overlayColor = isDark
        ? darkHeader.withOpacity(0.9)
        : skyBlue.withOpacity(0.6);

    return ClipRRect(
      borderRadius: BorderRadius.only(
        bottomLeft: Radius.circular(radius),
        bottomRight: Radius.circular(radius),
      ),
      child: SizedBox(
        height: isMobile ? 48.h : 55, // অনেক ছোট হাইট
        child: Stack(
          children: [
            // Background Lottie
            Positioned.fill(
              child: Lottie.network(
                'https://lottie.host/81b37365-2244-4861-9c86-13d6a455a5b1/F0mJ3Z9oYv.json',
                fit: BoxFit.cover,
                repeat: true,
              ),
            ),

            // Blur Overlay
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8), // কম ব্লার
                child: Container(
                  decoration: BoxDecoration(
                    color: overlayColor,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(radius),
                      bottomRight: Radius.circular(radius),
                    ),
                  ),
                ),
              ),
            ),

            // Content
            SafeArea(
              bottom: false,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.w), // কম প্যাডিং
                child: Row(
                  children: [
                    _buildLeadingIcon(context, ref, isDark),

                    Expanded(
                      child: Center(
                        child: Text(
                          isDetailView ? detailTitle : 'Easy Service',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.w600, // একটু কম বোল্ড
                            fontSize: isMobile ? 15.sp : 17, // ছোট ফন্ট
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ),

                    _buildTrailingAction(context, isDark),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeadingIcon(BuildContext context, WidgetRef ref, bool isDark) {
    if (isDetailView) {
      return IconButton(
        padding: EdgeInsets.zero, // এক্সট্রা প্যাডিং সরানো
        constraints: const BoxConstraints(),
        icon: Icon(
          Icons.arrow_back_rounded,
          color: Colors.white,
          size: 22.sp, // ছোট আইকন
        ),
        onPressed: () {
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

    return Builder(
      builder: (ctx) => IconButton(
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(),
        icon: Icon(
          Icons.menu_open_rounded,
          color: Colors.white,
          size: 24.sp, // ছোট আইকন
        ),
        onPressed: () => Scaffold.of(ctx).openDrawer(),
      ),
    );
  }

  Widget _buildTrailingAction(BuildContext context, bool isDark) {
    if (!isDetailView && isLoggedIn) {
      return IconButton(
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(),
        onPressed: () => context.push('/notifications'),
        icon: Badge(
          child: Icon(
            Icons.notifications_outlined,
            color: Colors.white,
            size: 22.sp, // ছোট আইকন
          ),
        ),
      );
    }
    return SizedBox(width: 40.w); // ছোট প্লেসহোল্ডার
  }
}
