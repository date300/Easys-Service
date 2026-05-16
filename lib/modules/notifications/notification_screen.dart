import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/services/push_notification_service.dart';
import '../../main.dart';

// ==================== CONSTANTS ====================
const String _baseUrl = 'https://api.easysarvice.com/api';

// ==================== TOKEN HELPER ====================
Future<String?> _getToken() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('jwt_token');
}

// ==================== NOTIFICATION MODEL ====================
class NotificationItem {
  final int id;
  final String messageEn;
  final String messageBn;
  final double previousBalance;
  final double amountAdded;
  final double newBalance;
  final String source;
  final bool isRead;
  final DateTime createdAt;

  const NotificationItem({
    required this.id,
    required this.messageEn,
    required this.messageBn,
    required this.previousBalance,
    required this.amountAdded,
    required this.newBalance,
    required this.source,
    required this.isRead,
    required this.createdAt,
  });

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      id: json['id'] as int,
      messageEn: json['message_en']?.toString() ?? '',
      messageBn: json['message_bn']?.toString() ?? '',
      previousBalance: double.tryParse(json['previous_balance'].toString()) ?? 0,
      amountAdded: double.tryParse(json['amount_added'].toString()) ?? 0,
      newBalance: double.tryParse(json['new_balance'].toString()) ?? 0,
      source: json['source']?.toString() ?? 'system',
      isRead: (json['is_read'] == 1 || json['is_read'] == true),
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ??
          DateTime.now(),
    );
  }

  NotificationItem copyWith({bool? isRead}) {
    return NotificationItem(
      id: id,
      messageEn: messageEn,
      messageBn: messageBn,
      previousBalance: previousBalance,
      amountAdded: amountAdded,
      newBalance: newBalance,
      source: source,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt,
    );
  }

  NotificationType get type {
    final s = source.toLowerCase();
    if (s.contains('referral')) return NotificationType.referral;
    if (s.contains('matrix')) return NotificationType.matrix;
    if (s.contains('royalty')) return NotificationType.royalty;
    return NotificationType.system;
  }
}

enum NotificationType { referral, matrix, royalty, system }

// ==================== API STATE ====================
enum ApiStatus { idle, loading, success, error }

class NotificationState {
  final List<NotificationItem> notifications;
  final ApiStatus status;
  final String? errorMessage;
  final bool hasMore;
  final int offset;

  const NotificationState({
    this.notifications = const [],
    this.status = ApiStatus.idle,
    this.errorMessage,
    this.hasMore = true,
    this.offset = 0,
  });

  NotificationState copyWith({
    List<NotificationItem>? notifications,
    ApiStatus? status,
    String? errorMessage,
    bool? hasMore,
    int? offset,
  }) {
    return NotificationState(
      notifications: notifications ?? this.notifications,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      hasMore: hasMore ?? this.hasMore,
      offset: offset ?? this.offset,
    );
  }
}

// ==================== PROVIDER ====================
final notificationsProvider =
    StateNotifierProvider<NotificationNotifier, NotificationState>((ref) {
  return NotificationNotifier();
});

class NotificationNotifier extends StateNotifier<NotificationState> {
  NotificationNotifier() : super(const NotificationState());

  static const int _limit = 20;

  Future<void> loadNotifications() async {
    state = state.copyWith(status: ApiStatus.loading, offset: 0);
    try {
      final token = await _getToken();
      final uri = Uri.parse('$_baseUrl/user/notifications?limit=$_limit&offset=0');
      final response = await http.get(uri, headers: _authHeader(token));
      _handleListResponse(response, replace: true);
    } catch (e) {
      state = state.copyWith(
        status: ApiStatus.error,
        errorMessage: 'Connection failed. Please try again.',
      );
    }
  }

  Future<void> loadMore() async {
    if (!state.hasMore || state.status == ApiStatus.loading) return;
    try {
      final token = await _getToken();
      final newOffset = state.offset + _limit;
      final uri = Uri.parse(
          '$_baseUrl/user/notifications?limit=$_limit&offset=$newOffset');
      final response = await http.get(uri, headers: _authHeader(token));
      _handleListResponse(response, replace: false, newOffset: newOffset);
    } catch (_) {/* silent */}
  }

  void _handleListResponse(
    http.Response response, {
    required bool replace,
    int newOffset = 0,
  }) {
    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final List data = body['data'] ?? [];
      final fetched = data.map((e) => NotificationItem.fromJson(e)).toList();

      final updated = replace
          ? fetched
          : [...state.notifications, ...fetched];

      state = state.copyWith(
        notifications: updated,
        status: ApiStatus.success,
        hasMore: fetched.length == _limit,
        offset: replace ? 0 : newOffset,
      );
    } else {
      state = state.copyWith(
        status: ApiStatus.error,
        errorMessage: 'Failed to load notifications.',
      );
    }
  }

  Future<void> markAsRead(int id) async {
    state = state.copyWith(
      notifications: state.notifications
          .map((n) => n.id == id ? n.copyWith(isRead: true) : n)
          .toList(),
    );
    try {
      final token = await _getToken();
      await http.post(
        Uri.parse('$_baseUrl/user/notifications/mark-read'),
        headers: _authHeader(token, json: true),
        body: jsonEncode({'notification_id': id}),
      );
    } catch (_) {/* optimistic */}
  }

  Future<void> markAllAsRead() async {
    state = state.copyWith(
      notifications:
          state.notifications.map((n) => n.copyWith(isRead: true)).toList(),
    );
    try {
      final token = await _getToken();
      await http.post(
        Uri.parse('$_baseUrl/user/notifications/mark-read'),
        headers: _authHeader(token, json: true),
        body: jsonEncode({'all': true}),
      );
    } catch (_) {/* optimistic */}
  }

  void deleteNotification(int id) {
    state = state.copyWith(
      notifications: state.notifications.where((n) => n.id != id).toList(),
    );
  }

  void clearAll() {
    state = state.copyWith(notifications: []);
  }

  Map<String, String> _authHeader(String? token, {bool json = false}) {
    return {
      'Authorization': 'Bearer ${token ?? ''}',
      if (json) 'Content-Type': 'application/json',
    };
  }
}

// ==================== MAIN SCREEN ====================
class NotificationScreen extends ConsumerStatefulWidget {
  const NotificationScreen({super.key});

  static const Color kPrimary = Color(0xFF29B6F6);

  @override
  ConsumerState<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends ConsumerState<NotificationScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();
  StreamSubscription<NotificationEvent>? _pushTapSub;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _tabController = TabController(length: 2, vsync: this);

    Future.microtask(
      () => ref.read(notificationsProvider.notifier).loadNotifications(),
    );

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        ref.read(notificationsProvider.notifier).loadMore();
      }
    });

    _pushTapSub = PushNotificationService.instance.onTap.listen((_) {
      if (mounted) {
        ref.read(notificationsProvider.notifier).loadNotifications();
        _tabController.animateTo(0);
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.read(notificationsProvider.notifier).loadNotifications();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _tabController.dispose();
    _scrollController.dispose();
    _pushTapSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notifState = ref.watch(notificationsProvider);
    final unreadCount =
        notifState.notifications.where((n) => !n.isRead).length;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final kBackground =
        isDark ? const Color(0xFF121212) : const Color(0xFFF8FAFC);
    final kCardBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final kTextDark = isDark ? Colors.white : const Color(0xFF0F172A);
    final kTextMid =
        isDark ? Colors.grey.shade400 : const Color(0xFF475569);
    final kBorder =
        isDark ? const Color(0xFF333333) : Colors.grey.shade200;
    final kAppBarBg = isDark ? const Color(0xFF1A1A1A) : Colors.white;
    final kTabBg = isDark ? const Color(0xFF1A1A1A) : Colors.white;
    final kUnreadBg =
        isDark ? const Color(0xFF1A2733) : const Color(0xFFE3F2FD);
    final kUnreadBorder = isDark
        ? NotificationScreen.kPrimary.withOpacity(0.4)
        : NotificationScreen.kPrimary.withOpacity(0.3);
    final kShadow = isDark
        ? Colors.black.withOpacity(0.3)
        : Colors.black.withOpacity(0.05);

    return Scaffold(
      backgroundColor: kBackground,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(
              unreadCount: unreadCount,
              isDark: isDark,
              kAppBarBg: kAppBarBg,
              kTextDark: kTextDark,
              kTextMid: kTextMid,
              kShadow: kShadow,
            ),
            Container(
              color: kTabBg,
              child: TabBar(
                controller: _tabController,
                labelColor: NotificationScreen.kPrimary,
                unselectedLabelColor: kTextMid,
                indicatorColor: NotificationScreen.kPrimary,
                labelStyle:
                    GoogleFonts.poppins(fontWeight: FontWeight.w600),
                unselectedLabelStyle: GoogleFonts.poppins(),
                tabs: [
                  Tab(text: 'All (${notifState.notifications.length})'),
                  Tab(text: 'Unread ($unreadCount)'),
                ],
              ),
            ),
            Expanded(
              child: _buildContent(
                notifState: notifState,
                isDark: isDark,
                kCardBg: kCardBg,
                kTextDark: kTextDark,
                kTextMid: kTextMid,
                kBorder: kBorder,
                kUnreadBg: kUnreadBg,
                kUnreadBorder: kUnreadBorder,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent({
    required NotificationState notifState,
    required bool isDark,
    required Color kCardBg,
    required Color kTextDark,
    required Color kTextMid,
    required Color kBorder,
    required Color kUnreadBg,
    required Color kUnreadBorder,
  }) {
    if (notifState.status == ApiStatus.loading &&
        notifState.notifications.isEmpty) {
      return Center(
        child: CircularProgressIndicator(
          color: NotificationScreen.kPrimary,
        ),
      );
    }

    if (notifState.status == ApiStatus.error &&
        notifState.notifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.wifi_off_rounded,
                size: 60.sp, color: kTextMid.withOpacity(0.5)),
            SizedBox(height: 16.h),
            Text(
              notifState.errorMessage ?? 'Something went wrong',
              style: GoogleFonts.poppins(color: kTextMid),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16.h),
            ElevatedButton.icon(
              onPressed: () =>
                  ref.read(notificationsProvider.notifier).loadNotifications(),
              icon: const Icon(Icons.refresh),
              label: Text('Retry', style: GoogleFonts.poppins()),
              style: ElevatedButton.styleFrom(
                backgroundColor: NotificationScreen.kPrimary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return TabBarView(
      controller: _tabController,
      children: [
        _buildNotificationList(
          notifState.notifications,
          notifState: notifState,
          isDark: isDark,
          kCardBg: kCardBg,
          kTextDark: kTextDark,
          kTextMid: kTextMid,
          kBorder: kBorder,
          kUnreadBg: kUnreadBg,
          kUnreadBorder: kUnreadBorder,
        ),
        _buildNotificationList(
          notifState.notifications.where((n) => !n.isRead).toList(),
          notifState: notifState,
          isDark: isDark,
          kCardBg: kCardBg,
          kTextDark: kTextDark,
          kTextMid: kTextMid,
          kBorder: kBorder,
          kUnreadBg: kUnreadBg,
          kUnreadBorder: kUnreadBorder,
        ),
      ],
    );
  }

  Widget _buildNotificationList(
    List<NotificationItem> notifications, {
    required NotificationState notifState,
    required bool isDark,
    required Color kCardBg,
    required Color kTextDark,
    required Color kTextMid,
    required Color kBorder,
    required Color kUnreadBg,
    required Color kUnreadBorder,
  }) {
    if (notifications.isEmpty) {
      return _buildEmptyState(kTextMid: kTextMid);
    }

    return RefreshIndicator(
      color: NotificationScreen.kPrimary,
      onRefresh: () =>
          ref.read(notificationsProvider.notifier).loadNotifications(),
      child: ListView.builder(
        controller: _scrollController,
        padding: EdgeInsets.all(16.r),
        itemCount: notifications.length + (notifState.hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == notifications.length) {
            return Padding(
              padding: EdgeInsets.symmetric(vertical: 16.h),
              child: Center(
                child: SizedBox(
                  width: 24.w,
                  height: 24.w,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: NotificationScreen.kPrimary,
                  ),
                ),
              ),
            );
          }

          return _buildNotificationCard(
            notifications[index],
            isDark: isDark,
            kCardBg: kCardBg,
            kTextDark: kTextDark,
            kTextMid: kTextMid,
            kBorder: kBorder,
            kUnreadBg: kUnreadBg,
            kUnreadBorder: kUnreadBorder,
          );
        },
      ),
    );
  }

  Widget _buildNotificationCard(
    NotificationItem notification, {
    required bool isDark,
    required Color kCardBg,
    required Color kTextDark,
    required Color kTextMid,
    required Color kBorder,
    required Color kUnreadBg,
    required Color kUnreadBorder,
  }) {
    final typeColor = _getTypeColor(notification.type);
    final typeIcon = _getTypeIcon(notification.type);

    return Dismissible(
      key: Key(notification.id.toString()),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(16.r),
        ),
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20.w),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) {
        ref
            .read(notificationsProvider.notifier)
            .deleteNotification(notification.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Notification removed',
                style: GoogleFonts.poppins(fontSize: 13.sp)),
            backgroundColor: const Color(0xFF1E1E1E),
            duration: const Duration(seconds: 2),
          ),
        );
      },
      child: GestureDetector(
        onTap: () {
          if (!notification.isRead) {
            ref
                .read(notificationsProvider.notifier)
                .markAsRead(notification.id);
          }
          _showNotificationDetail(notification,
              isDark: isDark, kTextDark: kTextDark, kTextMid: kTextMid);
        },
        child: Container(
          margin: EdgeInsets.only(bottom: 12.h),
          padding: EdgeInsets.all(16.r),
          decoration: BoxDecoration(
            color: notification.isRead ? kCardBg : kUnreadBg,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: notification.isRead ? kBorder : kUnreadBorder,
            ),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withOpacity(0.2)
                    : Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(12.r),
                decoration: BoxDecoration(
                  color: typeColor.withOpacity(isDark ? 0.2 : 0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(typeIcon, color: typeColor, size: 24.sp),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _getTitle(notification.type),
                            style: GoogleFonts.poppins(
                              fontSize: 14.sp,
                              fontWeight: notification.isRead
                                  ? FontWeight.w500
                                  : FontWeight.bold,
                              color: kTextDark,
                            ),
                          ),
                        ),
                        if (!notification.isRead)
                          Container(
                            width: 8.w,
                            height: 8.w,
                            decoration: const BoxDecoration(
                              color: NotificationScreen.kPrimary,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      notification.messageEn,
                      style: GoogleFonts.poppins(
                        fontSize: 12.sp,
                        color: kTextMid,
                        height: 1.5,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 6.h),
                    if (notification.amountAdded > 0)
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 8.w, vertical: 2.h),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Text(
                          '+${notification.amountAdded.toStringAsFixed(0)} BDT',
                          style: GoogleFonts.poppins(
                            fontSize: 11.sp,
                            color: Colors.green,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    SizedBox(height: 6.h),
                    Text(
                      _formatTime(notification.createdAt),
                      style: GoogleFonts.poppins(
                        fontSize: 11.sp,
                        color: isDark
                            ? Colors.grey.shade600
                            : Colors.grey.shade400,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showNotificationDetail(
    NotificationItem n, {
    required bool isDark,
    required Color kTextDark,
    required Color kTextMid,
  }) {
    final kBgSheet = isDark ? const Color(0xFF1E1E1E) : Colors.white;

    showModalBottomSheet(
      context: context,
      backgroundColor: kBgSheet,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.all(24.r),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              _getTitle(n.type),
              style: GoogleFonts.poppins(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: kTextDark,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              n.messageEn,
              style: GoogleFonts.poppins(
                  fontSize: 13.sp, color: kTextMid, height: 1.6),
            ),
            if (n.messageBn.isNotEmpty) ...[
              SizedBox(height: 6.h),
              Text(
                n.messageBn,
                style: GoogleFonts.poppins(
                    fontSize: 13.sp, color: kTextMid, height: 1.6),
              ),
            ],
            SizedBox(height: 16.h),
            if (n.amountAdded > 0)
              Container(
                padding: EdgeInsets.all(12.r),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _balanceInfo(
                        'Previous', n.previousBalance, kTextDark, kTextMid),
                    Icon(Icons.arrow_forward_ios,
                        size: 14.sp, color: Colors.green),
                    _balanceInfo('+Added', n.amountAdded, Colors.green, kTextMid,
                        valueColor: Colors.green),
                    Icon(Icons.arrow_forward_ios,
                        size: 14.sp, color: Colors.green),
                    _balanceInfo('New', n.newBalance, kTextDark, kTextMid),
                  ],
                ),
              ),
            SizedBox(height: 12.h),
            Text(
              DateFormat('d MMM y - hh:mm a').format(n.createdAt),
              style: GoogleFonts.poppins(
                  fontSize: 11.sp, color: Colors.grey.shade400),
            ),
            SizedBox(height: 8.h),
          ],
        ),
      ),
    );
  }

  Widget _balanceInfo(
    String label,
    double amount,
    Color labelColor,
    Color subColor, {
    Color? valueColor,
  }) {
    return Column(
      children: [
        Text(label,
            style: GoogleFonts.poppins(fontSize: 10.sp, color: subColor)),
        SizedBox(height: 2.h),
        Text(
          '${amount.toStringAsFixed(0)} Tk',
          style: GoogleFonts.poppins(
            fontSize: 13.sp,
            fontWeight: FontWeight.bold,
            color: valueColor ?? labelColor,
          ),
        ),
      ],
    );
  }

  Widget _buildAppBar({
    required int unreadCount,
    required bool isDark,
    required Color kAppBarBg,
    required Color kTextDark,
    required Color kTextMid,
    required Color kShadow,
  }) {
    final kIconBg = isDark ? const Color(0xFF2C2C2C) : Colors.grey.shade100;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: kAppBarBg,
        boxShadow: [
          BoxShadow(
              color: kShadow, blurRadius: 10, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              padding: EdgeInsets.all(8.r),
              decoration: BoxDecoration(
                color: kIconBg,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(Icons.arrow_back_ios_new,
                  size: 18.sp, color: kTextDark),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Notifications',
                  style: GoogleFonts.poppins(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: kTextDark,
                  ),
                ),
                if (unreadCount > 0)
                  Text(
                    '$unreadCount unread',
                    style: GoogleFonts.poppins(
                      fontSize: 12.sp,
                      color: NotificationScreen.kPrimary,
                    ),
                  ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () =>
                ref.read(notificationsProvider.notifier).loadNotifications(),
            child: Container(
              padding: EdgeInsets.all(8.r),
              decoration: BoxDecoration(
                color: kIconBg,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(Icons.refresh, size: 20.sp, color: kTextMid),
            ),
          ),
          SizedBox(width: 8.w),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: kTextMid),
            color: isDark ? const Color(0xFF2C2C2C) : Colors.white,
            onSelected: (value) {
              switch (value) {
                case 'mark_all':
                  ref.read(notificationsProvider.notifier).markAllAsRead();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('All marked as read',
                          style: GoogleFonts.poppins(fontSize: 13.sp)),
                      backgroundColor: NotificationScreen.kPrimary,
                    ),
                  );
                  break;
                case 'clear':
                  _showClearConfirmDialog(isDark: isDark);
                  break;
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'mark_all',
                child: Row(
                  children: [
                    Icon(Icons.done_all, size: 20, color: kTextDark),
                    SizedBox(width: 12.w),
                    Text('Mark all as read',
                        style: GoogleFonts.poppins(color: kTextDark)),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'clear',
                child: Row(
                  children: [
                    const Icon(Icons.delete_outline,
                        size: 20, color: Colors.red),
                    SizedBox(width: 12.w),
                    Text('Clear all',
                        style: GoogleFonts.poppins(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState({required Color kTextMid}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_off_outlined,
              size: 80.sp, color: kTextMid.withOpacity(0.4)),
          SizedBox(height: 16.h),
          Text(
            'No notifications yet',
            style: GoogleFonts.poppins(
              fontSize: 16.sp,
              color: kTextMid,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            "We'll notify you when something arrives",
            style: GoogleFonts.poppins(
              fontSize: 12.sp,
              color: kTextMid.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  String _getTitle(NotificationType type) {
    switch (type) {
      case NotificationType.referral:
        return 'Referral Commission';
      case NotificationType.matrix:
        return 'Matrix Bonus';
      case NotificationType.royalty:
        return 'Royalty Income';
      case NotificationType.system:
        return 'System Notification';
    }
  }

  Color _getTypeColor(NotificationType type) {
    switch (type) {
      case NotificationType.referral:
        return Colors.green;
      case NotificationType.matrix:
        return Colors.orange;
      case NotificationType.royalty:
        return const Color(0xFF29B6F6);
      case NotificationType.system:
        return Colors.purple;
    }
  }

  IconData _getTypeIcon(NotificationType type) {
    switch (type) {
      case NotificationType.referral:
        return Icons.people_outline;
      case NotificationType.matrix:
        return Icons.grid_view_outlined;
      case NotificationType.royalty:
        return Icons.workspace_premium_outlined;
      case NotificationType.system:
        return Icons.settings_outlined;
    }
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return DateFormat('MMM d, y').format(time);
  }

  void _showClearConfirmDialog({required bool isDark}) {
    final kCardBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final kTextDark = isDark ? Colors.white : const Color(0xFF0F172A);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: kCardBg,
        title: Text(
          'Clear all notifications?',
          style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold, color: kTextDark),
        ),
        content: Text(
          'This will remove all notifications from this device.',
          style: GoogleFonts.poppins(color: kTextDark.withOpacity(0.7)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel',
                style: GoogleFonts.poppins(
                    color: NotificationScreen.kPrimary)),
          ),
          TextButton(
            onPressed: () {
              ref.read(notificationsProvider.notifier).clearAll();
              Navigator.pop(context);
            },
            child: Text('Clear',
                style: GoogleFonts.poppins(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
