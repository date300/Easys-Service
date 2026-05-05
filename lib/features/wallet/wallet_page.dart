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
// 3. Wallet Page (Updated Design)
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

  // Income stats for the rows
  double _todayIncome = 0.0;
  double _yesterdayIncome = 0.0;
  double _last7DaysIncome = 0.0;
  bool _isLoadingStats = true;
  String? _statsError;

  String _token = '';

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
        _isLoadingStats = false;
      });
      return;
    }
    await Future.wait([_fetchBalance(), _fetchIncomeStats()]);
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

  Future<void> _fetchIncomeStats() async {
    setState(() { _isLoadingStats = true; _statsError = null; });
    try {
      // Fetch all recent records (no filter, large limit) to compute daily sums
      final records = await WalletApiService.fetchIncomeHistory(
        _token,
        type: null,           // all types
        limit: 500,          // ensure we get enough records
        offset: 0,
      );
      if (mounted) {
        _computeStats(records);
        setState(() { _isLoadingStats = false; });
      }
    } catch (e) {
      if (mounted) setState(() {
        _statsError = e.toString().replaceAll('Exception: ', '');
        _isLoadingStats = false;
      });
    }
  }

  void _computeStats(List<IncomeRecord> records) {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final yesterdayStart = todayStart.subtract(const Duration(days: 1));
    final weekStart = todayStart.subtract(const Duration(days: 7));

    double today = 0, yesterday = 0, week = 0;
    for (var rec in records) {
      final date = rec.createdAt;
      if (date.isAfter(todayStart) || date.isAtSameMomentAs(todayStart)) {
        today += rec.amount;
        week += rec.amount;
      } else if (date.isAfter(yesterdayStart) && date.isBefore(todayStart)) {
        yesterday += rec.amount;
        week += rec.amount;
      } else if (date.isAfter(weekStart) || date.isAtSameMomentAs(weekStart)) {
        week += rec.amount;
      }
    }
    _todayIncome = today;
    _yesterdayIncome = yesterday;
    _last7DaysIncome = week;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF000000) : const Color(0xFFF2F2F7);
    final cardColor = isDark ? const Color(0xFF1C1C1E) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF000000);
    final subTextColor = isDark ? const Color(0xFF8E8E93) : const Color(0xFF8E8E93);
    final borderColor = isDark ? const Color(0xFF2C2C2E) : const Color(0xFFE5E5EA);

    final screenWidth = MediaQuery.of(context).size.width;
    final isSmall = screenWidth < 360;
    final hPadding = isSmall ? 12.w : 16.w;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          color: accentColor,
          backgroundColor: cardColor,
          onRefresh: () async {
            HapticFeedback.mediumImpact();
            await Future.wait([_fetchBalance(), _fetchIncomeStats()]);
          },
          child: ListView(
            padding: EdgeInsets.fromLTRB(hPadding, 8.h, hPadding, 40.h),
            physics: const BouncingScrollPhysics(),
            children: [
              // ========== Percentage & synced info ==========
              _buildPercentageBlock(textColor),
              SizedBox(height: 12.h),
              // ========== Balance label & amount ==========
              _buildBalanceSection(textColor, subTextColor),
              SizedBox(height: 10.h),
              // ========== Synced notice ==========
              Text(
                'অ্যাসপ অ্যাকাউন্ট থেকে সিঙ্ক হয়েছে',
                style: GoogleFonts.poppins(color: subTextColor, fontSize: isSmall ? 11.sp : 12.sp),
              ),
              SizedBox(height: 16.h),
              // ========== Withdraw button ==========
              _buildWithdrawButton(isSmall),
              SizedBox(height: 24.h),
              // ========== Transaction History header ==========
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('ট্রানজেকশন হিস্ট্রি', style: GoogleFonts.poppins(
                    fontSize: isSmall ? 14.sp : 16.sp,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  )),
                  TextButton(
                    onPressed: () { /* TODO: View all transactions */ },
                    child: Text('সব দেখুন', style: GoogleFonts.poppins(fontSize: isSmall ? 10.sp : 12.sp, color: accentColor)),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              // ========== Income rows ==========
              if (_isLoadingStats)
                ...List.generate(3, (_) => _buildStatsShimmer(isSmall, cardColor))
              else if (_statsError != null)
                _buildErrorCard(_statsError!, () => _fetchIncomeStats(), isSmall, textColor)
              else ...[
                _buildIncomeRow('আজকের আয়', _todayIncome, cardColor, textColor, subTextColor, borderColor, isSmall, () {
                  // TODO: navigate to today's detail
                }),
                SizedBox(height: 8.h),
                _buildIncomeRow('গতকালের আয়', _yesterdayIncome, cardColor, textColor, subTextColor, borderColor, isSmall, () {
                  // TODO: navigate to yesterday's detail
                }),
                SizedBox(height: 8.h),
                _buildIncomeRow('গত ৭ দিনের আয়', _last7DaysIncome, cardColor, textColor, subTextColor, borderColor, isSmall, () {
                  // TODO: navigate to weekly detail
                }),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ==================== Percentage (840.01%) ====================
  Widget _buildPercentageBlock(Color textColor) {
    // This value should be replaced with real data from your backend.
    const String percentage = '840.01%';
    return Center(
      child: Text(
        percentage,
        style: GoogleFonts.poppins(
          fontSize: 42.sp,
          fontWeight: FontWeight.w800,
          color: accentColor,
          letterSpacing: -1,
        ),
      ),
    ).animate().fadeIn(delay: 60.ms).scale(begin: const Offset(0.95, 0.95));
  }

  // ==================== Balance ====================
  Widget _buildBalanceSection(Color textColor, Color subTextColor) {
    final balance = _balance?.balance ?? 0.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('বর্তমান ব্যালেন্স', style: GoogleFonts.poppins(
          fontSize: 13.sp,
          color: subTextColor,
        )),
        SizedBox(height: 2.h),
        if (_isLoadingBalance)
          _buildShimmerBalance()
        else if (_balanceError != null)
          GestureDetector(
            onTap: () { _fetchBalance(); },
            child: Row(
              children: [
                Icon(CupertinoIcons.exclamationmark_circle, color: Colors.red, size: 16.sp),
                SizedBox(width: 6.w),
                Text('লোড ব্যর্থ', style: GoogleFonts.poppins(color: Colors.red, fontSize: 14.sp)),
              ],
            ),
          )
        else
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('৳', style: GoogleFonts.poppins(color: textColor, fontSize: 22.sp, fontWeight: FontWeight.w600)),
              SizedBox(width: 2.w),
              Text(
                balance.toStringAsFixed(2),
                style: GoogleFonts.poppins(
                  fontSize: 26.sp,
                  fontWeight: FontWeight.w700,
                  color: textColor,
                  letterSpacing: -1,
                ),
              ),
            ],
          ),
      ],
    ).animate().fadeIn(delay: 120.ms);
  }

  Widget _buildShimmerBalance() => Container(
    height: 28.h,
    width: 140.w,
    decoration: BoxDecoration(
      color: Colors.grey.withOpacity(0.2),
      borderRadius: BorderRadius.circular(8.r),
    ),
  ).animate(onPlay: (c) => c.repeat()).shimmer(duration: 1200.ms, color: Colors.white.withOpacity(0.3));

  // ==================== Withdraw Button ====================
  Widget _buildWithdrawButton(bool isSmall) {
    return SizedBox(
      width: double.infinity,
      height: 44.h,
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        color: accentColor,
        borderRadius: BorderRadius.circular(12.r),
        onPressed: () {
          // TODO: Implement withdraw functionality
          HapticFeedback.mediumImpact();
        },
        child: Text(
          'উইথড্র',
          style: GoogleFonts.poppins(
            fontSize: isSmall ? 14.sp : 16.sp,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    ).animate().fadeIn(delay: 180.ms);
  }

  // ==================== Income Row (Today / Yesterday / Week) ====================
  Widget _buildIncomeRow(
    String title,
    double amount,
    Color cardColor,
    Color textColor,
    Color subTextColor,
    Color borderColor,
    bool isSmall,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: borderColor, width: 0.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 12,
              offset: const Offset(0, 4),
              spreadRadius: -2,
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: isSmall ? 13.sp : 14.sp,
                  fontWeight: FontWeight.w500,
                  color: textColor,
                ),
              ),
            ),
            Text(
              '৳ ${amount.toStringAsFixed(2)}',
              style: GoogleFonts.poppins(
                fontSize: isSmall ? 13.sp : 14.sp,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
            SizedBox(width: 8.w),
            Icon(
              CupertinoIcons.chevron_right,
              size: 18.sp,
              color: subTextColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsShimmer(bool isSmall, Color cardColor) => Container(
    height: 54.h,
    margin: EdgeInsets.only(bottom: 8.h),
    decoration: BoxDecoration(
      color: cardColor,
      borderRadius: BorderRadius.circular(14.r),
    ),
  ).animate(onPlay: (c) => c.repeat()).shimmer(duration: 1200.ms, color: Colors.grey.withOpacity(0.3));

  Widget _buildErrorCard(String msg, VoidCallback retry, bool isSmall, Color textColor) => Container(
    padding: EdgeInsets.all(16.w),
    margin: EdgeInsets.only(bottom: 8.h),
    decoration: BoxDecoration(
      color: Colors.red.withOpacity(0.05),
      borderRadius: BorderRadius.circular(14.r),
      border: Border.all(color: Colors.red.withOpacity(0.2)),
    ),
    child: Column(children: [
      Icon(CupertinoIcons.exclamationmark_circle, color: Colors.red, size: isSmall ? 24.sp : 28.sp),
      SizedBox(height: 8.h),
      Text(msg, style: GoogleFonts.poppins(fontSize: isSmall ? 11.sp : 12.sp, color: Colors.red), textAlign: TextAlign.center),
      SizedBox(height: 10.h),
      GestureDetector(onTap: retry, child: Container(padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h), decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(10.r)), child: Text('Retry', style: GoogleFonts.poppins(color: Colors.white)))),
    ]),
  );
}
