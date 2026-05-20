import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'product_model.dart';

class ResellBottomSheet extends StatefulWidget {
  final ProductModel product;
  final ProductVariant? selectedVariant;
  final Function(double margin) onConfirm;

  const ResellBottomSheet({
    super.key,
    required this.product,
    this.selectedVariant,
    required this.onConfirm,
  });

  @override
  State<ResellBottomSheet> createState() => _ResellBottomSheetState();
}

class _ResellBottomSheetState extends State<ResellBottomSheet> {
  // আসল ফিচারের জন্য এই ভ্যারিয়েবলগুলো আপাতত দরকার নেই, 
  // কিন্তু ভবিষ্যতে ব্যবহার করতে পারবে
  double _margin = 0;

  double get _basePrice =>
      widget.selectedVariant?.price ?? widget.product.wholesalePrice;

  double get _maxMargin => widget.product.maxResalePrice - _basePrice;
  double get _sellPrice => _basePrice + _margin;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBackground = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final kTextDark = isDark ? Colors.white : const Color(0xFF0F172A);
    final borderColor =
        isDark ? const Color(0xFF333333) : Colors.grey.withOpacity(0.1);

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
        children: [
          // Drag handle
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
          SizedBox(height: 40.h),

          // Coming Soon Content
          Icon(
            CupertinoIcons.hammer_fill,
            size: 48.sp,
            color: const Color(0xFF29B6F6).withOpacity(0.7),
          ),
          SizedBox(height: 16.h),
          Text(
            'Coming Soon',
            style: GoogleFonts.poppins(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: kTextDark,
            ),
          ),
          SizedBox(height: 8.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 32.w),
            child: Text(
              'Resell feature is under development.\nStay tuned!',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 13.sp,
                color: Colors.grey.shade500,
              ),
            ),
          ),
          SizedBox(height: 40.h),
        ],
      ),
    ).animate().slideY(begin: 0.15, duration: 300.ms, curve: Curves.easeOut);
  }
}
