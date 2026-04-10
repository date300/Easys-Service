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
  // ── Design tokens (HomeScreen এর মতো) ──────────────────────────
  static const Color kBackground = Color(0xFFF8FAFC);
  static const Color kTextDark   = Color(0xFF0F172A);
  static const Color kTextMid    = Color(0xFF475569);
  static const Color kPrimary    = Color(0xFF29B6F6);

  // ── Operator data ───────────────────────────────────────────────
  final List<String> operators = ['gp', 'robi', 'airtel', 'bl', 'teletalk', 'skitto'];

  final Map<String, String> operatorNames = {
    'gp':       'Grameenphone',
    'robi':     'Robi',
    'airtel':   'Airtel',
    'bl':       'Banglalink',
    'teletalk': 'Teletalk',
    'skitto':   'Skitto',
  };

  final Map<String, Color> operatorColors = {
    'gp':       Color(0xFF009B77),
    'robi':     Color(0xFF9C27B0),
    'airtel':   Color(0xFFE40000),
    'bl':       Color(0xFFE8000D),
    'teletalk': Color(0xFF003399),
    'skitto':   Color(0xFFFF6B00),
  };

  final Map<String, String> operatorCodes = {
    'gp':       'GP',
    'robi':     'RB',
    'airtel':   'AT',
    'bl':       'BL',
    'teletalk': 'TT',
    'skitto':   'SK',
  };

  final Map<String, List<String>> operatorCategories = {
    'gp':       ['All', 'Internet', 'Minute', 'Bundle', 'Social'],
    'robi':     ['All', 'Internet', 'Talktime', 'Combo', 'Roaming'],
    'airtel':   ['All', 'Data', 'Voice', 'Mixed', 'SMS'],
    'bl':       ['All', 'Internet', 'Minute', 'Bundle', 'Star'],
    'teletalk': ['All', 'Internet', 'Minute', 'Bundle', 'Special'],
    'skitto':   ['All', 'Data', 'Voice', 'Combo'],
  };

  String selectedOperator = 'gp';
  String selectedCategory = 'All';
  List<dynamic> drives         = [];
  List<dynamic> filteredDrives = [];
  bool isLoading       = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchDrives(selectedOperator);
  }

  // ── API ─────────────────────────────────────────────────────────
  Future<void> fetchDrives(String operator) async {
    setState(() {
      isLoading      = true;
      errorMessage   = null;
      drives         = [];
      filteredDrives = [];
    });

    try {
      final opCode   = operatorCodes[operator]!.toLowerCase();
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
            errorMessage = "API Error: ${json['message'] ?? 'Unknown error'}";
            isLoading    = false;
          });
        }
      } else {
        setState(() {
          errorMessage = 'Server error: ${response.statusCode}';
          isLoading    = false;
        });
      }
    } catch (_) {
      setState(() {
        errorMessage = 'Connection failed. Please try again.';
        isLoading    = false;
      });
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
      switch (cat) {
        case 'internet':
        case 'data':
          return t.contains('gb') || t.contains('mb') || t.contains('data');
        case 'minute':
        case 'talktime':
        case 'voice':
          return t.contains('min') || t.contains('minute') || t.contains('talktime');
        case 'bundle':
        case 'combo':
        case 'mixed':
          return t.contains('bundle') || t.contains('combo') ||
              (t.contains('gb') && t.contains('min'));
        case 'social':
          return t.contains('social') || t.contains('facebook') || t.contains('whatsapp');
        case 'sms':     return t.contains('sms');
        case 'roaming': return t.contains('roaming');
        case 'star':    return t.contains('star');
        case 'special': return t.contains('special') || t.contains('gift');
        default:        return true;
      }
    }).toList();
  }

  void _onCategoryChanged(String category) {
    setState(() {
      selectedCategory = category;
      _filterDrives();
    });
  }

  // ── Build ───────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTopBar(),
            _buildOperatorTabs(),
            _buildCategoryChips(),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  // ── Top bar ──────────────────────────────────────────────────────
  Widget _buildTopBar() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Drive Offers',
                style: GoogleFonts.poppins(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: kTextDark,
                ),
              ),
              Text(
                'Best packages for you',
                style: GoogleFonts.poppins(fontSize: 10.sp, color: kTextMid),
              ),
            ],
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: kPrimary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Text(
              '${filteredDrives.length} Packages',
              style: GoogleFonts.poppins(
                fontSize: 10.sp,
                fontWeight: FontWeight.w600,
                color: kPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Operator tabs ────────────────────────────────────────────────
  Widget _buildOperatorTabs() {
    return Container(
      color: Colors.white,
      height: 48.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
        itemCount: operators.length,
        itemBuilder: (context, index) {
          final op         = operators[index];
          final isSelected = op == selectedOperator;
          final color      = operatorColors[op]!;

          return GestureDetector(
            onTap: () {
              if (!isSelected) {
                setState(() {
                  selectedOperator = op;
                  selectedCategory = 'All';
                });
                fetchDrives(op);
              }
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: EdgeInsets.only(right: 8.w),
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              decoration: BoxDecoration(
                color: isSelected ? color : Colors.transparent,
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(
                  color: isSelected ? color : Colors.grey.shade300,
                  width: 1.2,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 18.w,
                    height: 18.w,
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.white24 : color.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        operatorCodes[op]!,
                        style: GoogleFonts.poppins(
                          fontSize: 6.sp,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white : color,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 5.w),
                  Text(
                    operatorNames[op]!,
                    style: GoogleFonts.poppins(
                      fontSize: 11.sp,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      color: isSelected ? Colors.white : kTextDark,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Category chips ───────────────────────────────────────────────
  Widget _buildCategoryChips() {
    final categories = operatorCategories[selectedOperator] ?? ['All'];
    final color      = operatorColors[selectedOperator]!;

    return Container(
      color: Colors.white,
      height: 40.h,
      margin: EdgeInsets.only(bottom: 1.h),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category   = categories[index];
          final isSelected = category == selectedCategory;

          return GestureDetector(
            onTap: () => _onCategoryChanged(category),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              margin: EdgeInsets.only(right: 6.w),
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              decoration: BoxDecoration(
                color: isSelected ? color : color.withOpacity(0.08),
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Text(
                category,
                style: GoogleFonts.poppins(
                  fontSize: 10.sp,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected ? Colors.white : color,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Body ─────────────────────────────────────────────────────────
  Widget _buildBody() {
    if (isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: operatorColors[selectedOperator],
              strokeWidth: 2.5,
            ),
            SizedBox(height: 12.h),
            Text(
              'Loading offers...',
              style: GoogleFonts.poppins(fontSize: 12.sp, color: kTextMid),
            ),
          ],
        ),
      );
    }

    if (errorMessage != null) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(CupertinoIcons.wifi_slash, size: 44.sp, color: Colors.grey[350]),
              SizedBox(height: 12.h),
              Text(
                errorMessage!,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(fontSize: 12.sp, color: kTextMid),
              ),
              SizedBox(height: 16.h),
              GestureDetector(
                onTap: () => fetchDrives(selectedOperator),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                  decoration: BoxDecoration(
                    color: operatorColors[selectedOperator],
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(CupertinoIcons.refresh, size: 13.sp, color: Colors.white),
                      SizedBox(width: 6.w),
                      Text(
                        'Retry',
                        style: GoogleFonts.poppins(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (filteredDrives.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(CupertinoIcons.square_stack_3d_up_slash, size: 40.sp, color: Colors.grey[300]),
            SizedBox(height: 10.h),
            Text(
              'No offers for this category',
              style: GoogleFonts.poppins(fontSize: 12.sp, color: kTextMid),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => fetchDrives(selectedOperator),
      color: operatorColors[selectedOperator],
      child: ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        itemCount: filteredDrives.length,
        itemBuilder: (context, index) => _buildDriveCard(filteredDrives[index]),
      ),
    );
  }

  // ── Drive card ───────────────────────────────────────────────────
  Widget _buildDriveCard(Map<String, dynamic> drive) {
    final color      = operatorColors[selectedOperator]!;
    final price      = drive['price']      ?? 0;
    final commission = drive['commission'] ?? 0;
    final duration   = drive['duration']   ?? '30';
    final title      = (drive['title']     ?? '') as String;
    final cleanTitle = title.replaceAll(RegExp(r'\(.*?\)'), '').trim();
    final isGift     = title.contains('GIFT');

    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            // Left color accent bar
            Container(
              width: 4.w,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.only(
                  topLeft:    Radius.circular(12.r),
                  bottomLeft: Radius.circular(12.r),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            cleanTitle,
                            style: GoogleFonts.poppins(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                              color: kTextDark,
                            ),
                          ),
                        ),
                        if (isGift)
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 2.h),
                            decoration: BoxDecoration(
                              color: Colors.amber.shade50,
                              borderRadius: BorderRadius.circular(20.r),
                              border: Border.all(color: Colors.amber.shade300),
                            ),
                            child: Text(
                              'GIFT',
                              style: GoogleFonts.poppins(
                                fontSize: 8.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.amber.shade700,
                              ),
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    Row(
                      children: [
                        _infoChip(CupertinoIcons.money_dollar_circle, '৳$price', color),
                        SizedBox(width: 6.w),
                        _infoChip(CupertinoIcons.calendar, '${duration}d', Colors.blueGrey),
                        SizedBox(width: 6.w),
                        _infoChip(CupertinoIcons.arrow_up_right, '+৳$commission', const Color(0xFF16A34A)),
                        const Spacer(),
                        GestureDetector(
                          onTap: () {
                            // TODO: handle buy action
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 5.h),
                            decoration: BoxDecoration(
                              color: color,
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Text(
                              'Buy',
                              style: GoogleFonts.poppins(
                                fontSize: 11.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Info chip ────────────────────────────────────────────────────
  Widget _infoChip(IconData icon, String label, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10.sp, color: color),
          SizedBox(width: 3.w),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 10.sp,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
