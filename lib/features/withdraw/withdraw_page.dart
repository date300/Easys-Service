import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
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

  static Future<List<<WithdrawItem>> fetchHistory(String token) async {
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
// 4. WithdrawLedgerPage
// ==========================================
class WithdrawLedgerPage extends StatefulWidget {
  const WithdrawLedgerPage({super.key});

  @override
  State<<WithdrawLedgerPage> createState() => _WithdrawLedgerPageState();
}

class _WithdrawLedgerPageState extends State<<WithdrawLedgerPage>
    with SingleTickerProviderStateMixin {
  static const Color _primary = Color(0xFF0F172A);
  static const Color _approved = Color(0xFF22C55E);
  static const Color _pending = Color(0xFFF59E0B);
  static const Color _rejected = Color(0xFFEF4444);

  final _accountNoCtrl = TextEditingController();
  final _accountHolderCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  String? _selectedMethod;
  bool _isSubmitting = false;
  String? _formError;

  List<<WithdrawItem> _withdraws = [];
  bool _isLoadingHistory = true;
  String? _historyError;
  String _token = '';
  String _searchQuery = '';

  final TextEditingController _searchCtrl = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late AnimationController _animationController;

  final List<String> _methods = ['bKash', 'Nagad', 'Rocket', 'Upay', 'Bank'];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _boot();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _accountNoCtrl.dispose();
    _accountHolderCtrl.dispose();
    _amountCtrl.dispose();
    _searchCtrl.dispose();
    _scrollController.dispose();
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
    setState(() {
      _isLoadingHistory = true;
      _historyError = null;
    });
    try {
      final data = await WithdrawApiService.fetchHistory(_token);
      if (mounted) {
        setState(() {
          _withdraws = data;
          _isLoadingHistory = false;
        });
        _animationController.reset();
        _animationController.forward();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _historyError = e.toString().replaceAll('Exception: ', '');
          _isLoadingHistory = false;
        });
      }
    }
  }

  Future<void> _submitForm() async {
    final method = _selectedMethod ?? '';
    final accountNo = _accountNoCtrl.text.trim();
    final amount = double.tryParse(_amountCtrl.text.trim());

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

    setState(() {
      _isSubmitting = true;
      _formError = null;
    });

    try {
      final result = await WithdrawApiService.submitWithdraw(
        token: _token,
        method: method,
        accountNo: accountNo,
        accountHolder: _accountHolderCtrl.text.trim(),
        amount: amount,
      );

      if (mounted) {
        _accountNoCtrl.clear();
        _accountHolderCtrl.clear();
        _amountCtrl.clear();
        setState(() {
          _selectedMethod = null;
          _isSubmitting = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Text('Request submitted successfully!'),
          backgroundColor: _approved,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          duration: const Duration(seconds: 2),
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

  List<<WithdrawItem> get _filtered {
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
      if (w.status == 'pending') pending += w.amount;
    }
    return {'count': _withdraws.length, 'approved': approved, 'pending': pending};
  }

  Color _statusColor(String s) =>
      s == 'approved' ? _approved : s == 'rejected' ? _rejected : _pending;

  IconData _statusIcon(String s) =>
      s == 'approved' ? Icons.check_circle : s == 'rejected' ? Icons.cancel : Icons.access_time_filled;

  String _statusLabel(String s) =>
      s == 'approved' ? 'Approved' : s == 'rejected' ? 'Rejected' : 'Pending';

  Color _secondaryTextColor(bool isDark) =>
      isDark ? Colors.grey.shade400 : Colors.grey.shade600;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor = isDark ? const Color(0xFF0F0F0F) : const Color(0xFFF8FAFC);
    final cardColor = isDark ? const Color(0xFF1A1A1A) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final secondaryTextColor = _secondaryTextColor(isDark);
    final borderColor =
        isDark ? const Color(0xFF2A2A2A) : Colors.grey.shade200;

    return Scaffold(
      backgroundColor: bgColor,
      body: RefreshIndicator(
        onRefresh: () async {
          HapticFeedback.mediumImpact();
          await _fetchHistory();
        },
        color: isDark ? Colors.white : const Color(0xFF0F172A),
        backgroundColor: cardColor,
        child: CustomScrollView(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Withdraw',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w700,
                            color: textColor,
                            height: 1.1,
                            letterSpacing: -0.5,
                          ),
                        ),
                        Text(
                          'Ledger',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w300,
                            color: textColor,
                            height: 1.1,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: _primary.withOpacity(0.08),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.account_balance_wallet_outlined,
                        color: _primary,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: borderColor),
                    boxShadow: [
                      if (!isDark)
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Request a Withdraw',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Fill the details and submit',
                        style: TextStyle(
                          fontSize: 13,
                          color: secondaryTextColor,
                        ),
                      ),
                      const SizedBox(height: 16),

                      Text(
                        'Payment Method *',
                        style: TextStyle(
                          fontSize: 13,
                          color: secondaryTextColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _methods.map((m) {
                          final selected = _selectedMethod == m;
                          return GestureDetector(
                            onTap: () => setState(() => _selectedMethod = selected ? null : m),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: selected ? _primary : isDark ? const Color(0xFF252525) : const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: selected ? _primary : borderColor,
                                ),
                              ),
                              child: Text(
                                m,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: selected ? Colors.white : textColor,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),

                      _buildFormField(
                        ctrl: _accountNoCtrl,
                        label: 'Account Number *',
                        hint: 'e.g. 01XXXXXXXXX',
                        icon: Icons.phone_android,
                        textColor: textColor,
                        sub: secondaryTextColor,
                        border: borderColor,
                        fill: isDark ? const Color(0xFF252525) : const Color(0xFFF8FAFC),
                        keyboard: TextInputType.phone,
                      ),
                      const SizedBox(height: 12),

                      _buildFormField(
                        ctrl: _accountHolderCtrl,
                        label: 'Account Holder (optional)',
                        hint: 'Name of account owner',
                        icon: Icons.person_outline,
                        textColor: textColor,
                        sub: secondaryTextColor,
                        border: borderColor,
                        fill: isDark ? const Color(0xFF252525) : const Color(0xFFF8FAFC),
                      ),
                      const SizedBox(height: 12),

                      _buildFormField(
                        ctrl: _amountCtrl,
                        label: 'Amount (৳) *',
                        hint: 'e.g. 500',
                        icon: Icons.attach_money,
                        textColor: textColor,
                        sub: secondaryTextColor,
                        border: borderColor,
                        fill: isDark ? const Color(0xFF252525) : const Color(0xFFF8FAFC),
                        keyboard: const TextInputType.numberWithOptions(decimal: true),
                      ),
                      const SizedBox(height: 16),

                      if (_formError != null) ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.red.withOpacity(0.2)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.error_outline, color: Colors.red, size: 18),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _formError!,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Colors.red,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isSubmitting ? null : _submitForm,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _primary,
                            disabledBackgroundColor: _primary.withOpacity(0.5),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 0,
                          ),
                          child: _isSubmitting
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  'Submit Withdraw Request',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            if (!_isLoadingHistory && _historyError == null) ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          icon: Icons.format_list_numbered,
                          iconColor: const Color(0xFF0EA5E9),
                          label: 'Total',
                          value: _stats['count'].toString(),
                          cardColor: cardColor,
                          textColor: textColor,
                          borderColor: borderColor,
                          isDark: isDark,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          icon: Icons.check_circle,
                          iconColor: _approved,
                          label: 'Approved',
                          value: formatCurrency(_stats['approved']),
                          cardColor: cardColor,
                          textColor: textColor,
                          borderColor: borderColor,
                          isDark: isDark,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          icon: Icons.access_time_filled,
                          iconColor: _pending,
                          label: 'Pending',
                          value: formatCurrency(_stats['pending']),
                          cardColor: cardColor,
                          textColor: textColor,
                          borderColor: borderColor,
                          isDark: isDark,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

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
                      controller: _searchCtrl,
                      onChanged: (value) => setState(() => _searchQuery = value.toLowerCase()),
                      decoration: InputDecoration(
                        hintText: 'Search by method, account or status...',
                        hintStyle: TextStyle(color: secondaryTextColor),
                        prefixIcon: Icon(Icons.search, color: secondaryTextColor),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: Icon(Icons.close, color: secondaryTextColor, size: 18),
                                onPressed: () {
                                  _searchCtrl.clear();
                                  setState(() => _searchQuery = '');
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                      style: TextStyle(color: textColor),
                    ),
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                  child: Row(
                    children: [
                      Container(
                        width: 4,
                        height: 18,
                        decoration: BoxDecoration(
                          color: const Color(0xFF0EA5E9),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Withdraw History',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            if (_isLoadingHistory)
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => _buildShimmerCard(cardColor, isDark),
                  childCount: 5,
                ),
              )
            else if (_historyError != null)
              SliverFillRemaining(
                child: _buildErrorState(_historyError!, isDark),
              )
            else if (_filtered.isEmpty)
              SliverFillRemaining(
                child: _buildEmptyState(
                  isDark,
                  _searchQuery.isNotEmpty,
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final item = _filtered[index];
                    return AnimatedBuilder(
                      animation: _animationController,
                      builder: (context, child) {
                        final delay = (index * 0.05).clamp(0.0, 0.95);
                        final value = (_animationController.value - delay).clamp(0.0, 1.0);
                        return Transform.translate(
                          offset: Offset(0, 20 * (1 - value)),
                          child: Opacity(
                            opacity: value,
                            child: child,
                          ),
                        );
                      },
                      child: _buildWithdrawCard(
                        item: item,
                        isDark: isDark,
                        cardColor: cardColor,
                        textColor: textColor,
                        borderColor: borderColor,
                        secondaryText: secondaryTextColor,
                      ),
                    );
                  },
                  childCount: _filtered.length,
                ),
              ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }

  Widget _buildFormField({
    required TextEditingController ctrl,
    required String label,
    required String hint,
    required IconData icon,
    required Color textColor,
    required Color sub,
    required Color border,
    required Color fill,
    TextInputType keyboard = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: sub,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: fill,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: border),
          ),
          child: TextField(
            controller: ctrl,
            keyboardType: keyboard,
            style: TextStyle(fontSize: 14, color: textColor),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: sub),
              prefixIcon: Icon(icon, size: 18, color: sub),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 13,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    required Color cardColor,
    required Color textColor,
    required Color borderColor,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: 16),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: textColor,
              letterSpacing: -0.3,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: _secondaryTextColor(isDark),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWithdrawCard({
    required WithdrawItem item,
    required bool isDark,
    required Color cardColor,
    required Color textColor,
    required Color borderColor,
    required Color secondaryText,
  }) {
    final sc = _statusColor(item.status);
    final isPending = item.status == 'pending';

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isPending ? sc.withOpacity(0.4) : borderColor,
          width: isPending ? 1.5 : 1,
        ),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: item.id != null
              ? () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => WithdrawDetailPage(item: item),
                    ),
                  )
              : null,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: sc.withOpacity(0.12),
                        shape: BoxShape.circle,
                        border: Border.all(color: sc.withOpacity(0.3)),
                      ),
                      child: Icon(
                        _statusIcon(item.status),
                        color: sc,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.method.toUpperCase(),
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.phone_android,
                                size: 12,
                                color: secondaryText,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  item.accountNo,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: secondaryText,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: sc.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(_statusIcon(item.status), size: 11, color: sc),
                                const SizedBox(width: 4),
                                Text(
                                  _statusLabel(item.status),
                                  style: TextStyle(
                                    color: sc,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          formatCurrency(item.amount),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: sc,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 12,
                          color: secondaryText,
                        ),
                      ],
                    ),
                  ],
                ),
                if (item.accountHolder.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _buildChip(
                    icon: Icons.person_outline,
                    label: item.accountHolder,
                    isDark: isDark,
                    textColor: textColor,
                    sub: secondaryText,
                  ),
                ],
                if (item.trxId != null && item.trxId!.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  _buildChip(
                    icon: Icons.receipt_long,
                    label: 'TRX: ${item.trxId}',
                    isDark: isDark,
                    textColor: textColor,
                    sub: secondaryText,
                  ),
                ],
                if (item.remarks != null && item.remarks!.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  _buildChip(
                    icon: Icons.chat_bubble_outline,
                    label: item.remarks!,
                    isDark: isDark,
                    textColor: textColor,
                    sub: secondaryText,
                  ),
                ],
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.access_time, size: 10, color: secondaryText),
                    const SizedBox(width: 4),
                    Text(
                      formatDate(item.createdAt),
                      style: TextStyle(
                        fontSize: 10,
                        color: secondaryText,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChip({
    required IconData icon,
    required String label,
    required bool isDark,
    required Color textColor,
    required Color sub,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF252525) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: sub),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11,
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

  Widget _buildShimmerCard(Color cardColor, bool isDark) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      height: 110,
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Shimmer.fromColors(
        baseColor: isDark ? const Color(0xFF1A1A1A) : Colors.grey[300]!,
        highlightColor: isDark ? const Color(0xFF2A2A2A) : Colors.grey[100]!,
        child: Container(
          margin: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 120,
                      height: 14,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 80,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark, bool isSearch) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          isSearch ? Icons.search_off : Icons.inbox,
          size: 56,
          color: isDark ? Colors.grey.shade700 : Colors.grey[400],
        ),
        const SizedBox(height: 16),
        Text(
          isSearch ? 'No results found' : 'No withdrawals yet',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.grey.shade400 : Colors.grey[600],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          isSearch
              ? 'Try a different search term'
              : 'Submit a request using the form above',
          style: TextStyle(
            fontSize: 13,
            color: isDark ? Colors.grey.shade600 : Colors.grey[500],
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState(String error, bool isDark) {
    String message = 'Something went wrong';
    IconData icon = Icons.error_outline;

    if (error.contains('Session expired') || error.contains('Token')) {
      message = 'Session expired. Please login again.';
      icon = Icons.lock;
    } else if (error.contains('Server error')) {
      message = error;
      icon = Icons.wifi_off;
    }

    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 56,
            color: isDark ? Colors.red.shade300 : Colors.red[300],
          ),
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
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _fetchHistory,
            icon: const Icon(Icons.refresh, size: 16),
            label: const Text('Try Again'),
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  isDark ? const Color(0xFF333333) : const Color(0xFF0F172A),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
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

  Color _sc(String s) =>
      s == 'approved' ? const Color(0xFF22C55E) : s == 'rejected' ? const Color(0xFFEF4444) : const Color(0xFFF59E0B);

  IconData _si(String s) =>
      s == 'approved' ? Icons.check_circle : s == 'rejected' ? Icons.cancel : Icons.access_time_filled;

  String _sl(String s) =>
      s == 'approved' ? 'Approved' : s == 'rejected' ? 'Rejected' : 'Pending';

  void _copy(BuildContext ctx, String? text) {
    if (text == null || text.isEmpty) return;
    Clipboard.setData(ClipboardData(text: text));
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
      content: const Text('Copied to clipboard'),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      duration: const Duration(seconds: 2),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0F0F0F) : const Color(0xFFF8FAFC);
    final cardColor = isDark ? const Color(0xFF1A1A1A) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final sub = isDark ? Colors.grey.shade400 : Colors.grey.shade600;
    final border = isDark ? const Color(0xFF2A2A2A) : Colors.grey.shade200;
    final sc = _sc(item.status);

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
          'Withdraw Detail',
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: sc.withOpacity(0.3)),
                boxShadow: [
                  if (!isDark)
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                ],
              ),
              child: Column(
                children: [
                  Icon(_si(item.status), color: sc, size: 48),
                  const SizedBox(height: 10),
                  Text(
                    formatCurrency(item.amount),
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                      color: sc,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                    decoration: BoxDecoration(
                      color: sc.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _sl(item.status),
                      style: TextStyle(
                        color: sc,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            _buildSection(
              title: 'Payment Info',
              icon: Icons.payment,
              isDark: isDark,
              cardColor: cardColor,
              border: border,
              textColor: textColor,
              child: Column(
                children: [
                  _buildInfoRow(
                    icon: Icons.phone_android,
                    label: 'Method',
                    value: item.method.toUpperCase(),
                    isDark: isDark,
                    textColor: textColor,
                    sub: sub,
                  ),
                  _buildDivider(isDark),
                  _buildInfoRow(
                    icon: Icons.person_outline,
                    label: 'Account Number',
                    value: item.accountNo,
                    isDark: isDark,
                    textColor: textColor,
                    sub: sub,
                    onCopy: () => _copy(context, item.accountNo),
                  ),
                  if (item.accountHolder.isNotEmpty) ...[
                    _buildDivider(isDark),
                    _buildInfoRow(
                      icon: Icons.person,
                      label: 'Account Holder',
                      value: item.accountHolder,
                      isDark: isDark,
                      textColor: textColor,
                      sub: sub,
                    ),
                  ],
                  _buildDivider(isDark),
                  _buildInfoRow(
                    icon: Icons.attach_money,
                    label: 'Amount',
                    value: formatCurrency(item.amount),
                    isDark: isDark,
                    textColor: textColor,
                    sub: sub,
                    valueColor: sc,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            _buildSection(
              title: 'Timeline',
              icon: Icons.access_time,
              isDark: isDark,
              cardColor: cardColor,
              border: border,
              textColor: textColor,
              child: Column(
                children: [
                  _buildInfoRow(
                    icon: Icons.add_circle_outline,
                    label: 'Requested At',
                    value: formatDate(item.createdAt),
                    isDark: isDark,
                    textColor: textColor,
                    sub: sub,
                  ),
                  if (item.updatedAt != null) ...[
                    _buildDivider(isDark),
                    _buildInfoRow(
                      icon: item.status == 'approved'
                          ? Icons.check_circle
                          : Icons.cancel,
                      label: item.status == 'approved' ? 'Approved At' : 'Rejected At',
                      value: formatDate(item.updatedAt),
                      isDark: isDark,
                      textColor: textColor,
                      sub: sub,
                      valueColor: sc,
                    ),
                  ],
                  if (item.trxId != null && item.trxId!.isNotEmpty) ...[
                    _buildDivider(isDark),
                    _buildInfoRow(
                      icon: Icons.receipt_long,
                      label: 'TRX ID',
                      value: item.trxId!,
                      isDark: isDark,
                      textColor: textColor,
                      sub: sub,
                      onCopy: () => _copy(context, item.trxId),
                    ),
                  ],
                  if (item.remarks != null && item.remarks!.isNotEmpty) ...[
                    _buildDivider(isDark),
                    _buildInfoRow(
                      icon: Icons.chat_bubble_outline,
                      label: 'Remarks',
                      value: item.remarks!,
                      isDark: isDark,
                      textColor: textColor,
                      sub: sub,
                    ),
                  ],
                ],
              ),
            ),
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
    required Color border,
    required Color textColor,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
              children: [
                Icon(icon, size: 18, color: const Color(0xFF0EA5E9)),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ],
            ),
          ),
          Divider(
            height: 1,
            color: isDark ? const Color(0xFF2A2A2A) : Colors.grey.shade100,
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: child,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required bool isDark,
    required Color textColor,
    required Color sub,
    Color? valueColor,
    VoidCallback? onCopy,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: sub),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 11, color: sub),
                ),
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
              icon: Icon(Icons.copy_outlined, size: 18, color: sub),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
        ],
      ),
    );
  }

  Widget _buildDivider(bool isDark) {
    return Divider(
      height: 16,
      color: isDark ? const Color(0xFF2A2A2A) : Colors.grey.shade100,
    );
  }
}
