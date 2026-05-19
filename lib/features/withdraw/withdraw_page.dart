import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

// ==========================================
// 1. Data Model
// ==========================================
class WithdrawItem {
  final int? id;
  final String method;
  final String accountNo;
  final String accountHolder;
  final double amount;
  final String status;
  final String? trxId;
  final String? remarks;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  WithdrawItem({
    this.id,
    required this.method,
    required this.accountNo,
    required this.accountHolder,
    required this.amount,
    required this.status,
    this.trxId,
    this.remarks,
    this.createdAt,
    this.updatedAt,
  });

  factory WithdrawItem.fromJson(Map<String, dynamic> json) {
    return WithdrawItem(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? ''),
      method: json['method'] ?? 'N/A',
      accountNo: json['account_no'] ?? 'N/A',
      accountHolder: json['account_holder'] ?? '',
      amount: json['amount'] is num
          ? (json['amount'] as num).toDouble()
          : double.tryParse(json['amount']?.toString() ?? '0') ?? 0,
      status: json['status'] ?? 'pending',
      trxId: json['trx_id'],
      remarks: json['remarks'],
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'])
          : null,
    );
  }
}

// ==========================================
// 2. API Service
// ==========================================
class WithdrawApiService {
  static const String _baseUrl = 'https://api.easysarvice.com/api';

  static Future<List<WithdrawItem>> fetchHistory(String token) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/withdraw/history'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    ).timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      if (json['status'] == 'success' && json['data'] != null) {
        return (json['data'] as List)
            .map((e) => WithdrawItem.fromJson(e))
            .toList();
      }
      return [];
    } else if (response.statusCode == 401) {
      throw Exception('Session expired. Please login again.');
    } else {
      throw Exception('Server error: ${response.statusCode}');
    }
  }

  static Future<Map<String, dynamic>> submitWithdraw({
    required String token,
    required String method,
    required String accountNo,
    required String accountHolder,
    required double amount,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/withdraw/submit'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'method': method.trim(),
        'account_no': accountNo.trim(),
        'account_holder': accountHolder.trim(),
        'amount': amount,
      }),
    ).timeout(const Duration(seconds: 15));

    final json = jsonDecode(response.body);

    if (response.statusCode == 201 && json['status'] == 'success') {
      return json;
    } else {
      throw Exception(json['message'] ?? 'Failed to submit withdraw request.');
    }
  }
}

// ==========================================
// 3. Helpers
// ==========================================
String formatCurrency(double amount) =>
    '৳${NumberFormat('#,##0', 'en_US').format(amount)}';

String formatDate(DateTime? dt) {
  if (dt == null) return 'N/A';
  return DateFormat('dd MMM yyyy, hh:mm a').format(dt);
}

// ==========================================
// 4. WithdrawLedgerPage (এক পেজেই ফর্ম + ইতিহাস)
// ==========================================
class WithdrawLedgerPage extends StatefulWidget {
  const WithdrawLedgerPage({super.key});

  @override
  State<WithdrawLedgerPage> createState() => _WithdrawLedgerPageState();
}

class _WithdrawLedgerPageState extends State<WithdrawLedgerPage> {
  static const Color _primary  = Color(0xFF0F172A);
  static const Color _approved = Color(0xFF22C55E);
  static const Color _pending  = Color(0xFFF59E0B);
  static const Color _rejected = Color(0xFFEF4444);

  // ── ফর্ম কন্ট্রোলার ──
  final _methodCtrl       = TextEditingController(); // selected method store as text (optional)
  final _accountNoCtrl     = TextEditingController();
  final _accountHolderCtrl = TextEditingController();
  final _amountCtrl        = TextEditingController();
  String? _selectedMethod;
  bool _isSubmitting = false;
  String? _formError;

  // ── ইতিহাস ──
  List<WithdrawItem> _withdraws = [];
  bool _isLoadingHistory = true;
  String? _historyError;
  String _token = '';
  String _searchQuery = '';

  final TextEditingController _searchCtrl = TextEditingController();

  final List<String> _methods = ['bKash', 'Nagad', 'Rocket', 'Upay', 'Bank'];

  @override
  void initState() {
    super.initState();
    _boot();
  }

  @override
  void dispose() {
    _methodCtrl.dispose();
    _accountNoCtrl.dispose();
    _accountHolderCtrl.dispose();
    _amountCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _boot() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('jwt_token') ?? '';
    if (_token.isEmpty) {
      setState(() {
        _historyError = 'Token not found. Please login again.';
        _isLoadingHistory = false;
      });
      return;
    }
    await _fetchHistory();
  }

  Future<void> _fetchHistory() async {
    setState(() { _isLoadingHistory = true; _historyError = null; });
    try {
      final data = await WithdrawApiService.fetchHistory(_token);
      if (mounted) setState(() { _withdraws = data; _isLoadingHistory = false; });
    } catch (e) {
      if (mounted) {
        setState(() {
          _historyError = e.toString().replaceAll('Exception: ', '');
          _isLoadingHistory = false;
        });
      }
    }
  }

  // ── সাবমিট ফর্ম ──
  Future<void> _submitForm() async {
    final method    = _selectedMethod ?? '';
    final accountNo = _accountNoCtrl.text.trim();
    final amount    = double.tryParse(_amountCtrl.text.trim());

    if (method.isEmpty) {
      setState(() => _formError = 'Please select a payment method.');
      return;
    }
    if (accountNo.isEmpty) {
      setState(() => _formError = 'Account number is required.');
      return;
    }
    if (amount == null || amount <= 0) {
      setState(() => _formError = 'Please enter a valid amount.');
      return;
    }

    setState(() { _isSubmitting = true; _formError = null; });

    try {
      final result = await WithdrawApiService.submitWithdraw(
        token: _token,
        method: method,
        accountNo: accountNo,
        accountHolder: _accountHolderCtrl.text.trim(),
        amount: amount,
      );

      // সাকসেস: ফর্ম ক্লিয়ার ও ইতিহাস রিফ্রেশ
      if (mounted) {
        _accountNoCtrl.clear();
        _accountHolderCtrl.clear();
        _amountCtrl.clear();
        setState(() {
          _selectedMethod = null;
          _isSubmitting = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(result['message'] ?? 'Request submitted successfully!',
              style: GoogleFonts.poppins(fontSize: 13)),
          backgroundColor: _approved,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
        ));
        await _fetchHistory();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _formError = e.toString().replaceAll('Exception: ', '');
          _isSubmitting = false;
        });
      }
    }
  }

  // ── ইতিহাস ফিল্টার ──
  List<WithdrawItem> get _filtered {
    if (_searchQuery.isEmpty) return _withdraws;
    final q = _searchQuery.toLowerCase();
    return _withdraws.where((w) =>
        w.method.toLowerCase().contains(q) ||
        w.accountNo.toLowerCase().contains(q) ||
        w.status.toLowerCase().contains(q) ||
        _statusLabel(w.status).toLowerCase().contains(q)).toList();
  }

  Map<String, dynamic> get _stats {
    double approved = 0, pending = 0;
    for (final w in _withdraws) {
      if (w.status == 'approved') approved += w.amount;
      if (w.status == 'pending')  pending  += w.amount;
    }
    return {'count': _withdraws.length, 'approved': approved, 'pending': pending};
  }

  Color    _statusColor(String s) => s == 'approved' ? _approved : s == 'rejected' ? _rejected : _pending;
  IconData _statusIcon(String s)  => s == 'approved' ? CupertinoIcons.checkmark_seal_fill : s == 'rejected' ? CupertinoIcons.xmark_circle_fill : CupertinoIcons.clock_fill;
  String   _statusLabel(String s) => s == 'approved' ? 'Approved' : s == 'rejected' ? 'Rejected' : 'Pending';

  @override
  Widget build(BuildContext context) {
    final isDark    = Theme.of(context).brightness == Brightness.dark;
    final bgColor   = isDark ? const Color(0xFF000000) : const Color(0xFFF2F2F7);
    final cardColor = isDark ? const Color(0xFF1C1C1E) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF000000);
    final sub       = isDark ? const Color(0xFF8E8E93) : const Color(0xFF8E8E93);
    final border    = isDark ? const Color(0xFF2C2C2E) : const Color(0xFFE5E5EA);
    final fill      = isDark ? const Color(0xFF2C2C2E) : const Color(0xFFF2F2F7);
    final shadow    = isDark ? Colors.black.withOpacity(0.5) : Colors.black.withOpacity(0.04);

    final sw       = MediaQuery.of(context).size.width;
    final isSmall  = sw < 360;
    final isDesktop = sw >= 1024;
    final isTablet  = sw >= 600 && sw < 1024;
    final hPad     = isDesktop ? 32.w : isTablet ? 20.w : isSmall ? 12.w : 16.w;

    return Scaffold(
      backgroundColor: bgColor,
      // কোনো FAB লাগবে না
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          color: _primary,
          backgroundColor: cardColor,
          onRefresh: () async {
            HapticFeedback.mediumImpact();
            await _fetchHistory();
          },
          child: ListView(
            padding: EdgeInsets.fromLTRB(hPad, 8.h, hPad, 100.h),
            physics: const BouncingScrollPhysics(),
            children: [
              // ── হেডার ──
              _buildHeader(textColor, sub, isSmall, isDesktop),
              SizedBox(height: 14.h),

              // ── উইথড্র ফর্ম ──
              _buildWithdrawForm(cardColor, textColor, sub, border, fill, isSmall),
              SizedBox(height: 20.h),

              // ── সামারি ও স্ট্যাট ──
              if (!_isLoadingHistory && _historyError == null) ...[
                _buildSummaryCard(isDark, isSmall)
                    .animate().fadeIn(delay: 80.ms).slideY(begin: 0.03),
                SizedBox(height: 10.h),
                Row(children: [
                  Expanded(child: _buildStatCard(
                    icon: CupertinoIcons.arrow_up_circle_fill, iconColor: _primary,
                    label: 'Total', value: _stats['count'].toString(),
                    cardColor: cardColor, textColor: textColor,
                    sub: sub, shadow: shadow, border: border, isSmall: isSmall,
                  ).animate().fadeIn(delay: 120.ms).slideY(begin: 0.03)),
                  SizedBox(width: 8.w),
                  Expanded(child: _buildStatCard(
                    icon: CupertinoIcons.checkmark_seal_fill, iconColor: _approved,
                    label: 'Approved', value: formatCurrency(_stats['approved']),
                    cardColor: cardColor, textColor: textColor,
                    sub: sub, shadow: shadow, border: border, isSmall: isSmall,
                  ).animate().fadeIn(delay: 140.ms).slideY(begin: 0.03)),
                  SizedBox(width: 8.w),
                  Expanded(child: _buildStatCard(
                    icon: CupertinoIcons.clock_fill, iconColor: _pending,
                    label: 'Pending', value: formatCurrency(_stats['pending']),
                    cardColor: cardColor, textColor: textColor,
                    sub: sub, shadow: shadow, border: border, isSmall: isSmall,
                  ).animate().fadeIn(delay: 160.ms).slideY(begin: 0.03)),
                ]),
                SizedBox(height: 10.h),
                _buildSearchBar(cardColor, textColor, sub, border, isSmall)
                    .animate().fadeIn(delay: 180.ms).slideY(begin: 0.03),
                SizedBox(height: 16.h),
                Padding(
                  padding: EdgeInsets.only(left: 4.w, bottom: 6.h),
                  child: Text('Withdraw History', style: GoogleFonts.poppins(
                      fontSize: isSmall ? 14.sp : 16.sp,
                      fontWeight: FontWeight.w600, color: textColor)),
                ),
              ],

              // ── ইতিহাস লোডিং/এরর/খালি ──
              if (_isLoadingHistory)
                ...List.generate(5, (_) => _buildShimmerCard(cardColor))
              else if (_historyError != null)
                _buildErrorCard(_historyError!, cardColor, textColor, isSmall)
              else if (_filtered.isEmpty)
                _buildEmptyCard(
                  _searchQuery.isNotEmpty ? 'No results found' : 'No withdrawals yet',
                  _searchQuery.isNotEmpty
                      ? 'Try a different search term'
                      : 'Submit a request using the form above',
                  cardColor, border, textColor, sub, isSmall,
                )
              else
                ..._filtered.asMap().entries.map((e) => _buildWithdrawCard(
                  item: e.value, isDark: isDark,
                  cardColor: cardColor, textColor: textColor,
                  sub: sub, border: border, shadow: shadow,
                  isSmall: isSmall, delay: 200 + e.key * 50,
                )),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────── উইথড্র ফর্ম (পুরো পেজের উপরে) ───────────
  Widget _buildWithdrawForm(Color cardColor, Color textColor, Color sub,
      Color border, Color fill, bool isSmall) {
    return Container(
      padding: EdgeInsets.all(isSmall ? 14.w : 18.w),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: border, width: 0.5),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 12, offset: Offset(0, 4))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Request a Withdraw', style: GoogleFonts.poppins(
            fontSize: isSmall ? 15.sp : 17.sp,
            fontWeight: FontWeight.w700, color: textColor)),
        SizedBox(height: 4.h),
        Text('Fill the details and submit', style: GoogleFonts.poppins(
            fontSize: isSmall ? 11.sp : 12.sp, color: sub)),
        SizedBox(height: 16.h),

        // Payment Method
        Text('Payment Method *', style: GoogleFonts.poppins(
            fontSize: isSmall ? 12.sp : 13.sp, color: sub, fontWeight: FontWeight.w500)),
        SizedBox(height: 6.h),
        Wrap(spacing: 8.w, runSpacing: 8.h,
          children: _methods.map((m) {
            final selected = _selectedMethod == m;
            return GestureDetector(
              onTap: () => setState(() => _selectedMethod = selected ? null : m),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: selected ? _primary : fill,
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(color: selected ? _primary : border, width: 0.5),
                ),
                child: Text(m, style: GoogleFonts.poppins(
                    fontSize: isSmall ? 11.sp : 12.sp, fontWeight: FontWeight.w600,
                    color: selected ? Colors.white : textColor)),
              ),
            );
          }).toList(),
        ),
        SizedBox(height: 16.h),

        // Account Number
        _buildFormField(
          ctrl: _accountNoCtrl, label: 'Account Number *', hint: 'e.g. 01XXXXXXXXX',
          icon: CupertinoIcons.phone, textColor: textColor, sub: sub,
          border: border, fill: fill, isSmall: isSmall,
          keyboard: TextInputType.phone,
        ),
        SizedBox(height: 12.h),

        // Account Holder (optional)
        _buildFormField(
          ctrl: _accountHolderCtrl, label: 'Account Holder (optional)', hint: 'Name of account owner',
          icon: CupertinoIcons.person, textColor: textColor, sub: sub,
          border: border, fill: fill, isSmall: isSmall,
        ),
        SizedBox(height: 12.h),

        // Amount
        _buildFormField(
          ctrl: _amountCtrl, label: 'Amount (৳) *', hint: 'e.g. 500',
          icon: CupertinoIcons.money_dollar_circle, textColor: textColor, sub: sub,
          border: border, fill: fill, isSmall: isSmall,
          keyboard: const TextInputType.numberWithOptions(decimal: true),
        ),
        SizedBox(height: 16.h),

        // Error message
        if (_formError != null) ...[
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(color: Colors.red.withOpacity(0.2)),
            ),
            child: Row(children: [
              Icon(CupertinoIcons.exclamationmark_circle, color: Colors.red, size: 15.sp),
              SizedBox(width: 8.w),
              Flexible(child: Text(_formError!, style: GoogleFonts.poppins(
                  fontSize: isSmall ? 12.sp : 13.sp, color: Colors.red))),
            ]),
          ),
          SizedBox(height: 12.h),
        ],

        // Submit Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isSubmitting ? null : _submitForm,
            style: ElevatedButton.styleFrom(
              backgroundColor: _primary,
              disabledBackgroundColor: _primary.withOpacity(0.5),
              padding: EdgeInsets.symmetric(vertical: isSmall ? 13.h : 15.h),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
              elevation: 0,
            ),
            child: _isSubmitting
                ? SizedBox(width: 20.w, height: 20.w,
                    child: const CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : Text('Submit Withdraw Request', style: GoogleFonts.poppins(
                    color: Colors.white, fontWeight: FontWeight.w700, fontSize: isSmall ? 13.sp : 14.sp)),
          ),
        ),
      ]),
    ).animate().fadeIn(delay: 40.ms).slideY(begin: 0.02);
  }

  Widget _buildFormField({
    required TextEditingController ctrl, required String label, required String hint,
    required IconData icon, required Color textColor, required Color sub,
    required Color border, required Color fill, required bool isSmall,
    TextInputType keyboard = TextInputType.text,
  }) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: GoogleFonts.poppins(
            fontSize: isSmall ? 12.sp : 13.sp, color: sub, fontWeight: FontWeight.w500)),
        SizedBox(height: 6.h),
        Container(
          decoration: BoxDecoration(
            color: fill, borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: border, width: 0.5),
          ),
          child: TextField(
            controller: ctrl, keyboardType: keyboard,
            style: GoogleFonts.poppins(fontSize: isSmall ? 13.sp : 14.sp, color: textColor),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.poppins(color: sub),
              prefixIcon: Icon(icon, size: 18.sp, color: sub),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 13.h),
            ),
          ),
        ),
      ]);

  // ───── নিচের সব হেল্পার উইজেট আগের মতোই (অপরিবর্তিত) ─────
  Widget _buildHeader(Color textColor, Color sub, bool isSmall, bool isDesktop) =>
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Withdraw', style: GoogleFonts.poppins(
                fontSize: isSmall ? 24.sp : isDesktop ? 30.sp : 26.sp,
                fontWeight: FontWeight.w700, color: textColor, height: 1.1, letterSpacing: -0.5)),
            Text('Ledger', style: GoogleFonts.poppins(
                fontSize: isSmall ? 24.sp : isDesktop ? 30.sp : 26.sp,
                fontWeight: FontWeight.w300, color: textColor, height: 1.1, letterSpacing: -0.5)),
          ]),
          Container(
            width: 32.w, height: 32.w,
            decoration: BoxDecoration(color: _primary.withOpacity(0.08), shape: BoxShape.circle),
            child: Icon(CupertinoIcons.arrow_up_arrow_down_circle,
                color: _primary, size: isSmall ? 16.sp : 18.sp),
          ),
        ],
      ).animate().fadeIn(delay: 40.ms);

  Widget _buildSummaryCard(bool isDark, bool isSmall) {
    final total = (_stats['approved'] as double) + (_stats['pending'] as double);
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: isSmall ? 16.w : 20.w, vertical: isSmall ? 20.h : 24.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
              : [const Color(0xFF0F172A), const Color(0xFF1E3A5F)],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [BoxShadow(
            color: const Color(0xFF0F172A).withOpacity(0.3),
            blurRadius: 24, offset: const Offset(0, 10), spreadRadius: -4)],
      ),
      child: Column(children: [
        Text('TOTAL WITHDRAWALS', style: GoogleFonts.poppins(
            color: Colors.white.withOpacity(0.6), fontSize: isSmall ? 10.sp : 11.sp,
            fontWeight: FontWeight.w500, letterSpacing: 1.2)),
        SizedBox(height: 8.h),
        Text(formatCurrency(total), style: GoogleFonts.poppins(
            color: Colors.white, fontSize: isSmall ? 28.sp : 32.sp,
            fontWeight: FontWeight.w700, letterSpacing: 1.0)),
        SizedBox(height: 8.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 5.h),
          decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(20.r)),
          child: Text(
            '${_stats['count']} request${_stats['count'] == 1 ? '' : 's'}',
            style: GoogleFonts.poppins(color: Colors.white70, fontSize: isSmall ? 10.sp : 11.sp)),
        ),
      ]),
    );
  }

  Widget _buildStatCard({
    required IconData icon, required Color iconColor,
    required String label, required String value,
    required Color cardColor, required Color textColor,
    required Color sub, required Color shadow, required Color border,
    required bool isSmall,
  }) =>
      Container(
        padding: EdgeInsets.all(isSmall ? 10.w : 12.w),
        decoration: BoxDecoration(
          color: cardColor, borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: border, width: 0.5),
          boxShadow: [BoxShadow(color: shadow, blurRadius: 16, offset: const Offset(0, 6), spreadRadius: -4)],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: isSmall ? 24.w : 26.w, height: isSmall ? 24.w : 26.w,
            decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8.r)),
            child: Icon(icon, color: iconColor, size: isSmall ? 12.sp : 13.sp),
          ),
          SizedBox(height: 6.h),
          Text(value, style: GoogleFonts.poppins(
              fontSize: isSmall ? 11.sp : 13.sp, fontWeight: FontWeight.w700,
              color: textColor, letterSpacing: -0.3), maxLines: 1, overflow: TextOverflow.ellipsis),
          SizedBox(height: 2.h),
          Text(label, style: GoogleFonts.poppins(
              fontSize: isSmall ? 8.sp : 9.sp, color: sub, fontWeight: FontWeight.w500)),
        ]),
      );

  Widget _buildSearchBar(Color cardColor, Color textColor, Color sub,
      Color border, bool isSmall) =>
      Container(
        decoration: BoxDecoration(
          color: cardColor, borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: border, width: 0.5),
        ),
        child: TextField(
          controller: _searchCtrl,
          onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
          decoration: InputDecoration(
            hintText: 'Search by method, account or status...',
            hintStyle: GoogleFonts.poppins(color: sub, fontSize: isSmall ? 11.sp : 12.sp),
            prefixIcon: Icon(CupertinoIcons.search, color: sub, size: isSmall ? 16.sp : 18.sp),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: Icon(CupertinoIcons.clear_circled_solid, color: sub, size: 16.sp),
                    onPressed: () { _searchCtrl.clear(); setState(() => _searchQuery = ''); })
                : null,
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: isSmall ? 12.h : 14.h),
          ),
          style: GoogleFonts.poppins(color: textColor, fontSize: isSmall ? 12.sp : 13.sp),
        ),
      );

  Widget _buildWithdrawCard({
    required WithdrawItem item, required bool isDark,
    required Color cardColor, required Color textColor,
    required Color sub, required Color border, required Color shadow,
    required bool isSmall, required int delay,
  }) {
    final sc        = _statusColor(item.status);
    final isPending = item.status == 'pending';

    return GestureDetector(
      onTap: item.id != null
          ? () => Navigator.push(context, MaterialPageRoute(builder: (_) => WithdrawDetailPage(item: item)))
          : null,
      child: Container(
        padding: EdgeInsets.all(isSmall ? 12.w : 14.w),
        margin: EdgeInsets.only(bottom: 8.h),
        decoration: BoxDecoration(
          color: cardColor, borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: isPending ? sc.withOpacity(0.4) : border, width: isPending ? 1.5 : 0.5),
          boxShadow: [BoxShadow(color: shadow, blurRadius: 12, offset: const Offset(0, 4), spreadRadius: -2)],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              width: isSmall ? 38.w : 42.w, height: isSmall ? 38.w : 42.w,
              decoration: BoxDecoration(
                  color: sc.withOpacity(0.1), shape: BoxShape.circle,
                  border: Border.all(color: sc.withOpacity(0.3))),
              child: Icon(CupertinoIcons.phone_fill, color: sc, size: isSmall ? 16.sp : 18.sp),
            ),
            SizedBox(width: 10.w),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(item.method.toUpperCase(), style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w700, fontSize: isSmall ? 13.sp : 14.sp, color: textColor)),
              SizedBox(height: 2.h),
              Row(children: [
                Icon(CupertinoIcons.person_circle, size: 11.sp, color: sub),
                SizedBox(width: 4.w),
                Flexible(child: Text(item.accountNo, style: GoogleFonts.poppins(
                    fontSize: isSmall ? 10.sp : 11.sp, color: sub), maxLines: 1, overflow: TextOverflow.ellipsis)),
              ]),
            ])),
            SizedBox(width: 8.w),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text(formatCurrency(item.amount), style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w700, fontSize: isSmall ? 14.sp : 16.sp, color: sc)),
              SizedBox(height: 4.h),
              _buildBadge(item.status, sc, isSmall),
            ]),
          ]),
          if (item.accountHolder.isNotEmpty) ...[
            SizedBox(height: 8.h),
            _buildChip(CupertinoIcons.person, item.accountHolder, isDark, textColor, sub, isSmall),
          ],
          if (item.trxId != null && item.trxId!.isNotEmpty) ...[
            SizedBox(height: 6.h),
            _buildChip(CupertinoIcons.doc_plaintext, 'TRX: ${item.trxId}', isDark, textColor, sub, isSmall),
          ],
          if (item.remarks != null && item.remarks!.isNotEmpty) ...[
            SizedBox(height: 6.h),
            _buildChip(CupertinoIcons.chat_bubble_text, item.remarks!, isDark, textColor, sub, isSmall),
          ],
          SizedBox(height: 8.h),
          Row(children: [
            Icon(CupertinoIcons.clock, size: 10.sp, color: sub),
            SizedBox(width: 4.w),
            Text(formatDate(item.createdAt), style: GoogleFonts.poppins(
                fontSize: isSmall ? 9.sp : 10.sp, color: sub)),
          ]),
        ]),
      ).animate().fadeIn(delay: Duration(milliseconds: delay)).slideY(begin: 0.02),
    );
  }

  Widget _buildBadge(String status, Color color, bool isSmall) =>
      Container(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(_statusIcon(status), size: 10.sp, color: color),
          SizedBox(width: 3.w),
          Text(_statusLabel(status), style: GoogleFonts.poppins(
              color: color, fontSize: isSmall ? 9.sp : 10.sp, fontWeight: FontWeight.w600)),
        ]),
      );

  Widget _buildChip(IconData icon, String label, bool isDark,
      Color textColor, Color sub, bool isSmall) =>
      Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF252525) : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 11.sp, color: sub),
          SizedBox(width: 6.w),
          Flexible(child: Text(label, style: GoogleFonts.poppins(
              fontSize: isSmall ? 10.sp : 11.sp, fontWeight: FontWeight.w500, color: textColor),
              maxLines: 1, overflow: TextOverflow.ellipsis)),
        ]),
      );

  Widget _buildShimmerCard(Color cardColor) =>
      Container(
        height: 110.h, margin: EdgeInsets.only(bottom: 8.h),
        decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(16.r)),
      ).animate(onPlay: (c) => c.repeat()).shimmer(duration: 1200.ms, color: Colors.grey.withOpacity(0.3));

  Widget _buildErrorCard(String msg, Color cardColor, Color textColor, bool isSmall) =>
      Container(
        padding: EdgeInsets.all(20.w), margin: EdgeInsets.only(bottom: 8.h),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.05), borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: Colors.red.withOpacity(0.2)),
        ),
        child: Column(children: [
          Icon(CupertinoIcons.exclamationmark_circle, color: Colors.red, size: isSmall ? 28.sp : 32.sp),
          SizedBox(height: 10.h),
          Text(msg, style: GoogleFonts.poppins(fontSize: isSmall ? 11.sp : 12.sp, color: Colors.red),
              textAlign: TextAlign.center),
          SizedBox(height: 12.h),
          GestureDetector(
            onTap: _fetchHistory,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
              decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(10.r)),
              child: Text('Try Again', style: GoogleFonts.poppins(
                  color: Colors.white, fontWeight: FontWeight.w600)),
            ),
          ),
        ]),
      );

  Widget _buildEmptyCard(String title, String subtitle, Color cardColor,
      Color border, Color textColor, Color sub, bool isSmall) =>
      Container(
        padding: EdgeInsets.all(32.w), margin: EdgeInsets.only(bottom: 8.h),
        decoration: BoxDecoration(
          color: cardColor, borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: border, width: 0.5),
        ),
        child: Column(children: [
          Icon(CupertinoIcons.tray, color: sub, size: isSmall ? 36.sp : 42.sp),
          SizedBox(height: 10.h),
          Text(title, style: GoogleFonts.poppins(
              fontSize: isSmall ? 13.sp : 14.sp, fontWeight: FontWeight.w600, color: textColor)),
          SizedBox(height: 4.h),
          Text(subtitle, style: GoogleFonts.poppins(
              fontSize: isSmall ? 11.sp : 12.sp, color: sub), textAlign: TextAlign.center),
        ]),
      );
}

// ==========================================
// 5. WithdrawDetailPage (অপরিবর্তিত)
// ==========================================
class WithdrawDetailPage extends StatelessWidget {
  final WithdrawItem item;
  const WithdrawDetailPage({super.key, required this.item});

  Color    _sc(String s) => s == 'approved' ? const Color(0xFF22C55E) : s == 'rejected' ? const Color(0xFFEF4444) : const Color(0xFFF59E0B);
  IconData _si(String s) => s == 'approved' ? CupertinoIcons.checkmark_seal_fill : s == 'rejected' ? CupertinoIcons.xmark_circle_fill : CupertinoIcons.clock_fill;
  String   _sl(String s) => s == 'approved' ? 'Approved' : s == 'rejected' ? 'Rejected' : 'Pending';

  void _copy(BuildContext ctx, String? text) {
    if (text == null || text.isEmpty) return;
    Clipboard.setData(ClipboardData(text: text));
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
      content: Text('Copied to clipboard', style: GoogleFonts.poppins(fontSize: 13)),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
      duration: const Duration(seconds: 2),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final isDark    = Theme.of(context).brightness == Brightness.dark;
    final bgColor   = isDark ? const Color(0xFF000000) : const Color(0xFFF2F2F7);
    final cardColor = isDark ? const Color(0xFF1C1C1E) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF000000);
    final sub       = isDark ? const Color(0xFF8E8E93) : const Color(0xFF8E8E93);
    final border    = isDark ? const Color(0xFF2C2C2E) : const Color(0xFFE5E5EA);
    final sc        = _sc(item.status);
    final isSmall   = MediaQuery.of(context).size.width < 360;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: cardColor, elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(CupertinoIcons.chevron_left, color: textColor, size: 20.sp),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Withdraw Detail', style: GoogleFonts.poppins(
            color: textColor, fontWeight: FontWeight.w700, fontSize: 17.sp)),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: double.infinity, padding: EdgeInsets.all(24.w),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
                sc.withOpacity(isDark ? 0.25 : 0.12),
                sc.withOpacity(isDark ? 0.08 : 0.04),
              ], begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(color: sc.withOpacity(0.3)),
            ),
            child: Column(children: [
              Icon(_si(item.status), color: sc, size: 48.sp),
              SizedBox(height: 10.h),
              Text(formatCurrency(item.amount), style: GoogleFonts.poppins(
                  fontSize: 30.sp, fontWeight: FontWeight.w700, color: sc)),
              SizedBox(height: 6.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 5.h),
                decoration: BoxDecoration(
                    color: sc.withOpacity(0.15), borderRadius: BorderRadius.circular(20.r)),
                child: Text(_sl(item.status), style: GoogleFonts.poppins(
                    color: sc, fontWeight: FontWeight.w700, fontSize: isSmall ? 12.sp : 13.sp)),
              ),
            ]),
          ).animate().fadeIn().slideY(begin: 0.03),
          SizedBox(height: 16.h),

          _section(
            title: 'Payment Info', icon: CupertinoIcons.creditcard,
            isDark: isDark, cardColor: cardColor, border: border, textColor: textColor,
            child: Column(children: [
              _row(ctx: context, icon: CupertinoIcons.phone, label: 'Method', value: item.method.toUpperCase(),
                  isDark: isDark, textColor: textColor, sub: sub, isSmall: isSmall),
              _divider(isDark),
              _row(ctx: context, icon: CupertinoIcons.person_circle, label: 'Account Number', value: item.accountNo,
                  isDark: isDark, textColor: textColor, sub: sub, isSmall: isSmall, onCopy: () => _copy(context, item.accountNo)),
              if (item.accountHolder.isNotEmpty) ...[
                _divider(isDark),
                _row(ctx: context, icon: CupertinoIcons.person, label: 'Account Holder', value: item.accountHolder,
                    isDark: isDark, textColor: textColor, sub: sub, isSmall: isSmall),
              ],
              _divider(isDark),
              _row(ctx: context, icon: CupertinoIcons.money_dollar_circle, label: 'Amount', value: formatCurrency(item.amount),
                  isDark: isDark, textColor: textColor, sub: sub, isSmall: isSmall, valueColor: sc),
            ]),
          ).animate().fadeIn(delay: 80.ms).slideY(begin: 0.03),
          SizedBox(height: 14.h),

          _section(
            title: 'Timeline', icon: CupertinoIcons.time,
            isDark: isDark, cardColor: cardColor, border: border, textColor: textColor,
            child: Column(children: [
              _row(ctx: context, icon: CupertinoIcons.add_circled, label: 'Requested At',
                  value: formatDate(item.createdAt),
                  isDark: isDark, textColor: textColor, sub: sub, isSmall: isSmall),
              if (item.updatedAt != null) ...[
                _divider(isDark),
                _row(ctx: context,
                    icon: item.status == 'approved' ? CupertinoIcons.checkmark_circle : CupertinoIcons.xmark_circle,
                    label: item.status == 'approved' ? 'Approved At' : 'Rejected At',
                    value: formatDate(item.updatedAt),
                    isDark: isDark, textColor: textColor, sub: sub, isSmall: isSmall, valueColor: sc),
              ],
              if (item.trxId != null && item.trxId!.isNotEmpty) ...[
                _divider(isDark),
                _row(ctx: context, icon: CupertinoIcons.doc_plaintext, label: 'TRX ID', value: item.trxId!,
                    isDark: isDark, textColor: textColor, sub: sub, isSmall: isSmall,
                    onCopy: () => _copy(context, item.trxId)),
              ],
              if (item.remarks != null && item.remarks!.isNotEmpty) ...[
                _divider(isDark),
                _row(ctx: context, icon: CupertinoIcons.chat_bubble_text, label: 'Remarks', value: item.remarks!,
                    isDark: isDark, textColor: textColor, sub: sub, isSmall: isSmall),
              ],
            ]),
          ).animate().fadeIn(delay: 140.ms).slideY(begin: 0.03),
          SizedBox(height: 32.h),
        ]),
      ),
    );
  }

  Widget _section({
    required String title, required IconData icon, required bool isDark,
    required Color cardColor, required Color border, required Color textColor,
    required Widget child,
  }) =>
      Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: cardColor, borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: border, width: 0.5),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 10.h),
            child: Row(children: [
              Icon(icon, size: 17, color: const Color(0xFF0EA5E9)),
              SizedBox(width: 8.w),
              Text(title, style: GoogleFonts.poppins(
                  fontSize: 14, fontWeight: FontWeight.w600, color: textColor)),
            ]),
          ),
          Divider(height: 1, color: isDark ? const Color(0xFF2A2A2A) : Colors.grey.shade100),
          Padding(padding: EdgeInsets.all(16.w), child: child),
        ]),
      );

  Widget _row({
    required BuildContext ctx, required IconData icon,
    required String label, required String value, required bool isDark,
    required Color textColor, required Color sub, required bool isSmall,
    Color? valueColor, VoidCallback? onCopy,
  }) =>
      Row(children: [
        Icon(icon, size: 17, color: sub),
        SizedBox(width: 12.w),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: GoogleFonts.poppins(fontSize: isSmall ? 10 : 11, color: sub)),
          SizedBox(height: 2.h),
          Text(value, style: GoogleFonts.poppins(
              fontSize: isSmall ? 13 : 14, fontWeight: FontWeight.w600,
              color: valueColor ?? textColor)),
        ])),
        if (onCopy != null)
          IconButton(
            onPressed: onCopy,
            icon: Icon(CupertinoIcons.doc_on_clipboard, size: 16, color: sub),
            padding: EdgeInsets.zero, constraints: const BoxConstraints(),
          ),
      ]);

  Widget _divider(bool isDark) => Divider(height: 16,
      color: isDark ? const Color(0xFF2A2A2A) : Colors.grey.shade100);
}
