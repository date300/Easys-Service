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
    final double radius = isMobile ? 32.r : 28;
    
    // 🔥 DYNAMIC THEME COLORS
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final overlayColor = isDark 
        ? darkHeader.withOpacity(0.85)  // Dark mode: darker overlay
        : skyBlue.withOpacity(0.55);      // Light mode: skyBlue overlay

    return ClipRRect(
      borderRadius: BorderRadius.only(
        bottomLeft: Radius.circular(radius),
        bottomRight: Radius.circular(radius),
      ),
      child: SizedBox(
        height: isMobile ? 65.h : 75,
        child: Stack(
          children: [
            // Background Lottie Animation
            Positioned.fill(
              child: Lottie.network(
                'https://lottie.host/81b37365-2244-4861-9c86-13d6a455a5b1/F0mJ3Z9oYv.json',
                fit: BoxFit.cover,
                repeat: true,
              ),
            ),

            // Blur Overlay - DYNAMIC COLOR
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Container(
                  decoration: BoxDecoration(
                    color: overlayColor,  // 🔥 DYNAMIC
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
                padding: EdgeInsets.symmetric(horizontal: 10.w),
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
                            color: Colors.white,  // Always white for contrast
                            fontWeight: FontWeight.bold,
                            fontSize: isMobile ? 18.sp : 20,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),

                    // Notification Action
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
        icon: Icon(
          Icons.arrow_back_rounded, 
          color: Colors.white, 
          size: 26.sp,  // 🔥 Added .sp for responsive
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
        icon: Icon(
          Icons.menu_open_rounded, 
          color: Colors.white, 
          size: 28.sp,  // 🔥 Added .sp for responsive
        ),
        onPressed: () => Scaffold.of(ctx).openDrawer(),
      ),
    );
  }

  // Notification Icon with Navigation - DYNAMIC
  Widget _buildTrailingAction(BuildContext context, bool isDark) {
    if (!isDetailView && isLoggedIn) {
      return IconButton(
        onPressed: () {
          context.push('/notifications');
        },
        icon: Badge(
          child: Icon(
            Icons.notifications_outlined, 
            color: Colors.white, 
            size: 26.sp,  // 🔥 Added .sp for responsive
          ),
        ),
      );
    }
    return SizedBox(width: 48.w);
  }
}
