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
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? ''),
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

  static Future<List<WithdrawItem>> fetchWithdraws(String token) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/wallet/withdraws'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    ).timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final list = json['data'] as List? ?? [];
      return list.map((e) => WithdrawItem.fromJson(e)).toList();
    } else if (response.statusCode == 401) {
      throw Exception('Session expired. Please login again.');
    } else if (response.statusCode == 403) {
      throw Exception('Access denied.');
    } else {
      throw Exception('Server error: ${response.statusCode}');
    }
  }
}

// ==========================================
// 3. Helpers
// ==========================================

String formatCurrency(double amount) {
  return '৳${NumberFormat('#,##0', 'en_US').format(amount)}';
}

String formatDate(DateTime? dt) {
  if (dt == null) return 'N/A';
  return DateFormat('dd MMM yyyy, hh:mm a').format(dt);
}

// ==========================================
// 4. WithdrawLedgerPage
// ==========================================

class WithdrawLedgerPage extends StatefulWidget {
  const WithdrawLedgerPage({super.key});

  @override
  State<WithdrawLedgerPage> createState() => _WithdrawLedgerPageState();
}

class _WithdrawLedgerPageState extends State<WithdrawLedgerPage> {
  static const Color primaryColor = Color(0xFF0F172A);
  static const Color accentApproved = Color(0xFF22C55E);
  static const Color accentPending = Color(0xFFF59E0B);
  static const Color accentRejected = Color(0xFFEF4444);

  List<WithdrawItem> _withdraws = [];
  bool _isLoading = true;
  String? _error;
  String _token = '';
  String _searchQuery = '';

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('jwt_token') ?? '';
    if (_token.isEmpty) {
      setState(() {
        _error = 'Token not found. Please login again.';
        _isLoading = false;
      });
      return;
    }
    await _fetchWithdraws();
  }

  Future<void> _fetchWithdraws() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final data = await WithdrawApiService.fetchWithdraws(_token);
      if (mounted) {
        setState(() {
          _withdraws = data;
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

  // ── Filtering ──────────────────────────────
  List<WithdrawItem> get _filtered {
    if (_searchQuery.isEmpty) return _withdraws;
    final q = _searchQuery.toLowerCase();
    return _withdraws.where((w) {
      return w.method.toLowerCase().contains(q) ||
          w.accountNo.toLowerCase().contains(q) ||
          w.status.toLowerCase().contains(q) ||
          _statusLabel(w.status).toLowerCase().contains(q);
    }).toList();
  }

  // ── Summary ────────────────────────────────
  Map<String, dynamic> get _stats {
    double approved = 0, pending = 0;
    for (final w in _withdraws) {
      if (w.status == 'approved') approved += w.amount;
      if (w.status == 'pending') pending += w.amount;
    }
    return {
      'count': _withdraws.length,
      'approved': approved,
      'pending': pending,
    };
  }

  // ── Status helpers ─────────────────────────
  Color _statusColor(String status) {
    switch (status) {
      case 'approved':
        return accentApproved;
      case 'rejected':
        return accentRejected;
      default:
        return accentPending;
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'approved':
        return CupertinoIcons.checkmark_seal_fill;
      case 'rejected':
        return CupertinoIcons.xmark_circle_fill;
      default:
        return CupertinoIcons.clock_fill;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'approved':
        return 'Approved';
      case 'rejected':
        return 'Rejected';
      default:
        return 'Pending';
    }
  }

  // ==========================================
  // Build
  // ==========================================

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF000000) : const Color(0xFFF2F2F7);
    final cardColor = isDark ? const Color(0xFF1C1C1E) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF000000);
    final subTextColor = isDark ? const Color(0xFF8E8E93) : const Color(0xFF8E8E93);
    final borderColor = isDark ? const Color(0xFF2C2C2E) : const Color(0xFFE5E5EA);
    final shadowColor =
        isDark ? Colors.black.withOpacity(0.5) : Colors.black.withOpacity(0.04);

    final screenWidth = MediaQuery.of(context).size.width;
    final isSmall = screenWidth < 360;
    final isDesktop = screenWidth >= 1024;
    final isTablet = screenWidth >= 600 && screenWidth < 1024;
    final hPadding =
        isDesktop ? 32.w : isTablet ? 20.w : isSmall ? 12.w : 16.w;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          color: primaryColor,
          backgroundColor: cardColor,
          onRefresh: () async {
            HapticFeedback.mediumImpact();
            await _fetchWithdraws();
          },
          child: ListView(
            padding:
                EdgeInsets.fromLTRB(hPadding, 8.h, hPadding, 40.h),
            physics: const BouncingScrollPhysics(),
            children: [
              // Header
              _buildHeader(textColor, subTextColor, isSmall, isDesktop),
              SizedBox(height: 14.h),

              // Summary card
              if (!_isLoading && _error == null)
                _buildSummaryCard(isDark, isSmall)
                    .animate()
                    .fadeIn(delay: 80.ms)
                    .slideY(begin: 0.03),

              if (!_isLoading && _error == null) SizedBox(height: 10.h),

              // Stat chips row
              if (!_isLoading && _error == null)
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        icon: CupertinoIcons.arrow_up_circle_fill,
                        iconColor: primaryColor,
                        label: 'Total',
                        value: _stats['count'].toString(),
                        cardColor: cardColor,
                        textColor: textColor,
                        subTextColor: subTextColor,
                        shadowColor: shadowColor,
                        borderColor: borderColor,
                        isSmall: isSmall,
                      ).animate().fadeIn(delay: 120.ms).slideY(begin: 0.03),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: _buildStatCard(
                        icon: CupertinoIcons.checkmark_seal_fill,
                        iconColor: accentApproved,
                        label: 'Approved',
                        value: formatCurrency(_stats['approved']),
                        cardColor: cardColor,
                        textColor: textColor,
                        subTextColor: subTextColor,
                        shadowColor: shadowColor,
                        borderColor: borderColor,
                        isSmall: isSmall,
                      ).animate().fadeIn(delay: 140.ms).slideY(begin: 0.03),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: _buildStatCard(
                        icon: CupertinoIcons.clock_fill,
                        iconColor: accentPending,
                        label: 'Pending',
                        value: formatCurrency(_stats['pending']),
                        cardColor: cardColor,
                        textColor: textColor,
                        subTextColor: subTextColor,
                        shadowColor: shadowColor,
                        borderColor: borderColor,
                        isSmall: isSmall,
                      ).animate().fadeIn(delay: 160.ms).slideY(begin: 0.03),
                    ),
                  ],
                ),

              if (!_isLoading && _error == null) SizedBox(height: 10.h),

              // Search bar
              if (!_isLoading && _error == null)
                _buildSearchBar(cardColor, textColor, subTextColor, borderColor, isSmall)
                    .animate()
                    .fadeIn(delay: 180.ms)
                    .slideY(begin: 0.03),

              SizedBox(height: 16.h),

              // List header
              if (!_isLoading && _error == null)
                Padding(
                  padding: EdgeInsets.only(left: 4.w, bottom: 6.h),
                  child: Text(
                    'Withdraw History',
                    style: GoogleFonts.poppins(
                      fontSize: isSmall ? 14.sp : 16.sp,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                ),

              // Content
              if (_isLoading)
                ...List.generate(
                    5, (_) => _buildShimmerCard(isSmall, cardColor))
              else if (_error != null)
                _buildErrorCard(_error!, isSmall, cardColor, textColor)
              else if (_filtered.isEmpty)
                _buildEmptyCard(
                  _searchQuery.isNotEmpty
                      ? 'No results found'
                      : 'No withdrawals yet',
                  _searchQuery.isNotEmpty
                      ? 'Try a different search term'
                      : 'Your withdrawal history will appear here',
                  isSmall,
                  cardColor,
                  borderColor,
                  textColor,
                  subTextColor,
                )
              else
                ..._filtered.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final item = entry.value;
                  return _buildWithdrawCard(
                    item: item,
                    isDark: isDark,
                    cardColor: cardColor,
                    textColor: textColor,
                    subTextColor: subTextColor,
                    borderColor: borderColor,
                    shadowColor: shadowColor,
                    isSmall: isSmall,
                    delay: 200 + idx * 50,
                  );
                }),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================
  // Widgets
  // ==========================================

  Widget _buildHeader(
      Color textColor, Color subTextColor, bool isSmall, bool isDesktop) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Withdraw',
              style: GoogleFonts.poppins(
                fontSize: isSmall ? 24.sp : isDesktop ? 30.sp : 26.sp,
                fontWeight: FontWeight.w700,
                color: textColor,
                height: 1.1,
                letterSpacing: -0.5,
              ),
            ),
            Text(
              'Ledger',
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
            CupertinoIcons.arrow_up_arrow_down_circle,
            color: primaryColor,
            size: isSmall ? 16.sp : 18.sp,
          ),
        ),
      ],
    ).animate().fadeIn(delay: 40.ms);
  }

  Widget _buildSummaryCard(bool isDark, bool isSmall) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
          horizontal: isSmall ? 16.w : 20.w, vertical: isSmall ? 20.h : 24.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
              : [const Color(0xFF0F172A), const Color(0xFF1E3A5F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withOpacity(0.3),
            blurRadius: 24,
            offset: const Offset(0, 10),
            spreadRadius: -4,
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'TOTAL WITHDRAWALS',
            style: GoogleFonts.poppins(
              color: Colors.white.withOpacity(0.6),
              fontSize: isSmall ? 10.sp : 11.sp,
              fontWeight: FontWeight.w500,
              letterSpacing: 1.2,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            formatCurrency((_stats['approved'] as double) +
                (_stats['pending'] as double)),
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: isSmall ? 28.sp : 32.sp,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.0,
            ),
          ),
          SizedBox(height: 8.h),
          Container(
            padding:
                EdgeInsets.symmetric(horizontal: 12.w, vertical: 5.h),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Text(
              '${_stats['count']} withdrawal request${_stats['count'] == 1 ? '' : 's'}',
              style: GoogleFonts.poppins(
                  color: Colors.white70,
                  fontSize: isSmall ? 10.sp : 11.sp),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    required Color cardColor,
    required Color textColor,
    required Color subTextColor,
    required Color shadowColor,
    required Color borderColor,
    required bool isSmall,
  }) {
    return Container(
      padding: EdgeInsets.all(isSmall ? 10.w : 12.w),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: borderColor, width: 0.5),
        boxShadow: [
          BoxShadow(
              color: shadowColor,
              blurRadius: 16,
              offset: const Offset(0, 6),
              spreadRadius: -4)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: isSmall ? 24.w : 26.w,
                height: isSmall ? 24.w : 26.w,
                decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.r)),
                child:
                    Icon(icon, color: iconColor, size: isSmall ? 12.sp : 13.sp),
              ),
              const Spacer(),
            ],
          ),
          SizedBox(height: 6.h),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: isSmall ? 11.sp : 13.sp,
              fontWeight: FontWeight.w700,
              color: textColor,
              letterSpacing: -0.3,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 2.h),
          Text(
            label,
            style: GoogleFonts.poppins(
                fontSize: isSmall ? 8.sp : 9.sp,
                color: subTextColor,
                fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(Color cardColor, Color textColor, Color subTextColor,
      Color borderColor, bool isSmall) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: borderColor, width: 0.5),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
        decoration: InputDecoration(
          hintText: 'Search by method, account or status...',
          hintStyle: GoogleFonts.poppins(
              color: subTextColor, fontSize: isSmall ? 11.sp : 12.sp),
          prefixIcon: Icon(CupertinoIcons.search,
              color: subTextColor, size: isSmall ? 16.sp : 18.sp),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: Icon(CupertinoIcons.clear_circled_solid,
                      color: subTextColor, size: 16.sp),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
              horizontal: 16.w, vertical: isSmall ? 12.h : 14.h),
        ),
        style: GoogleFonts.poppins(
            color: textColor, fontSize: isSmall ? 12.sp : 13.sp),
      ),
    );
  }

  Widget _buildWithdrawCard({
    required WithdrawItem item,
    required bool isDark,
    required Color cardColor,
    required Color textColor,
    required Color subTextColor,
    required Color borderColor,
    required Color shadowColor,
    required bool isSmall,
    required int delay,
  }) {
    final statusColor = _statusColor(item.status);
    final isPending = item.status == 'pending';

    return GestureDetector(
      onTap: item.id != null
          ? () => Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => WithdrawDetailPage(item: item),
              ))
          : null,
      child: Container(
        padding: EdgeInsets.all(isSmall ? 12.w : 14.w),
        margin: EdgeInsets.only(bottom: 8.h),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isPending ? statusColor.withOpacity(0.4) : borderColor,
            width: isPending ? 1.5 : 0.5,
          ),
          boxShadow: [
            BoxShadow(
                color: shadowColor,
                blurRadius: 12,
                offset: const Offset(0, 4),
                spreadRadius: -2)
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Method avatar
                Container(
                  width: isSmall ? 38.w : 42.w,
                  height: isSmall ? 38.w : 42.w,
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                    border:
                        Border.all(color: statusColor.withOpacity(0.3)),
                  ),
                  child: Center(
                    child: Icon(CupertinoIcons.phone_fill,
                        color: statusColor, size: isSmall ? 16.sp : 18.sp),
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.method.toUpperCase(),
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w700,
                          fontSize: isSmall ? 13.sp : 14.sp,
                          color: textColor,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Row(
                        children: [
                          Icon(CupertinoIcons.person_circle,
                              size: 11.sp, color: subTextColor),
                          SizedBox(width: 4.w),
                          Flexible(
                            child: Text(
                              item.accountNo,
                              style: GoogleFonts.poppins(
                                  fontSize: isSmall ? 10.sp : 11.sp,
                                  color: subTextColor),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 8.w),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      formatCurrency(item.amount),
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w700,
                        fontSize: isSmall ? 14.sp : 16.sp,
                        color: statusColor,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    _buildStatusBadge(item.status, statusColor, isSmall),
                  ],
                ),
              ],
            ),

            // Account holder
            if (item.accountHolder.isNotEmpty) ...[
              SizedBox(height: 8.h),
              _buildInfoChip(
                  icon: CupertinoIcons.person,
                  label: item.accountHolder,
                  isDark: isDark,
                  textColor: textColor,
                  subTextColor: subTextColor,
                  isSmall: isSmall),
            ],

            // TRX ID
            if (item.trxId != null && item.trxId!.isNotEmpty) ...[
              SizedBox(height: 6.h),
              _buildInfoChip(
                  icon: CupertinoIcons.doc_plaintext,
                  label: 'TRX: ${item.trxId}',
                  isDark: isDark,
                  textColor: textColor,
                  subTextColor: subTextColor,
                  isSmall: isSmall),
            ],

            // Remarks
            if (item.remarks != null && item.remarks!.isNotEmpty) ...[
              SizedBox(height: 6.h),
              _buildInfoChip(
                  icon: CupertinoIcons.chat_bubble_text,
                  label: item.remarks!,
                  isDark: isDark,
                  textColor: textColor,
                  subTextColor: subTextColor,
                  isSmall: isSmall),
            ],

            SizedBox(height: 8.h),

            // Date
            Row(
              children: [
                Icon(CupertinoIcons.clock, size: 10.sp, color: subTextColor),
                SizedBox(width: 4.w),
                Text(
                  formatDate(item.createdAt),
                  style: GoogleFonts.poppins(
                      fontSize: isSmall ? 9.sp : 10.sp, color: subTextColor),
                ),
              ],
            ),
          ],
        ),
      ).animate().fadeIn(delay: Duration(milliseconds: delay)).slideY(begin: 0.02),
    );
  }

  Widget _buildStatusBadge(String status, Color color, bool isSmall) {
    return Container(
      padding:
          EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_statusIcon(status), size: 10.sp, color: color),
          SizedBox(width: 3.w),
          Text(
            _statusLabel(status),
            style: GoogleFonts.poppins(
                color: color,
                fontSize: isSmall ? 9.sp : 10.sp,
                fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required bool isDark,
    required Color textColor,
    required Color subTextColor,
    required bool isSmall,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF252525)
            : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11.sp, color: subTextColor),
          SizedBox(width: 6.w),
          Flexible(
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: isSmall ? 10.sp : 11.sp,
                fontWeight: FontWeight.w500,
                color: textColor,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerCard(bool isSmall, Color cardColor) {
    return Container(
      height: 110.h,
      margin: EdgeInsets.only(bottom: 8.h),
      decoration: BoxDecoration(
          color: cardColor, borderRadius: BorderRadius.circular(16.r)),
    )
        .animate(onPlay: (c) => c.repeat())
        .shimmer(duration: 1200.ms, color: Colors.grey.withOpacity(0.3));
  }

  Widget _buildErrorCard(
      String message, bool isSmall, Color cardColor, Color textColor) {
    return Container(
      padding: EdgeInsets.all(20.w),
      margin: EdgeInsets.only(bottom: 8.h),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.red.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(CupertinoIcons.exclamationmark_circle,
              color: Colors.red, size: isSmall ? 28.sp : 32.sp),
          SizedBox(height: 10.h),
          Text(
            message,
            style: GoogleFonts.poppins(
                fontSize: isSmall ? 11.sp : 12.sp, color: Colors.red),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 12.h),
          GestureDetector(
            onTap: _fetchWithdraws,
            child: Container(
              padding:
                  EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
              decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(10.r)),
              child: Text(
                'Try Again',
                style: GoogleFonts.poppins(
                    color: Colors.white, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCard(
    String title,
    String subtitle,
    bool isSmall,
    Color cardColor,
    Color borderColor,
    Color textColor,
    Color subTextColor,
  ) {
    return Container(
      padding: EdgeInsets.all(32.w),
      margin: EdgeInsets.only(bottom: 8.h),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: borderColor, width: 0.5),
      ),
      child: Column(
        children: [
          Icon(CupertinoIcons.tray,
              color: subTextColor, size: isSmall ? 36.sp : 42.sp),
          SizedBox(height: 10.h),
          Text(
            title,
            style: GoogleFonts.poppins(
                fontSize: isSmall ? 13.sp : 14.sp,
                fontWeight: FontWeight.w600,
                color: textColor),
          ),
          SizedBox(height: 4.h),
          Text(
            subtitle,
            style: GoogleFonts.poppins(
                fontSize: isSmall ? 11.sp : 12.sp, color: subTextColor),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ==========================================
// 5. WithdrawDetailPage
// ==========================================

class WithdrawDetailPage extends StatelessWidget {
  final WithdrawItem item;

  const WithdrawDetailPage({super.key, required this.item});

  Color _statusColor(String status) {
    switch (status) {
      case 'approved':
        return const Color(0xFF22C55E);
      case 'rejected':
        return const Color(0xFFEF4444);
      default:
        return const Color(0xFFF59E0B);
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'approved':
        return CupertinoIcons.checkmark_seal_fill;
      case 'rejected':
        return CupertinoIcons.xmark_circle_fill;
      default:
        return CupertinoIcons.clock_fill;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'approved':
        return 'Approved';
      case 'rejected':
        return 'Rejected';
      default:
        return 'Pending';
    }
  }

  void _copy(BuildContext context, String? text) {
    if (text == null || text.isEmpty) return;
    Clipboard.setData(ClipboardData(text: text));
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Copied to clipboard',
            style: GoogleFonts.poppins(fontSize: 13)),
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor =
        isDark ? const Color(0xFF000000) : const Color(0xFFF2F2F7);
    final cardColor = isDark ? const Color(0xFF1C1C1E) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF000000);
    final subTextColor =
        isDark ? const Color(0xFF8E8E93) : const Color(0xFF8E8E93);
    final borderColor =
        isDark ? const Color(0xFF2C2C2E) : const Color(0xFFE5E5EA);

    final statusColor = _statusColor(item.status);
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmall = screenWidth < 360;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: cardColor,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(CupertinoIcons.chevron_left,
              color: textColor, size: 20.sp),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Withdraw Detail',
          style: GoogleFonts.poppins(
              color: textColor,
              fontWeight: FontWeight.w700,
              fontSize: 17.sp),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status hero
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(24.w),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    statusColor.withOpacity(isDark ? 0.25 : 0.12),
                    statusColor.withOpacity(isDark ? 0.08 : 0.04),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20.r),
                border:
                    Border.all(color: statusColor.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  Icon(_statusIcon(item.status),
                      color: statusColor, size: 48.sp),
                  SizedBox(height: 10.h),
                  Text(
                    formatCurrency(item.amount),
                    style: GoogleFonts.poppins(
                        fontSize: 30.sp,
                        fontWeight: FontWeight.w700,
                        color: statusColor),
                  ),
                  SizedBox(height: 6.h),
                  Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: 14.w, vertical: 5.h),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Text(
                      _statusLabel(item.status),
                      style: GoogleFonts.poppins(
                          color: statusColor,
                          fontWeight: FontWeight.w700,
                          fontSize: isSmall ? 12.sp : 13.sp),
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn().slideY(begin: 0.03),

            SizedBox(height: 16.h),

            // Payment Info section
            _buildSection(
              title: 'Payment Info',
              icon: CupertinoIcons.creditcard,
              isDark: isDark,
              cardColor: cardColor,
              borderColor: borderColor,
              textColor: textColor,
              child: Column(
                children: [
                  _buildRow(
                    context: context,
                    icon: CupertinoIcons.phone,
                    label: 'Method',
                    value: item.method.toUpperCase(),
                    isDark: isDark,
                    textColor: textColor,
                    subTextColor: subTextColor,
                    isSmall: isSmall,
                  ),
                  _buildDivider(isDark),
                  _buildRow(
                    context: context,
                    icon: CupertinoIcons.person_circle,
                    label: 'Account Number',
                    value: item.accountNo,
                    isDark: isDark,
                    textColor: textColor,
                    subTextColor: subTextColor,
                    isSmall: isSmall,
                    onCopy: () => _copy(context, item.accountNo),
                  ),
                  if (item.accountHolder.isNotEmpty) ...[
                    _buildDivider(isDark),
                    _buildRow(
                      context: context,
                      icon: CupertinoIcons.person,
                      label: 'Account Holder',
                      value: item.accountHolder,
                      isDark: isDark,
                      textColor: textColor,
                      subTextColor: subTextColor,
                      isSmall: isSmall,
                    ),
                  ],
                  _buildDivider(isDark),
                  _buildRow(
                    context: context,
                    icon: CupertinoIcons.money_dollar_circle,
                    label: 'Amount',
                    value: formatCurrency(item.amount),
                    isDark: isDark,
                    textColor: textColor,
                    subTextColor: subTextColor,
                    isSmall: isSmall,
                    valueColor: statusColor,
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 80.ms).slideY(begin: 0.03),

            SizedBox(height: 14.h),

            // Timeline section
            _buildSection(
              title: 'Timeline',
              icon: CupertinoIcons.time,
              isDark: isDark,
              cardColor: cardColor,
              borderColor: borderColor,
              textColor: textColor,
              child: Column(
                children: [
                  _buildRow(
                    context: context,
                    icon: CupertinoIcons.add_circled,
                    label: 'Requested At',
                    value: formatDate(item.createdAt),
                    isDark: isDark,
                    textColor: textColor,
                    subTextColor: subTextColor,
                    isSmall: isSmall,
                  ),
                  if (item.updatedAt != null) ...[
                    _buildDivider(isDark),
                    _buildRow(
                      context: context,
                      icon: item.status == 'approved'
                          ? CupertinoIcons.checkmark_circle
                          : CupertinoIcons.xmark_circle,
                      label: item.status == 'approved'
                          ? 'Approved At'
                          : 'Rejected At',
                      value: formatDate(item.updatedAt),
                      isDark: isDark,
                      textColor: textColor,
                      subTextColor: subTextColor,
                      isSmall: isSmall,
                      valueColor: statusColor,
                    ),
                  ],
                  if (item.trxId != null && item.trxId!.isNotEmpty) ...[
                    _buildDivider(isDark),
                    _buildRow(
                      context: context,
                      icon: CupertinoIcons.doc_plaintext,
                      label: 'TRX ID',
                      value: item.trxId!,
                      isDark: isDark,
                      textColor: textColor,
                      subTextColor: subTextColor,
                      isSmall: isSmall,
                      onCopy: () => _copy(context, item.trxId),
                    ),
                  ],
                  if (item.remarks != null && item.remarks!.isNotEmpty) ...[
                    _buildDivider(isDark),
                    _buildRow(
                      context: context,
                      icon: CupertinoIcons.chat_bubble_text,
                      label: 'Remarks',
                      value: item.remarks!,
                      isDark: isDark,
                      textColor: textColor,
                      subTextColor: subTextColor,
                      isSmall: isSmall,
                    ),
                  ],
                ],
              ),
            ).animate().fadeIn(delay: 140.ms).slideY(begin: 0.03),

            SizedBox(height: 32.h),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required bool isDark,
    required Color cardColor,
    required Color borderColor,
    required Color textColor,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 10.h),
            child: Row(
              children: [
                Icon(icon, size: 17, color: const Color(0xFF0EA5E9)),
                SizedBox(width: 8.w),
                Text(
                  title,
                  style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: textColor),
                ),
              ],
            ),
          ),
          Divider(
              height: 1,
              color: isDark
                  ? const Color(0xFF2A2A2A)
                  : Colors.grey.shade100),
          Padding(padding: EdgeInsets.all(16.w), child: child),
        ],
      ),
    );
  }

  Widget _buildRow({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String value,
    required bool isDark,
    required Color textColor,
    required Color subTextColor,
    required bool isSmall,
    Color? valueColor,
    VoidCallback? onCopy,
  }) {
    return Row(
      children: [
        Icon(icon, size: 17, color: subTextColor),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: GoogleFonts.poppins(
                      fontSize: isSmall ? 10 : 11, color: subTextColor)),
              SizedBox(height: 2.h),
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: isSmall ? 13 : 14,
                  fontWeight: FontWeight.w600,
                  color: valueColor ?? textColor,
                ),
              ),
            ],
          ),
        ),
        if (onCopy != null)
          IconButton(
            onPressed: onCopy,
            icon: Icon(CupertinoIcons.doc_on_clipboard,
                size: 16, color: subTextColor),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
      ],
    );
  }

  Widget _buildDivider(bool isDark) => Divider(
        height: 16,
        color: isDark
            ? const Color(0xFF2A2A2A)
            : Colors.grey.shade100,
      );
}
