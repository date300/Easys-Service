import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../main.dart';

// ========== Models ==========
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

// ========== Helpers ==========
String formatCurrency(double amount) {
  final formatter = NumberFormat.currency(
    locale: 'bn_BD',
    symbol: '৳',
    decimalDigits: 0,
  );
  return formatter.format(amount);
}

// ========== API Service ==========
class WalletApiService {
  static const String _baseUrl = 'https://api.easysarvice.com/api';

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

// ========== Compact Wallet Page ==========
class WalletPage extends ConsumerStatefulWidget {
  const WalletPage({super.key});
  @override
  ConsumerState<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends ConsumerState<WalletPage> {
  static const Color _accent      = Color(0xFF0EA5E9);
  static const Color _accentLight = Color(0xFF38BDF8);
  static const Color _accentDeep  = Color(0xFF0284C7);

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
    final bgColor   = isDark ? const Color(0xFF0F0F0F) : const Color(0xFFF8FAFC);
    final cardColor = isDark ? const Color(0xFF1A1A1A) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final subColor  = isDark ? Colors.grey.shade400 : Colors.grey.shade600;
    final borderColor = isDark ? const Color(0xFF2A2A2A) : Colors.grey.shade200;

    return Scaffold(
      backgroundColor: bgColor,
      body: RefreshIndicator(
        color: _accent,
        backgroundColor: cardColor,
        onRefresh: () async {
          HapticFeedback.mediumImpact();
          await _fetchBalance();
        },
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Compact Balance Card
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: borderColor),
                        boxShadow: [
                          if (!isDark)
                            BoxShadow(
                              color: Colors.black.withOpacity(0.03),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Compact Wallet Illustration
                          _buildCompactWallet(isDark),
                          const SizedBox(height: 10),
                          Text(
                            'My Wallet',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'View all your earnings',
                            style: TextStyle(
                              fontSize: 11,
                              color: subColor,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Compact Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: _actionBtn(
                            label: 'Withdraw',
                            icon: Icons.arrow_upward,
                            onTap: () {
                              HapticFeedback.mediumImpact();
                              ref.read(detailViewTitleProvider.notifier).state = 'Withdraw';
                              context.push('/withdraw');
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _actionBtn(
                            label: 'History',
                            icon: Icons.history,
                            onTap: () {
                              HapticFeedback.mediumImpact();
                              ref.read(detailViewTitleProvider.notifier).state = 'Transaction History';
                              context.push('/transactions');
                            },
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    // Compact Income Menu
                    _menuItem(
                      label: 'Daily Income',
                      icon: Icons.wb_sunny,
                      cardColor: cardColor,
                      textColor: textColor,
                      borderColor: borderColor,
                      isDark: isDark,
                      onTap: () {
                        HapticFeedback.lightImpact();
                        ref.read(detailViewTitleProvider.notifier).state = 'Daily Income';
                        context.push('/daily-income');
                      },
                    ),
                    _menuItem(
                      label: 'Weekly Income',
                      icon: Icons.date_range,
                      cardColor: cardColor,
                      textColor: textColor,
                      borderColor: borderColor,
                      isDark: isDark,
                      onTap: () {
                        HapticFeedback.lightImpact();
                        ref.read(detailViewTitleProvider.notifier).state = 'Weekly Income';
                        context.push('/weekly-income');
                      },
                    ),
                    _menuItem(
                      label: 'Monthly & Total',
                      icon: Icons.calendar_month,
                      cardColor: cardColor,
                      textColor: textColor,
                      borderColor: borderColor,
                      isDark: isDark,
                      onTap: () {
                        HapticFeedback.lightImpact();
                        ref.read(detailViewTitleProvider.notifier).state = 'Monthly & Total';
                        context.push('/monthly-income');
                      },
                    ),

                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactWallet(bool isDark) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_accentLight, _accent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: _accent.withOpacity(0.25),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background decoration
          Positioned(
            right: -20,
            top: -20,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            left: -10,
            bottom: -10,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
            ),
          ),
          // Content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.account_balance_wallet,
                      color: Colors.white.withOpacity(0.9),
                      size: 18,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Balance',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                _isLoading
                    ? _buildShimmer()
                    : _error != null
                        ? GestureDetector(
                            onTap: _fetchBalance,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'Tap to Retry',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          )
                        : Text(
                            formatCurrency(_balance?.balance ?? 0),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.5,
                            ),
                          ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.white.withOpacity(0.3),
      highlightColor: Colors.white.withOpacity(0.5),
      child: Container(
        width: 120,
        height: 28,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6),
        ),
      ),
    );
  }

  Widget _actionBtn({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [_accentLight, _accent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: _accent.withOpacity(0.25),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 14),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _menuItem({
    required String label,
    required IconData icon,
    required Color cardColor,
    required Color textColor,
    required Color borderColor,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: cardColor,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: borderColor),
              boxShadow: [
                if (!isDark)
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: _accent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: _accent, size: 16),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
                  size: 12,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
