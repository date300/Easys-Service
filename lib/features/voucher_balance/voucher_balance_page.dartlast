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
  final String type;
  final String date;
  final String status;

  VoucherTransaction({
    required this.id,
    required this.description,
    required this.amount,
    required this.type,
    required this.date,
    required this.status,
  });
}

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
      date: '26 Apr, 10:30 AM',
      status: 'completed',
    ),
    VoucherTransaction(
      id: '2',
      description: 'Voucher Redeemed',
      amount: 250.00,
      type: 'debit',
      date: '25 Apr, 03:15 PM',
      status: 'completed',
    ),
    VoucherTransaction(
      id: '3',
      description: 'Daily Login Reward',
      amount: 50.00,
      type: 'credit',
      date: '25 Apr, 09:00 AM',
      status: 'completed',
    ),
    VoucherTransaction(
      id: '4',
      description: 'Withdrawal Request',
      amount: 1000.00,
      type: 'debit',
      date: '24 Apr, 06:45 PM',
      status: 'pending',
    ),
    VoucherTransaction(
      id: '5',
      description: 'Team Bonus Reward',
      amount: 750.00,
      type: 'credit',
      date: '23 Apr, 11:20 AM',
      status: 'completed',
    ),
    VoucherTransaction(
      id: '6',
      description: 'Purchase Voucher',
      amount: 200.00,
      type: 'debit',
      date: '22 Apr, 02:10 PM',
      status: 'failed',
    ),
    VoucherTransaction(
      id: '7',
      description: 'Royalty Salary',
      amount: 1200.00,
      type: 'credit',
      date: '21 Apr, 08:00 AM',
      status: 'completed',
    ),
    VoucherTransaction(
      id: '8',
      description: 'Special Event Bonus',
      amount: 400.00,
      type: 'credit',
      date: '20 Apr, 05:30 PM',
      status: 'pending',
    ),
    VoucherTransaction(
      id: '9',
      description: 'Voucher Used at Shop',
      amount: 400.00,
      type: 'debit',
      date: '19 Apr, 01:00 PM',
      status: 'completed',
    ),
    VoucherTransaction(
      id: '10',
      description: 'Welcome Bonus',
      amount: 300.00,
      type: 'credit',
      date: '18 Apr, 10:00 AM',
      status: 'completed',
    ),
  ],
);

// ==========================================
// 2. VoucherBalancePage — Ultra Premium iOS
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

  void _goToPayment() {
    HapticFeedback.mediumImpact();
    Navigator.pushNamed(context, '/payment');
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
    final separatorColor = isDark ? const Color(0xFF2C2C2E) : const Color(0xFFE5E5EA);

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
            padding: EdgeInsets.fromLTRB(hPadding, 8.h, hPadding, 40.h),
            physics: const BouncingScrollPhysics(),
            children: [
              // Compact iOS Header
              _buildHeader(textColor, subTextColor, isSmall, isDesktop),
              SizedBox(height: 14.h),

              // Premium Balance Card — compact
              _buildBalanceCard(voucher, isSmall).animate().fadeIn(delay: 80.ms).slideY(begin: 0.03),
              SizedBox(height: 10.h),

              // Deposit Card — ultra compact
              _buildDepositCard(isSmall, isDesktop, cardColor, shadowColor, borderColor, textColor, subTextColor)
                  .animate().fadeIn(delay: 120.ms).slideY(begin: 0.03),
              SizedBox(height: 10.h),

              // Compact Stats Row
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      icon: CupertinoIcons.arrow_down_circle_fill,
                      iconColor: const Color(0xFF34C759),
                      label: 'Earned',
                      amount: '\u09F3${voucher.totalBalance.toStringAsFixed(0)}',
                      cardColor: cardColor,
                      textColor: textColor,
                      subTextColor: subTextColor,
                      shadowColor: shadowColor,
                      borderColor: borderColor,
                      isSmall: isSmall,
                      isDesktop: isDesktop,
                    ).animate().fadeIn(delay: 160.ms).slideY(begin: 0.03),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: _buildStatCard(
                      icon: CupertinoIcons.arrow_up_circle_fill,
                      iconColor: const Color(0xFFFF9500),
                      label: 'Used',
                      amount: '\u09F3${voucher.usedBalance.toStringAsFixed(0)}',
                      cardColor: cardColor,
                      textColor: textColor,
                      subTextColor: subTextColor,
                      shadowColor: shadowColor,
                      borderColor: borderColor,
                      isSmall: isSmall,
                      isDesktop: isDesktop,
                    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.03),
                  ),
                ],
              ),
              SizedBox(height: 18.h),

              // Section Header — compact
              _buildSectionHeader(textColor, subTextColor, filtered.length, isSmall, isDesktop),
              SizedBox(height: 8.h),

              // Filter Chips — compact
              _buildFilterChips(isDark, subTextColor, borderColor).animate().fadeIn(delay: 240.ms),
              SizedBox(height: 10.h),

              // iOS Grouped List Style Transactions
              if (filtered.isEmpty)
                _buildEmptyState(subTextColor)
              else
                _buildGroupedTransactions(
                  filtered,
                  isDark,
                  cardColor,
                  textColor,
                  subTextColor,
                  shadowColor,
                  borderColor,
                  separatorColor,
                  isSmall,
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ==================== COMPACT iOS HEADER ====================
  Widget _buildHeader(Color textColor, Color subTextColor, bool isSmall, bool isDesktop) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Voucher',
              style: GoogleFonts.poppins(
                fontSize: isSmall ? 24.sp : isDesktop ? 30.sp : 26.sp,
                fontWeight: FontWeight.w700,
                color: textColor,
                height: 1.1,
                letterSpacing: -0.5,
              ),
            ),
            Text(
              'Balance',
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
        GestureDetector(
          onTap: () => HapticFeedback.lightImpact(),
          child: Container(
            width: 32.w,
            height: 32.w,
            decoration: BoxDecoration(
              color: isSmall ? const Color(0xFF29B6F6).withOpacity(0.08) : const Color(0xFF29B6F6).withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(
              CupertinoIcons.question_circle,
              color: const Color(0xFF29B6F6),
              size: isSmall ? 16.sp : 18.sp,
            ),
          ),
        ),
      ],
    ).animate().fadeIn(delay: 40.ms);
  }

  // ==================== PREMIUM COMPACT BALANCE CARD ====================
  Widget _buildBalanceCard(VoucherBalance voucher, bool isSmall) {
    final usedPercent = voucher.totalBalance > 0
        ? (voucher.usedBalance / voucher.totalBalance).clamp(0.0, 1.0)
        : 0.0;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: isSmall ? 16.w : 20.w, vertical: isSmall ? 16.h : 18.h),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF29B6F6), Color(0xFF0284C7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF29B6F6).withOpacity(0.25),
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
                  Icon(CupertinoIcons.gift_fill, color: Colors.white.withOpacity(0.7), size: isSmall ? 11.sp : 12.sp),
                  SizedBox(width: 5.w),
                  Text(
                    'Available',
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
                  'Voucher',
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
                voucher.availableBalance.toStringAsFixed(2),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Used \u09F3${voucher.usedBalance.toStringAsFixed(0)}',
                style: GoogleFonts.poppins(
                  color: Colors.white.withOpacity(0.55),
                  fontSize: isSmall ? 9.sp : 10.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                'Total \u09F3${voucher.totalBalance.toStringAsFixed(0)}',
                style: GoogleFonts.poppins(
                  color: Colors.white.withOpacity(0.55),
                  fontSize: isSmall ? 9.sp : 10.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          SizedBox(height: 5.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(8.r),
            child: LinearProgressIndicator(
              value: usedPercent,
              backgroundColor: Colors.white.withOpacity(0.18),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              minHeight: 4.h,
            ),
          ),
          SizedBox(height: 12.h),
          GestureDetector(
            onTap: () {
              HapticFeedback.mediumImpact();
              Clipboard.setData(ClipboardData(
                  text: voucher.availableBalance.toStringAsFixed(2)));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Balance copied', style: GoogleFonts.poppins(fontSize: 12.sp)),
                  backgroundColor: const Color(0xFF0288D1),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                  duration: const Duration(seconds: 2),
                  margin: EdgeInsets.all(16.w),
                ),
              );
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
                  Icon(CupertinoIcons.doc_on_doc, color: Colors.white.withOpacity(0.8), size: isSmall ? 10.sp : 11.sp),
                  SizedBox(width: 5.w),
                  Text(
                    'Copy',
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

  // ==================== ULTRA COMPACT DEPOSIT CARD ====================
  Widget _buildDepositCard(
    bool isSmall,
    bool isDesktop,
    Color cardColor,
    Color shadowColor,
    Color borderColor,
    Color textColor,
    Color subTextColor,
  ) {
    return GestureDetector(
      onTap: _goToPayment,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: isSmall ? 14.w : 16.w, vertical: isSmall ? 10.h : 12.h),
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
                  colors: [Color(0xFF29B6F6), Color(0xFF0284C7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(10.r),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF29B6F6).withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  CupertinoIcons.plus,
                  color: Colors.white,
                  size: isSmall ? 16.sp : 18.sp,
                ),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Deposit Voucher Balance',
                    style: GoogleFonts.poppins(
                      fontSize: isSmall ? 12.sp : 13.sp,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                      letterSpacing: -0.2,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    'Add funds instantly',
                    style: GoogleFonts.poppins(
                      fontSize: isSmall ? 9.sp : 10.sp,
                      color: subTextColor,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              CupertinoIcons.chevron_right,
              color: subTextColor.withOpacity(0.5),
              size: isSmall ? 12.sp : 14.sp,
            ),
          ],
        ),
      ),
    );
  }

  // ==================== COMPACT STAT CARD ====================
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
                child: Icon(icon, color: iconColor, size: isSmall ? 14.sp : 15.sp),
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

  // ==================== COMPACT SECTION HEADER ====================
  Widget _buildSectionHeader(Color textColor, Color subTextColor, int count, bool isSmall, bool isDesktop) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'Transactions',
          style: GoogleFonts.poppins(
            fontSize: isSmall ? 16.sp : (isDesktop ? 20.sp : 18.sp),
            fontWeight: FontWeight.w700,
            color: textColor,
            letterSpacing: -0.4,
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
          decoration: BoxDecoration(
            color: const Color(0xFF29B6F6).withOpacity(0.08),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Text(
            '$count',
            style: GoogleFonts.poppins(
              fontSize: isSmall ? 10.sp : 11.sp,
              color: const Color(0xFF29B6F6),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    ).animate().fadeIn(duration: 300.ms);
  }

  // ==================== COMPACT FILTER CHIPS ====================
  Widget _buildFilterChips(bool isDark, Color subTextColor, Color borderColor) {
    return SizedBox(
      height: 30.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: _filters.length,
        separatorBuilder: (_, __) => SizedBox(width: 6.w),
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
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 5.h),
              decoration: BoxDecoration(
                color: selected
                    ? skyBlue
                    : (isDark ? const Color(0xFF2C2C2E) : const Color(0xFFE5E5EA)),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Text(
                f,
                style: GoogleFonts.poppins(
                  fontSize: 11.sp,
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

  // ==================== iOS GROUPED LIST TRANSACTIONS ====================
  Widget _buildGroupedTransactions(
    List<VoucherTransaction> transactions,
    bool isDark,
    Color cardColor,
    Color textColor,
    Color subTextColor,
    Color shadowColor,
    Color borderColor,
    Color separatorColor,
    bool isSmall,
  ) {
    return Container(
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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.r),
        child: Column(
          children: transactions.asMap().entries.map((entry) {
            final tx = entry.value;
            final isLast = entry.key == transactions.length - 1;
            return _buildCompactTransactionRow(
              tx,
              textColor,
              subTextColor,
              separatorColor,
              isLast,
              isSmall,
            ).animate().fadeIn(delay: (entry.key * 40).ms, duration: 250.ms).slideY(begin: 0.04, curve: Curves.easeOut);
          }).toList(),
        ),
      ),
    );
  }

  // ==================== COMPACT iOS ROW ====================
  Widget _buildCompactTransactionRow(
    VoucherTransaction tx,
    Color textColor,
    Color subTextColor,
    Color separatorColor,
    bool isLast,
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
        statusLabel = 'Done';
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

    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: isSmall ? 12.w : 14.w, vertical: isSmall ? 10.h : 11.h),
          child: Row(
            children: [
              Container(
                width: isSmall ? 32.w : 34.w,
                height: isSmall ? 32.w : 34.w,
                decoration: BoxDecoration(
                  color: amountColor.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(9.r),
                ),
                child: Icon(iconData, color: amountColor, size: isSmall ? 14.sp : 15.sp),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tx.description,
                      style: GoogleFonts.poppins(
                        fontSize: isSmall ? 11.sp : 12.sp,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                        letterSpacing: -0.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 1.h),
                    Text(
                      tx.date,
                      style: GoogleFonts.poppins(
                        fontSize: isSmall ? 9.sp : 10.sp,
                        color: subTextColor,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '$amountPrefix\u09F3${tx.amount.toStringAsFixed(0)}',
                    style: GoogleFonts.poppins(
                      fontSize: isSmall ? 12.sp : 13.sp,
                      fontWeight: FontWeight.w700,
                      color: amountColor,
                      letterSpacing: -0.3,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.5.h),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    child: Text(
                      statusLabel,
                      style: GoogleFonts.poppins(
                        fontSize: isSmall ? 8.sp : 9.sp,
                        fontWeight: FontWeight.w600,
                        color: statusColor,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (!isLast)
          Padding(
            padding: EdgeInsets.only(left: isSmall ? 54.w : 58.w),
            child: Divider(color: separatorColor, height: 0.5, thickness: 0.5),
          ),
      ],
    );
  }

  // ==================== COMPACT EMPTY STATE ====================
  Widget _buildEmptyState(Color subTextColor) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 48.h),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: const Color(0xFF29B6F6).withOpacity(0.06),
                shape: BoxShape.circle,
              ),
              child: Icon(
                CupertinoIcons.doc_text,
                size: 32.sp,
                color: const Color(0xFF29B6F6).withOpacity(0.5),
              ),
            ).animate().scale(duration: 500.ms, curve: Curves.elasticOut),
            SizedBox(height: 12.h),
            Text(
              'No transactions',
              style: GoogleFonts.poppins(
                color: subTextColor,
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
