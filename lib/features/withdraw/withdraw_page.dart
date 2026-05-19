import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:intl/intl.dart';
import '../../main.dart';

// ==================== API CONFIG ====================
const String _API_BASE = 'https://api.easysarvice.com/api';

// ==================== PROVIDERS ====================
final withdrawStatusFilterProvider = StateProvider<String>((ref) => 'pending');
final withdrawSearchProvider = StateProvider<String>((ref) => '');

Future<String?> _getToken() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('jwt_token');
}

String formatCurrency(dynamic amount) {
  if (amount == null) return '৳0';
  final value = amount is num ? amount : num.tryParse(amount.toString()) ?? 0;
  return NumberFormat.currency(
    locale: 'bn_BD',
    symbol: '৳',
    decimalDigits: 0,
  ).format(value);
}

// ── Pending withdraws provider ──
final pendingWithdrawsProvider = FutureProvider<List<dynamic>>((ref) async {
  final token = await _getToken();
  if (token == null || token.isEmpty) throw Exception('UNAUTHORIZED');

  final response = await http.get(
    Uri.parse('$_API_BASE/admin/withdraws/pending'),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return data['data'] ?? [];
  } else if (response.statusCode == 401) {
    throw Exception('UNAUTHORIZED');
  } else if (response.statusCode == 403) {
    throw Exception('FORBIDDEN');
  } else {
    throw Exception('SERVER_ERROR');
  }
});

// ── Approve / Reject action ──
Future<Map<String, dynamic>> approveOrRejectWithdraw({
  required int withdrawId,
  required String action, // 'approved' or 'rejected'
  String? trxId,
  String? remarks,
}) async {
  final token = await _getToken();
  if (token == null || token.isEmpty) {
    return {'success': false, 'message': 'Unauthorized'};
  }

  try {
    final response = await http.post(
      Uri.parse('$_API_BASE/admin/approve-withdraw'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'withdrawId': withdrawId,
        'action': action,
        if (trxId != null && trxId.isNotEmpty) 'trxId': trxId,
        if (remarks != null && remarks.isNotEmpty) 'remarks': remarks,
      }),
    );

    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      return {'success': true, 'message': data['message'] ?? 'Success'};
    } else {
      return {
        'success': false,
        'message': data['message'] ?? 'Something went wrong'
      };
    }
  } catch (e) {
    return {'success': false, 'message': 'Network error'};
  }
}

// ==================== PAGE ====================
class WithdrawLedgerPage extends ConsumerStatefulWidget {
  const WithdrawLedgerPage({super.key});

  @override
  ConsumerState<WithdrawLedgerPage> createState() =>
      _WithdrawLedgerPageState();
}

class _WithdrawLedgerPageState extends ConsumerState<WithdrawLedgerPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();

    Future.microtask(() {
      ref.read(isDetailViewProvider.notifier).state = true;
      ref.read(detailViewTitleProvider.notifier).state = 'Withdraw Ledger';
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    ref.invalidate(pendingWithdrawsProvider);
  }

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
        return Icons.check_circle_outline;
      case 'rejected':
        return Icons.cancel_outlined;
      default:
        return Icons.hourglass_empty;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'approved':
        return 'অনুমোদিত';
      case 'rejected':
        return 'প্রত্যাখ্যাত';
      default:
        return 'অপেক্ষমাণ';
    }
  }

  // ── Summary stats from pending list ──
  Map<String, dynamic> _calcStats(List<dynamic> data) {
    double total = 0;
    for (final item in data) {
      total += (item['amount'] is num)
          ? (item['amount'] as num).toDouble()
          : double.tryParse(item['amount']?.toString() ?? '0') ?? 0;
    }
    return {'count': data.length, 'total': total};
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final searchQuery = ref.watch(withdrawSearchProvider);
    final withdrawsAsync = ref.watch(pendingWithdrawsProvider);

    final bgColor =
        isDark ? const Color(0xFF0F0F0F) : const Color(0xFFF8FAFC);
    final cardColor = isDark ? const Color(0xFF1A1A1A) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final secondaryText =
        isDark ? Colors.grey.shade400 : Colors.grey.shade600;
    final borderColor =
        isDark ? const Color(0xFF2A2A2A) : Colors.grey.shade200;

    return Scaffold(
      backgroundColor: bgColor,
      body: RefreshIndicator(
        onRefresh: _refresh,
        color: isDark ? Colors.white : const Color(0xFF0F172A),
        backgroundColor: cardColor,
        child: withdrawsAsync.when(
          data: (allData) {
            final stats = _calcStats(allData);

            // Filter by search
            final filtered = searchQuery.isEmpty
                ? allData
                : allData.where((item) {
                    final name = (item['user_name'] ?? '')
                        .toString()
                        .toLowerCase();
                    final mobile =
                        (item['mobile'] ?? '').toString().toLowerCase();
                    final email =
                        (item['user_email'] ?? '').toString().toLowerCase();
                    final account =
                        (item['account_no'] ?? '').toString().toLowerCase();
                    return name.contains(searchQuery) ||
                        mobile.contains(searchQuery) ||
                        email.contains(searchQuery) ||
                        account.contains(searchQuery);
                  }).toList();

            return CustomScrollView(
              slivers: [
                // ── Search bar ──
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: borderColor),
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (v) => ref
                            .read(withdrawSearchProvider.notifier)
                            .state = v.toLowerCase(),
                        decoration: InputDecoration(
                          hintText: 'নাম, মোবাইল, ইমেইল বা অ্যাকাউন্ট নম্বর...',
                          hintStyle: TextStyle(color: secondaryText, fontSize: 13),
                          prefixIcon:
                              Icon(Icons.search, color: secondaryText),
                          suffixIcon: searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: Icon(Icons.close,
                                      color: secondaryText, size: 18),
                                  onPressed: () {
                                    _searchController.clear();
                                    ref
                                        .read(withdrawSearchProvider.notifier)
                                        .state = '';
                                  },
                                )
                              : null,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                        ),
                        style: TextStyle(color: textColor),
                      ),
                    ),
                  ),
                ),

                // ── Summary card ──
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isDark
                              ? [
                                  const Color(0xFF1E293B),
                                  const Color(0xFF0F172A),
                                ]
                              : [
                                  const Color(0xFF0F172A),
                                  const Color(0xFF1E3A5F),
                                ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          // Pending count
                          Expanded(
                            child: _buildSummaryItem(
                              label: 'মোট অনুরোধ',
                              value: stats['count'].toString(),
                              icon: Icons.list_alt,
                              color: const Color(0xFFF59E0B),
                            ),
                          ),
                          Container(
                            width: 1,
                            height: 40,
                            color: Colors.white.withOpacity(0.15),
                          ),
                          Expanded(
                            child: _buildSummaryItem(
                              label: 'মোট পরিমাণ',
                              value: formatCurrency(stats['total']),
                              icon: Icons.account_balance_wallet_outlined,
                              color: const Color(0xFF22C55E),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // ── List ──
                filtered.isEmpty
                    ? SliverFillRemaining(
                        child: _buildEmptyState(
                            isDark, searchQuery.isNotEmpty),
                      )
                    : SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final item = filtered[index];
                            return AnimatedBuilder(
                              animation: _animController,
                              builder: (context, child) {
                                final delay =
                                    (index * 0.05).clamp(0.0, 0.95);
                                final value =
                                    (_animController.value - delay)
                                        .clamp(0.0, 1.0);
                                return Transform.translate(
                                  offset: Offset(0, 20 * (1 - value)),
                                  child: Opacity(
                                      opacity: value, child: child),
                                );
                              },
                              child: _buildWithdrawCard(
                                item: item,
                                isDark: isDark,
                                cardColor: cardColor,
                                textColor: textColor,
                                secondaryText: secondaryText,
                                borderColor: borderColor,
                              ),
                            );
                          },
                          childCount: filtered.length,
                        ),
                      ),

                const SliverToBoxAdapter(child: SizedBox(height: 32)),
              ],
            );
          },
          loading: () => ListView.builder(
            padding: const EdgeInsets.only(top: 16),
            itemCount: 6,
            itemBuilder: (_, __) =>
                _buildShimmerCard(isDark, cardColor),
          ),
          error: (err, _) => _buildErrorState(err.toString(), isDark),
        ),
      ),
    );
  }

  Widget _buildSummaryItem({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.6),
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _buildWithdrawCard({
    required dynamic item,
    required bool isDark,
    required Color cardColor,
    required Color textColor,
    required Color secondaryText,
    required Color borderColor,
  }) {
    final status = item['status'] ?? 'pending';
    final statusColor = _statusColor(status);
    final int? withdrawId = item['id'] is int
        ? item['id'] as int
        : int.tryParse(item['id']?.toString() ?? '');
    final String userName = item['user_name'] ?? 'Unknown';
    final String mobile = item['mobile'] ?? item['user_email'] ?? '';
    final String method = item['method'] ?? 'N/A';
    final String accountNo = item['account_no'] ?? 'N/A';
    final String accountHolder = item['account_holder'] ?? '';
    final String amount = formatCurrency(item['amount']);
    final String createdAt = item['created_at'] != null
        ? DateFormat('dd MMM yyyy, hh:mm a')
            .format(DateTime.parse(item['created_at']))
        : 'N/A';

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: status == 'pending'
              ? statusColor.withOpacity(0.4)
              : borderColor,
          width: status == 'pending' ? 1.5 : 1,
        ),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: withdrawId != null
              ? () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => WithdrawDetailPage(
                        withdrawId: withdrawId,
                        initialData: item,
                      ),
                    ),
                  )
              : null,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Top row: user + amount ──
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Avatar
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                        border:
                            Border.all(color: statusColor.withOpacity(0.4)),
                      ),
                      child: Center(
                        child: Text(
                          userName.isNotEmpty
                              ? userName[0].toUpperCase()
                              : '?',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: statusColor,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            userName,
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                              color: textColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              Icon(Icons.phone_android,
                                  size: 12, color: secondaryText),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  mobile,
                                  style: TextStyle(
                                      fontSize: 12, color: secondaryText),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Amount + Status
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          amount,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                            color: statusColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        _buildStatusBadge(status, statusColor),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 12),
                Divider(
                    height: 1,
                    color: isDark
                        ? const Color(0xFF2A2A2A)
                        : Colors.grey.shade100),
                const SizedBox(height: 12),

                // ── Method + Account ──
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoChip(
                        icon: Icons.mobile_friendly,
                        label: method.toUpperCase(),
                        isDark: isDark,
                        textColor: textColor,
                        secondaryText: secondaryText,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildInfoChip(
                        icon: Icons.account_circle_outlined,
                        label: accountNo,
                        isDark: isDark,
                        textColor: textColor,
                        secondaryText: secondaryText,
                      ),
                    ),
                  ],
                ),

                if (accountHolder.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _buildInfoChip(
                    icon: Icons.person_outline,
                    label: accountHolder,
                    isDark: isDark,
                    textColor: textColor,
                    secondaryText: secondaryText,
                  ),
                ],

                const SizedBox(height: 10),

                // ── Date + Approve/Reject Buttons ──
                Row(
                  children: [
                    Icon(Icons.access_time, size: 12, color: secondaryText),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        createdAt,
                        style:
                            TextStyle(fontSize: 11, color: secondaryText),
                      ),
                    ),
                    if (status == 'pending' && withdrawId != null) ...[
                      _buildActionButton(
                        label: 'প্রত্যাখ্যান',
                        color: const Color(0xFFEF4444),
                        icon: Icons.close,
                        onTap: () => _showActionDialog(
                          context: context,
                          withdrawId: withdrawId,
                          action: 'rejected',
                          userName: userName,
                          amount: amount,
                          isDark: isDark,
                        ),
                      ),
                      const SizedBox(width: 8),
                      _buildActionButton(
                        label: 'অনুমোদন',
                        color: const Color(0xFF22C55E),
                        icon: Icons.check,
                        onTap: () => _showActionDialog(
                          context: context,
                          withdrawId: withdrawId,
                          action: 'approved',
                          userName: userName,
                          amount: amount,
                          isDark: isDark,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_statusIcon(status), size: 11, color: color),
          const SizedBox(width: 4),
          Text(
            _statusLabel(status),
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
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
    required Color secondaryText,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF252525)
            : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: secondaryText),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
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

  Widget _buildActionButton({
    required String label,
    required Color color,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.4)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Approve / Reject Dialog ──
  void _showActionDialog({
    required BuildContext context,
    required int withdrawId,
    required String action,
    required String userName,
    required String amount,
    required bool isDark,
  }) {
    final trxController = TextEditingController();
    final remarksController = TextEditingController();
    final isApprove = action == 'approved';

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor:
              isDark ? const Color(0xFF1A1A1A) : Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Icon(
                isApprove
                    ? Icons.check_circle_outline
                    : Icons.cancel_outlined,
                color: isApprove
                    ? const Color(0xFF22C55E)
                    : const Color(0xFFEF4444),
              ),
              const SizedBox(width: 10),
              Text(
                isApprove ? 'অনুমোদন করুন' : 'প্রত্যাখ্যান করুন',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Info row
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF252525)
                      : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Icon(Icons.person_outline,
                        size: 16,
                        color: isDark
                            ? Colors.grey.shade400
                            : Colors.grey.shade600),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(userName,
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: isDark
                                    ? Colors.white
                                    : const Color(0xFF0F172A),
                              )),
                          Text(amount,
                              style: const TextStyle(
                                  color: Color(0xFF22C55E),
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              if (isApprove) ...[
                Text('ট্রানজেকশন আইডি (ঐচ্ছিক)',
                    style: TextStyle(
                        fontSize: 12,
                        color: isDark
                            ? Colors.grey.shade400
                            : Colors.grey.shade600)),
                const SizedBox(height: 6),
                TextField(
                  controller: trxController,
                  decoration: InputDecoration(
                    hintText: 'TRX ID লিখুন...',
                    hintStyle: TextStyle(
                        color: isDark
                            ? Colors.grey.shade600
                            : Colors.grey.shade400,
                        fontSize: 13),
                    filled: true,
                    fillColor: isDark
                        ? const Color(0xFF252525)
                        : const Color(0xFFF8FAFC),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                          color: isDark
                              ? const Color(0xFF2A2A2A)
                              : Colors.grey.shade200),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                          color: isDark
                              ? const Color(0xFF2A2A2A)
                              : Colors.grey.shade200),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                  ),
                  style: TextStyle(
                      color: isDark ? Colors.white : const Color(0xFF0F172A)),
                ),
                const SizedBox(height: 10),
              ],
              Text('মন্তব্য (ঐচ্ছিক)',
                  style: TextStyle(
                      fontSize: 12,
                      color: isDark
                          ? Colors.grey.shade400
                          : Colors.grey.shade600)),
              const SizedBox(height: 6),
              TextField(
                controller: remarksController,
                maxLines: 2,
                decoration: InputDecoration(
                  hintText: 'মন্তব্য লিখুন...',
                  hintStyle: TextStyle(
                      color: isDark
                          ? Colors.grey.shade600
                          : Colors.grey.shade400,
                      fontSize: 13),
                  filled: true,
                  fillColor: isDark
                      ? const Color(0xFF252525)
                      : const Color(0xFFF8FAFC),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                        color: isDark
                            ? const Color(0xFF2A2A2A)
                            : Colors.grey.shade200),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                        color: isDark
                            ? const Color(0xFF2A2A2A)
                            : Colors.grey.shade200),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 12),
                ),
                style: TextStyle(
                    color: isDark ? Colors.white : const Color(0xFF0F172A)),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('বাতিল',
                  style: TextStyle(
                      color: isDark
                          ? Colors.grey.shade400
                          : Colors.grey.shade600)),
            ),
            ElevatedButton.icon(
              onPressed: () async {
                Navigator.pop(ctx);
                await _processAction(
                  withdrawId: withdrawId,
                  action: action,
                  trxId: trxController.text,
                  remarks: remarksController.text,
                );
              },
              icon: Icon(isApprove ? Icons.check : Icons.close, size: 16),
              label: Text(isApprove ? 'অনুমোদন করুন' : 'প্রত্যাখ্যান করুন'),
              style: ElevatedButton.styleFrom(
                backgroundColor: isApprove
                    ? const Color(0xFF22C55E)
                    : const Color(0xFFEF4444),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 10),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _processAction({
    required int withdrawId,
    required String action,
    String? trxId,
    String? remarks,
  }) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Loading snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Text(action == 'approved'
                ? 'অনুমোদন করা হচ্ছে...'
                : 'প্রত্যাখ্যান করা হচ্ছে...'),
          ],
        ),
        duration: const Duration(seconds: 10),
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        backgroundColor:
            isDark ? const Color(0xFF1A1A1A) : const Color(0xFF0F172A),
      ),
    );

    final result = await approveOrRejectWithdraw(
      withdrawId: withdrawId,
      action: action,
      trxId: trxId,
      remarks: remarks,
    );

    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    final isSuccess = result['success'] == true;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isSuccess ? Icons.check_circle : Icons.error_outline,
              color: Colors.white,
              size: 18,
            ),
            const SizedBox(width: 10),
            Expanded(child: Text(result['message'] ?? '')),
          ],
        ),
        backgroundColor: isSuccess
            ? const Color(0xFF22C55E)
            : const Color(0xFFEF4444),
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 3),
      ),
    );

    if (isSuccess) {
      ref.invalidate(pendingWithdrawsProvider);
    }
  }

  Widget _buildShimmerCard(bool isDark, Color cardColor) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      height: 140,
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Shimmer.fromColors(
        baseColor:
            isDark ? const Color(0xFF1A1A1A) : Colors.grey[300]!,
        highlightColor:
            isDark ? const Color(0xFF2A2A2A) : Colors.grey[100]!,
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(
                        color: Colors.white, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                            width: 130,
                            height: 14,
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(4))),
                        const SizedBox(height: 8),
                        Container(
                            width: 90,
                            height: 12,
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(4))),
                      ],
                    ),
                  ),
                  Container(
                      width: 70,
                      height: 20,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4))),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                      width: 100,
                      height: 32,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8))),
                  const SizedBox(width: 8),
                  Container(
                      width: 120,
                      height: 32,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8))),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark, bool isSearch) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isSearch ? Icons.search_off : Icons.inbox_outlined,
            size: 64,
            color: isDark ? Colors.grey.shade700 : Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            isSearch
                ? 'কোনো ফলাফল পাওয়া যায়নি'
                : 'কোনো উইথড্র অনুরোধ নেই',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color:
                  isDark ? Colors.grey.shade400 : Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isSearch
                ? 'অন্যভাবে সার্চ করুন'
                : 'নতুন অনুরোধ এলে এখানে দেখাবে',
            style: TextStyle(
              fontSize: 13,
              color: isDark ? Colors.grey.shade600 : Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error, bool isDark) {
    String message = 'কিছু একটা সমস্যা হয়েছে';
    IconData icon = Icons.error_outline;

    if (error.contains('UNAUTHORIZED')) {
      message = 'সেশন শেষ হয়ে গেছে। আবার লগইন করুন।';
      icon = Icons.lock_outline;
    } else if (error.contains('FORBIDDEN')) {
      message = 'অ্যাডমিন অ্যাক্সেস প্রয়োজন';
      icon = Icons.gpp_bad_outlined;
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                size: 64,
                color: isDark ? Colors.red.shade300 : Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              message,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.grey.shade300 : Colors.grey[700],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _refresh,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('আবার চেষ্টা করুন'),
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark
                    ? const Color(0xFF333333)
                    : const Color(0xFF0F172A),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== Withdraw Detail Page ====================
class WithdrawDetailPage extends ConsumerWidget {
  final int withdrawId;
  final dynamic initialData;

  const WithdrawDetailPage({
    super.key,
    required this.withdrawId,
    required this.initialData,
  });

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
        return Icons.check_circle;
      case 'rejected':
        return Icons.cancel;
      default:
        return Icons.hourglass_empty;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'approved':
        return 'অনুমোদিত';
      case 'rejected':
        return 'প্রত্যাখ্যাত';
      default:
        return 'অপেক্ষমাণ';
    }
  }

  void _copyToClipboard(BuildContext context, String? text) {
    if (text == null || text.isEmpty) return;
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('ক্লিপবোর্ডে কপি হয়েছে'),
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final item = initialData;

    final bgColor =
        isDark ? const Color(0xFF0F0F0F) : const Color(0xFFF8FAFC);
    final cardColor = isDark ? const Color(0xFF1A1A1A) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final secondaryText =
        isDark ? Colors.grey.shade400 : Colors.grey.shade600;
    final borderColor =
        isDark ? const Color(0xFF2A2A2A) : Colors.grey.shade200;

    final String status = item['status'] ?? 'pending';
    final Color statusColor = _statusColor(status);
    final String userName = item['user_name'] ?? 'Unknown';
    final String mobile = item['mobile'] ?? 'N/A';
    final String email = item['user_email'] ?? 'N/A';
    final String method = item['method'] ?? 'N/A';
    final String accountNo = item['account_no'] ?? 'N/A';
    final String accountHolder = item['account_holder'] ?? 'N/A';
    final String amount = formatCurrency(item['amount']);
    final String? trxId = item['trx_id'];
    final String? remarks = item['remarks'];
    final String createdAt = item['created_at'] != null
        ? DateFormat('dd MMM yyyy, hh:mm a')
            .format(DateTime.parse(item['created_at']))
        : 'N/A';
    final String? updatedAt = item['updated_at'] != null
        ? DateFormat('dd MMM yyyy, hh:mm a')
            .format(DateTime.parse(item['updated_at']))
        : null;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: cardColor,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: textColor, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'উইথড্র বিস্তারিত',
          style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w700,
              fontSize: 18),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Status Hero Card ──
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    statusColor.withOpacity(isDark ? 0.25 : 0.12),
                    statusColor.withOpacity(isDark ? 0.1 : 0.04),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: statusColor.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  Icon(_statusIcon(status), color: statusColor, size: 48),
                  const SizedBox(height: 10),
                  Text(
                    amount,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 5),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _statusLabel(status),
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── User Info ──
            _buildSection(
              title: 'ইউজারের তথ্য',
              icon: Icons.person_outline,
              isDark: isDark,
              cardColor: cardColor,
              borderColor: borderColor,
              child: Column(
                children: [
                  _buildRow(
                      icon: Icons.badge_outlined,
                      label: 'নাম',
                      value: userName,
                      isDark: isDark,
                      textColor: textColor,
                      secondaryText: secondaryText),
                  _buildDivider(isDark),
                  _buildRow(
                    icon: Icons.phone_android,
                    label: 'মোবাইল',
                    value: mobile,
                    isDark: isDark,
                    textColor: textColor,
                    secondaryText: secondaryText,
                    onCopy: () => _copyToClipboard(context, mobile),
                  ),
                  _buildDivider(isDark),
                  _buildRow(
                    icon: Icons.email_outlined,
                    label: 'ইমেইল',
                    value: email,
                    isDark: isDark,
                    textColor: textColor,
                    secondaryText: secondaryText,
                    onCopy: () => _copyToClipboard(context, email),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // ── Payment Info ──
            _buildSection(
              title: 'পেমেন্টের তথ্য',
              icon: Icons.payment_outlined,
              isDark: isDark,
              cardColor: cardColor,
              borderColor: borderColor,
              child: Column(
                children: [
                  _buildRow(
                      icon: Icons.mobile_friendly,
                      label: 'পদ্ধতি',
                      value: method.toUpperCase(),
                      isDark: isDark,
                      textColor: textColor,
                      secondaryText: secondaryText),
                  _buildDivider(isDark),
                  _buildRow(
                    icon: Icons.account_circle_outlined,
                    label: 'অ্যাকাউন্ট নম্বর',
                    value: accountNo,
                    isDark: isDark,
                    textColor: textColor,
                    secondaryText: secondaryText,
                    onCopy: () => _copyToClipboard(context, accountNo),
                  ),
                  if (accountHolder != 'N/A') ...[
                    _buildDivider(isDark),
                    _buildRow(
                        icon: Icons.person_outline,
                        label: 'অ্যাকাউন্ট ধারক',
                        value: accountHolder,
                        isDark: isDark,
                        textColor: textColor,
                        secondaryText: secondaryText),
                  ],
                  _buildDivider(isDark),
                  _buildRow(
                      icon: Icons.monetization_on_outlined,
                      label: 'পরিমাণ',
                      value: amount,
                      isDark: isDark,
                      textColor: textColor,
                      secondaryText: secondaryText,
                      valueColor: statusColor),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // ── Timeline ──
            _buildSection(
              title: 'টাইমলাইন',
              icon: Icons.timeline,
              isDark: isDark,
              cardColor: cardColor,
              borderColor: borderColor,
              child: Column(
                children: [
                  _buildRow(
                      icon: Icons.add_circle_outline,
                      label: 'জমা দেওয়া হয়েছে',
                      value: createdAt,
                      isDark: isDark,
                      textColor: textColor,
                      secondaryText: secondaryText),
                  if (updatedAt != null) ...[
                    _buildDivider(isDark),
                    _buildRow(
                        icon: status == 'approved'
                            ? Icons.check_circle_outline
                            : Icons.cancel_outlined,
                        label: status == 'approved'
                            ? 'অনুমোদিত হয়েছে'
                            : 'প্রত্যাখ্যাত হয়েছে',
                        value: updatedAt,
                        isDark: isDark,
                        textColor: textColor,
                        secondaryText: secondaryText,
                        valueColor: statusColor),
                  ],
                  if (trxId != null && trxId.isNotEmpty) ...[
                    _buildDivider(isDark),
                    _buildRow(
                      icon: Icons.receipt_long_outlined,
                      label: 'TRX ID',
                      value: trxId,
                      isDark: isDark,
                      textColor: textColor,
                      secondaryText: secondaryText,
                      onCopy: () => _copyToClipboard(context, trxId),
                    ),
                  ],
                  if (remarks != null && remarks.isNotEmpty) ...[
                    _buildDivider(isDark),
                    _buildRow(
                        icon: Icons.comment_outlined,
                        label: 'মন্তব্য',
                        value: remarks,
                        isDark: isDark,
                        textColor: textColor,
                        secondaryText: secondaryText),
                  ],
                ],
              ),
            ),

            // ── Approve/Reject from detail page too ──
            if (status == 'pending') ...[
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.close,
                          size: 18, color: Color(0xFFEF4444)),
                      label: const Text('প্রত্যাখ্যান',
                          style: TextStyle(color: Color(0xFFEF4444))),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFEF4444)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.check, size: 18),
                      label: const Text('অনুমোদন'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF22C55E),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 32),
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
    required Widget child,
  }) {
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Row(
              children: [
                Icon(icon, size: 18, color: const Color(0xFF0EA5E9)),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ],
            ),
          ),
          Divider(
              height: 1,
              color: isDark
                  ? const Color(0xFF2A2A2A)
                  : Colors.grey.shade100),
          Padding(
            padding: const EdgeInsets.all(16),
            child: child,
          ),
        ],
      ),
    );
  }

  Widget _buildRow({
    required IconData icon,
    required String label,
    required String value,
    required bool isDark,
    required Color textColor,
    required Color secondaryText,
    Color? valueColor,
    VoidCallback? onCopy,
  }) {
    return Row(
      children: [
        Icon(icon, size: 17, color: secondaryText),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: TextStyle(fontSize: 11, color: secondaryText)),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
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
            icon: Icon(Icons.copy_outlined, size: 17, color: secondaryText),
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
