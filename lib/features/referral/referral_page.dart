// lib/features/referral/referral_page.dart
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

class ReferralUser {
  final int id;
  final String fullName;
  final String mobile;
  final String email;
  final bool isActive;
  final String idVerified;
  final DateTime createdAt;

  ReferralUser({
    required this.id,
    required this.fullName,
    required this.mobile,
    required this.email,
    required this.isActive,
    required this.idVerified,
    required this.createdAt,
  });

  factory ReferralUser.fromJson(Map<String, dynamic> json) {
    return ReferralUser(
      id: json['id'],
      fullName: json['full_name'] ?? '',
      mobile: json['mobile'] ?? '',
      email: json['email'] ?? '',
      isActive: json['is_active'] == 1 || json['is_active'] == true,
      idVerified: json['id_verified'] ?? 'unverified',
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}

class UserProfile {
  final int id;
  final String fullName;
  final String referralCode;
  final String mobile;
  final String email;

  UserProfile({
    required this.id,
    required this.fullName,
    required this.referralCode,
    required this.mobile,
    required this.email,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'],
      fullName: json['full_name'] ?? '',
      referralCode: json['referral_code'] ?? '',
      mobile: json['mobile'] ?? '',
      email: json['email'] ?? '',
    );
  }
}

// ==========================================
// 2. API Service
// ==========================================

class ReferralApiService {
  static const String _baseUrl = 'https://easy.ltcminematrix.com/api';

  static Future<List<ReferralUser>> fetchReferrals(String token) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/user/referrals'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    ).timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      if (json['status'] == 'success' && json['data'] != null) {
        return (json['data'] as List).map((e) => ReferralUser.fromJson(e)).toList();
      }
      return [];
    } else if (response.statusCode == 401) {
      throw Exception('Session expired. Please login again.');
    } else {
      throw Exception('Server error: ${response.statusCode}');
    }
  }

  static Future<UserProfile> fetchProfile(String token) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/user/profile'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    ).timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      if (json['status'] == 'success' && json['data'] != null) {
        final data = json['data'];
        if (data is Map<String, dynamic>) {
          if (data.containsKey('referral_code')) {
            return UserProfile.fromJson(data);
          }
          if (data['user'] != null && data['user'] is Map<String, dynamic>) {
            return UserProfile.fromJson(data['user']);
          }
        }
      }
      throw Exception('Invalid profile data');
    } else if (response.statusCode == 401) {
      throw Exception('Unauthorized. Please login again.');
    } else {
      throw Exception('Server error: ${response.statusCode}');
    }
  }
}

// ==========================================
// 3. ReferralPage
// ==========================================

class ReferralPage extends StatefulWidget {
  const ReferralPage({super.key});

  @override
  State<ReferralPage> createState() => _ReferralPageState();
}

class _ReferralPageState extends State<ReferralPage> {
  static const Color primaryColor = Color(0xFF7C3AED);

  UserProfile? _profile;
  bool _isLoadingProfile = true;
  String? _profileError;

  List<ReferralUser> _referrals = [];
  bool _isLoadingReferrals = true;
  String? _referralError;

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
        _profileError = 'Token not found. Please login.';
        _isLoadingProfile = false;
      });
      return;
    }
    await Future.wait([_fetchProfile(), _fetchReferrals()]);
  }

  Future<void> _fetchProfile() async {
    setState(() {
      _isLoadingProfile = true;
      _profileError = null;
    });
    try {
      final profile = await ReferralApiService.fetchProfile(_token);
      if (mounted) {
        setState(() {
          _profile = profile;
          _isLoadingProfile = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _profileError = e.toString().replaceAll('Exception: ', '');
          _isLoadingProfile = false;
        });
      }
    }
  }

  Future<void> _fetchReferrals() async {
    setState(() {
      _isLoadingReferrals = true;
      _referralError = null;
    });
    try {
      final referrals = await ReferralApiService.fetchReferrals(_token);
      if (mounted) {
        setState(() {
          _referrals = referrals;
          _isLoadingReferrals = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _referralError = e.toString().replaceAll('Exception: ', '');
          _isLoadingReferrals = false;
        });
      }
    }
  }

  void _copyReferralCode() {
    if (_profile == null || _profile!.referralCode.isEmpty) return;
    Clipboard.setData(ClipboardData(text: _profile!.referralCode));
    HapticFeedback.mediumImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Referral code copied!'),
        backgroundColor: primaryColor,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _copyReferralLink() {
    if (_profile == null) return;
    final code = _profile!.referralCode;
    final link = 'https://easy.ltcminematrix.com/register?ref=$code';
    Clipboard.setData(ClipboardData(text: link));
    HapticFeedback.mediumImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Referral link copied!'),
        backgroundColor: primaryColor,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
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

    final totalReferrals = _referrals.length;
    final activeCount = _referrals.where((r) => r.isActive).length;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          color: primaryColor,
          backgroundColor: cardColor,
          onRefresh: () async {
            HapticFeedback.mediumImpact();
            await Future.wait([_fetchProfile(), _fetchReferrals()]);
          },
          child: ListView(
            padding: EdgeInsets.fromLTRB(hPadding, 8.h, hPadding, 40.h),
            physics: const BouncingScrollPhysics(),
            children: [
              _buildHeader(textColor, subTextColor, isSmall, isDesktop),
              SizedBox(height: 14.h),
              _buildReferralCodeCard(isSmall)
                  .animate()
                  .fadeIn(delay: 80.ms)
                  .slideY(begin: 0.03),
              SizedBox(height: 10.h),
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      icon: CupertinoIcons.person_2_fill,
                      iconColor: primaryColor,
                      label: 'Total',
                      amount: _isLoadingReferrals ? '...' : totalReferrals.toString(),
                      cardColor: cardColor, textColor: textColor,
                      subTextColor: subTextColor, shadowColor: shadowColor,
                      borderColor: borderColor, isSmall: isSmall,
                    ).animate().fadeIn(delay: 120.ms).slideY(begin: 0.03),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: _buildStatCard(
                      icon: CupertinoIcons.checkmark_seal_fill,
                      iconColor: Colors.green,
                      label: 'Active',
                      amount: _isLoadingReferrals ? '...' : activeCount.toString(),
                      cardColor: cardColor, textColor: textColor,
                      subTextColor: subTextColor, shadowColor: shadowColor,
                      borderColor: borderColor, isSmall: isSmall,
                    ).animate().fadeIn(delay: 140.ms).slideY(begin: 0.03),
                  ),
                ],
              ),
              SizedBox(height: 10.h),
              _buildCopyLinkButton(isSmall, cardColor, shadowColor, borderColor, textColor)
                  .animate().fadeIn(delay: 160.ms).slideY(begin: 0.03),
              SizedBox(height: 20.h),
              _buildReferralListHeader(textColor, isSmall),
              SizedBox(height: 6.h),
              if (_isLoadingReferrals)
                ...List.generate(4, (_) => _buildShimmerListItem(isSmall, cardColor))
              else if (_referralError != null)
                _buildErrorCard(_referralError!, () => _fetchReferrals(), isSmall, cardColor, textColor)
              else if (_referrals.isEmpty)
                _buildEmptyCard('No referrals yet', isSmall, cardColor, shadowColor, borderColor, textColor, subTextColor)
              else
                ..._referrals.map((ref) => _buildReferralTile(ref, isSmall, cardColor, shadowColor, borderColor, textColor, subTextColor)),
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
              'Referral',
              style: GoogleFonts.poppins(
                fontSize: isSmall ? 24.sp : isDesktop ? 30.sp : 26.sp,
                fontWeight: FontWeight.w700,
                color: textColor,
                height: 1.1,
                letterSpacing: -0.5,
              ),
            ),
            Text(
              'Program',
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
            color: primaryColor.withOpacity(0.08),
            shape: BoxShape.circle,
          ),
          child: Icon(
            CupertinoIcons.person_2_alt,
            color: primaryColor,
            size: isSmall ? 16.sp : 18.sp,
          ),
        ),
      ],
    ).animate().fadeIn(delay: 40.ms);
  }

  Widget _buildReferralCodeCard(bool isSmall) {
    final code = _profile?.referralCode ?? '--------';
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: isSmall ? 16.w : 20.w, vertical: isSmall ? 20.h : 24.h),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF7C3AED), Color(0xFF5B21B6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7C3AED).withOpacity(0.3),
            blurRadius: 24,
            offset: const Offset(0, 10),
            spreadRadius: -4,
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'YOUR REFERRAL CODE',
            style: GoogleFonts.poppins(
              color: Colors.white.withOpacity(0.7),
              fontSize: isSmall ? 10.sp : 11.sp,
              fontWeight: FontWeight.w500,
              letterSpacing: 1.2,
            ),
          ),
          SizedBox(height: 12.h),
          if (_isLoadingProfile)
            Container(
              height: isSmall ? 34.h : 38.h,
              width: 140.w,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8.r),
              ),
            ).animate(onPlay: (c) => c.repeat()).shimmer(
                  duration: 1200.ms,
                  color: Colors.white.withOpacity(0.35),
                )
          else if (_profileError != null)
            Text(
              'Error',
              style: GoogleFonts.poppins(color: Colors.white, fontSize: isSmall ? 20.sp : 24.sp, fontWeight: FontWeight.w700),
            )
          else
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  code,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: isSmall ? 28.sp : 32.sp,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2.0,
                  ),
                ),
                SizedBox(width: 12.w),
                GestureDetector(
                  onTap: _copyReferralCode,
                  child: Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Icon(CupertinoIcons.doc_on_clipboard, color: Colors.white, size: isSmall ? 18.sp : 20.sp),
                  ),
                ),
              ],
            ),
          SizedBox(height: 16.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Text(
              'Share with friends and earn rewards!',
              style: GoogleFonts.poppins(color: Colors.white70, fontSize: isSmall ? 10.sp : 11.sp),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCopyLinkButton(bool isSmall, Color cardColor, Color shadowColor, Color borderColor, Color textColor) {
    return GestureDetector(
      onTap: _copyReferralLink,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: isSmall ? 14.w : 16.w, vertical: isSmall ? 12.h : 14.h),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: borderColor, width: 0.5),
          boxShadow: [BoxShadow(color: shadowColor, blurRadius: 16, offset: const Offset(0, 6), spreadRadius: -4)],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(CupertinoIcons.link, color: primaryColor, size: isSmall ? 18.sp : 20.sp),
            SizedBox(width: 8.w),
            Text(
              'Copy Referral Link',
              style: GoogleFonts.poppins(
                fontSize: isSmall ? 13.sp : 14.sp,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReferralListHeader(Color textColor, bool isSmall) {
    return Padding(
      padding: EdgeInsets.only(left: 4.w, bottom: 4.h),
      child: Text(
        'Your Referrals',
        style: GoogleFonts.poppins(
          fontSize: isSmall ? 14.sp : 16.sp,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildReferralTile(ReferralUser ref, bool isSmall, Color cardColor, Color shadowColor, Color borderColor, Color textColor, Color subTextColor) {
    final isVerified = ref.idVerified == 'verified';
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
          CircleAvatar(
            radius: isSmall ? 18.r : 20.r,
            backgroundColor: primaryColor.withOpacity(0.1),
            child: Text(
              ref.fullName.isNotEmpty ? ref.fullName[0].toUpperCase() : '?',
              style: GoogleFonts.poppins(color: primaryColor, fontWeight: FontWeight.w600, fontSize: isSmall ? 14.sp : 16.sp),
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        ref.fullName,
                        style: GoogleFonts.poppins(fontSize: isSmall ? 12.sp : 13.sp, fontWeight: FontWeight.w600, color: textColor),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(width: 4.w),
                    if (isVerified)
                      Icon(CupertinoIcons.checkmark_seal_fill, color: Colors.green, size: isSmall ? 12.sp : 14.sp),
                  ],
                ),
                SizedBox(height: 2.h),
                Text(
                  ref.mobile,
                  style: GoogleFonts.poppins(fontSize: isSmall ? 10.sp : 11.sp, color: subTextColor),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: ref.isActive ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Text(
                  ref.isActive ? 'Active' : 'Inactive',
                  style: GoogleFonts.poppins(
                    fontSize: isSmall ? 9.sp : 10.sp,
                    fontWeight: FontWeight.w600,
                    color: ref.isActive ? Colors.green : Colors.orange,
                  ),
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                '${ref.createdAt.day}/${ref.createdAt.month}/${ref.createdAt.year}',
                style: GoogleFonts.poppins(fontSize: isSmall ? 8.sp : 9.sp, color: subTextColor),
              ),
            ],
          ),
        ],
      ),
    );
  }

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
  }) {
    return Container(
      padding: EdgeInsets.all(isSmall ? 12.w : 14.w),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: borderColor, width: 0.5),
        boxShadow: [BoxShadow(color: shadowColor, blurRadius: 16, offset: const Offset(0, 6), spreadRadius: -4)],
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
                child: Icon(icon, color: iconColor, size: isSmall ? 14.sp : 15.sp),
              ),
              const Spacer(),
              Text(
                label,
                style: GoogleFonts.poppins(fontSize: isSmall ? 9.sp : 10.sp, color: subTextColor, fontWeight: FontWeight.w500),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            amount,
            style: GoogleFonts.poppins(fontSize: isSmall ? 15.sp : 17.sp, fontWeight: FontWeight.w700, color: textColor, letterSpacing: -0.5),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerListItem(bool isSmall, Color cardColor) {
    return Container(
      height: 60.h,
      margin: EdgeInsets.only(bottom: 6.h),
      decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(14.r)),
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
