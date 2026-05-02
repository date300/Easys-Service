import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

// ==========================================
// 1. Data Models
// ==========================================

class RoyaltyIncome {
  final int id;
  final double amount;
  final String description;
  final DateTime createdAt;

  RoyaltyIncome({required this.id, required this.amount, required this.description, required this.createdAt});

  factory RoyaltyIncome.fromJson(Map<String, dynamic> json) => RoyaltyIncome(
        id: json['id'],
        amount: double.tryParse(json['amount'].toString()) ?? 0.0,
        description: json['description'] ?? '',
        createdAt: DateTime.parse(json['created_at']),
      );
}

class RoyaltyGlobalData {
  final double royaltyFund;

  RoyaltyGlobalData({required this.royaltyFund});

  factory RoyaltyGlobalData.fromJson(Map<String, dynamic> json) => RoyaltyGlobalData(
        royaltyFund: double.tryParse(json['data']['royalty_fund'].toString()) ?? 0.0,
      );
}

// ==========================================
// 2. API Service
// ==========================================

class RoyaltyApiService {
  static const String _baseUrl = 'https://easy.ltcminematrix.com/api';

  static Future<List<RoyaltyIncome>> fetchMyRoyaltyHistory(String token) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/income/history?type=royalty&limit=50'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    ).timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      if (json['status'] == 'success' && json['data'] != null) {
        return (json['data'] as List).map((e) => RoyaltyIncome.fromJson(e)).toList();
      }
      return [];
    } else if (response.statusCode == 401) {
      throw Exception('Session expired. Please login again.');
    } else {
      throw Exception('Server error: ${response.statusCode}');
    }
  }

  static Future<RoyaltyGlobalData> fetchGlobalFunds() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/global-funds'),
      headers: {'Content-Type': 'application/json'},
    ).timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      if (json['status'] == 'success') {
        return RoyaltyGlobalData.fromJson(json);
      }
      throw Exception('API error');
    } else {
      throw Exception('Server error: ${response.statusCode}');
    }
  }
}

// ==========================================
// 3. RoyaltySalaryPage
// ==========================================

class RoyaltySalaryPage extends StatefulWidget {
  const RoyaltySalaryPage({super.key});

  @override
  State<RoyaltySalaryPage> createState() => _RoyaltySalaryPageState();
}

class _RoyaltySalaryPageState extends State<RoyaltySalaryPage> {
  static const Color royaltyGold = Color(0xFFF59E0B);

  List<RoyaltyIncome> _myRoyalties = [];
  bool _isLoadingMy = true;
  String? _myError;

  RoyaltyGlobalData? _globalData;
  bool _isLoadingGlobal = true;
  String? _globalError;

  String _token = '';

  @override
  void initState() {
    super.initState();
    _loadToken();
  }

  Future<void> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('jwt_token') ?? '';
    await Future.wait([_fetchMyRoyalties(), _fetchGlobalFunds()]);
  }

  Future<void> _fetchMyRoyalties() async {
    setState(() {
      _isLoadingMy = true;
      _myError = null;
    });
    try {
      if (_token.isEmpty) throw Exception('Token not found');
      final data = await RoyaltyApiService.fetchMyRoyaltyHistory(_token);
      if (mounted) {
        setState(() {
          _myRoyalties = data;
          _isLoadingMy = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _myError = e.toString().replaceAll('Exception: ', '');
          _isLoadingMy = false;
        });
      }
    }
  }

  Future<void> _fetchGlobalFunds() async {
    setState(() {
      _isLoadingGlobal = true;
      _globalError = null;
    });
    try {
      final data = await RoyaltyApiService.fetchGlobalFunds();
      if (mounted) {
        setState(() {
          _globalData = data;
          _isLoadingGlobal = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _globalError = e.toString().replaceAll('Exception: ', '');
          _isLoadingGlobal = false;
        });
      }
    }
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

    final totalEarned = _myRoyalties.fold<double>(0, (sum, item) => sum + item.amount);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          color: royaltyGold,
          backgroundColor: cardColor,
          onRefresh: () async {
            HapticFeedback.mediumImpact();
            await Future.wait([_fetchMyRoyalties(), _fetchGlobalFunds()]);
          },
          child: ListView(
            padding: EdgeInsets.fromLTRB(hPadding, 8.h, hPadding, 40.h),
            physics: const BouncingScrollPhysics(),
            children: [
              _buildHeader(textColor, subTextColor, isSmall, isDesktop),
              SizedBox(height: 14.h),

              // Royalty Balance Card (gradient, like voucher)
              _buildRoyaltyBalanceCard(isSmall, totalEarned)
                  .animate()
                  .fadeIn(delay: 80.ms)
                  .slideY(begin: 0.03),
              SizedBox(height: 10.h),

              // Global Fund Card
              _buildGlobalFundCard(
                isSmall, isDesktop, cardColor,
                shadowColor, borderColor, textColor, subTextColor,
              ).animate().fadeIn(delay: 120.ms).slideY(begin: 0.03),
              SizedBox(height: 10.h),

              // Stat Card: Total Earned
              _buildStatCard(
                icon: CupertinoIcons.star_fill,
                iconColor: royaltyGold,
                label: 'My Royalty',
                amount: _isLoadingMy
                    ? '...'
                    : '\u09F3${totalEarned.toStringAsFixed(2)}',
                cardColor: cardColor,
                textColor: textColor,
                subTextColor: subTextColor,
                shadowColor: shadowColor,
                borderColor: borderColor,
                isSmall: isSmall,
                isDesktop: isDesktop,
              ).animate().fadeIn(delay: 160.ms).slideY(begin: 0.03),
              SizedBox(height: 20.h),

              // Recent Royalty History
              _buildHistorySection(isSmall, cardColor, shadowColor, borderColor, textColor, subTextColor)
                  .animate().fadeIn(delay: 200.ms).slideY(begin: 0.03),
            ],
          ),
        ),
      ),
    );
  }

  // ==================== HEADER ====================
  Widget _buildHeader(Color textColor, Color subTextColor, bool isSmall, bool isDesktop) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Royalty',
              style: GoogleFonts.poppins(
                fontSize: isSmall ? 24.sp : isDesktop ? 30.sp : 26.sp,
                fontWeight: FontWeight.w700,
                color: textColor,
                height: 1.1,
                letterSpacing: -0.5,
              ),
            ),
            Text(
              'Salary',
              style: GoogleFonts.poppins(
                fontSize: isSmall ? 24.sp : isDesktop ? 30.sp : 26.sp,
                fontWeight: FontWeight.w300,
                color: textColor,
                height: 1.1,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        Container(
          width: 32.w,
          height: 32.w,
          decoration: BoxDecoration(
            color: royaltyGold.withOpacity(0.08),
            shape: BoxShape.circle,
          ),
          child: Icon(
            CupertinoIcons.star_fill,
            color: royaltyGold,
            size: isSmall ? 16.sp : 18.sp,
          ),
        ),
      ],
    ).animate().fadeIn(delay: 40.ms);
  }

  // ==================== ROYALTY BALANCE CARD (Gradient) ====================
  Widget _buildRoyaltyBalanceCard(bool isSmall, double totalEarned) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isSmall ? 16.w : 20.w,
        vertical: isSmall ? 16.h : 18.h,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFF59E0B).withOpacity(0.25),
            blurRadius: 24,
            offset: const Offset(0, 10),
            spreadRadius: -4,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(CupertinoIcons.star_fill,
                      color: Colors.white.withOpacity(0.7),
                      size: isSmall ? 11.sp : 12.sp),
                  SizedBox(width: 5.w),
                  Text(
                    'Your Royalty Income',
                    style: GoogleFonts.poppins(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: isSmall ? 10.sp : 11.sp,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Text(
                  'Monthly',
                  style: GoogleFonts.poppins(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: isSmall ? 9.sp : 10.sp,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),

          if (_isLoadingMy)
            _buildBalanceShimmer(isSmall)
          else if (_myError != null)
            _buildBalanceError(isSmall)
          else
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '\u09F3',
                  style: GoogleFonts.poppins(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: isSmall ? 16.sp : 18.sp,
                    fontWeight: FontWeight.w500,
                    height: 1.2,
                  ),
                ),
                SizedBox(width: 3.w),
                Text(
                  totalEarned.toStringAsFixed(2),
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: isSmall ? 28.sp : 32.sp,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -1.2,
                    height: 1.1,
                  ),
                ),
              ],
            ),

          SizedBox(height: 14.h),

          if (_myError == null)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total earned from royalty',
                  style: GoogleFonts.poppins(
                    color: Colors.white.withOpacity(0.55),
                    fontSize: isSmall ? 9.sp : 10.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (!_isLoadingMy)
                  GestureDetector(
                    onTap: () async {
                      HapticFeedback.lightImpact();
                      await _fetchMyRoyalties();
                    },
                    child: Row(
                      children: [
                        Icon(CupertinoIcons.arrow_clockwise,
                            color: Colors.white.withOpacity(0.55),
                            size: isSmall ? 9.sp : 10.sp),
                        SizedBox(width: 3.w),
                        Text(
                          'Refresh',
                          style: GoogleFonts.poppins(
                            color: Colors.white.withOpacity(0.55),
                            fontSize: isSmall ? 9.sp : 10.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),

          SizedBox(height: 12.h),

          if (_myError != null)
            GestureDetector(
              onTap: () async {
                HapticFeedback.mediumImpact();
                await _fetchMyRoyalties();
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(CupertinoIcons.arrow_clockwise,
                        color: Colors.white.withOpacity(0.8),
                        size: isSmall ? 10.sp : 11.sp),
                    SizedBox(width: 5.w),
                    Text(
                      'Retry',
                      style: GoogleFonts.poppins(
                        color: Colors.white.withOpacity(0.85),
                        fontSize: isSmall ? 10.sp : 11.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBalanceShimmer(bool isSmall) {
    return Container(
      height: isSmall ? 34.h : 38.h,
      width: 140.w,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8.r),
      ),
    ).animate(onPlay: (c) => c.repeat()).shimmer(
          duration: 1200.ms,
          color: Colors.white.withOpacity(0.35),
        );
  }

  Widget _buildBalanceError(bool isSmall) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(CupertinoIcons.exclamationmark_circle,
                color: Colors.white.withOpacity(0.8),
                size: isSmall ? 14.sp : 16.sp),
            SizedBox(width: 6.w),
            Text(
              'Failed to load',
              style: GoogleFonts.poppins(
                color: Colors.white.withOpacity(0.8),
                fontSize: isSmall ? 14.sp : 16.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        SizedBox(height: 4.h),
        Text(
          _myError ?? '',
          style: GoogleFonts.poppins(
            color: Colors.white.withOpacity(0.5),
            fontSize: isSmall ? 9.sp : 10.sp,
            fontWeight: FontWeight.w400,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  // ==================== GLOBAL FUND CARD ====================
  Widget _buildGlobalFundCard(
    bool isSmall,
    bool isDesktop,
    Color cardColor,
    Color shadowColor,
    Color borderColor,
    Color textColor,
    Color subTextColor,
  ) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
          horizontal: isSmall ? 14.w : 16.w,
          vertical: isSmall ? 10.h : 12.h),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: borderColor, width: 0.5),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: 16,
            offset: const Offset(0, 6),
            spreadRadius: -4,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: isSmall ? 34.w : 36.w,
            height: isSmall ? 34.w : 36.w,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(10.r),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFF59E0B).withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Icon(CupertinoIcons.globe,
                  color: Colors.white, size: isSmall ? 16.sp : 18.sp),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Global Royalty Fund',
                  style: GoogleFonts.poppins(
                    fontSize: isSmall ? 12.sp : 13.sp,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                    letterSpacing: -0.2,
                  ),
                ),
                SizedBox(height: 1.h),
                Text(
                  _isLoadingGlobal
                      ? 'Loading...'
                      : _globalError != null
                          ? 'Failed to load'
                          : '\u09F3${_globalData!.royaltyFund.toStringAsFixed(2)}',
                  style: GoogleFonts.poppins(
                    fontSize: isSmall ? 9.sp : 10.sp,
                    color: subTextColor,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          if (_isLoadingGlobal)
            CupertinoActivityIndicator(radius: isSmall ? 6.r : 7.r)
          else if (_globalError != null)
            Icon(CupertinoIcons.exclamationmark_circle,
                color: Colors.red, size: isSmall ? 14.sp : 16.sp)
          else
            Text(
              'Live',
              style: GoogleFonts.poppins(
                color: Colors.green,
                fontSize: isSmall ? 10.sp : 11.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
        ],
      ),
    );
  }

  // ==================== STAT CARD ====================
  Widget _buildStatCard({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String amount,
    required Color cardColor,
    required Color textColor,
    required Color subTextColor,
    required Color shadowColor,
    required Color borderColor,
    required bool isSmall,
    required bool isDesktop,
  }) {
    return Container(
      padding: EdgeInsets.all(isSmall ? 12.w : 14.w),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: borderColor, width: 0.5),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: 16,
            offset: const Offset(0, 6),
            spreadRadius: -4,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: isSmall ? 26.w : 28.w,
                height: isSmall ? 26.w : 28.w,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(icon,
                    color: iconColor, size: isSmall ? 14.sp : 15.sp),
              ),
              const Spacer(),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: isSmall ? 9.sp : 10.sp,
                  color: subTextColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            amount,
            style: GoogleFonts.poppins(
              fontSize: isSmall ? 15.sp : 17.sp,
              fontWeight: FontWeight.w700,
              color: textColor,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }

  // ==================== HISTORY SECTION ====================
  Widget _buildHistorySection(bool isSmall, Color cardColor, Color shadowColor, Color borderColor, Color textColor, Color subTextColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 4.w, bottom: 8.h),
          child: Text(
            'Recent Royalty Payments',
            style: GoogleFonts.poppins(
              fontSize: isSmall ? 13.sp : 14.sp,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ),
        if (_isLoadingMy)
          ...List.generate(3, (_) => _buildShimmerListItem(isSmall, cardColor))
        else if (_myError != null)
          _buildErrorCard('Failed to load history', () => _fetchMyRoyalties(), isSmall, cardColor, textColor)
        else if (_myRoyalties.isEmpty)
          _buildEmptyCard('No royalty payments yet', isSmall, cardColor, shadowColor, borderColor, textColor, subTextColor)
        else
          ..._myRoyalties.take(5).map((item) => _buildHistoryTile(item, isSmall, cardColor, shadowColor, borderColor, textColor, subTextColor)),
      ],
    );
  }

  Widget _buildHistoryTile(RoyaltyIncome item, bool isSmall, Color cardColor, Color shadowColor, Color borderColor, Color textColor, Color subTextColor) {
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
            decoration: BoxDecoration(
              color: royaltyGold.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(CupertinoIcons.star_fill, color: royaltyGold, size: isSmall ? 16.sp : 18.sp),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.description,
                  style: GoogleFonts.poppins(fontSize: isSmall ? 11.sp : 12.sp, fontWeight: FontWeight.w600, color: textColor),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 2.h),
                Text(
                  '${item.createdAt.day}/${item.createdAt.month}/${item.createdAt.year}',
                  style: GoogleFonts.poppins(fontSize: isSmall ? 9.sp : 10.sp, color: subTextColor),
                ),
              ],
            ),
          ),
          Text(
            '\u09F3${item.amount.toStringAsFixed(2)}',
            style: GoogleFonts.poppins(
              fontSize: isSmall ? 13.sp : 15.sp,
              fontWeight: FontWeight.w700,
              color: royaltyGold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerListItem(bool isSmall, Color cardColor) {
    return Container(
      height: 60.h,
      margin: EdgeInsets.only(bottom: 6.h),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(14.r),
      ),
    ).animate(onPlay: (c) => c.repeat()).shimmer(duration: 1200.ms, color: Colors.grey.withOpacity(0.3));
  }

  Widget _buildErrorCard(String message, VoidCallback onRetry, bool isSmall, Color cardColor, Color textColor) {
    return Container(
      padding: EdgeInsets.all(16.w),
      margin: EdgeInsets.only(bottom: 6.h),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.05),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: Colors.red.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(CupertinoIcons.exclamationmark_circle, color: Colors.red, size: isSmall ? 24.sp : 28.sp),
          SizedBox(height: 8.h),
          Text(message, style: GoogleFonts.poppins(fontSize: isSmall ? 11.sp : 12.sp, color: Colors.red, fontWeight: FontWeight.w500), textAlign: TextAlign.center),
          SizedBox(height: 10.h),
          GestureDetector(
            onTap: onRetry,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
              decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(10.r)),
              child: Text('Retry', style: GoogleFonts.poppins(color: Colors.white, fontSize: isSmall ? 11.sp : 12.sp)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCard(String text, bool isSmall, Color cardColor, Color shadowColor, Color borderColor, Color textColor, Color subTextColor) {
    return Container(
      padding: EdgeInsets.all(24.w),
      margin: EdgeInsets.only(bottom: 6.h),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: borderColor, width: 0.5),
      ),
      child: Column(
        children: [
          Icon(CupertinoIcons.tray, color: subTextColor, size: isSmall ? 32.sp : 36.sp),
          SizedBox(height: 8.h),
          Text(text, style: GoogleFonts.poppins(fontSize: isSmall ? 12.sp : 13.sp, color: subTextColor)),
        ],
      ),
    );
  }
}
