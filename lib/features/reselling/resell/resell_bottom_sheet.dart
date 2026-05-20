import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';

// NOTE: Update this import to point to your main file containing ProductModel
// import 'path_to_your_main_file.dart' show ProductModel;

// ==================== RESELL BOTTOM SHEET ====================

class ResellBottomSheet extends StatefulWidget {
  final ProductModel product;
  final Function(double margin) onConfirm;

  const ResellBottomSheet({
    super.key,
    required this.product,
    required this.onConfirm,
  });

  @override
  State<ResellBottomSheet> createState() => _ResellBottomSheetState();
}

class _ResellBottomSheetState extends State<ResellBottomSheet> {
  double _margin = 0;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBackground = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final kTextDark = isDark ? Colors.white : const Color(0xFF0F172A);
    final kTextMid = isDark ? Colors.grey.shade400 : const Color(0xFF475569);
    final borderColor = isDark ? const Color(0xFF333333) : Colors.grey.withOpacity(0.1);

    final maxMargin = widget.product.maxMargin;
    final sellPrice = widget.product.wholesalePrice + _margin;

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24.h,
      ),
      decoration: BoxDecoration(
        color: cardBackground,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              margin: EdgeInsets.only(top: 12.h),
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: borderColor,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
          ),
          SizedBox(height: 20.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12.r),
                  child: SizedBox(
                    width: 52.w,
                    height: 52.w,
                    child: Image.network(
                      widget.product.image,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: Colors.grey.shade100,
                        child: Icon(CupertinoIcons.photo, color: Colors.grey.shade400),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 14.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.product.title,
                        style: GoogleFonts.poppins(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.bold,
                          color: kTextDark,
                        ),
                      ),
                      Text(
                        'Wholesale: ৳${widget.product.wholesalePrice.toInt()}',
                        style: GoogleFonts.poppins(
                          fontSize: 12.sp,
                          color: kTextMid,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 24.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Text(
              'Set Your Margin',
              style: GoogleFonts.poppins(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
                color: kTextDark,
              ),
            ),
          ),
          SizedBox(height: 10.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('৳0', style: GoogleFonts.poppins(fontSize: 12.sp, color: kTextMid)),
                Text('৳${maxMargin.toInt()}', style: GoogleFonts.poppins(fontSize: 12.sp, color: kTextMid)),
              ],
            ),
          ),
          Slider(
            value: _margin,
            min: 0,
            max: maxMargin,
            divisions: maxMargin.toInt(),
            activeColor: const Color(0xFF29B6F6),
            inactiveColor: borderColor,
            thumbColor: const Color(0xFF29B6F6),
            onChanged: (val) => setState(() => _margin = val),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(14.w),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF2C2C2C) : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: borderColor),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Margin',
                          style: GoogleFonts.poppins(fontSize: 11.sp, color: kTextMid),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          '৳${_margin.toInt()}',
                          style: GoogleFonts.poppins(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF34C759),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(14.w),
                    decoration: BoxDecoration(
                      color: const Color(0xFF29B6F6).withOpacity(0.06),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: const Color(0xFF29B6F6).withOpacity(0.2)),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Sell Price',
                          style: GoogleFonts.poppins(fontSize: 11.sp, color: kTextMid),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          '৳${sellPrice.toInt()}',
                          style: GoogleFonts.poppins(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF29B6F6),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: GestureDetector(
              onTap: () {
                HapticFeedback.mediumImpact();
                widget.onConfirm(_margin);
                Navigator.pop(context);
              },
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 16.h),
                decoration: BoxDecoration(
                  color: const Color(0xFF29B6F6),
                  borderRadius: BorderRadius.circular(14.r),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF29B6F6).withOpacity(0.3),
                      blurRadius: 14,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Text(
                  'Start Reselling',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 12.h),
        ],
      ),
    ).animate().slideY(begin: 0.15, duration: 300.ms, curve: Curves.easeOut);
  }
}
