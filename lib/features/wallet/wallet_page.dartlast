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
// 1. Model
// ==========================================

class WalletBalance {
  final double balance;
  WalletBalance({required this.balance});
  factory WalletBalance.fromJson(Map<String, dynamic> json) =>
      WalletBalance(balance: double.tryParse(json['balance'].toString()) ?? 0.0);
}

// ==========================================
// 2. API Service
// ==========================================

class WalletApiService {
  static const String _baseUrl = 'https://easy.ltcminematrix.com/api';

  static Future<WalletBalance> fetchBalance(String token) async {
    final res = await http
        .get(
          Uri.parse('$_baseUrl/user/profile'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        )
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
  // ── Sky Blue Palette ───────────────────────────────────
  static const Color _accent      = Color(0xFF0EA5E9); // sky-500
  static const Color _accentLight = Color(0xFF38BDF8); // sky-400
  static const Color _accentDeep  = Color(0xFF075985); // sky-800
  static const Color _ink         = Color(0xFF0C1A26); // near-black
  // ──────────────────────────────────────────────────────

  WalletBalance? _balance;
  bool _isLoading = true;
  String? _error;
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
      setState(() { _error = 'Token not found'; _isLoading = false; });
      return;
    }
    await _fetchBalance();
  }

  Future<void> _fetchBalance() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final b = await WalletApiService.fetchBalance(_token);
      if (mounted) setState(() { _balance = b; _isLoading = false; });
    } catch (e) {
      if (mounted) setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark     = Theme.of(context).brightness == Brightness.dark;
    final bgColor    = isDark ? const Color(0xFF060D17) : const Color(0xFFF0F9FF);
    final cardColor  = isDark ? const Color(0xFF0F1E2E) : Colors.white;
    final textColor  = isDark ? Colors.white            : _ink;
    final subColor   = isDark ? const Color(0xFF7BA3BE) : const Color(0xFF94A3B8);
    final isSmall    = MediaQuery.of(context).size.width < 360;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: RefreshIndicator(
          color: _accent,
          backgroundColor: cardColor,
          onRefresh: () async {
            HapticFeedback.mediumImpact();
            await _fetchBalance();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 48.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Top Balance Card ──────────────────────────
                _buildBalanceCard(isSmall, cardColor, textColor, subColor)
                    .animate()
                    .fadeIn(delay: 60.ms)
                    .slideY(begin: 0.04, curve: Curves.easeOut),

                SizedBox(height: 16.h),

                // ── Action Buttons ────────────────────────────
                _buildActionButtons(isSmall)
                    .animate()
                    .fadeIn(delay: 130.ms)
                    .slideY(begin: 0.04, curve: Curves.easeOut),

                SizedBox(height: 14.h),

                // ── Income Menu ───────────────────────────────
                ..._buildIncomeMenu(isSmall, cardColor, textColor),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════
  //  TOP BALANCE CARD
  // ════════════════════════════════════════════════════════
  Widget _buildBalanceCard(
    bool isSmall,
    Color cardColor,
    Color textColor,
    Color subColor,
  ) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(16.w, 28.h, 16.w, 22.h),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(22.r),
        boxShadow: [
          BoxShadow(
            color: _accent.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 6),
            spreadRadius: -2,
          ),
        ],
      ),
      child: Column(
        children: [
          _buildWalletIllustration(isSmall),
          SizedBox(height: 20.h),
          Text(
            'বর্তমান ব্যালান্স',
            style: GoogleFonts.hindSiliguri(
              fontSize: isSmall ? 20.sp : 22.sp,
              fontWeight: FontWeight.w700,
              color: textColor,
              height: 1.2,
            ),
          ),
          SizedBox(height: 5.h),
          Text(
            'অ্যাপ অ্যাকাউন্ট থেকে সিঙ্ক হয়েছে',
            style: GoogleFonts.hindSiliguri(
              fontSize: isSmall ? 11.sp : 12.sp,
              color: subColor,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════
  //  WALLET ILLUSTRATION  (cartoon-style, sky blue)
  // ════════════════════════════════════════════════════════
  Widget _buildWalletIllustration(bool isSmall) {
    // Dimensions
    final double wW   = isSmall ? 210 : 245; // wallet body width
    final double wH   = isSmall ? 170 : 198; // wallet body height
    final double cW   = isSmall ? 52  : 60;  // clasp width
    final double cH   = isSmall ? 70  : 82;  // clasp height
    final double peek = isSmall ? 22  : 26;  // top peek for back card
    // Total bounding box (clasp protrudes ~55% of cW beyond wallet right edge)
    final double totalW = wW + cW * 0.56;
    final double totalH = wH + peek;

    return Center(
      child: SizedBox(
        width:  totalW.w,
        height: totalH.h,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // ── Back card peeking top-left ─────────────────
            Positioned(
              top:  0,
              left: (wW * 0.13).w,
              child: Transform.rotate(
                angle: -0.20,
                alignment: Alignment.bottomLeft,
                child: Container(
                  width:  (wW * 0.50).w,
                  height: (wH * 0.52).h,
                  decoration: BoxDecoration(
                    color: _accentDeep,
                    borderRadius: BorderRadius.circular(13.r),
                    border: Border.all(color: _ink, width: 3.2),
                  ),
                ),
              ),
            ),

            // ── Main wallet body ───────────────────────────
            Positioned(
              bottom: 0,
              left:   0,
              child: Container(
                width:  wW.w,
                height: wH.h,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [_accentLight, _accent],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(22.r),
                  border: Border.all(color: _ink, width: 3.5),
                  boxShadow: [
                    BoxShadow(
                      color: _accent.withOpacity(0.35),
                      blurRadius: 24,
                      offset: const Offset(0, 10),
                      spreadRadius: -4,
                    ),
                  ],
                ),
                // Balance text (bottom-left area of wallet)
                child: Padding(
                  padding: EdgeInsets.only(left: 20.w, top: 10.h),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: _isLoading
                        ? _shimmer(isSmall)
                        : _error != null
                            ? _errorWidget(isSmall)
                            : Text(
                                '${(_balance?.balance ?? 0).toStringAsFixed(2)}৳',
                                style: GoogleFonts.poppins(
                                  color: _ink,
                                  fontSize: isSmall ? 26.sp : 30.sp,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -1.2,
                                ),
                              ),
                  ),
                ),
              ),
            ),

            // ── Clasp (right, overlapping wallet right edge) ─
            Positioned(
              right:  0,
              bottom: (wH * 0.20).h,
              child: Container(
                width:  cW.w,
                height: cH.h,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft:     Radius.circular(10.r),
                    bottomLeft:  Radius.circular(10.r),
                    topRight:    Radius.circular(18.r),
                    bottomRight: Radius.circular(18.r),
                  ),
                  border: Border.all(color: _ink, width: 3.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.12),
                      blurRadius: 8,
                      offset: const Offset(3, 2),
                    ),
                  ],
                ),
                child: Center(child: _claspButton()),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Double-ring clasp button
  Widget _claspButton() => Container(
        width:  32.w,
        height: 32.w,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: _ink, width: 3),
          color: Colors.white,
        ),
        child: Center(
          child: Container(
            width:  12.w,
            height: 12.w,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: _accent,
            ),
          ),
        ),
      );

  Widget _shimmer(bool isSmall) => Container(
        height: isSmall ? 32.h : 38.h,
        width:  130.w,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.25),
          borderRadius: BorderRadius.circular(8.r),
        ),
      ).animate(onPlay: (c) => c.repeat()).shimmer(
            duration: 1400.ms,
            color: Colors.white.withOpacity(0.45),
          );

  Widget _errorWidget(bool isSmall) => GestureDetector(
        onTap: _fetchBalance,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.22),
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(color: Colors.white.withOpacity(0.35)),
          ),
          child: Text(
            'Retry',
            style: GoogleFonts.poppins(
              color: _ink,
              fontSize: isSmall ? 12.sp : 13.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      );

  // ════════════════════════════════════════════════════════
  //  ACTION BUTTONS
  // ════════════════════════════════════════════════════════
  Widget _buildActionButtons(bool isSmall) {
    return Row(
      children: [
        Expanded(
          child: _actionBtn(
            label: 'উইথড্র',
            icon:  CupertinoIcons.arrow_up_circle_fill,
            isSmall: isSmall,
            onTap: () {
              HapticFeedback.mediumImpact();
              // TODO: navigate to withdraw screen
            },
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: _actionBtn(
            label: 'ট্রানজেকশন হিস্ট্রি',
            icon:  CupertinoIcons.list_bullet_below_rectangle,
            isSmall: isSmall,
            onTap: () {
              HapticFeedback.mediumImpact();
              // TODO: navigate to transaction history
            },
          ),
        ),
      ],
    );
  }

  Widget _actionBtn({
    required String label,
    required IconData icon,
    required bool isSmall,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 15.h),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [_accentLight, _accent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(14.r),
          boxShadow: [
            BoxShadow(
              color: _accent.withOpacity(0.30),
              blurRadius: 14,
              offset: const Offset(0, 5),
              spreadRadius: -3,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: isSmall ? 14.sp : 16.sp),
            SizedBox(width: 5.w),
            Text(
              label,
              style: GoogleFonts.hindSiliguri(
                color: Colors.white,
                fontSize: isSmall ? 13.sp : 14.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════
  //  INCOME MENU  (আজকের আয় / গতকালের আয় / গত ৭ দিনের আয়)
  // ════════════════════════════════════════════════════════
  List<Widget> _buildIncomeMenu(
    bool isSmall,
    Color cardColor,
    Color textColor,
  ) {
    final items = [
      {'label': 'আজকের আয়',       'icon': CupertinoIcons.sun_max_fill,         'delay': 160},
      {'label': 'গতকালের আয়',     'icon': CupertinoIcons.moon_stars_fill,       'delay': 210},
      {'label': 'গত ৭ দিনের আয়', 'icon': CupertinoIcons.calendar,              'delay': 260},
    ];

    return items.map((item) {
      return _menuItem(
        label:     item['label']  as String,
        icon:      item['icon']   as IconData,
        isSmall:   isSmall,
        cardColor: cardColor,
        textColor: textColor,
        onTap: () {
          HapticFeedback.lightImpact();
          // TODO: navigate to detail screen
        },
      )
          .animate()
          .fadeIn(delay: Duration(milliseconds: item['delay'] as int))
          .slideX(begin: 0.04, curve: Curves.easeOut);
    }).toList();
  }

  Widget _menuItem({
    required String   label,
    required IconData icon,
    required bool     isSmall,
    required Color    cardColor,
    required Color    textColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin:  EdgeInsets.only(bottom: 10.h),
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 13.h),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: _accent.withOpacity(0.06),
              blurRadius: 14,
              offset: const Offset(0, 4),
              spreadRadius: -2,
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon badge
            Container(
              width:  isSmall ? 40.w : 44.w,
              height: isSmall ? 40.w : 44.w,
              decoration: BoxDecoration(
                color: _accent.withOpacity(0.10),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: _accent.withOpacity(0.18),
                  width: 0.8,
                ),
              ),
              child: Icon(icon, color: _accent, size: isSmall ? 18.sp : 20.sp),
            ),
            SizedBox(width: 12.w),
            // Label
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.hindSiliguri(
                  fontSize: isSmall ? 14.sp : 15.sp,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
            ),
            // Arrow badge
            Container(
              width:  30.w,
              height: 30.w,
              decoration: BoxDecoration(
                color: _accent.withOpacity(0.09),
                shape: BoxShape.circle,
              ),
              child: Icon(
                CupertinoIcons.chevron_right,
                color: _accent,
                size: isSmall ? 13.sp : 14.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
