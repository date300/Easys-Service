import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Riverpod যুক্ত করা হয়েছে
import 'package:go_router/go_router.dart'; // GoRouter যুক্ত করা হয়েছে

// আপনার main.dart থেকে প্রোভাইডারগুলো ইম্পোর্ট করে নিবেন
import '../main.dart'; 

// ==========================================
// 1. Models
// ==========================================

class WalletBalance {
  final double balance;
  WalletBalance({required this.balance});
  factory WalletBalance.fromJson(Map<String, dynamic> json) =>
      WalletBalance(balance: double.tryParse(json['balance'].toString()) ?? 0.0);
}

class Transaction {
  final int id;
  final double amount;
  final String type;
  final String description;
  final String createdAt;
  Transaction({
    required this.id,
    required this.amount,
    required this.type,
    required this.description,
    required this.createdAt,
  });
  factory Transaction.fromJson(Map<String, dynamic> json) => Transaction(
    id: json['id'],
    amount: double.tryParse(json['amount'].toString()) ?? 0.0,
    type: json['type'] ?? '',
    description: json['description'] ?? '',
    createdAt: json['created_at'] ?? '',
  );
}

// ==========================================
// 2. API Service
// ==========================================

class WalletApiService {
  static const String _baseUrl = 'https://easy.ltcminematrix.com/api';

  static Future<WalletBalance> fetchBalance(String token) async {
    final res = await http.get(
      Uri.parse('$_baseUrl/wallet/balance'),
      headers: {'Authorization': 'Bearer $token'},
    ).timeout(const Duration(seconds: 15));
    if (res.statusCode == 200) {
      final json = jsonDecode(res.body);
      if (json['status'] == 'success' && json['data'] != null) {
        return WalletBalance.fromJson(json['data']);
      }
      throw Exception('Invalid balance data');
    } else {
      throw Exception('Server error: ${res.statusCode}');
    }
  }

  static Future<double> fetchDailyIncome(String token) async {
    final res = await http.get(
      Uri.parse('$_baseUrl/wallet/income/daily'),
      headers: {'Authorization': 'Bearer $token'},
    ).timeout(const Duration(seconds: 15));
    if (res.statusCode == 200) {
      final json = jsonDecode(res.body);
      if (json['status'] == 'success' && json['data'] != null) {
        return double.tryParse(json['data']['total_income'].toString()) ?? 0.0;
      }
      throw Exception('Invalid data');
    } else {
      throw Exception('Server error: ${res.statusCode}');
    }
  }

  static Future<double> fetchWeeklyIncome(String token) async {
    final res = await http.get(
      Uri.parse('$_baseUrl/wallet/income/weekly'),
      headers: {'Authorization': 'Bearer $token'},
    ).timeout(const Duration(seconds: 15));
    if (res.statusCode == 200) {
      final json = jsonDecode(res.body);
      if (json['status'] == 'success' && json['data'] != null) {
        return double.tryParse(json['data']['total_income'].toString()) ?? 0.0;
      }
      throw Exception('Invalid data');
    } else {
      throw Exception('Server error: ${res.statusCode}');
    }
  }

  static Future<double> fetchMonthlyIncome(String token) async {
    final res = await http.get(
      Uri.parse('$_baseUrl/wallet/income/monthly'),
      headers: {'Authorization': 'Bearer $token'},
    ).timeout(const Duration(seconds: 15));
    if (res.statusCode == 200) {
      final json = jsonDecode(res.body);
      if (json['status'] == 'success' && json['data'] != null) {
        return double.tryParse(json['data']['total_income'].toString()) ?? 0.0;
      }
      throw Exception('Invalid data');
    } else {
      throw Exception('Server error: ${res.statusCode}');
    }
  }

  static Future<Map<String, double>> fetchIncomeSummary(String token) async {
    final res = await http.get(
      Uri.parse('$_baseUrl/wallet/income/summary'),
      headers: {'Authorization': 'Bearer $token'},
    ).timeout(const Duration(seconds: 15));
    if (res.statusCode == 200) {
      final json = jsonDecode(res.body);
      if (json['status'] == 'success' && json['data'] != null) {
        return {
          'daily': double.tryParse(json['data']['daily_income'].toString()) ?? 0.0,
          'weekly': double.tryParse(json['data']['weekly_income'].toString()) ?? 0.0,
          'monthly': double.tryParse(json['data']['monthly_income'].toString()) ?? 0.0,
        };
      }
      throw Exception('Invalid data');
    } else {
      throw Exception('Server error: ${res.statusCode}');
    }
  }

  static Future<List<Transaction>> fetchTransactions(
    String token, {
    String? type,
    int limit = 20,
    int offset = 0,
  }) async {
    final params = <String, String>{
      'limit': limit.toString(),
      'offset': offset.toString(),
    };
    if (type != null) params['type'] = type;
    final uri = Uri.parse('$_baseUrl/wallet/transactions').replace(queryParameters: params);
    final res = await http.get(
      uri,
      headers: {'Authorization': 'Bearer $token'},
    ).timeout(const Duration(seconds: 15));
    if (res.statusCode == 200) {
      final json = jsonDecode(res.body);
      if (json['status'] == 'success' && json['data'] != null) {
        return (json['data'] as List)
            .map((e) => Transaction.fromJson(e))
            .toList();
      }
      throw Exception('Invalid data');
    } else {
      throw Exception('Server error: ${res.statusCode}');
    }
  }
}

// ==========================================
// 3. Wallet Page (Main) - Updated to ConsumerStatefulWidget
// ==========================================

class WalletPage extends ConsumerStatefulWidget {
  const WalletPage({super.key});
  @override
  ConsumerState<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends ConsumerState<WalletPage> {
  static const Color _accent      = Color(0xFF29B6F6);
  static const Color _accentLight = Color(0xFF4FC3F7);
  static const Color _accentDeep  = Color(0xFF0277BD);
  static const Color _darkBg      = Color(0xFF121212);
  static const Color _darkCard    = Color(0xFF1E1E1E);
  static const Color _lightBg     = Color(0xFFF5F5F5);
  static const Color _lightCard   = Colors.white;
  static const Color _ink         = Color(0xFF0C1A26);

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
    final isDark    = Theme.of(context).brightness == Brightness.dark;
    final bgColor   = isDark ? _darkBg   : _lightBg;
    final cardColor = isDark ? _darkCard : _lightCard;
    final textColor = isDark ? Colors.white : _ink;
    final subColor  = isDark ? const Color(0xFF9E9E9E) : const Color(0xFF757575);
    final isSmall   = MediaQuery.of(context).size.width < 360;

    return Scaffold(
      backgroundColor: bgColor,
      body: RefreshIndicator(
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
          padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 48.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildBalanceCard(isSmall, cardColor, textColor, subColor)
                  .animate()
                  .fadeIn(delay: 60.ms)
                  .slideY(begin: 0.04, curve: Curves.easeOut),
              SizedBox(height: 16.h),
              _buildActionButtons(isSmall)
                  .animate()
                  .fadeIn(delay: 130.ms)
                  .slideY(begin: 0.04, curve: Curves.easeOut),
              SizedBox(height: 14.h),
              ..._buildIncomeMenu(isSmall, cardColor, textColor, isDark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBalanceCard(
    bool isSmall, Color cardColor, Color textColor, Color subColor,
  ) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(16.w, 28.h, 16.w, 22.h),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(22.r),
        border: Border.all(color: _accent.withOpacity(0.12), width: 1),
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
          Text('My Wallet',
            style: GoogleFonts.poppins(
              fontSize: isSmall ? 20.sp : 22.sp,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
          SizedBox(height: 5.h),
          Text('View all your earnings here',
            style: GoogleFonts.poppins(
              fontSize: isSmall ? 11.sp : 12.sp,
              color: subColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWalletIllustration(bool isSmall) {
    final double wW   = isSmall ? 210 : 245;
    final double wH   = isSmall ? 170 : 198;
    final double cW   = isSmall ? 52  : 60;
    final double cH   = isSmall ? 70  : 82;
    final double peek = isSmall ? 22  : 26;
    final double totalW = wW + cW * 0.56;
    final double totalH = wH + peek;

    return Center(
      child: SizedBox(
        width:  totalW.w,
        height: totalH.h,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
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
                    border: Border.all(color: Colors.black.withOpacity(0.4), width: 3.2),
                  ),
                ),
              ),
            ),
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
                  border: Border.all(color: Colors.black.withOpacity(0.3), width: 3.5),
                  boxShadow: [
                    BoxShadow(
                      color: _accent.withOpacity(0.35),
                      blurRadius: 24,
                      offset: const Offset(0, 10),
                      spreadRadius: -4,
                    ),
                  ],
                ),
                child: Padding(
                  padding: EdgeInsets.only(left: 20.w, top: 10.h),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: _isLoading
                        ? _shimmer(isSmall)
                        : _error != null
                            ? _errorWidget(isSmall)
                            : Text(
                                '\$${(_balance?.balance ?? 0).toStringAsFixed(2)}',
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: isSmall ? 26.sp : 30.sp,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -1.2,
                                ),
                              ),
                  ),
                ),
              ),
            ),
            Positioned(
              right:  0,
              bottom: (wH * 0.20).h,
              child: Container(
                width:  cW.w,
                height: cH.h,
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.only(
                    topLeft:     Radius.circular(10.r),
                    bottomLeft:  Radius.circular(10.r),
                    topRight:    Radius.circular(18.r),
                    bottomRight: Radius.circular(18.r),
                  ),
                  border: Border.all(color: Colors.black.withOpacity(0.3), width: 3.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
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

  Widget _claspButton() => Container(
        width:  32.w,
        height: 32.w,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.black.withOpacity(0.3), width: 3),
          color: const Color(0xFF1E1E1E),
        ),
        child: Center(
          child: Container(
            width:  12.w,
            height: 12.w,
            decoration: const BoxDecoration(shape: BoxShape.circle, color: _accent),
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
          child: Text('Tap to Retry',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: isSmall ? 12.sp : 13.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      );

  Widget _buildActionButtons(bool isSmall) {
    return Row(
      children: [
        Expanded(
          child: _actionBtn(
            label: 'Withdraw',
            icon:  CupertinoIcons.arrow_up_circle_fill,
            isSmall: isSmall,
            onTap: () {
              HapticFeedback.mediumImpact();
              // Withdraw পেজের জন্য লজিক এখানে দিতে পারেন
            },
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: _actionBtn(
            label: 'History',
            icon:  CupertinoIcons.list_bullet_below_rectangle,
            isSmall: isSmall,
            onTap: () {
              HapticFeedback.mediumImpact();
              
              // Detail View Logic
              ref.read(isDetailViewProvider.notifier).state = true;
              ref.read(detailViewTitleProvider.notifier).state = 'Transaction History';
              
              // GoRouter Navigation
              context.push('/transactions');
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
            Text(label,
              style: GoogleFonts.poppins(
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

  List<Widget> _buildIncomeMenu(
    bool isSmall, Color cardColor, Color textColor, bool isDark,
  ) {
    final items = [
      {'label': 'Daily Income',    'icon': CupertinoIcons.sun_max_fill,         'delay': 160, 'period': 'daily'},
      {'label': 'Weekly Income',   'icon': CupertinoIcons.moon_stars_fill,      'delay': 210, 'period': 'weekly'},
      {'label': 'Monthly & Total', 'icon': CupertinoIcons.calendar,             'delay': 260, 'period': 'summary'},
    ];

    return items.map((item) {
      return _menuItem(
        label:     item['label']  as String,
        icon:      item['icon']   as IconData,
        isSmall:   isSmall,
        cardColor: cardColor,
        textColor: textColor,
        isDark:    isDark,
        onTap: () {
          HapticFeedback.lightImpact();
          
          // Detail View Logic
          ref.read(isDetailViewProvider.notifier).state = true;
          ref.read(detailViewTitleProvider.notifier).state = item['label'] as String;
          
          // GoRouter Navigation with Params
          final period = item['period'] as String;
          context.push('/income-detail?period=$period');
        },
      )
          .animate()
          .fadeIn(delay: Duration(milliseconds: item['delay'] as int))
          .slideX(begin: 0.04, curve: Curves.easeOut);
    }).toList();
  }

  Widget _menuItem({
    required String label,
    required IconData icon,
    required bool isSmall,
    required Color cardColor,
    required Color textColor,
    required bool isDark,
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
          border: isDark ? Border.all(color: Colors.white.withOpacity(0.05)) : null,
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
            Container(
              width:  isSmall ? 40.w : 44.w,
              height: isSmall ? 40.w : 44.w,
              decoration: BoxDecoration(
                color: _accent.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: _accent.withOpacity(0.20)),
              ),
              child: Icon(icon, color: _accent, size: isSmall ? 18.sp : 20.sp),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(label,
                style: GoogleFonts.poppins(
                  fontSize: isSmall ? 14.sp : 15.sp,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
            ),
            Container(
              width:  30.w,
              height: 30.w,
              decoration: BoxDecoration(
                color: _accent.withOpacity(0.10),
                shape: BoxShape.circle,
              ),
              child: Icon(CupertinoIcons.chevron_right,
                color: _accent, size: isSmall ? 13.sp : 14.sp),
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// 4. Income Detail Page (Optimized for Detail View)
// ==========================================

class IncomeDetailPage extends StatefulWidget {
  final String period;
  const IncomeDetailPage({super.key, required this.period});
  @override
  State<IncomeDetailPage> createState() => _IncomeDetailPageState();
}

class _IncomeDetailPageState extends State<IncomeDetailPage> {
  static const Color _accent = Color(0xFF29B6F6);
  bool _isLoading = true;
  String? _error;
  double _totalIncome = 0.0;
  Map<String, double> _summary = {};
  String _token = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('jwt_token') ?? '';
    if (_token.isEmpty) {
      setState(() { _error = 'Token missing'; _isLoading = false; });
      return;
    }
    try {
      if (widget.period == 'daily') {
        _totalIncome = await WalletApiService.fetchDailyIncome(_token);
      } else if (widget.period == 'weekly') {
        _totalIncome = await WalletApiService.fetchWeeklyIncome(_token);
      } else if (widget.period == 'monthly') {
        _totalIncome = await WalletApiService.fetchMonthlyIncome(_token);
      } else if (widget.period == 'summary') {
        _summary = await WalletApiService.fetchIncomeSummary(_token);
      }
      setState(() { _isLoading = false; });
    } catch (e) {
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // Detail View-এ মেইন ফ্রেম যেহেতু ব্যাক বাটন হ্যান্ডেল করে, 
    // তাই এখানে আলাদা SafeArea বা Header না দিলেও চলে।
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF5F5F5),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: _accent))
          : _error != null
              ? Center(child: Text(_error!, style: const TextStyle(color: Colors.red)))
              : widget.period == 'summary'
                  ? _buildSummary()
                  : _buildSingleTotal(),
    );
  }

  Widget _buildSingleTotal() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(24.w),
              decoration: BoxDecoration(
                color: _accent.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(CupertinoIcons.money_dollar_circle_fill, color: _accent, size: 60.sp),
            ),
            SizedBox(height: 24.h),
            Text(
              '\$${_totalIncome.toStringAsFixed(2)}',
              style: GoogleFonts.poppins(
                fontSize: 36.sp,
                fontWeight: FontWeight.w900,
                color: _accent,
              ),
            ),
            Text('Total Earnings', 
              style: GoogleFonts.poppins(fontSize: 14.sp, color: Colors.grey)),
          ],
        ),
      ),
    ).animate().scale(duration: 400.ms, curve: Curves.backOut);
  }

  Widget _buildSummary() {
    return ListView(
      padding: EdgeInsets.all(24.w),
      children: [
        _summaryCard('Today', _summary['daily'] ?? 0),
        SizedBox(height: 12.h),
        _summaryCard('This Week', _summary['weekly'] ?? 0),
        SizedBox(height: 12.h),
        _summaryCard('This Month', _summary['monthly'] ?? 0),
      ],
    );
  }

  Widget _summaryCard(String label, double amount) {
    return Container(
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF1E1E1E)
            : Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.poppins(fontSize: 16.sp, fontWeight: FontWeight.w600)),
          Text('\$${amount.toStringAsFixed(2)}',
            style: GoogleFonts.poppins(
              fontSize: 18.sp,
              fontWeight: FontWeight.w800,
              color: _accent,
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// 5. Transaction List Page (Optimized for Detail View)
// ==========================================

class TransactionListPage extends StatefulWidget {
  const TransactionListPage({super.key});
  @override
  State<TransactionListPage> createState() => _TransactionListPageState();
}

class _TransactionListPageState extends State<TransactionListPage> {
  static const Color _accent = Color(0xFF29B6F6);
  List<Transaction> _transactions = [];
  bool _isLoading = true;
  String? _error;
  String _token = '';
  int _offset = 0;
  bool _hasMore = true;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    _loadInitial();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 100 &&
        !_isLoading &&
        _hasMore) {
      _loadMore();
    }
  }

  Future<void> _loadInitial() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('jwt_token') ?? '';
    if (_token.isEmpty) {
      setState(() { _error = 'Token missing'; _isLoading = false; });
      return;
    }
    await _fetchTransactions(reset: true);
  }

  Future<void> _fetchTransactions({bool reset = false}) async {
    if (reset) {
      _offset = 0;
      _hasMore = true;
    }
    setState(() { _isLoading = true; _error = null; });
    try {
      final newList = await WalletApiService.fetchTransactions(
        _token,
        limit: 20,
        offset: _offset,
      );
      if (mounted) {
        setState(() {
          if (reset) _transactions = newList;
          else _transactions.addAll(newList);
          _offset += newList.length;
          _hasMore = newList.length == 20;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString().replaceAll('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadMore() async {
    if (_isLoading || !_hasMore) return;
    await _fetchTransactions();
  }

  Future<void> _refresh() async {
    await _fetchTransactions(reset: true);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF5F5F5),
      body: _isLoading && _transactions.isEmpty
          ? const Center(child: CircularProgressIndicator(color: _accent))
          : RefreshIndicator(
              onRefresh: _refresh,
              color: _accent,
              child: ListView.builder(
                controller: _scrollController,
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.all(16.w),
                itemCount: _transactions.length + (_hasMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == _transactions.length) {
                    return const Center(child: Padding(padding: EdgeInsets.all(20.0), child: CircularProgressIndicator()));
                  }
                  final t = _transactions[index];
                  return Card(
                    color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                    margin: EdgeInsets.only(bottom: 10.h),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.r),
                      side: BorderSide(color: _accent.withOpacity(0.1)),
                    ),
                    child: ListTile(
                      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
                      leading: Container(
                        padding: EdgeInsets.all(10.w),
                        decoration: BoxDecoration(color: _accent.withOpacity(0.1), shape: BoxShape.circle),
                        child: Icon(CupertinoIcons.doc_text_fill, color: _accent, size: 20.sp),
                      ),
                      title: Text(t.description, style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13.sp)),
                      subtitle: Text(_formatDate(t.createdAt), style: GoogleFonts.poppins(fontSize: 11.sp, color: Colors.grey)),
                      trailing: Text(
                        '\$${t.amount.toStringAsFixed(2)}',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 15.sp, color: _accent),
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }

  String _formatDate(String iso) {
    try {
      final dt = DateTime.parse(iso);
      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (_) {
      return iso;
    }
  }
}
