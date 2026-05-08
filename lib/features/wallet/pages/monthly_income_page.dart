import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../wallet_page.dart';

class MonthlyIncomePage extends StatefulWidget {
  const MonthlyIncomePage({super.key});
  @override
  State<MonthlyIncomePage> createState() => _MonthlyIncomePageState();
}

class _MonthlyIncomePageState extends State<MonthlyIncomePage> {
  static const Color _accent = Color(0xFF29B6F6);
  bool _isLoading = true;
  String? _error;
  Map<String, double> _summary = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token') ?? '';
    if (token.isEmpty) {
      setState(() { _error = 'Token missing'; _isLoading = false; });
      return;
    }
    try {
      _summary = await WalletApiService.fetchIncomeSummary(token);
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
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF5F5F5),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: _accent))
          : _error != null
              ? Center(
                  child: Padding(
                    padding: EdgeInsets.all(24.w),
                    child: Text(
                      _error!,
                      style: TextStyle(color: Colors.red, fontSize: 16.sp),
                    ),
                  ),
                )
              : ListView(
                  padding: EdgeInsets.all(24.w),
                  children: [
                    _summaryCard('Today', _summary['daily'] ?? 0, isDark),
                    SizedBox(height: 12.h),
                    _summaryCard('This Week', _summary['weekly'] ?? 0, isDark),
                    SizedBox(height: 12.h),
                    _summaryCard('This Month', _summary['monthly'] ?? 0, isDark),
                  ],
                ),
    );
  }

  Widget _summaryCard(String label, double amount, bool isDark) {
    return Container(
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
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
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            '৳ ${amount.toStringAsFixed(2)}',
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
