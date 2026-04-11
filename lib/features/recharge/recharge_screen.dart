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
  // Design Tokens
  static const Color kBackground = Color(0xFFF8FAFC);
  static const Color kTextDark   = Color(0xFF0F172A);
  static const Color kPrimary    = Color(0xFF29B6F6);

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

  // Predefined amounts for quick selection
  final List<String> quickAmounts = ['20', '50', '100', '200', '500', '1000'];

  // 🔥 1. API Call: Execute Recharge
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
        "operator": selectedOperator, // Backend handles the lowercase
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

  // Success Dialog with Lottie Animation
  void _showSuccessDialog(String trxid) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Lottie.network(
              'https://lottie.host/86d49492-9387-434a-91d8-06775797669d/Asf7H2WvKz.json', // Success Checkmark
              height: 120.h,
              repeat: false,
            ),
            Text('Success!', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18.sp)),
            SizedBox(height: 10.h),
            Text('Recharge request sent successfully.', textAlign: TextAlign.center, style: GoogleFonts.poppins(fontSize: 12.sp, color: Colors.grey)),
            SizedBox(height: 5.h),
            SelectableText('TRX: $trxid', style: GoogleFonts.poppins(fontSize: 11.sp, fontWeight: FontWeight.bold, color: kPrimary)),
            SizedBox(height: 20.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: kPrimary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r))),
                onPressed: () {
                  Navigator.pop(context);
                  _numberController.clear();
                  _amountController.clear();
                },
                child: const Text('OK', style: TextStyle(color: Colors.white)),
              ),
            )
          ],
        ),
      ),
    );
  }

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: color, behavior: SnackBarBehavior.floating));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppBar(
        title: Text('Mobile Recharge', style: GoogleFonts.poppins(fontSize: 18.sp, fontWeight: FontWeight.bold, color: kTextDark)),
        backgroundColor: Colors.white, elevation: 0.5, centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Number Input
            _buildSectionTitle("Enter Mobile Number"),
            _buildTextField(_numberController, "01XXXXXXXXX", CupertinoIcons.phone, TextInputType.phone),

            SizedBox(height: 20.h),

            // Operator Selection
            _buildSectionTitle("Select Operator"),
            SizedBox(height: 10.h),
            _buildOperatorSelector(),

            SizedBox(height: 25.h),

            // Amount Input
            _buildSectionTitle("Recharge Amount"),
            _buildTextField(_amountController, "Amount (BDT)", CupertinoIcons.money_dollar, TextInputType.number),

            // Quick Amount Chips
            SizedBox(height: 15.h),
            Wrap(
              spacing: 10.w,
              children: quickAmounts.map((amt) => ActionChip(
                label: Text('৳$amt'),
                backgroundColor: Colors.white,
                labelStyle: GoogleFonts.poppins(fontSize: 12.sp, color: kTextDark),
                onPressed: () => setState(() => _amountController.text = amt),
              )).toList(),
            ),

            SizedBox(height: 40.h),

            // Submit Button
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
                  : Text('Recharge Now', style: GoogleFonts.poppins(fontSize: 16.sp, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: GoogleFonts.poppins(fontSize: 14.sp, fontWeight: FontWeight.w600, color: kTextDark));
  }

  Widget _buildTextField(TextEditingController controller, String hint, IconData icon, TextInputType type) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15.r), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)]),
      child: TextField(
        controller: controller,
        keyboardType: type,
        style: GoogleFonts.poppins(fontSize: 15.sp),
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon, color: Colors.grey),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 15.h),
        ),
      ),
    );
  }

  Widget _buildOperatorSelector() {
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
                color: isSelected ? operatorColors[op] : Colors.white,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: isSelected ? operatorColors[op]! : Colors.grey.shade200),
              ),
              child: Center(
                child: Text(
                  operatorNames[op]!,
                  style: GoogleFonts.poppins(fontSize: 12.sp, color: isSelected ? Colors.white : Colors.grey, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
