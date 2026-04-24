import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';

class RechargeScreen extends StatefulWidget {
  const RechargeScreen({super.key});

  @override
  State<RechargeScreen> createState() => _RechargeScreenState();
}

class _RechargeScreenState extends State<RechargeScreen> {
  static const Color kPrimary = Color(0xFF29B6F6);

  final List<String> operators = ['gp', 'robi', 'airtel', 'bl', 'teletalk'];
  
  final Map<String, String> operatorNames = {
    'gp': 'Grameenphone', 'robi': 'Robi', 'airtel': 'Airtel',
    'bl': 'Banglalink', 'teletalk': 'Teletalk',
  };

  final Map<String, Color> operatorColors = {
    'gp': const Color(0xFF009B77), 'robi': const Color(0xFF9C27B0), 'airtel': const Color(0xFFE40000),
    'bl': const Color(0xFFE8000D), 'teletalk': const Color(0xFF003399),
  };

  String selectedOperator = 'gp';
  final TextEditingController _numberController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  bool isProcessing = false;

  final List<String> quickAmounts = ['20', '50', '100', '200', '500', '1000'];

  Future<void> _handleRecharge() async {
    final number = _numberController.text.trim();
    final amount = _amountController.text.trim();

    if (number.length != 11 || amount.isEmpty) {
      _showSnack("Please enter a valid 11-digit number and amount", Colors.orange);
      return;
    }

    setState(() => isProcessing = true);

    try {
      final payload = {
        "number": number,
        "amount": amount,
        "operator": selectedOperator,
      };

      final response = await http.post(
        Uri.parse('https://easy.ltcminematrix.com/api/recharge/recharge'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(payload),
      ).timeout(const Duration(seconds: 20));

      final resData = jsonDecode(response.body);

      if (response.statusCode == 200 && resData['success'] == true) {
        _showSuccessDialog(resData['trxid']);
      } else {
        _showSnack(resData['message'] ?? "Recharge failed", Colors.red);
      }
    } catch (e) {
      _showSnack("Connection error. Try again later.", Colors.red);
    } finally {
      setState(() => isProcessing = false);
    }
  }

  void _showSuccessDialog(String trxid) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dialogBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final subTextColor = isDark ? Colors.grey.shade400 : Colors.grey;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: dialogBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Lottie.network(
              'https://lottie.host/86d49492-9387-434a-91d8-06775797669d/Asf7H2WvKz.json',
              height: 120.h,
              repeat: false,
            ),
            Text(
              'Success!',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 18.sp,
                color: textColor,
              ),
            ),
            SizedBox(height: 10.h),
            Text(
              'Recharge request sent successfully.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 12.sp,
                color: subTextColor,
              ),
            ),
            SizedBox(height: 5.h),
            SelectableText(
              'TRX: $trxid',
              style: GoogleFonts.poppins(
                fontSize: 11.sp,
                fontWeight: FontWeight.bold,
                color: kPrimary,
              ),
            ),
            SizedBox(height: 20.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  _numberController.clear();
                  _amountController.clear();
                },
                child: const Text('OK', style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSnack(String msg, Color color) {
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final kBackground = isDark ? const Color(0xFF121212) : const Color(0xFFF8FAFC);
    final kTextDark = isDark ? Colors.white : const Color(0xFF0F172A);
    final cardBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final shadowColor = isDark ? Colors.black.withOpacity(0.3) : Colors.black.withOpacity(0.02);
    final fieldBorder = isDark ? const Color(0xFF333333) : Colors.grey.shade200;
    final hintColor = isDark ? Colors.grey.shade500 : Colors.grey;
    final iconColor = isDark ? Colors.grey.shade400 : Colors.grey;
    final chipBg = isDark ? const Color(0xFF2C2C2C) : Colors.white;
    final chipBorder = isDark ? const Color(0xFF444444) : Colors.grey.shade200;
    final chipText = isDark ? Colors.grey.shade400 : Colors.grey;

    return Scaffold(
      backgroundColor: kBackground,
      // ❌ appBar: AppBar(...) বাদ দেওয়া হলো
      // MainWrapper এর AppTopBar ই যথেষ্ট
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle("Enter Mobile Number", kTextDark),
            _buildTextField(
              _numberController,
              "01XXXXXXXXX",
              CupertinoIcons.phone,
              TextInputType.phone,
              cardBg,
              shadowColor,
              fieldBorder,
              hintColor,
              iconColor,
              kTextDark,
            ),

            SizedBox(height: 20.h),

            _buildSectionTitle("Select Operator", kTextDark),
            SizedBox(height: 10.h),
            _buildOperatorSelector(chipBg, chipBorder, chipText, kTextDark),

            SizedBox(height: 25.h),

            _buildSectionTitle("Recharge Amount", kTextDark),
            _buildTextField(
              _amountController,
              "Amount (BDT)",
              CupertinoIcons.money_dollar,
              TextInputType.number,
              cardBg,
              shadowColor,
              fieldBorder,
              hintColor,
              iconColor,
              kTextDark,
            ),

            SizedBox(height: 15.h),
            Wrap(
              spacing: 10.w,
              children: quickAmounts.map((amt) => ActionChip(
                label: Text('৳$amt'),
                backgroundColor: chipBg,
                side: BorderSide(color: chipBorder),
                labelStyle: GoogleFonts.poppins(
                  fontSize: 12.sp,
                  color: kTextDark,
                ),
                onPressed: () => setState(() => _amountController.text = amt),
              )).toList(),
            ),

            SizedBox(height: 40.h),

            SizedBox(
              width: double.infinity,
              height: 55.h,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: operatorColors[selectedOperator],
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.r)),
                  elevation: 0,
                ),
                onPressed: isProcessing ? null : _handleRecharge,
                child: isProcessing 
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(
                      'Recharge Now',
                      style: GoogleFonts.poppins(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, Color kTextDark) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 14.sp,
        fontWeight: FontWeight.w600,
        color: kTextDark,
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hint,
    IconData icon,
    TextInputType type,
    Color cardBg,
    Color shadowColor,
    Color fieldBorder,
    Color hintColor,
    Color iconColor,
    Color textColor,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(15.r),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: 10,
          ),
        ],
        border: Border.all(color: fieldBorder, width: 1),
      ),
      child: TextField(
        controller: controller,
        keyboardType: type,
        style: GoogleFonts.poppins(
          fontSize: 15.sp,
          color: textColor,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.poppins(color: hintColor),
          prefixIcon: Icon(icon, color: iconColor),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 15.h),
        ),
      ),
    );
  }

  Widget _buildOperatorSelector(
    Color chipBg,
    Color chipBorder,
    Color chipText,
    Color selectedTextColor,
  ) {
    return SizedBox(
      height: 50.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: operators.length,
        itemBuilder: (context, i) {
          final op = operators[i];
          final isSelected = selectedOperator == op;
          return GestureDetector(
            onTap: () => setState(() => selectedOperator = op),
            child: Container(
              margin: EdgeInsets.only(right: 10.w),
              padding: EdgeInsets.symmetric(horizontal: 15.w),
              decoration: BoxDecoration(
                color: isSelected ? operatorColors[op] : chipBg,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: isSelected ? operatorColors[op]! : chipBorder,
                ),
              ),
              child: Center(
                child: Text(
                  operatorNames[op]!,
                  style: GoogleFonts.poppins(
                    fontSize: 12.sp,
                    color: isSelected ? Colors.white : chipText,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
