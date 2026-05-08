import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../wallet_page.dart';

class WeeklyIncomePage extends StatefulWidget {
  const WeeklyIncomePage({super.key});
  @override
  State<WeeklyIncomePage> createState() => _WeeklyIncomePageState();
}

class _WeeklyIncomePageState extends State<WeeklyIncomePage> {
  static const Color _accent = Color(0xFF29B6F6);
  bool _isLoading = true;
  String? _error;
  double _totalIncome = 0.0;

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
      _totalIncome = await WalletApiService.fetchWeeklyIncome(token);
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
              : Center(
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
                          child: Icon(
                            CupertinoIcons.moon_stars_fill,
                            color: _accent,
                            size: 60.sp,
                          ),
                        ),
                        SizedBox(height: 24.h),
                        Text(
                          '৳ ${_totalIncome.toStringAsFixed(2)}',
                          style: GoogleFonts.poppins(
                            fontSize: 36.sp,
                            fontWeight: FontWeight.w900,
                            color: _accent,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          "This Week's Earnings",
                          style: GoogleFonts.poppins(
                            fontSize: 14.sp,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),
    );
  }
}
