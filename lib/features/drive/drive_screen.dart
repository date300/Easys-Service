import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';

class DriveScreen extends StatefulWidget {
  const DriveScreen({super.key});

  @override
  State<DriveScreen> createState() => _DriveScreenState();
}

class _DriveScreenState extends State<DriveScreen> {
  static const Color kPrimary = Color(0xFF29B6F6);

  final List<String> operators = ['gp', 'robi', 'airtel', 'bl', 'teletalk', 'skitto'];

  final Map<String, String> operatorNames = {
    'gp': 'Grameenphone', 'robi': 'Robi', 'airtel': 'Airtel',
    'bl': 'Banglalink', 'teletalk': 'Teletalk', 'skitto': 'Skitto',
  };

  final Map<String, Color> operatorColors = {
    'gp': const Color(0xFF009B77), 'robi': const Color(0xFF9C27B0), 'airtel': const Color(0xFFE40000),
    'bl': const Color(0xFFE8000D), 'teletalk': const Color(0xFF003399), 'skitto': const Color(0xFFFF6B00),
  };

  final Map<String, String> operatorCodes = {
    'gp': 'GP', 'robi': 'ROBI', 'airtel': 'AIRTEL', 'bl': 'BL', 'teletalk': 'TELETALK', 'skitto': 'SKITTO',
  };

  final Map<String, List<String>> operatorCategories = {
    'gp': ['All', 'Internet', 'Minute', 'Bundle'],
    'robi': ['All', 'Internet', 'Talktime', 'Combo'],
    'airtel': ['All', 'Data', 'Voice', 'Mixed'],
    'bl': ['All', 'Internet', 'Minute', 'Bundle'],
    'teletalk': ['All', 'Internet', 'Minute', 'Bundle'],
    'skitto': ['All', 'Data', 'Voice', 'Combo'],
  };

  String selectedOperator = 'gp';
  String selectedCategory = 'All';
  List<dynamic> drives = [];
  List<dynamic> filteredDrives = [];
  bool isLoading = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchDrives(selectedOperator);
  }

  Future<void> fetchDrives(String operator) async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final opCode = operator.toLowerCase();
      final response = await http
          .get(Uri.parse('https://easy.ltcminematrix.com/api/recharge/drives/$opCode'))
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        if (json['success'] == true) {
          setState(() {
            drives = json['data']['drives'] ?? [];
            _filterDrives();
            isLoading = false;
          });
        } else {
          setState(() {
            errorMessage = "API Error: ${json['message'] ?? 'Unknown'}";
            isLoading = false;
          });
        }
      } else {
        setState(() { errorMessage = 'Server Error: ${response.statusCode}'; isLoading = false; });
      }
    } catch (_) {
      setState(() { errorMessage = 'Connection failed! Please try again.'; isLoading = false; });
    }
  }

  void _filterDrives() {
    if (selectedCategory == 'All') {
      filteredDrives = drives;
      return;
    }
    final cat = selectedCategory.toLowerCase();
    filteredDrives = drives.where((drive) {
      final t = (drive['title'] ?? '').toString().toLowerCase();
      if (cat == 'internet' || cat == 'data') return t.contains('gb') || t.contains('mb');
      if (cat == 'minute' || cat == 'talktime' || cat == 'voice') return t.contains('min');
      if (cat == 'bundle' || cat == 'combo') return t.contains('gb') && t.contains('min');
      return true;
    }).toList();
  }

  Future<void> _executePurchase(Map<String, dynamic> drive, String number) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: CircularProgressIndicator(
          color: kPrimary,
          backgroundColor: isDark ? const Color(0xFF333333) : null,
        ),
      ),
    );

    try {
      final payload = {
        "number": number,
        "amount": drive['price'],
        "operator": selectedOperator.toLowerCase(),
      };

      final response = await http.post(
        Uri.parse('https://easy.ltcminematrix.com/api/recharge/recharge'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(payload),
      ).timeout(const Duration(seconds: 20));

      Navigator.pop(context);

      final resData = jsonDecode(response.body);
      if (response.statusCode == 200 && resData['success'] == true) {
        _showStatusSnack("Order Placed! TRX ID: ${resData['trxid']}", Colors.green);
      } else {
        _showStatusSnack(resData['message'] ?? "Purchase failed!", Colors.red);
      }
    } catch (e) {
      Navigator.pop(context);
      _showStatusSnack("Server connection error!", Colors.red);
    }
  }

  void _showStatusSnack(String msg, Color color) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          msg,
          style: GoogleFonts.poppins(color: Colors.white),
        ),
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.r),
        ),
      ),
    );
  }

  void _openPurchaseSheet(Map<String, dynamic> drive) {
    final TextEditingController numController = TextEditingController();
    final color = operatorColors[selectedOperator]!;
    
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sheetBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final textMid = isDark ? Colors.grey.shade400 : const Color(0xFF475569);
    final fieldBg = isDark ? const Color(0xFF2C2C2C) : Colors.white;
    final borderColor = isDark ? const Color(0xFF333333) : Colors.grey.shade300;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: sheetBg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 20.w,
          right: 20.w,
          top: 20.h,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF333333) : Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            SizedBox(height: 15.h),
            Text(
              'Confirm Order',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 16.sp,
                color: textColor,
              ),
            ),
            SizedBox(height: 5.h),
            Text(
              drive['title'],
              style: GoogleFonts.poppins(
                fontSize: 12.sp,
                color: textMid,
              ),
            ),
            SizedBox(height: 20.h),
            TextField(
              controller: numController,
              keyboardType: TextInputType.phone,
              style: GoogleFonts.poppins(color: textColor),
              decoration: InputDecoration(
                labelText: 'Mobile Number',
                labelStyle: GoogleFonts.poppins(color: textMid),
                hintText: '01XXXXXXXXX',
                hintStyle: GoogleFonts.poppins(color: isDark ? Colors.grey.shade600 : Colors.grey),
                prefixIcon: Icon(CupertinoIcons.phone, color: textMid),
                filled: true,
                fillColor: fieldBg,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(color: borderColor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(color: borderColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(color: kPrimary),
                ),
              ),
            ),
            SizedBox(height: 20.h),
            SizedBox(
              width: double.infinity,
              height: 50.h,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                onPressed: () {
                  if (numController.text.length == 11) {
                    Navigator.pop(context);
                    _executePurchase(drive, numController.text);
                  } else {
                    _showStatusSnack("Please enter a valid 11-digit number", Colors.orange);
                  }
                },
                child: Text(
                  'Confirm Purchase ৳${drive['price']}',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14.sp,
                  ),
                ),
              ),
            ),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final kBackground = isDark ? const Color(0xFF121212) : const Color(0xFFF8FAFC);
    final kTextDark = isDark ? Colors.white : const Color(0xFF0F172A);
    final kTextMid = isDark ? Colors.grey.shade400 : const Color(0xFF475569);
    final appBarBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final cardBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final shadowColor = isDark ? Colors.black.withOpacity(0.3) : Colors.black.withOpacity(0.04);
    final chipBg = isDark ? const Color(0xFF2C2C2C) : const Color(0xFFF8FAFC);
    final chipBorder = isDark ? const Color(0xFF333333) : Colors.grey.shade300;

    return Scaffold(
      backgroundColor: kBackground,
      // ❌ appBar: AppBar(...) বাদ দেওয়া হলো
      // MainWrapper এর AppTopBar ই যথেষ্ট
      body: Column(
        children: [
          _buildOperatorTabs(isDark, appBarBg, kTextDark),
          _buildCategoryChips(isDark, chipBg, kTextMid, chipBorder),
          Expanded(child: _buildBody(isDark, kBackground, kTextDark, kTextMid, cardBg, shadowColor)),
        ],
      ),
    );
  }

  Widget _buildOperatorTabs(bool isDark, Color appBarBg, Color kTextDark) {
    return Container(
      height: 65.h,
      color: appBarBg,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: operators.length,
        padding: EdgeInsets.symmetric(horizontal: 10.w),
        itemBuilder: (context, i) {
          final op = operators[i];
          final isSel = op == selectedOperator;
          return GestureDetector(
            onTap: () {
              setState(() => selectedOperator = op);
              fetchDrives(op);
            },
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 6.w, vertical: 12.h),
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              decoration: BoxDecoration(
                color: isSel ? operatorColors[op] : Colors.transparent,
                borderRadius: BorderRadius.circular(25.r),
                border: Border.all(
                  color: isSel ? operatorColors[op]! : (isDark ? const Color(0xFF444444) : Colors.grey.shade300),
                ),
              ),
              child: Center(
                child: Text(
                  operatorNames[op]!,
                  style: GoogleFonts.poppins(
                    color: isSel ? Colors.white : kTextDark,
                    fontSize: 12.sp,
                    fontWeight: isSel ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategoryChips(bool isDark, Color chipBg, Color kTextMid, Color chipBorder) {
    final cats = operatorCategories[selectedOperator]!;
    return Container(
      height: 45.h,
      color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: cats.length,
        itemBuilder: (context, i) => GestureDetector(
          onTap: () {
            setState(() => selectedCategory = cats[i]);
            _filterDrives();
          },
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 8.w, vertical: 5.h),
            padding: EdgeInsets.symmetric(horizontal: 18.w),
            decoration: BoxDecoration(
              color: selectedCategory == cats[i] 
                  ? operatorColors[selectedOperator]!.withOpacity(0.1) 
                  : chipBg,
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(
                color: selectedCategory == cats[i] 
                    ? operatorColors[selectedOperator]! 
                    : chipBorder,
              ),
            ),
            child: Center(
              child: Text(
                cats[i],
                style: GoogleFonts.poppins(
                  fontSize: 11.sp,
                  color: selectedCategory == cats[i] 
                      ? operatorColors[selectedOperator] 
                      : kTextMid,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(
    bool isDark,
    Color kBackground,
    Color kTextDark,
    Color kTextMid,
    Color cardBg,
    Color shadowColor,
  ) {
    if (isLoading) {
      return Center(
        child: CircularProgressIndicator(
          color: kPrimary,
          backgroundColor: isDark ? const Color(0xFF333333) : null,
        ),
      );
    }

    if (errorMessage != null) {
      return Center(
        child: Text(
          errorMessage!,
          style: GoogleFonts.poppins(
            color: isDark ? Colors.redAccent : Colors.red,
          ),
        ),
      );
    }

    if (filteredDrives.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.network(
              'https://lottie.host/17e089d8-99ed-498c-850f-f1cbba20251c/MowR12iE75.json',
              height: 200.h,
              errorBuilder: (context, error, stackTrace) => Icon(
                Icons.folder_open,
                size: 80,
                color: isDark ? Colors.grey.shade600 : Colors.grey,
              ),
            ),
            SizedBox(height: 10.h),
            Text(
              'No Offers Found!',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                color: kTextMid,
              ),
            ),
            Text(
              'Try checking another operator.',
              style: GoogleFonts.poppins(
                fontSize: 12.sp,
                color: isDark ? Colors.grey.shade500 : Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: filteredDrives.length,
      padding: EdgeInsets.all(16.w),
      itemBuilder: (context, i) {
        final drive = filteredDrives[i];
        return Container(
          margin: EdgeInsets.only(bottom: 12.h),
          padding: EdgeInsets.all(15.w),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(15.r),
            boxShadow: [
              BoxShadow(
                color: shadowColor,
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
            border: isDark ? Border.all(color: const Color(0xFF333333), width: 1) : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                drive['title'],
                style: GoogleFonts.poppins(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.bold,
                  color: kTextDark,
                ),
              ),
              Divider(
                color: isDark ? const Color(0xFF333333) : Colors.grey.shade300,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "৳${drive['price']}",
                        style: GoogleFonts.poppins(
                          fontSize: 16.sp,
                          color: kPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "Validity: ${drive['duration']} Days",
                        style: GoogleFonts.poppins(
                          fontSize: 10.sp,
                          color: kTextMid,
                        ),
                      ),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: () => _openPurchaseSheet(drive),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: operatorColors[selectedOperator],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                    child: Text(
                      'Buy Now',
                      style: GoogleFonts.poppins(
                        fontSize: 12.sp,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
