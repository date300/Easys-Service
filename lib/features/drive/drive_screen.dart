import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;

class DriveScreen extends StatefulWidget {
  const DriveScreen({super.key});

  @override
  State<DriveScreen> createState() => _DriveScreenState();
}

class _DriveScreenState extends State<DriveScreen> {
  static const Color kBackground = Color(0xFFF8FAFC);
  static const Color kTextDark   = Color(0xFF0F172A);
  static const Color kTextMid    = Color(0xFF475569);
  static const Color kPrimary    = Color(0xFF29B6F6);

  final List<String> operators = ['gp', 'robi', 'airtel', 'bl', 'teletalk', 'skitto'];

  final Map<String, String> operatorNames = {
    'gp': 'Grameenphone', 'robi': 'Robi', 'airtel': 'Airtel',
    'bl': 'Banglalink', 'teletalk': 'Teletalk', 'skitto': 'Skitto',
  };

  final Map<String, Color> operatorColors = {
    'gp': Color(0xFF009B77), 'robi': Color(0xFF9C27B0), 'airtel': Color(0xFFE40000),
    'bl': Color(0xFFE8000D), 'teletalk': Color(0xFF003399), 'skitto': Color(0xFFFF6B00),
  };

  final Map<String, String> operatorCodes = {
    'gp': 'GP', 'robi': 'RB', 'airtel': 'AT', 'bl': 'BL', 'teletalk': 'TT', 'skitto': 'SK',
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

  // 🔥 API: Fetch Drives
  Future<void> fetchDrives(String operator) async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final opCode = operatorCodes[operator]!.toLowerCase();
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
        setState(() { errorMessage = 'Server error: ${response.statusCode}'; isLoading = false; });
      }
    } catch (_) {
      setState(() { errorMessage = 'Connection failed. Please try again.'; isLoading = false; });
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

  // 🛒 Function: Purchase Execution
  Future<void> _executePurchase(Map<String, dynamic> drive, String number) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator(color: kPrimary)),
    );

    try {
      final payload = {
        "number": number,
        "amount": drive['price'],
        "operator": operatorCodes[selectedOperator],
        "package_id": drive['driveId'].toString(),
        "type": "drive"
      };

      final response = await http.post(
        Uri.parse('https://easy.ltcminematrix.com/api/recharge/recharge'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(payload),
      ).timeout(const Duration(seconds: 20));

      Navigator.pop(context); // Close loading

      final resData = jsonDecode(response.body);
      if (response.statusCode == 200 && resData['success'] == true) {
        _showStatusSnack("Request Sent! TRX: ${resData['trxid']}", Colors.green);
      } else {
        _showStatusSnack(resData['message'] ?? "Purchase Failed", Colors.red);
      }
    } catch (e) {
      Navigator.pop(context);
      _showStatusSnack("Connection Error", Colors.red);
    }
  }

  void _showStatusSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: color, behavior: SnackBarBehavior.floating),
    );
  }

  // 📝 UI: Purchase BottomSheet
  void _openPurchaseSheet(Map<String, dynamic> drive) {
    final TextEditingController numController = TextEditingController();
    final color = operatorColors[selectedOperator]!;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20.r))),
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 20.w, right: 20.w, top: 20.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Confirm Order', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16.sp)),
            SizedBox(height: 10.h),
            Text(drive['title'], textAlign: TextAlign.center, style: GoogleFonts.poppins(fontSize: 12.sp, color: kTextMid)),
            SizedBox(height: 20.h),
            TextField(
              controller: numController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                hintText: 'Enter Mobile Number',
                prefixIcon: const Icon(CupertinoIcons.phone),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
              ),
            ),
            SizedBox(height: 20.h),
            SizedBox(
              width: double.infinity,
              height: 45.h,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: color, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r))),
                onPressed: () {
                  if (numController.text.length == 11) {
                    Navigator.pop(context);
                    _executePurchase(drive, numController.text);
                  }
                },
                child: Text('Buy Now ৳${drive['price']}', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
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
    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppBar(
        title: Text('Drive Offers', style: GoogleFonts.poppins(fontSize: 18.sp, fontWeight: FontWeight.bold, color: kTextDark)),
        backgroundColor: Colors.white, elevation: 0,
      ),
      body: Column(
        children: [
          _buildOperatorTabs(),
          _buildCategoryChips(),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildOperatorTabs() {
    return Container(
      height: 60.h, color: Colors.white,
      child: ListView.builder(
        scrollDirection: Axis.horizontal, itemCount: operators.length,
        padding: EdgeInsets.symmetric(horizontal: 10.w),
        itemBuilder: (context, i) {
          final op = operators[i];
          final isSel = op == selectedOperator;
          return GestureDetector(
            onTap: () { setState(() => selectedOperator = op); fetchDrives(op); },
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 5.w, vertical: 10.h),
              padding: EdgeInsets.symmetric(horizontal: 15.w),
              decoration: BoxDecoration(color: isSel ? operatorColors[op] : Colors.transparent, borderRadius: BorderRadius.circular(20.r), border: Border.all(color: Colors.grey.shade300)),
              child: Center(child: Text(operatorNames[op]!, style: GoogleFonts.poppins(color: isSel ? Colors.white : kTextDark, fontSize: 12.sp))),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategoryChips() {
    final cats = operatorCategories[selectedOperator]!;
    return Container(
      height: 45.h, color: Colors.white,
      child: ListView.builder(
        scrollDirection: Axis.horizontal, itemCount: cats.length,
        itemBuilder: (context, i) => GestureDetector(
          onTap: () { setState(() => selectedCategory = cats[i]); _filterDrives(); },
          child: Container(
            margin: EdgeInsets.all(8.h), padding: EdgeInsets.symmetric(horizontal: 15.w),
            decoration: BoxDecoration(color: selectedCategory == cats[i] ? kPrimary : kBackground, borderRadius: BorderRadius.circular(15.r)),
            child: Center(child: Text(cats[i], style: GoogleFonts.poppins(fontSize: 10.sp))),
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (isLoading) return const Center(child: CircularProgressIndicator());
    return ListView.builder(
      itemCount: filteredDrives.length,
      padding: EdgeInsets.all(15.w),
      itemBuilder: (context, i) {
        final drive = filteredDrives[i];
        return Card(
          margin: EdgeInsets.only(bottom: 10.h),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
          child: ListTile(
            title: Text(drive['title'], style: GoogleFonts.poppins(fontSize: 12.sp, fontWeight: FontWeight.w600)),
            subtitle: Text("৳${drive['price']} | Valid: ${drive['duration']} Days", style: GoogleFonts.poppins(fontSize: 10.sp)),
            trailing: ElevatedButton(
              onPressed: () => _openPurchaseSheet(drive),
              style: ElevatedButton.styleFrom(backgroundColor: operatorColors[selectedOperator]),
              child: Text('Buy', style: GoogleFonts.poppins(fontSize: 10.sp, color: Colors.white)),
            ),
          ),
        );
      },
    );
  }
}
