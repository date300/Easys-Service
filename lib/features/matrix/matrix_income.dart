// lib/features/matrix/matrix_page.dart
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
// 1. Data Models
// ==========================================

class MatrixMyStatus {
  final int userId;
  final String fullName;
  final int currentPayoutCount;
  final List<double> amountsReceived;
  final double totalReceived;
  final double nextAmount;
  final double maxPossible;

  MatrixMyStatus({
    required this.userId,
    required this.fullName,
    required this.currentPayoutCount,
    required this.amountsReceived,
    required this.totalReceived,
    required this.nextAmount,
    required this.maxPossible,
  });

  factory MatrixMyStatus.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    return MatrixMyStatus(
      userId: data['user_id'],
      fullName: data['full_name'] ?? '',
      currentPayoutCount: data['current_payout_count'],
      amountsReceived: (data['amounts_received'] as List<dynamic>)
          .map((e) => double.tryParse(e.toString()) ?? 0.0)
          .toList(),
      totalReceived: double.tryParse(data['total_received'].toString()) ?? 0.0,
      nextAmount: double.tryParse(data['next_amount']?.toString() ?? '0') ?? 0.0,
      maxPossible: double.tryParse(data['max_possible']?.toString() ?? '3000') ?? 3000.0,
    );
  }
}

class MatrixGlobalStatus {
  final double matrixFund;
  final MatrixNextPayout? nextPayout;
  final int maxPayoutSteps;

  MatrixGlobalStatus({
    required this.matrixFund,
    this.nextPayout,
    required this.maxPayoutSteps,
  });

  factory MatrixGlobalStatus.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    return MatrixGlobalStatus(
      matrixFund: double.tryParse(data['matrix_fund'].toString()) ?? 0.0,
      nextPayout: data['next_payout'] != null
          ? MatrixNextPayout.fromJson(data['next_payout'])
          : null,
      maxPayoutSteps: data['max_payout_steps'],
    );
  }
}

class MatrixNextPayout {
  final int userId;
  final String fullName;
  final double expectedAmount;
  final int currentPayoutCount;

  MatrixNextPayout({
    required this.userId,
    required this.fullName,
    required this.expectedAmount,
    required this.currentPayoutCount,
  });

  factory MatrixNextPayout.fromJson(Map<String, dynamic> json) {
    return MatrixNextPayout(
      userId: json['user_id'],
      fullName: json['full_name'] ?? '',
      expectedAmount: double.tryParse(json['expected_amount'].toString()) ?? 0.0,
      currentPayoutCount: json['current_payout_count'],
    );
  }
}

// ==========================================
// 2. API Service
// ==========================================

class MatrixApiService {
  static const String _baseUrl = 'https://easy.ltcminematrix.com/api';

  static Future<MatrixMyStatus> fetchMyStatus(String token) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/matrix/my-status'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    ).timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      if (json['status'] == 'success') {
        return MatrixMyStatus.fromJson(json);
      }
      throw Exception('API error');
    } else {
      throw Exception('Server error: ${response.statusCode}');
    }
  }

  static Future<MatrixGlobalStatus> fetchGlobalStatus() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/matrix/status'),
      headers: {'Content-Type': 'application/json'},
    ).timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      if (json['status'] == 'success') {
        return MatrixGlobalStatus.fromJson(json);
      }
      throw Exception('API error');
    } else {
      throw Exception('Server error: ${response.statusCode}');
    }
  }
}

// ==========================================
// 3. MatrixIncomePage
// ==========================================

class MatrixIncomePage extends StatefulWidget {
  const MatrixIncomePage({super.key});

  @override
  State<MatrixIncomePage> createState() => _MatrixIncomePageState();
}

class _MatrixIncomePageState extends State<MatrixIncomePage> {
  static const Color matrixBlue = Color(0xFF6366F1);

  MatrixMyStatus? _myStatus;
  MatrixGlobalStatus? _globalStatus;
  bool _isLoadingMy = true;
  bool _isLoadingGlobal = true;
  String? _myError;
  String? _globalError;

  String _token = '';

  @override
  void initState() {
    super.initState();
    _loadTokenAndFetch();
  }

  Future<void> _loadTokenAndFetch() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('jwt_token') ?? '';
    if (_token.isEmpty) {
      setState(() {
        _myError = 'Token not found. Please login.';
        _isLoadingMy = false;
      });
      return;
    }
    await Future.wait([_fetchMyStatus(), _fetchGlobalStatus()]);
  }

  Future<void> _fetchMyStatus() async {
    setState(() {
      _isLoadingMy = true;
      _myError = null;
    });
    try {
      final myStatus = await MatrixApiService.fetchMyStatus(_token);
      if (mounted) {
        setState(() {
          _myStatus = myStatus;
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

  Future<void> _fetchGlobalStatus() async {
    setState(() {
      _isLoadingGlobal = true;
      _globalError = null;
    });
    try {
      final globalStatus = await MatrixApiService.fetchGlobalStatus();
      if (mounted) {
        setState(() {
          _globalStatus = globalStatus;
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

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          color: matrixBlue,
          backgroundColor: cardColor,
          onRefresh: () async {
            HapticFeedback.mediumImpact();
            await Future.wait([_fetchMyStatus(), _fetchGlobalStatus()]);
          },
          child: ListView(
            padding: EdgeInsets.fromLTRB(hPadding, 8.h, hPadding, 40.h),
            physics: const BouncingScrollPhysics(),
            children: [
              _buildHeader(textColor, subTextColor, isSmall, isDesktop),
              SizedBox(height: 14.h),
              _buildTotalEarnedCard(isSmall, cardColor, textColor, subTextColor)
                  .animate().fadeIn(delay: 80.ms).slideY(begin: 0.03),
              SizedBox(height: 10.h),
              _buildNextPayoutCard(isSmall, cardColor, textColor, subTextColor)
                  .animate().fadeIn(delay: 120.ms).slideY(begin: 0.03),
              if (_globalStatus != null) ...[
                SizedBox(height: 10.h),
                _buildGlobalFundCard(isSmall, cardColor, shadowColor, borderColor, textColor, subTextColor)
                    .animate().fadeIn(delay: 160.ms).slideY(begin: 0.03),
              ],
              SizedBox(height: 20.h),
              _buildProgressSection(isSmall, cardColor, shadowColor, borderColor, textColor, subTextColor)
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
              'Matrix',
              style: GoogleFonts.poppins(
                fontSize: isSmall ? 24.sp : isDesktop ? 30.sp : 26.sp,
                fontWeight: FontWeight.w700,
                color: textColor,
                height: 1.1,
                letterSpacing: -0.5,
              ),
            ),
            Text(
              'Income',
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
            color: matrixBlue.withOpacity(0.08),
            shape: BoxShape.circle,
          ),
          child: Icon(
            CupertinoIcons.cube_box_fill,
            color: matrixBlue,
            size: isSmall ? 16.sp : 18.sp,
          ),
        ),
      ],
    ).animate().fadeIn(delay: 40.ms);
  }

  // ==================== TOTAL EARNED CARD (gradient) ====================
  Widget _buildTotalEarnedCard(bool isSmall, Color cardColor, Color textColor, Color subTextColor) {
    final total = _myStatus?.totalReceived ?? 0.0;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: isSmall ? 16.w : 20.w, vertical: isSmall ? 16.h : 18.h),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: matrixBlue.withOpacity(0.3),
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
                  Icon(CupertinoIcons.cube_box_fill,
                      color: Colors.white.withOpacity(0.7), size: isSmall ? 11.sp : 12.sp),
                  SizedBox(width: 5.w),
                  Text(
                    'Total Matrix Income',
                    style: GoogleFonts.poppins(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: isSmall ? 10.sp : 11.sp,
                      fontWeight: FontWeight.w500,
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
                  'Lifetime',
                  style: GoogleFonts.poppins(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: isSmall ? 9.sp : 10.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          if (_isLoadingMy)
            _buildShimmerAmount(isSmall)
          else if (_myError != null)
            Text('Error', style: GoogleFonts.poppins(color: Colors.white, fontSize: isSmall ? 18.sp : 22.sp))
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
                  ),
                ),
                SizedBox(width: 3.w),
                Text(
                  total.toStringAsFixed(2),
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: isSmall ? 28.sp : 32.sp,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -1.2,
                  ),
                ),
              ],
            ),
          SizedBox(height: 12.h),
          Text(
            _myStatus != null
                ? 'Step ${_myStatus!.currentPayoutCount} / $MAX_STEPS'
                : '--',
            style: GoogleFonts.poppins(
              color: Colors.white.withOpacity(0.55),
              fontSize: isSmall ? 9.sp : 10.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ==================== NEXT PAYOUT CARD ====================
  Widget _buildNextPayoutCard(bool isSmall, Color cardColor, Color textColor, Color subTextColor) {
    final nextAmount = _myStatus?.nextAmount ?? 0.0;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isSmall ? 14.w : 16.w),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFE5E5EA), width: 0.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 6),
            spreadRadius: -4,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: isSmall ? 36.w : 40.w,
            height: isSmall ? 36.w : 40.w,
            decoration: BoxDecoration(
              color: matrixBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(CupertinoIcons.arrow_right_arrow_left,
                color: matrixBlue, size: isSmall ? 18.sp : 20.sp),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Next Payout',
                  style: GoogleFonts.poppins(
                    fontSize: isSmall ? 12.sp : 13.sp,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  _isLoadingMy ? '...' : '\u09F3 $nextAmount',
                  style: GoogleFonts.poppins(
                    fontSize: isSmall ? 14.sp : 16.sp,
                    fontWeight: FontWeight.w700,
                    color: matrixBlue,
                  ),
                ),
              ],
            ),
          ),
          if (_isLoadingMy)
            CupertinoActivityIndicator(radius: 10.r)
          else
            Icon(CupertinoIcons.checkmark_alt, color: Colors.green, size: isSmall ? 20.sp : 24.sp),
        ],
      ),
    );
  }

  // ==================== GLOBAL FUND CARD ====================
  Widget _buildGlobalFundCard(bool isSmall, Color cardColor, Color shadowColor, Color borderColor, Color textColor, Color subTextColor) {
    final fund = _globalStatus?.matrixFund ?? 0.0;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: isSmall ? 14.w : 16.w, vertical: isSmall ? 10.h : 12.h),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: borderColor, width: 0.5),
        boxShadow: [BoxShadow(color: shadowColor, blurRadius: 16, offset: const Offset(0, 6), spreadRadius: -4)],
      ),
      child: Row(
        children: [
          Container(
            width: isSmall ? 34.w : 36.w,
            height: isSmall ? 34.w : 36.w,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(CupertinoIcons.globe, color: Colors.white, size: isSmall ? 16.sp : 18.sp),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Global Matrix Fund',
                  style: GoogleFonts.poppins(
                    fontSize: isSmall ? 12.sp : 13.sp,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
                SizedBox(height: 1.h),
                Text(
                  _isLoadingGlobal ? 'Loading...' : '\u09F3${fund.toStringAsFixed(2)}',
                  style: GoogleFonts.poppins(fontSize: isSmall ? 9.sp : 10.sp, color: subTextColor),
                ),
              ],
            ),
          ),
          if (_isLoadingGlobal)
            CupertinoActivityIndicator(radius: isSmall ? 6.r : 7.r)
          else
            Text('Live', style: GoogleFonts.poppins(color: Colors.green, fontSize: isSmall ? 10.sp : 11.sp)),
        ],
      ),
    );
  }

  // ==================== PROGRESS SECTION ====================
  static const int MAX_STEPS = 18;
  static const List<double> STEPS = [
    5, 10, 15, 20, 25, 30, 50, 100, 200, 300,
    400, 500, 800, 1000, 1500, 2000, 2500, 3000
  ];

  Widget _buildProgressSection(bool isSmall, Color cardColor, Color shadowColor, Color borderColor, Color textColor, Color subTextColor) {
    final mySteps = _myStatus?.amountsReceived ?? [];
    final currentStep = _myStatus?.currentPayoutCount ?? 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 4.w, bottom: 8.h),
          child: Text(
            'Payout Steps',
            style: GoogleFonts.poppins(
              fontSize: isSmall ? 14.sp : 16.sp,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ),
        // Progress Bar
        Container(
          margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 4.h),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10.r),
            child: LinearProgressIndicator(
              value: currentStep / MAX_STEPS,
              backgroundColor: matrixBlue.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation(matrixBlue),
              minHeight: 8.h,
            ),
          ),
        ),
        SizedBox(height: 8.h),
        // Grid of steps
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: isSmall ? 3 : 4,
            childAspectRatio: 2.5,
            crossAxisSpacing: 6.w,
            mainAxisSpacing: 6.h,
          ),
          itemCount: MAX_STEPS,
          itemBuilder: (context, index) {
            final amount = STEPS[index];
            final received = index < mySteps.length; // already received
            final isCurrent = index == currentStep - 1; // latest received
            final isNext = index == currentStep; // next to receive
            Color bgColor;
            Color textColorStep;
            if (received) {
              bgColor = Colors.green.withOpacity(0.1);
              textColorStep = Colors.green;
            } else if (isNext) {
              bgColor = matrixBlue.withOpacity(0.1);
              textColorStep = matrixBlue;
            } else {
              bgColor = cardColor;
              textColorStep = subTextColor.withOpacity(0.5);
            }
            return Container(
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(
                  color: isNext ? matrixBlue : Colors.transparent,
                  width: isNext ? 1 : 0,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                '\u09F3 ${amount.toStringAsFixed(0)}',
                style: GoogleFonts.poppins(
                  fontSize: isSmall ? 10.sp : 11.sp,
                  fontWeight: isCurrent || isNext ? FontWeight.w600 : FontWeight.w400,
                  color: textColorStep,
                ),
              ),
            );
          },
        ),
        SizedBox(height: 10.h),
        if (_isLoadingMy)
          const Center(child: CupertinoActivityIndicator())
        else if (_myError != null)
          _buildErrorCard(_myError!, () => _fetchMyStatus(), isSmall, cardColor, textColor)
        else if (mySteps.isEmpty)
          _buildEmptyCard('No payouts yet', isSmall, cardColor, shadowColor, borderColor, textColor, subTextColor),
      ],
    );
  }

  Widget _buildShimmerAmount(bool isSmall) {
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
          Text(message, style: GoogleFonts.poppins(fontSize: isSmall ? 11.sp : 12.sp, color: Colors.red), textAlign: TextAlign.center),
          SizedBox(height: 10.h),
          GestureDetector(
            onTap: onRetry,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
              decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(10.r)),
              child: Text('Retry', style: GoogleFonts.poppins(color: Colors.white)),
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
        color: cardColor, borderRadius: BorderRadius.circular(14.r), border: Border.all(color: borderColor, width: 0.5),
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
