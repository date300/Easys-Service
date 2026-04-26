import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';

// ==========================================
// 1. Demo Data Models
// ==========================================

class VoucherBalance {
  final double totalBalance;
  final double usedBalance;
  final double availableBalance;
  final List<VoucherTransaction> transactions;

  VoucherBalance({
    required this.totalBalance,
    required this.usedBalance,
    required this.availableBalance,
    required this.transactions,
  });
}

class VoucherTransaction {
  final String id;
  final String description;
  final double amount;
  final String type;   // 'credit' | 'debit'
  final String date;
  final String status; // 'completed' | 'pending' | 'failed'

  VoucherTransaction({
    required this.id,
    required this.description,
    required this.amount,
    required this.type,
    required this.date,
    required this.status,
  });
}

// Demo Data
final VoucherBalance demoVoucherBalance = VoucherBalance(
  totalBalance: 5000.00,
  usedBalance: 1850.00,
  availableBalance: 3150.00,
  transactions: [
    VoucherTransaction(
      id: '1',
      description: 'Referral Bonus',
      amount: 500.00,
      type: 'credit',
      date: '26 Apr 2026, 10:30 AM',
      status: 'completed',
    ),
    VoucherTransaction(
      id: '2',
      description: 'Voucher Redeemed',
      amount: 250.00,
      type: 'debit',
      date: '25 Apr 2026, 03:15 PM',
      status: 'completed',
    ),
    VoucherTransaction(
      id: '3',
      description: 'Daily Login Reward',
      amount: 50.00,
      type: 'credit',
      date: '25 Apr 2026, 09:00 AM',
      status: 'completed',
    ),
    VoucherTransaction(
      id: '4',
      description: 'Withdrawal Request',
      amount: 1000.00,
      type: 'debit',
      date: '24 Apr 2026, 06:45 PM',
      status: 'pending',
    ),
    VoucherTransaction(
      id: '5',
      description: 'Team Bonus Reward',
      amount: 750.00,
      type: 'credit',
      date: '23 Apr 2026, 11:20 AM',
      status: 'completed',
    ),
    VoucherTransaction(
      id: '6',
      description: 'Purchase Voucher',
      amount: 200.00,
      type: 'debit',
      date: '22 Apr 2026, 02:10 PM',
      status: 'failed',
    ),
    VoucherTransaction(
      id: '7',
      description: 'Royalty Salary',
      amount: 1200.00,
      type: 'credit',
      date: '21 Apr 2026, 08:00 AM',
      status: 'completed',
    ),
    VoucherTransaction(
      id: '8',
      description: 'Special Event Bonus',
      amount: 400.00,
      type: 'credit',
      date: '20 Apr 2026, 05:30 PM',
      status: 'pending',
    ),
    VoucherTransaction(
      id: '9',
      description: 'Voucher Used at Shop',
      amount: 400.00,
      type: 'debit',
      date: '19 Apr 2026, 01:00 PM',
      status: 'completed',
    ),
    VoucherTransaction(
      id: '10',
      description: 'Welcome Bonus',
      amount: 300.00,
      type: 'credit',
      date: '18 Apr 2026, 10:00 AM',
      status: 'completed',
    ),
  ],
);

// ==========================================
// 2. VoucherBalancePage (Design Matched)
// ==========================================

class VoucherBalancePage extends StatefulWidget {
  const VoucherBalancePage({super.key});

  @override
  State<VoucherBalancePage> createState() => _VoucherBalancePageState();
}

class _VoucherBalancePageState extends State<VoucherBalancePage> {
  static const Color skyBlue = Color(0xFF29B6F6);
  String _selectedFilter = 'All';
  final List<String> _filters = ['All', 'Credit', 'Debit', 'Pending'];

  List<VoucherTransaction> _getFiltered(List<VoucherTransaction> all) {
    switch (_selectedFilter) {
      case 'Credit':
        return all.where((t) => t.type == 'credit').toList();
      case 'Debit':
        return all.where((t) => t.type == 'debit').toList();
      case 'Pending':
        return all.where((t) => t.status == 'pending').toList();
      default:
        return all;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF121212) : const Color(0xFFF8FAFC);
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final subTextColor = isDark ? Colors.grey.shade400 : const Color(0xFF475569);
    final borderColor = isDark ? const Color(0xFF333333) : Colors.grey.withOpacity(0.1);
    final shadowColor = isDark ? Colors.black.withOpacity(0.3) : Colors.black.withOpacity(0.04);

    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 1024;
    final isTablet = screenWidth >= 600 && screenWidth < 1024;
    final isSmall = screenWidth < 360;
    final hPadding = isDesktop ? 32.w : isTablet ? 20.w : isSmall ? 12.w : 16.w;

    final voucher = demoVoucherBalance;
    final filtered = _getFiltered(voucher.transactions);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          color: skyBlue,
          backgroundColor: cardColor,
          onRefresh: () async {
            HapticFeedback.mediumImpact();
            await Future.delayed(const Duration(seconds: 1));
          },
          child: ListView(
            padding: EdgeInsets.fromLTRB(hPadding, 16.h, hPadding, 30.h),
            physics: const BouncingScrollPhysics(),
            children: [
              // Header
              _buildHeader(textColor, subTextColor, isSmall, isDesktop),
              SizedBox(height: 20.h),

              // Balance Card
              _buildBalanceCard(voucher, isSmall).animate().fadeIn(delay: 100.ms).slideY(begin: 0.05),
              SizedBox(height: 16.h),

              // Stats Row
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      icon: CupertinoIcons.add_circled,
                      iconColor: const Color(0xFF34C759),
                      label: 'Total Earned',
                      amount: '৳${voucher.totalBalance.toStringAsFixed(2)}',
                      cardColor: cardColor,
                      textColor: textColor,
                      subTextColor: subTextColor,
                      shadowColor: shadowColor,
                      borderColor: borderColor,
                      isSmall: isSmall,
                      isDesktop: isDesktop,
                    ).animate().fadeIn(delay: 150.ms).slideY(begin: 0.05),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: _buildStatCard(
                      icon: CupertinoIcons.minus_circled,
                      iconColor: const Color(0xFFFF9500),
                      label: 'Total Used',
                      amount: '৳${voucher.usedBalance.toStringAsFixed(2)}',
                      cardColor: cardColor,
                      textColor: textColor,
                      subTextColor: subTextColor,
                      shadowColor: shadowColor,
                      borderColor: borderColor,
                      isSmall: isSmall,
                      isDesktop: isDesktop,
                    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.05),
                  ),
                ],
              ),
              SizedBox(height: 24.h),

              // Transaction Header
              _buildSectionHeader(textColor, subTextColor, filtered.length, isSmall, isDesktop),
              SizedBox(height: 12.h),

              // Filter Chips
              _buildFilterChips(isDark, subTextColor, borderColor).animate().fadeIn(delay: 250.ms),
              SizedBox(height: 14.h),

              // Transaction List
              if (filtered.isEmpty)
                _buildEmptyState(subTextColor)
              else
                ...filtered.asMap().entries.map(
                  (e) => _buildTransactionCard(
                    e.value,
                    isDark,
                    cardColor,
                    textColor,
                    subTextColor,
                    shadowColor,
                    borderColor,
                    isSmall,
                  ).animate().fadeIn(delay: (e.key * 50).ms, duration: 300.ms).slideY(begin: 0.06, curve: Curves.easeOut),
                ),
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
              'Voucher Balance',
              style: GoogleFonts.poppins(
                fontSize: isSmall ? 18.sp : isDesktop ? 24.sp : 22.sp,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              'Track your voucher earnings & usage',
              style: GoogleFonts.poppins(
                fontSize: isSmall ? 10.sp : isDesktop ? 13.sp : 12.sp,
                color: subTextColor,
              ),
            ),
          ],
        ),
        GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
          },
          child: Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: const Color(0xFF29B6F6).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              CupertinoIcons.question_circle,
              color: const Color(0xFF29B6F6),
              size: isSmall ? 18.sp : 22.sp,
            ),
          ),
        ),
      ],
    ).animate().fadeIn(delay: 50.ms);
  }

  // ==================== BALANCE CARD ====================
  Widget _buildBalanceCard(VoucherBalance voucher, bool isSmall) {
    final usedPercent = voucher.totalBalance > 0
        ? (voucher.usedBalance / voucher.totalBalance).clamp(0.0, 1.0)
        : 0.0;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isSmall ? 20.w : 24.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF29B6F6), Color(0xFF0284C7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF29B6F6).withOpacity(0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Available Balance',
                style: GoogleFonts.poppins(
                  color: Colors.white70,
                  fontSize: isSmall ? 11.sp : 13.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(CupertinoIcons.gift_fill, color: Colors.white, size: isSmall ? 12.sp : 14.sp),
                    SizedBox(width: 4.w),
                    Text(
                      'Voucher',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: isSmall ? 10.sp : 11.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '৳',
                style: GoogleFonts.poppins(
                  color: Colors.white70,
                  fontSize: isSmall ? 18.sp : 22.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(width: 4.w),
              Text(
                voucher.availableBalance.toStringAsFixed(2),
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: isSmall ? 32.sp : 38.sp,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -1,
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Used: ৳${voucher.usedBalance.toStringAsFixed(2)}',
                style: GoogleFonts.poppins(
                  color: Colors.white70,
                  fontSize: isSmall ? 10.sp : 11.sp,
                ),
              ),
              Text(
                'Total: ৳${voucher.totalBalance.toStringAsFixed(2)}',
                style: GoogleFonts.poppins(
                  color: Colors.white70,
                  fontSize: isSmall ? 10.sp : 11.sp,
                ),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(10.r),
            child: LinearProgressIndicator(
              value: usedPercent,
              backgroundColor: Colors.white.withOpacity(0.25),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              minHeight: 7.h,
            ),
          ),
          SizedBox(height: 16.h),
          GestureDetector(
            onTap: () {
              HapticFeedback.mediumImpact();
              Clipboard.setData(ClipboardData(
                  text: voucher.availableBalance.toStringAsFixed(2)));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Balance copied!', style: GoogleFonts.poppins(fontSize: 13.sp)),
                  backgroundColor: const Color(0xFF0288D1),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                  duration: const Duration(seconds: 2),
                  margin: EdgeInsets.all(16.w),
                ),
              );
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: Colors.white.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(CupertinoIcons.doc_on_doc, color: Colors.white, size: isSmall ? 12.sp : 14.sp),
                  SizedBox(width: 6.w),
                  Text(
                    'Copy Balance',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: isSmall ? 11.sp : 12.sp,
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
      padding: EdgeInsets.all(isSmall ? 14.w : 16.w),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: borderColor, width: 0.5),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: isSmall ? 34.w : (isDesktop ? 42.w : 38.w),
            height: isSmall ? 34.w : (isDesktop ? 42.w : 38.w),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(icon, color: iconColor, size: isSmall ? 18.sp : (isDesktop ? 22.sp : 20.sp)),
          ),
          SizedBox(height: 10.h),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: isSmall ? 10.sp : 11.sp,
              color: subTextColor,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            amount,
            style: GoogleFonts.poppins(
              fontSize: isSmall ? 14.sp : 16.sp,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  // ==================== SECTION HEADER ====================
  Widget _buildSectionHeader(Color textColor, Color subTextColor, int count, bool isSmall, bool isDesktop) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Transactions',
              style: GoogleFonts.poppins(
                fontSize: isSmall ? 14.sp : (isDesktop ? 18.sp : 16.sp),
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            Text(
              'Recent voucher activity',
              style: GoogleFonts.poppins(
                fontSize: isSmall ? 10.sp : (isDesktop ? 12.sp : 11.sp),
                color: subTextColor,
              ),
            ),
          ],
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: const Color(0xFF29B6F6).withOpacity(0.08),
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(color: const Color(0xFF29B6F6).withOpacity(0.2)),
          ),
          child: Text(
            '$count records',
            style: GoogleFonts.poppins(
              fontSize: isSmall ? 10.sp : 11.sp,
              color: const Color(0xFF29B6F6),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    ).animate().fadeIn(duration: 400.ms);
  }

  // ==================== FILTER CHIPS ====================
  Widget _buildFilterChips(bool isDark, Color subTextColor, Color borderColor) {
    return SizedBox(
      height: 36.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: _filters.length,
        separatorBuilder: (_, __) => SizedBox(width: 8.w),
        itemBuilder: (context, i) {
          final f = _filters[i];
          final selected = _selectedFilter == f;
          return GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() => _selectedFilter = f);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 7.h),
              decoration: BoxDecoration(
                color: selected
                    ? skyBlue
                    : (isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF1F5F9)),
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(
                  color: selected ? skyBlue : borderColor,
                  width: selected ? 1.5 : 0.5,
                ),
              ),
              child: Text(
                f,
                style: GoogleFonts.poppins(
                  fontSize: 12.sp,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                  color: selected ? Colors.white : subTextColor,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ==================== TRANSACTION CARD ====================
  Widget _buildTransactionCard(
    VoucherTransaction tx,
    bool isDark,
    Color cardColor,
    Color textColor,
    Color subTextColor,
    Color shadowColor,
    Color borderColor,
    bool isSmall,
  ) {
    final isCredit = tx.type == 'credit';
    final amountColor = isCredit ? const Color(0xFF34C759) : const Color(0xFFFF9500);
    final iconData = isCredit ? CupertinoIcons.arrow_down : CupertinoIcons.arrow_up;
    final amountPrefix = isCredit ? '+' : '-';

    Color statusColor;
    String statusLabel;
    switch (tx.status) {
      case 'completed':
        statusColor = const Color(0xFF34C759);
        statusLabel = 'Completed';
        break;
      case 'pending':
        statusColor = const Color(0xFFFF9500);
        statusLabel = 'Pending';
        break;
      case 'failed':
        statusColor = const Color(0xFFFF3B30);
        statusLabel = 'Failed';
        break;
      default:
        statusColor = Colors.grey;
        statusLabel = tx.status;
    }

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(isSmall ? 14.w : 16.w),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: borderColor, width: 0.5),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: isSmall ? 42.w : 46.w,
            height: isSmall ? 42.w : 46.w,
            decoration: BoxDecoration(
              color: amountColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(13.r),
            ),
            child: Icon(iconData, color: amountColor, size: isSmall ? 20.sp : 22.sp),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tx.description,
                  style: GoogleFonts.poppins(
                    fontSize: isSmall ? 12.sp : 13.sp,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Icon(CupertinoIcons.clock, size: 11.sp, color: subTextColor),
                    SizedBox(width: 4.w),
                    Text(
                      tx.date,
                      style: GoogleFonts.poppins(
                        fontSize: 11.sp,
                        color: subTextColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$amountPrefix৳${tx.amount.toStringAsFixed(2)}',
                style: GoogleFonts.poppins(
                  fontSize: isSmall ? 13.sp : 14.sp,
                  fontWeight: FontWeight.bold,
                  color: amountColor,
                ),
              ),
              SizedBox(height: 4.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  statusLabel,
                  style: GoogleFonts.poppins(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==================== EMPTY STATE ====================
  Widget _buildEmptyState(Color subTextColor) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 40.h),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(24.w),
              decoration: BoxDecoration(
                color: const Color(0xFF29B6F6).withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                CupertinoIcons.doc_text,
                size: 44.sp,
                color: const Color(0xFF29B6F6),
              ),
            ).animate().scale(duration: 500.ms, curve: Curves.elasticOut),
            SizedBox(height: 14.h),
            Text(
              'No transactions found',
              style: GoogleFonts.poppins(
                color: subTextColor,
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
