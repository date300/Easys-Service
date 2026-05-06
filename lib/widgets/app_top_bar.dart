import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../main.dart';

// ==================== Unread Count Provider ====================

final unreadNotificationCountProvider =
    StateNotifierProvider<UnreadCountNotifier, int>((ref) {
  return UnreadCountNotifier();
});

class UnreadCountNotifier extends StateNotifier<int> {
  UnreadCountNotifier() : super(0);

  Future<void> fetchUnreadCount() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token') ?? '';
      if (token.isEmpty) return;

      final uri = Uri.parse(
          'https://easy.ltcminematrix.com/api/user/notifications?limit=1&is_read=0');
      final response = await http.get(
        uri,
        headers: {'Authorization': 'Bearer $token'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final List data = body['data'] ?? [];
        // data তে কিছু থাকলে unread আছে, না থাকলে 0
        // সঠিক count এর জন্য full list fetch করতে হবে
        // তাই notification screen এর provider থেকে sync করাই ভালো
        state = data.isNotEmpty ? 1 : 0;
      }
    } catch (_) {
      // Silent fail — badge hide থাকবে
    }
  }

  /// Notification screen load হলে এই method call করে exact count set করো
  void setCount(int count) => state = count;

  /// Notification screen এ গেলে clear করো
  void clear() => state = 0;
}

// ==================== AppTopBar ====================

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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    final double contentHeight = isMobile ? 48.h : 55;
    final double totalHeight = contentHeight + statusBarHeight;
    final double radius = isMobile ? 16.r : 14;

    // App open হলে unread count fetch করো
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (isLoggedIn) {
        ref.read(unreadNotificationCountProvider.notifier).fetchUnreadCount();
      }
    });

    final overlayColor = isDark
        ? darkHeader.withOpacity(0.9)
        : skyBlue.withOpacity(0.6);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness:
            isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness:
            isDark ? Brightness.dark : Brightness.light,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(radius),
          bottomRight: Radius.circular(radius),
        ),
        child: SizedBox(
          height: totalHeight,
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

              // Blur + Color Overlay
              Positioned.fill(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                  child: Container(color: overlayColor),
                ),
              ),

              // Content
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
                        _buildTrailingAction(context, ref, isDark),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLeadingIcon(BuildContext context, WidgetRef ref, bool isDark) {
    if (isDetailView) {
      return IconButton(
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(),
        icon: Icon(Icons.arrow_back_rounded, color: Colors.white, size: 22.sp),
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
        icon: Icon(Icons.menu_open_rounded, color: Colors.white, size: 24.sp),
        onPressed: () => Scaffold.of(ctx).openDrawer(),
      ),
    );
  }

  Widget _buildTrailingAction(
      BuildContext context, WidgetRef ref, bool isDark) {
    if (!isDetailView && isLoggedIn) {
      final unreadCount = ref.watch(unreadNotificationCountProvider);
      final hasUnread = unreadCount > 0;

      return IconButton(
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(),
        onPressed: () {
          // Notification screen এ গেলে badge clear করো
          ref.read(unreadNotificationCountProvider.notifier).clear();
          context.push('/notifications');
        },
        icon: Badge(
          isLabelVisible: hasUnread,           // শুধু unread থাকলে লাল দেখাবে
          label: unreadCount > 99
              ? const Text('99+',
                  style: TextStyle(fontSize: 9, color: Colors.white))
              : unreadCount > 1
                  ? Text(
                      '$unreadCount',
                      style: const TextStyle(
                          fontSize: 9, color: Colors.white),
                    )
                  : null,
          backgroundColor: Colors.red,
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
