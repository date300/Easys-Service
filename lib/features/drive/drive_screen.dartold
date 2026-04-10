import 'dart:convert';
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
  final List<String> operators = ['gp', 'robi', 'airtel', 'bl', 'teletalk', 'skitto'];

  final Map<String, String> operatorNames = {
    'gp': 'Grameenphone',
    'robi': 'Robi',
    'airtel': 'Airtel',
    'bl': 'Banglalink',
    'teletalk': 'Teletalk',
    'skitto': 'Skitto',
  };

  final Map<String, Color> operatorColors = {
    'gp': Color(0xFF009B77),
    'robi': Color(0xFF9C27B0),
    'airtel': Color(0xFFE40000),
    'bl': Color(0xFFE8000D),
    'teletalk': Color(0xFF003399),
    'skitto': Color(0xFFFF6B00),
  };

  final Map<String, String> operatorCodes = {
    'gp': 'GP',
    'robi': 'RB',
    'airtel': 'AT',
    'bl': 'BL',
    'teletalk': 'TT',
    'skitto': 'SK',
  };

  final Map<String, List<String>> operatorCategories = {
    'gp': ['All', 'Internet', 'Minute', 'Bundle', 'Social'],
    'robi': ['All', 'Internet', 'Talktime', 'Combo', 'Roaming'],
    'airtel': ['All', 'Data', 'Voice', 'Mixed', 'SMS'],
    'bl': ['All', 'Internet', 'Minute', 'Bundle', 'Star'],
    'teletalk': ['All', 'Internet', 'Minute', 'Bundle', 'Special'],
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
      drives = [];
      filteredDrives = [];
    });

    try {
      final opCode = operatorCodes[operator]!.toLowerCase();
      final response = await http.get(
        Uri.parse('https://easy.ltcminematrix.com/api/recharge/drives/$opCode'),
      ).timeout(const Duration(seconds: 15));

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
            // FIX: outer double quote ????? inner single quote conflict ?????? ??????
            errorMessage = "API Error: ${json['message'] ?? 'Unknown error'}";
            isLoading = false;
          });
        }
      } else {
        setState(() {
          errorMessage = 'Server error: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Connection failed. Please try again.';
        isLoading = false;
      });
    }
  }

  void _filterDrives() {
    if (selectedCategory == 'All') {
      filteredDrives = drives;
    } else {
      filteredDrives = drives.where((drive) {
        final title = (drive['title'] ?? '').toString().toLowerCase();
        final category = selectedCategory.toLowerCase();

        switch (category) {
          case 'internet':
          case 'data':
            return title.contains('gb') || title.contains('mb') || title.contains('data');
          case 'minute':
          case 'talktime':
          case 'voice':
            return title.contains('min') || title.contains('minute') || title.contains('talktime');
          case 'bundle':
          case 'combo':
          case 'mixed':
            return title.contains('bundle') || title.contains('combo') || (title.contains('gb') && title.contains('min'));
          case 'social':
            return title.contains('social') || title.contains('facebook') || title.contains('whatsapp');
          case 'sms':
            return title.contains('sms');
          case 'roaming':
            return title.contains('roaming');
          case 'star':
            return title.contains('star');
          case 'special':
            return title.contains('special') || title.contains('gift');
          default:
            return true;
        }
      }).toList();
    }
  }

  void _onCategoryChanged(String category) {
    setState(() {
      selectedCategory = category;
      _filterDrives();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Column(
        children: [
          _buildHeader(),
          _buildOperatorTabs(),
          _buildCategoryTabs(),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 16.h,
        bottom: 16.h,
        left: 20.w,
        right: 20.w,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
      ),
      child: Row(
        children: [
          const Spacer(),
          Text(
            '${filteredDrives.length} Packages',
            style: GoogleFonts.poppins(
              fontSize: 12.sp,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOperatorTabs() {
    return Container(
      color: Colors.white,
      height: 56.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        itemCount: operators.length,
        itemBuilder: (context, index) {
          final op = operators[index];
          final isSelected = op == selectedOperator;
          final color = operatorColors[op]!;

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
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: isSelected ? color : Colors.white10,
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(
                  color: isSelected ? color : Colors.white24,
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 22.w,
                    height: 22.w,
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.white24 : color.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        operatorCodes[op]!,
                        style: GoogleFonts.poppins(
                          fontSize: 7.sp,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white : color,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 6.w),
                  Text(
                    operatorNames[op]!,
                    style: GoogleFonts.poppins(
                      fontSize: 12.sp,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      color: isSelected ? Colors.white : Colors.black87,
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

  Widget _buildCategoryTabs() {
    final categories = operatorCategories[selectedOperator] ?? ['All'];
    final color = operatorColors[selectedOperator]!;

    return Container(
      color: Colors.white,
      height: 48.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = category == selectedCategory;

          return GestureDetector(
            onTap: () => _onCategoryChanged(category),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: EdgeInsets.only(right: 8.w),
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: isSelected ? color : color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(
                  color: isSelected ? color : color.withOpacity(0.3),
                  width: 1.5,
                ),
              ),
              child: Text(
                category,
                style: GoogleFonts.poppins(
                  fontSize: 12.sp,
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

  Widget _buildBody() {
    if (isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: operatorColors[selectedOperator],
              strokeWidth: 3,
            ),
            SizedBox(height: 16.h),
            Text(
              'Loading offers...',
              style: GoogleFonts.poppins(fontSize: 14.sp, color: Colors.grey[500]),
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
              Icon(Icons.wifi_off_rounded, size: 60.sp, color: Colors.grey[400]),
              SizedBox(height: 16.h),
              Text(
                errorMessage!,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(fontSize: 14.sp, color: Colors.grey[600]),
              ),
              SizedBox(height: 20.h),
              ElevatedButton.icon(
                onPressed: () => fetchDrives(selectedOperator),
                icon: const Icon(Icons.refresh_rounded),
                label: Text('Retry', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: operatorColors[selectedOperator],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                  padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (filteredDrives.isEmpty) {
      return Center(
        child: Text(
          'No offers available for this category',
          style: GoogleFonts.poppins(fontSize: 14.sp, color: Colors.grey[500]),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => fetchDrives(selectedOperator),
      color: operatorColors[selectedOperator],
      child: ListView.builder(
        padding: EdgeInsets.all(16.w),
        itemCount: filteredDrives.length,
        itemBuilder: (context, index) {
          return _buildDriveCard(filteredDrives[index]);
        },
      ),
    );
  }

  Widget _buildDriveCard(Map<String, dynamic> drive) {
    final color = operatorColors[selectedOperator]!;
    final price = drive['price'] ?? 0;
    final commission = drive['commission'] ?? 0;
    final duration = drive['duration'] ?? '30';
    final title = (drive['title'] ?? '') as String;

    // FIX: garbled unicode regex ??? ??? ??????
    final cleanTitle = title.replaceAll(RegExp(r'\(.*?\)'), '').trim();
    final isGift = title.contains('GIFT');

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Container(
              width: 6.w,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16.r),
                  bottomLeft: Radius.circular(16.r),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(14.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            cleanTitle,
                            style: GoogleFonts.poppins(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF1A1A2E),
                            ),
                          ),
                        ),
                        if (isGift)
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                            decoration: BoxDecoration(
                              color: Colors.amber.shade50,
                              borderRadius: BorderRadius.circular(20.r),
                              border: Border.all(color: Colors.amber.shade300),
                            ),
                            child: Text(
                              'GIFT',
                              style: GoogleFonts.poppins(
                                fontSize: 9.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.amber.shade700,
                              ),
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: 10.h),
                    Row(
                      children: [
                        _infoChip(Icons.currency_exchange_rounded, '?$price', color),
                        SizedBox(width: 8.w),
                        _infoChip(Icons.calendar_today_rounded, '${duration}d', Colors.blueGrey),
                        SizedBox(width: 8.w),
                        _infoChip(Icons.trending_up_rounded, '+?$commission', Colors.green),
                        const Spacer(),
                        GestureDetector(
                          onTap: () {
                            // TODO: handle buy action
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
                            decoration: BoxDecoration(
                              color: color,
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Text(
                              'Buy',
                              style: GoogleFonts.poppins(
                                fontSize: 12.sp,
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

  Widget _infoChip(IconData icon, String label, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        children: [
          Icon(icon, size: 12.sp, color: color),
          SizedBox(width: 4.w),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
