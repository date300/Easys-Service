import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// ==========================================
// 1. Models
// ==========================================

class WalletBalance {
  final double balance;
  WalletBalance({required this.balance});
  factory WalletBalance.fromJson(Map<String, dynamic> json) =>
      WalletBalance(balance: double.tryParse(json['balance'].toString()) ?? 0.0);
}

class IncomeRecord {
  final int id;
  final double amount;
  final String type;
  final String description;
  final DateTime createdAt;
  IncomeRecord({required this.id, required this.amount, required this.type, required this.description, required this.createdAt});
  factory IncomeRecord.fromJson(Map<String, dynamic> json) => IncomeRecord(
        id: json['id'],
        amount: double.tryParse(json['amount'].toString()) ?? 0.0,
        type: json['type'] ?? '',
        description: json['description'] ?? '',
        createdAt: DateTime.parse(json['created_at']),
      );
}

// ==========================================
// 2. API Service
// ==========================================

class WalletApiService {
  static const String _baseUrl = 'https://easy.ltcminematrix.com/api';

  static Future<WalletBalance> fetchBalance(String token) async {
    final res = await http.get(Uri.parse('$_baseUrl/user/profile'),
        headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'})
        .timeout(const Duration(seconds: 15));
    if (res.statusCode == 200) {
      final json = jsonDecode(res.body);
      if (json['status'] == 'success' && json['user'] != null) {
        return WalletBalance.fromJson(json['user']);
      }
      throw Exception('Invalid profile data');
    } else {
      throw Exception('Server error: ${res.statusCode}');
    }
  }

  static Future<List<IncomeRecord>> fetchIncomeHistory(String token, {String? type, int limit = 20, int offset = 0}) async {
    final uri = Uri.parse('$_baseUrl/income/history')
        .replace(queryParameters: {
      if (type != null && type != 'all') 'type': type,
      'limit': limit.toString(),
      'offset': offset.toString(),
    });
    final res = await http.get(uri, headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json'
    }).timeout(const Duration(seconds: 15));
    if (res.statusCode == 200) {
      final json = jsonDecode(res.body);
      if (json['status'] == 'success' && json['data'] != null) {
        return (json['data'] as List).map((e) => IncomeRecord.fromJson(e)).toList();
      }
      return [];
    } else {
      throw Exception('Server error: ${res.statusCode}');
    }
  }
}

// ==========================================
// 3. Wallet Page
// ==========================================

class WalletPage extends StatefulWidget {
  const WalletPage({super.key});
  @override
  State<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  static const Color accentColor = Color(0xFF10B981);

  WalletBalance? _balance;
  bool _isLoadingBalance = true;
  String? _balanceError;

  List<IncomeRecord> _records = [];
  bool _isLoadingHistory = true;
  String? _historyError;
  String _activeFilter = 'all';

  String _token = '';
  bool _hasMore = true;
  int _offset = 0;
  static const int _limit = 20;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('jwt_token') ?? '';
    if (_token.isEmpty) {
      setState(() {
        _balanceError = 'Token not found';
        _isLoadingBalance = false;
      });
      return;
    }
    await Future.wait([_fetchBalance(), _fetchHistory(reset: true)]);
  }

  Future<void> _fetchBalance() async {
    setState(() { _isLoadingBalance = true; _balanceError = null; });
    try {
      final balance = await WalletApiService.fetchBalance(_token);
      if (mounted) setState(() { _balance = balance; _isLoadingBalance = false; });
    } catch (e) {
      if (mounted) setState(() { _balanceError = e.toString().replaceAll('Exception: ', ''); _isLoadingBalance = false; });
    }
  }

  Future<void> _fetchHistory({bool reset = false}) async {
    if (reset) {
      setState(() { _offset = 0; _records = []; _hasMore = true; _isLoadingHistory = true; _historyError = null; });
    } else {
      if (!_hasMore || _isLoadingHistory) return;
      setState(() { _isLoadingHistory = true; });
    }
    try {
      final newRecords = await WalletApiService.fetchIncomeHistory(
        _token,
        type: _activeFilter == 'all' ? null : _activeFilter,
        limit: _limit,
        offset: _offset,
      );
      if (mounted) {
        setState(() {
          _records.addAll(newRecords);
          _offset += newRecords.length;
          _hasMore = newRecords.length == _limit;
          _isLoadingHistory = false;
          _historyError = null;
        });
      }
    } catch (e) {
      if (mounted) setState(() {
        _historyError = e.toString().replaceAll('Exception: ', '');
        _isLoadingHistory = false;
      });
    }
  }

  void _onFilterChanged(String filter) {
    if (_activeFilter == filter) return;
    _activeFilter = filter;
    _fetchHistory(reset: true);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF000000) : const Color(0xFFF2F2F7);
    final cardColor = isDark ? const Color(0xFF1C1C1E) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF000000);
    final subTextColor = isDark ? const Color(0xFF8E8E93) : const Color(0xFF8E8E93);
    final borderColor = isDark ? const Color(0xFF2C2C2E) : const Color(0xFFE5E5EA);
    final shadowColor = isDark ? Colors.black.withOpacity(0.5) : Colors.black.withOpacity(0.04);

    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 1024;
    final isTablet = screenWidth >= 600 && screenWidth < 1024;
    final isSmall = screenWidth < 360;
    final hPadding = isDesktop ? 32.w : isTablet ? 20.w : isSmall ? 12.w : 16.w;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          color: accentColor,
          backgroundColor: cardColor,
          onRefresh: () async {
            HapticFeedback.mediumImpact();
            await _fetchBalance();
            await _fetchHistory(reset: true);
          },
          child: NotificationListener<ScrollNotification>(
            onNotification: (scroll) {
              if (scroll is ScrollEndNotification && scroll.metrics.pixels >= scroll.metrics.maxScrollExtent - 50) {
                _fetchHistory();
              }
              return false;
            },
            child: ListView(
              padding: EdgeInsets.fromLTRB(hPadding, 8.h, hPadding, 40.h),
              physics: const BouncingScrollPhysics(),
              children: [
                _buildHeader(textColor, subTextColor, isSmall, isDesktop),
                SizedBox(height: 14.h),
                _buildBalanceCard(isSmall)
                    .animate().fadeIn(delay: 80.ms).slideY(begin: 0.03),
                SizedBox(height: 20.h),
                _buildFilterChips(isSmall, cardColor, textColor, subTextColor, borderColor)
                    .animate().fadeIn(delay: 120.ms).slideY(begin: 0.03),
                SizedBox(height: 10.h),
                if (_isLoadingHistory && _records.isEmpty)
                  ...List.generate(4, (_) => _buildShimmerItem(isSmall, cardColor))
                else if (_historyError != null && _records.isEmpty)
                  _buildErrorCard(_historyError!, () => _fetchHistory(reset: true), isSmall, cardColor, textColor)
                else if (_records.isEmpty)
                  _buildEmptyCard('No income records yet', isSmall, cardColor, shadowColor, borderColor, textColor, subTextColor)
                else ...
                  _records.map((r) => _buildIncomeTile(r, isSmall, cardColor, shadowColor, borderColor, textColor, subTextColor)).toList(),
                if (_isLoadingHistory && _records.isNotEmpty)
                  Padding(padding: EdgeInsets.symmetric(vertical: 10.h), child: const CupertinoActivityIndicator()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ==================== HEADER ====================
  Widget _buildHeader(Color textColor, Color subTextColor, bool isSmall, bool isDesktop) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Wallet', style: GoogleFonts.poppins(fontSize: isSmall ? 24.sp : isDesktop ? 30.sp : 26.sp, fontWeight: FontWeight.w700, color: textColor, height: 1.1)),
            Text('Balance', style: GoogleFonts.poppins(fontSize: isSmall ? 24.sp : isDesktop ? 30.sp : 26.sp, fontWeight: FontWeight.w300, color: textColor, height: 1.1)),
          ],
        ),
        Container(
          width: 32.w, height: 32.w,
          decoration: BoxDecoration(color: accentColor.withOpacity(0.08), shape: BoxShape.circle),
          child: Icon(CupertinoIcons.money_dollar_circle_fill, color: accentColor, size: isSmall ? 18.sp : 20.sp),
        ),
      ],
    ).animate().fadeIn(delay: 40.ms);
  }

  // ==================== BALANCE CARD ====================
  Widget _buildBalanceCard(bool isSmall) {
    final balance = _balance?.balance ?? 0.0;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: isSmall ? 16.w : 20.w, vertical: isSmall ? 16.h : 18.h),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF10B981), Color(0xFF059669)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [BoxShadow(color: accentColor.withOpacity(0.3), blurRadius: 24, offset: const Offset(0, 10), spreadRadius: -4)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(CupertinoIcons.money_dollar_circle, color: Colors.white.withOpacity(0.7), size: isSmall ? 12.sp : 14.sp),
              SizedBox(width: 5.w),
              Text('Available Balance', style: GoogleFonts.poppins(color: Colors.white.withOpacity(0.7), fontSize: isSmall ? 10.sp : 11.sp, fontWeight: FontWeight.w500)),
              const Spacer(),
              if (!_isLoadingBalance)
                GestureDetector(
                  onTap: () async { HapticFeedback.lightImpact(); await _fetchBalance(); },
                  child: Row(children: [
                    Icon(CupertinoIcons.arrow_clockwise, color: Colors.white.withOpacity(0.55), size: isSmall ? 10.sp : 11.sp),
                    SizedBox(width: 3.w),
                    Text('Refresh', style: GoogleFonts.poppins(color: Colors.white.withOpacity(0.55), fontSize: isSmall ? 9.sp : 10.sp)),
                  ]),
                ),
            ],
          ),
          SizedBox(height: 8.h),
          if (_isLoadingBalance)
            _buildShimmer(isSmall)
          else if (_balanceError != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Icon(CupertinoIcons.exclamationmark_circle, color: Colors.white.withOpacity(0.8), size: isSmall ? 14.sp : 16.sp),
                  SizedBox(width: 6.w),
                  Text('Failed to load', style: GoogleFonts.poppins(color: Colors.white.withOpacity(0.8), fontSize: isSmall ? 14.sp : 16.sp)),
                ]),
                SizedBox(height: 6.h),
                GestureDetector(
                  onTap: () async { HapticFeedback.mediumImpact(); await _fetchBalance(); },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.12), borderRadius: BorderRadius.circular(10.r)),
                    child: Text('Retry', style: GoogleFonts.poppins(color: Colors.white, fontSize: isSmall ? 10.sp : 11.sp)),
                  ),
                ),
              ],
            )
          else
            Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text('\u09F3', style: GoogleFonts.poppins(color: Colors.white.withOpacity(0.6), fontSize: isSmall ? 16.sp : 18.sp)),
              SizedBox(width: 3.w),
              Text(balance.toStringAsFixed(2), style: GoogleFonts.poppins(color: Colors.white, fontSize: isSmall ? 28.sp : 32.sp, fontWeight: FontWeight.w700, letterSpacing: -1.2)),
            ]),
        ],
      ),
    );
  }

  Widget _buildShimmer(bool isSmall) => Container(
    height: isSmall ? 34.h : 38.h,
    width: 140.w,
    decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(8.r)),
  ).animate(onPlay: (c) => c.repeat()).shimmer(duration: 1200.ms, color: Colors.white.withOpacity(0.35));

  // ==================== FILTER CHIPS ====================
  Widget _buildFilterChips(bool isSmall, Color cardColor, Color textColor, Color subTextColor, Color borderColor) {
    final filters = [
      {'label': 'All', 'value': 'all'},
      {'label': 'Referral', 'value': 'referral'},
      {'label': 'Matrix', 'value': 'matrix'},
      {'label': 'Royalty', 'value': 'royalty'},
    ];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.zero,
      child: Row(
        children: filters.map((f) {
          final selected = _activeFilter == f['value'];
          return Padding(
            padding: EdgeInsets.only(right: 6.w),
            child: GestureDetector(
              onTap: () => _onFilterChanged(f['value']!),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: selected ? accentColor : cardColor,
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(color: selected ? accentColor : borderColor, width: 0.5),
                ),
                child: Text(
                  f['label']!,
                  style: GoogleFonts.poppins(
                    fontSize: isSmall ? 11.sp : 12.sp,
                    fontWeight: FontWeight.w500,
                    color: selected ? Colors.white : textColor,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ==================== INCOME TILE ====================
  Widget _buildIncomeTile(IncomeRecord rec, bool isSmall, Color cardColor, Color shadowColor, Color borderColor, Color textColor, Color subTextColor) {
    Color typeColor;
    IconData icon;
    switch (rec.type) {
      case 'referral':
        typeColor = const Color(0xFF8B5CF6);
        icon = CupertinoIcons.person_2_fill;
        break;
      case 'matrix':
        typeColor = const Color(0xFF6366F1);
        icon = CupertinoIcons.cube_box_fill;
        break;
      case 'royalty':
        typeColor = const Color(0xFFF59E0B);
        icon = CupertinoIcons.star_fill;
        break;
      default:
        typeColor = Colors.grey;
        icon = CupertinoIcons.money_dollar;
    }
    return Container(
      padding: EdgeInsets.all(isSmall ? 12.w : 14.w),
      margin: EdgeInsets.only(bottom: 6.h),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: borderColor, width: 0.5),
        boxShadow: [BoxShadow(color: shadowColor, blurRadius: 12, offset: const Offset(0, 4), spreadRadius: -2)],
      ),
      child: Row(
        children: [
          Container(
            width: isSmall ? 36.w : 40.w,
            height: isSmall ? 36.w : 40.w,
            decoration: BoxDecoration(color: typeColor.withOpacity(0.1), borderRadius: BorderRadius.circular(10.r)),
            child: Icon(icon, color: typeColor, size: isSmall ? 16.sp : 18.sp),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(rec.description, style: GoogleFonts.poppins(fontSize: isSmall ? 11.sp : 12.sp, fontWeight: FontWeight.w600, color: textColor), maxLines: 1, overflow: TextOverflow.ellipsis),
                SizedBox(height: 2.h),
                Text('${rec.createdAt.day}/${rec.createdAt.month}/${rec.createdAt.year}', style: GoogleFonts.poppins(fontSize: isSmall ? 9.sp : 10.sp, color: subTextColor)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('\u09F3 ${rec.amount.toStringAsFixed(2)}', style: GoogleFonts.poppins(fontSize: isSmall ? 13.sp : 15.sp, fontWeight: FontWeight.w700, color: textColor)),
              SizedBox(height: 2.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                decoration: BoxDecoration(color: typeColor.withOpacity(0.1), borderRadius: BorderRadius.circular(6.r)),
                child: Text(rec.type.toUpperCase(), style: GoogleFonts.poppins(fontSize: isSmall ? 8.sp : 9.sp, color: typeColor, fontWeight: FontWeight.w500)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerItem(bool isSmall, Color cardColor) => Container(
    height: 60.h, margin: EdgeInsets.only(bottom: 6.h),
    decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(14.r)),
  ).animate(onPlay: (c) => c.repeat()).shimmer(duration: 1200.ms, color: Colors.grey.withOpacity(0.3));

  Widget _buildErrorCard(String msg, VoidCallback retry, bool isSmall, Color cardColor, Color textColor) => Container(
    padding: EdgeInsets.all(16.w), margin: EdgeInsets.only(bottom: 6.h),
    decoration: BoxDecoration(color: Colors.red.withOpacity(0.05), borderRadius: BorderRadius.circular(14.r), border: Border.all(color: Colors.red.withOpacity(0.2))),
    child: Column(children: [
      Icon(CupertinoIcons.exclamationmark_circle, color: Colors.red, size: isSmall ? 24.sp : 28.sp),
      SizedBox(height: 8.h),
      Text(msg, style: GoogleFonts.poppins(fontSize: isSmall ? 11.sp : 12.sp, color: Colors.red), textAlign: TextAlign.center),
      SizedBox(height: 10.h),
      GestureDetector(onTap: retry, child: Container(padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h), decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(10.r)), child: Text('Retry', style: GoogleFonts.poppins(color: Colors.white)))),
    ]),
  );

  Widget _buildEmptyCard(String text, bool isSmall, Color cardColor, Color shadowColor, Color borderColor, Color textColor, Color subTextColor) => Container(
    padding: EdgeInsets.all(24.w), margin: EdgeInsets.only(bottom: 6.h),
    decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(14.r), border: Border.all(color: borderColor, width: 0.5)),
    child: Column(children: [
      Icon(CupertinoIcons.tray, color: subTextColor, size: isSmall ? 32.sp : 36.sp),
      SizedBox(height: 8.h),
      Text(text, style: GoogleFonts.poppins(fontSize: isSmall ? 12.sp : 13.sp, color: subTextColor)),
    ]),
  );
}
