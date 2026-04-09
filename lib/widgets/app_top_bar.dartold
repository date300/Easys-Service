import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

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
      color: skyBlue,
      height: isMobile ? 56.h : 60,
      child: Row(
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
    );
  }
}
