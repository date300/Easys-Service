import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

// ==========================================
// 1. Data Models
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

  factory VoucherBalance.fromJson(Map<String, dynamic> json) {
    final List txList = json['transactions'] ?? [];
    return VoucherBalance(
      totalBalance: (json['total_balance'] ?? 0).toDouble(),
      usedBalance: (json['used_balance'] ?? 0).toDouble(),
      availableBalance: (json['available_balance'] ?? 0).toDouble(),
      transactions: txList.map((e) => VoucherTransaction.fromJson(e)).toList(),
    );
  }
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

  factory VoucherTransaction.fromJson(Map<String, dynamic> json) {
    return VoucherTransaction(
      id: json['id']?.toString() ?? '',
      description: json['description'] ?? 'Voucher Transaction',
      amount: (json['amount'] ?? 0).toDouble(),
      type: json['type'] ?? 'credit',
      date: json['date'] ?? '',
      status: json['status'] ?? 'completed',
    );
  }
}

// ==========================================
// 2. Provider
// ==========================================

final voucherBalanceProvider = FutureProvider<VoucherBalance?>((ref) async {
  const String baseUrl = "https://easy.ltcminematrix.com/api";
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('jwt_token');

  if (token == null) return null;

  try {
    final response = await http.get(
      Uri.parse("$baseUrl/user/voucher-balance"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    ).timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['status'] == 'success') {
        return VoucherBalance.fromJson(data['data']);
      }
    }
  } catch (e) {
    debugPrint("Voucher Balance Error: $e");
    return null;
  }
  return null;
});

// ==========================================
// 3. VoucherBalancePage
// ==========================================

class VoucherBalancePage extends ConsumerStatefulWidget {
  const VoucherBalancePage({super.key});

  @override
  ConsumerState<VoucherBalancePage> createState() => _VoucherBalancePageState();
}

class _VoucherBalancePageState extends ConsumerState<VoucherBalancePage> {
  static const Color skyBlue = Color(0xFF29B6F6);
  String _selectedFilter = 'All';
  final List<String> _filters = ['All', 'Credit', 'Debit', 'Pending'];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF121212) : const Color(0xFFF5F7FA);
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subTextColor = isDark ? Colors.grey.shade400 : Colors.grey.shade600;
    final dividerColor = isDark ? const Color(0xFF2C2C2C) : const Color(0xFFEEEEEE);

    final voucherAsync = ref.watch(voucherBalanceProvider);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: voucherAsync.when(
          data: (voucher) {
            if (voucher == null) {
              return _buildErrorState(isDark, textColor, subTextColor, 'No data found');
            }
            return _buildContent(
              voucher, isDark, cardColor, textColor, subTextColor, dividerColor,
            );
          },
          loading: () => _buildLoadingState(isDark),
          error: (err, _) =>
              _buildErrorState(isDark, textColor, subTextColor, err.toString()),
        ),
      ),
    );
  }

  // ── Main Content ──────────────────────────────────────────────────────────────

  Widget _buildContent(
    VoucherBalance voucher,
    bool isDark,
    Color cardColor,
    Color textColor,
    Color subTextColor,
    Color dividerColor,
  ) {
    final filtered = _getFiltered(voucher.transactions);

    return RefreshIndicator(
      color: skyBlue,
      backgroundColor: cardColor,
      onRefresh: () async => ref.refresh(voucherBalanceProvider),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 30),
        physics: const BouncingScrollPhysics(),
        children: [
          // Page Title
          Text(
            'Voucher Balance',
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Track your voucher earnings & usage',
            style: GoogleFonts.poppins(fontSize: 13, color: subTextColor),
          ),

          const SizedBox(height: 20),

          // Balance Card
          _buildBalanceCard(voucher),

          const SizedBox(height: 16),

          // Stats Row
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: Icons.add_circle_rounded,
                  iconColor: Colors.green,
                  label: 'Total Earned',
                  amount: '৳${voucher.totalBalance.toStringAsFixed(2)}',
                  cardColor: cardColor,
                  textColor: textColor,
                  subTextColor: subTextColor,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.remove_circle_rounded,
                  iconColor: Colors.orange,
                  label: 'Total Used',
                  amount: '৳${voucher.usedBalance.toStringAsFixed(2)}',
                  cardColor: cardColor,
                  textColor: textColor,
                  subTextColor: subTextColor,
                  isDark: isDark,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Transaction Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Transactions',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              Text(
                '${filtered.length} records',
                style: GoogleFonts.poppins(fontSize: 12, color: subTextColor),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Filter Chips
          _buildFilterChips(isDark, subTextColor),

          const SizedBox(height: 14),

          // Transactions
          if (filtered.isEmpty)
            _buildEmptyState(subTextColor)
          else
            ...filtered.asMap().entries.map(
              (e) => _buildTransactionCard(
                e.value, isDark, cardColor, textColor, subTextColor, e.key,
              ),
            ),
        ],
      ),
    );
  }

  // ── Balance Card ──────────────────────────────────────────────────────────────

  Widget _buildBalanceCard(VoucherBalance voucher) {
    final usedPercent = voucher.totalBalance > 0
        ? (voucher.usedBalance / voucher.totalBalance).clamp(0.0, 1.0)
        : 0.0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF29B6F6), Color(0xFF0288D1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: skyBlue.withOpacity(0.35),
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
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.card_giftcard_rounded,
                        color: Colors.white, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      'Voucher',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '৳',
                style: GoogleFonts.poppins(
                  color: Colors.white70,
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                voucher.availableBalance.toStringAsFixed(2),
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 38,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -1,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Used: ৳${voucher.usedBalance.toStringAsFixed(2)}',
                style: GoogleFonts.poppins(color: Colors.white70, fontSize: 11),
              ),
              Text(
                'Total: ৳${voucher.totalBalance.toStringAsFixed(2)}',
                style: GoogleFonts.poppins(color: Colors.white70, fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: usedPercent,
              backgroundColor: Colors.white.withOpacity(0.25),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              minHeight: 7,
            ),
          ),

          const SizedBox(height: 16),

          GestureDetector(
            onTap: () {
              Clipboard.setData(ClipboardData(
                  text: voucher.availableBalance.toStringAsFixed(2)));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Balance copied!', style: GoogleFonts.poppins()),
                  backgroundColor: const Color(0xFF0288D1),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.copy_rounded, color: Colors.white, size: 14),
                  const SizedBox(width: 6),
                  Text(
                    'Copy Balance',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 12,
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

  // ── Stat Card ─────────────────────────────────────────────────────────────────

  Widget _buildStatCard({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String amount,
    required Color cardColor,
    required Color textColor,
    required Color subTextColor,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(height: 10),
          Text(label,
              style: GoogleFonts.poppins(fontSize: 11, color: subTextColor)),
          const SizedBox(height: 2),
          Text(
            amount,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  // ── Filter Chips ──────────────────────────────────────────────────────────────

  Widget _buildFilterChips(bool isDark, Color subTextColor) {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: _filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final f = _filters[i];
          final selected = _selectedFilter == f;
          return GestureDetector(
            onTap: () => setState(() => _selectedFilter = f),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 7),
              decoration: BoxDecoration(
                color: selected
                    ? skyBlue
                    : (isDark ? const Color(0xFF2A2A2A) : Colors.grey.shade100),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                f,
                style: GoogleFonts.poppins(
                  fontSize: 12,
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

  // ── Transaction Card ──────────────────────────────────────────────────────────

  Widget _buildTransactionCard(
    VoucherTransaction tx,
    bool isDark,
    Color cardColor,
    Color textColor,
    Color subTextColor,
    int index,
  ) {
    final isCredit = tx.type == 'credit';
    final amountColor = isCredit ? Colors.green : Colors.orange;
    final iconData =
        isCredit ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded;
    final amountPrefix = isCredit ? '+' : '-';

    Color statusColor;
    String statusLabel;
    switch (tx.status) {
      case 'completed':
        statusColor = Colors.green;
        statusLabel = 'Completed';
        break;
      case 'pending':
        statusColor = Colors.orange;
        statusLabel = 'Pending';
        break;
      case 'failed':
        statusColor = Colors.red;
        statusLabel = 'Failed';
        break;
      default:
        statusColor = Colors.grey;
        statusLabel = tx.status;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.25 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: amountColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(iconData, color: amountColor, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tx.description,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.access_time_rounded,
                        size: 11, color: subTextColor),
                    const SizedBox(width: 4),
                    Text(
                      tx.date,
                      style: GoogleFonts.poppins(
                          fontSize: 11, color: subTextColor),
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
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: amountColor,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  statusLabel,
                  style: GoogleFonts.poppins(
                    fontSize: 10,
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

  // ── Empty State ───────────────────────────────────────────────────────────────

  Widget _buildEmptyState(Color subTextColor) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            Icon(Icons.receipt_long_rounded,
                size: 64, color: subTextColor.withOpacity(0.4)),
            const SizedBox(height: 14),
            Text(
              'No transactions found',
              style: GoogleFonts.poppins(
                color: subTextColor,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Loading State ─────────────────────────────────────────────────────────────

  Widget _buildLoadingState(bool isDark) {
    final base = isDark ? const Color(0xFF2A2A2A) : Colors.grey.shade200;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 30),
      children: [
        _shimmer(200, 24, base),
        const SizedBox(height: 16),
        Row(children: [
          Expanded(child: _shimmer(100, 18, base)),
          const SizedBox(width: 12),
          Expanded(child: _shimmer(100, 18, base)),
        ]),
        const SizedBox(height: 20),
        ...List.generate(
          5,
          (_) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _shimmer(72, 18, base),
          ),
        ),
      ],
    );
  }

  Widget _shimmer(double height, double radius, Color base) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: base,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }

  // ── Error State ───────────────────────────────────────────────────────────────

  Widget _buildErrorState(
      bool isDark, Color textColor, Color subTextColor, String msg) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cloud_off_rounded,
                size: 72, color: subTextColor.withOpacity(0.5)),
            const SizedBox(height: 16),
            Text(
              'Something went wrong',
              style: GoogleFonts.poppins(
                color: textColor,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              msg,
              style: GoogleFonts.poppins(color: subTextColor, fontSize: 12),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: skyBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                    horizontal: 28, vertical: 13),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: Text('Try Again',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
              onPressed: () => ref.refresh(voucherBalanceProvider),
            ),
          ],
        ),
      ),
    );
  }

  // ── Filter Helper ─────────────────────────────────────────────────────────────

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
}
