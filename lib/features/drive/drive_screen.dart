import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart'; // Lottie ইমপোর্ট করা হলো

class DriveScreen extends StatefulWidget {
  const DriveScreen({super.key});

  @override
  State<DriveScreen> createState() => _DriveScreenState();
}

class _DriveScreenState extends State<DriveScreen> {
  // ডিজাইন টোকেন
  static const Color kBackground = Color(0xFFF8FAFC);
  static const Color kTextDark   = Color(0xFF0F172A);
  static const Color kTextMid    = Color(0xFF475569);
  static const Color kPrimary    = Color(0xFF29B6F6);

  // অপারেটর ডাটা
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

  // ১. ড্রাইভ লিস্ট নিয়ে আসার এপিআই
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
            errorMessage = "এপিআই এরর: ${json['message'] ?? 'Unknown'}";
            isLoading = false;
          });
        }
      } else {
        setState(() { errorMessage = 'সার্ভার এরর: ${response.statusCode}'; isLoading = false; });
      }
    } catch (_) {
      setState(() { errorMessage = 'কানেকশন ফেইলড! আবার চেষ্টা করুন।'; isLoading = false; });
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

  // ২. ড্রাইভ কেনার মূল ফাংশন
  Future<void> _executePurchase(Map<String, dynamic> drive, String number, String pin) async {
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
        "type": "drive",
        "pin": pin
      };

      final response = await http.post(
        Uri.parse('https://easy.ltcminematrix.com/api/recharge/recharge'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(payload),
      ).timeout(const Duration(seconds: 20));

      Navigator.pop(context); // লোডিং বন্ধ করা

      final resData = jsonDecode(response.body);
      if (response.statusCode == 200 && resData['success'] == true) {
        _showStatusSnack("রিকোয়েস্ট সফল হয়েছে! TRX ID: ${resData['trxid']}", Colors.green);
      } else {
        _showStatusSnack(resData['message'] ?? "কেনা ব্যর্থ হয়েছে!", Colors.red);
      }
    } catch (e) {
      Navigator.pop(context);
      _showStatusSnack("সার্ভার কানেকশন এরর!", Colors.red);
    }
  }

  void _showStatusSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: color, behavior: SnackBarBehavior.floating),
    );
  }

  // ৩. নম্বর এবং পিন নেওয়ার জন্য বটম শীট
  void _openPurchaseSheet(Map<String, dynamic> drive) {
    final TextEditingController numController = TextEditingController();
    final TextEditingController pinController = TextEditingController();
    final color = operatorColors[selectedOperator]!;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20.r))),
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 20.w, right: 20.w, top: 20.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40.w, height: 4.h, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)))),
            SizedBox(height: 15.h),
            Text('Confirm Purchase', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16.sp)),
            SizedBox(height: 5.h),
            Text(drive['title'], style: GoogleFonts.poppins(fontSize: 12.sp, color: kTextMid)),
            SizedBox(height: 20.h),
            TextField(
              controller: numController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: 'Mobile Number',
                prefixIcon: const Icon(CupertinoIcons.phone),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
              ),
            ),
            SizedBox(height: 15.h),
            TextField(
              controller: pinController,
              keyboardType: TextInputType.number,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'App PIN',
                prefixIcon: const Icon(CupertinoIcons.lock),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
              ),
            ),
            SizedBox(height: 20.h),
            SizedBox(
              width: double.infinity,
              height: 50.h,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: color, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r))),
                onPressed: () {
                  if (numController.text.length == 11 && pinController.text.isNotEmpty) {
                    Navigator.pop(context);
                    _executePurchase(drive, numController.text, pinController.text);
                  } else {
                    _showStatusSnack("সঠিক নম্বর এবং পিন দিন", Colors.orange);
                  }
                },
                child: Text('Buy Now ৳${drive['price']}', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14.sp)),
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
        backgroundColor: Colors.white, elevation: 0.5,
        centerTitle: true,
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
      height: 65.h, color: Colors.white,
      child: ListView.builder(
        scrollDirection: Axis.horizontal, itemCount: operators.length,
        padding: EdgeInsets.symmetric(horizontal: 10.w),
        itemBuilder: (context, i) {
          final op = operators[i];
          final isSel = op == selectedOperator;
          return GestureDetector(
            onTap: () { setState(() => selectedOperator = op); fetchDrives(op); },
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 6.w, vertical: 12.h),
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              decoration: BoxDecoration(
                color: isSel ? operatorColors[op] : Colors.transparent,
                borderRadius: BorderRadius.circular(25.r),
                border: Border.all(color: isSel ? operatorColors[op]! : Colors.grey.shade300)
              ),
              child: Center(child: Text(operatorNames[op]!, style: GoogleFonts.poppins(color: isSel ? Colors.white : kTextDark, fontSize: 12.sp, fontWeight: isSel ? FontWeight.w600 : FontWeight.normal))),
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
            margin: EdgeInsets.symmetric(horizontal: 8.w, vertical: 5.h),
            padding: EdgeInsets.symmetric(horizontal: 18.w),
            decoration: BoxDecoration(
              color: selectedCategory == cats[i] ? operatorColors[selectedOperator]!.withOpacity(0.1) : kBackground,
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(color: selectedCategory == cats[i] ? operatorColors[selectedOperator]! : Colors.transparent)
            ),
            child: Center(child: Text(cats[i], style: GoogleFonts.poppins(fontSize: 11.sp, color: selectedCategory == cats[i] ? operatorColors[selectedOperator] : kTextMid))),
          ),
        ),
      ),
    );
  }

  // 🌟 আপডেট: মূল বডি (ডেটা না থাকলে Lottie দেখাবে)
  Widget _buildBody() {
    if (isLoading) return const Center(child: CircularProgressIndicator());
    
    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 50.sp, color: Colors.redAccent),
            SizedBox(height: 10.h),
            Text(errorMessage!, style: GoogleFonts.poppins(fontSize: 14.sp, color: kTextMid)),
          ],
        ),
      );
    }

    // 🔥 যদি কোনো ডেটা বা অফার না থাকে
    if (filteredDrives.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.network(
              'https://lottie.host/17e089d8-99ed-498c-850f-f1cbba20251c/MowR12iE75.json', // Empty box/No Data Lottie link
              height: 180.h,
              width: 180.w,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => 
                  Icon(CupertinoIcons.folder_open, size: 80.sp, color: Colors.grey.shade400),
            ),
            SizedBox(height: 15.h),
            Text(
              'দুঃখিত, কোনো অফার পাওয়া যায়নি!',
              style: GoogleFonts.poppins(fontSize: 14.sp, fontWeight: FontWeight.w600, color: kTextMid),
            ),
            Text(
              'অন্য ক্যাটাগরি বা অপারেটর চেক করুন।',
              style: GoogleFonts.poppins(fontSize: 11.sp, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    // ডেটা থাকলে লিস্ট দেখাবে
    return ListView.builder(
      itemCount: filteredDrives.length,
      padding: EdgeInsets.all(16.w),
      itemBuilder: (context, i) {
        final drive = filteredDrives[i];
        return Container(
          margin: EdgeInsets.only(bottom: 12.h),
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15.r),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 5))]
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(drive['title'], style: GoogleFonts.poppins(fontSize: 13.sp, fontWeight: FontWeight.bold, color: kTextDark)),
              SizedBox(height: 8.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Price: ৳${drive['price']}", style: GoogleFonts.poppins(fontSize: 12.sp, color: kPrimary, fontWeight: FontWeight.w600)),
                      Text("Validity: ${drive['duration']} Days", style: GoogleFonts.poppins(fontSize: 10.sp, color: kTextMid)),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: () => _openPurchaseSheet(drive),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: operatorColors[selectedOperator],
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                      elevation: 0
                    ),
                    child: Text('Buy Now', style: GoogleFonts.poppins(fontSize: 11.sp, color: Colors.white, fontWeight: FontWeight.bold)),
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
