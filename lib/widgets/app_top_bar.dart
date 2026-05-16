import 'dart:async';
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

import '../../core/services/push_notification_service.dart';
import '../../main.dart';
import '../../modules/ai/easy_ai_sheet.dart'; // আলাদা ফাইল থেকে import

// ==================== Unread Count Provider ====================

final unreadNotificationCountProvider =
    StateNotifierProvider<UnreadCountNotifier, int>((ref) {
  return UnreadCountNotifier();
});

class UnreadCountNotifier extends StateNotifier<int> {
  StreamSubscription<int>? _pushSub;

  UnreadCountNotifier() : super(0) {
    _pushSub =
        PushNotificationService.instance.unreadCountStream.listen((delta) {
      if (delta == 0) {
        state = 0;
      } else {
        state = state + delta;
      }
    });
  }

  @override
  void dispose() {
    _pushSub?.cancel();
    super.dispose();
  }

  Future<void> fetchUnreadCount() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token') ?? '';
      if (token.isEmpty) return;

      final uri = Uri.parse(
          'https://api.easysarvice.com/api/user/notifications?limit=1&is_read=0');
      final response = await http.get(
        uri,
        headers: {'Authorization': 'Bearer $token'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final List data = body['data'] ?? [];
        state = data.isNotEmpty ? 1 : 0;
      }
    } catch (_) {
      // Silent fail — badge hide
    }
  }

  void setCount(int count) => state = count;
  void clear() => state = 0;
}

// ==================== AppTopBar ====================

class AppTopBar extends ConsumerStatefulWidget {
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
  ConsumerState<AppTopBar> createState() => _AppTopBarState();
}

class _AppTopBarState extends ConsumerState<AppTopBar> {
  @override
  void initState() {
    super.initState();
    // শুধু একবার fetch করবে, প্রতিটা rebuild-এ নয়
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.isLoggedIn) {
        ref.read(unreadNotificationCountProvider.notifier).fetchUnreadCount();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    final double contentHeight = widget.isMobile ? 48.h : 55;
    final double totalHeight = contentHeight + statusBarHeight;
    final double radius = widget.isMobile ? 16.r : 14;

    final overlayColor = isDark
        ? AppTopBar.darkHeader.withOpacity(0.9)
        : AppTopBar.skyBlue.withOpacity(0.6);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
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
                        _buildLeadingIcon(context, isDark),
                        Expanded(
                          child: Center(
                            child: Text(
                              widget.isDetailView
                                  ? widget.detailTitle
                                  : 'Easy Service',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: widget.isMobile ? 15.sp : 17,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),
                        ),
                        _buildTrailingActions(context),
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

  Widget _buildLeadingIcon(BuildContext context, bool isDark) {
    if (widget.isDetailView) {
      return IconButton(
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(),
        icon:
            Icon(Icons.arrow_back_rounded, color: Colors.white, size: 22.sp),
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
        icon:
            Icon(Icons.menu_open_rounded, color: Colors.white, size: 24.sp),
        onPressed: () => Scaffold.of(ctx).openDrawer(),
      ),
    );
  }

  Widget _buildTrailingActions(BuildContext context) {
    if (widget.isDetailView || !widget.isLoggedIn) {
      return SizedBox(width: 40.w);
    }

    final unreadCount = ref.watch(unreadNotificationCountProvider);
    final hasUnread = unreadCount > 0;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── Easy AI Button ──
        GestureDetector(
          onTap: () => EasyAiSheet.show(context),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(
                  color: Colors.white.withOpacity(0.35), width: 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.auto_awesome_rounded,
                    color: Colors.white,
                    size: widget.isMobile ? 14.sp : 14),
                SizedBox(width: 4.w),
                Text(
                  'Easy AI',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: widget.isMobile ? 11.sp : 11,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
        ),

        SizedBox(width: 4.w),

        // ── Notification Bell ──
        IconButton(
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          onPressed: () {
            ref.read(unreadNotificationCountProvider.notifier).clear();
            context.push('/notifications');
          },
          icon: Badge(
            isLabelVisible: hasUnread,
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
        ),
      ],
    );
  }
}
