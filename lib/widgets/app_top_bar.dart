import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // for SystemChrome
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
    final double radius = isMobile ? 16.r : 14;
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    final double contentHeight = isMobile ? 48.h : 55;
    final double totalHeight = contentHeight + statusBarHeight;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final overlayColor = isDark
        ? darkHeader.withOpacity(0.9)
        : skyBlue.withOpacity(0.6);

    // স্ট্যাটাস বার ট্রান্সপারেন্ট ও সাদা আইকন
    WidgetsBinding.instance.addPostFrameCallback((_) {
      SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.light, // iOS এর জন্য
        ),
      );
    });

    return ClipRRect(
      borderRadius: BorderRadius.only(
        bottomLeft: Radius.circular(radius),
        bottomRight: Radius.circular(radius),
      ),
      child: SizedBox(
        height: totalHeight,
        child: Stack(
          children: [
            // Background Lottie (পুরো উচ্চতা জুড়ে)
            Positioned.fill(
              child: Lottie.network(
                'https://lottie.host/81b37365-2244-4861-9c86-13d6a455a5b1/F0mJ3Z9oYv.json',
                fit: BoxFit.cover,
                repeat: true,
              ),
            ),

            // Blur Overlay (পুরো উচ্চতা জুড়ে)
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
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

            // Content – স্ট্যাটাস বারের নিচে
            Positioned(
              left: 0,
              right: 0,
              top: statusBarHeight,
              child: SizedBox(
                height: contentHeight,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.w),
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
                              fontWeight: FontWeight.w600,
                              fontSize: isMobile ? 15.sp : 17,
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeadingIcon(BuildContext context, WidgetRef ref, bool isDark) {
    if (isDetailView) {
      return IconButton(
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(),
        icon: Icon(
          Icons.arrow_back_rounded,
          color: Colors.white,
          size: 22.sp,
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
          size: 24.sp,
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
            size: 22.sp,
          ),
        ),
      );
    }
    return SizedBox(width: 40.w);
  }
}
