import 'dart:ui';
import 'package:flutter/cupertino.dart'; // Cupertino আইকনের জন্য
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class AppBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final void Function(int) onTap;

  // আপনার আগের স্কাই ব্লু কালারটিই রাখা হয়েছে হাইলাইটের জন্য
  static const Color skyBlue = Color(0xFF29B6F6);

  const AppBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: BackdropFilter(
        // গ্লাস ইফেক্ট ব্লার
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.7), // প্রিমিয়াম ডার্ক থিম
            border: Border(
              top: BorderSide(
                color: Colors.white.withOpacity(0.1),
                width: 0.5,
              ),
            ),
          ),
          child: SafeArea(
            child: Container(
              height: 75.h,
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(
                    index: 0,
                    inactiveIcon: CupertinoIcons.house,
                    activeIcon: CupertinoIcons.house_fill,
                    label: 'Home',
                  ),
                  _buildNavItem(
                    index: 1,
                    inactiveIcon: CupertinoIcons.bag,
                    activeIcon: CupertinoIcons.bag_fill,
                    label: 'Reselling',
                  ),
                  _buildNavItem(
                    index: 2,
                    inactiveIcon: CupertinoIcons.doc_text,
                    activeIcon: CupertinoIcons.doc_text_fill,
                    label: 'Microjobs',
                  ),
                  _buildNavItem(
                    index: 3,
                    inactiveIcon: CupertinoIcons.speaker_2,
                    activeIcon: CupertinoIcons.speaker_2_fill,
                    label: 'Campaigns',
                  ),
                  _buildNavItem(
                    index: 4,
                    inactiveIcon: CupertinoIcons.person,
                    activeIcon: CupertinoIcons.person_fill,
                    label: 'Profile',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData inactiveIcon,
    required IconData activeIcon,
    required String label,
  }) {
    final isSelected = index == currentIndex;

    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // আইকন অ্যানিমেশন
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            padding: EdgeInsets.all(isSelected ? 7.w : 0),
            decoration: BoxDecoration(
              color: isSelected ? skyBlue.withOpacity(0.15) : Colors.transparent,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              isSelected ? activeIcon : inactiveIcon,
              color: isSelected ? skyBlue : Colors.white.withOpacity(0.5),
              size: isSelected ? 22.sp : 24.sp,
            ),
          ),
          SizedBox(height: 4.h),
          // লেবেল
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 300),
            style: GoogleFonts.poppins(
              color: isSelected ? skyBlue : Colors.white.withOpacity(0.5),
              fontSize: 10.sp,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            ),
            child: Text(label),
          ),
          // সেই ছোট ইন্ডিকেটর লাইন
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            margin: EdgeInsets.only(top: 4.h),
            height: 2.h,
            width: isSelected ? 12.w : 0,
            decoration: BoxDecoration(
              color: skyBlue,
              borderRadius: BorderRadius.circular(2.r),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: skyBlue.withOpacity(0.6),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ]
                  : [],
            ),
          ),
        ],
      ),
    );
  }
}
