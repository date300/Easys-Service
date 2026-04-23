import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class AppBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final void Function(int) onTap;

  // Primary Theme Color
  static const Color skyBlue = Color(0xFF29B6F6);

  const AppBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // 🔥 Dynamic Theme Colors
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final shadowColor = isDark ? Colors.black.withOpacity(0.3) : Colors.black.withOpacity(0.05);
    final unselectedIconColor = isDark ? Colors.grey.shade600 : Colors.grey.shade400;
    final unselectedTextColor = isDark ? Colors.grey.shade500 : Colors.grey.shade500;

    return Container(
      // 🔥 Dynamic Background
      decoration: BoxDecoration(
        color: backgroundColor,
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: 15,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          height: 65.h,
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, CupertinoIcons.house, CupertinoIcons.house_fill, 'Home', isDark, unselectedIconColor, unselectedTextColor),
              _buildNavItem(1, CupertinoIcons.bag, CupertinoIcons.bag_fill, 'Reselling', isDark, unselectedIconColor, unselectedTextColor),
              _buildNavItem(2, CupertinoIcons.doc_text, CupertinoIcons.doc_text_fill, 'Jobs', isDark, unselectedIconColor, unselectedTextColor),
              _buildNavItem(3, Icons.campaign_outlined, Icons.campaign, 'Campaign', isDark, unselectedIconColor, unselectedTextColor),
              _buildNavItem(4, CupertinoIcons.person, CupertinoIcons.person_fill, 'Profile', isDark, unselectedIconColor, unselectedTextColor),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    int index, 
    IconData inactiveIcon, 
    IconData activeIcon, 
    String label,
    bool isDark,
    Color unselectedIconColor,
    Color unselectedTextColor,
  ) {
    final isSelected = index == currentIndex;
    // 🔥 Dynamic selected background
    final selectedBgColor = isDark ? skyBlue.withOpacity(0.15) : skyBlue.withOpacity(0.1);

    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon Container
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            padding: EdgeInsets.all(isSelected ? 5.w : 2.w),
            decoration: BoxDecoration(
              color: isSelected ? selectedBgColor : Colors.transparent,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(
              isSelected ? activeIcon : inactiveIcon,
              color: isSelected ? skyBlue : unselectedIconColor,
              size: 22.sp,
            ),
          ),
          
          SizedBox(height: 2.h),
          
          // Label
          Text(
            label,
            style: GoogleFonts.poppins(
              color: isSelected ? skyBlue : unselectedTextColor,
              fontSize: 9.sp,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
          
          // Active Indicator
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            margin: EdgeInsets.only(top: 2.h),
            height: 1.5.h,
            width: isSelected ? 10.w : 0,
            decoration: BoxDecoration(
              color: skyBlue,
              borderRadius: BorderRadius.circular(10.r),
            ),
          ),
        ],
      ),
    );
  }
}
