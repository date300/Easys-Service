import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class AppBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final void Function(int) onTap;

  static const Color skyBlue = Color(0xFF29B6F6);

  const AppBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? const Color(0xFF000000) : Colors.white;
    final unselectedColor = isDark ? Colors.grey.shade600 : Colors.grey.shade500;

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border(
          top: BorderSide(
            color: isDark ? Colors.grey.shade900 : Colors.grey.shade200,
            width: 0.5,
          ),
        ),
      ),
      child: SafeArea(
        top: false, // শুধু নিচের প্যাডিং রাখবে
        child: SizedBox(
          height: 48.h, // TikTok স্টাইল — অনেক চিকন
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildNavItem(0, CupertinoIcons.house, CupertinoIcons.house_fill, 'Home', unselectedColor),
              _buildNavItem(1, CupertinoIcons.bag, CupertinoIcons.bag_fill, 'Reselling', unselectedColor),
              _buildNavItem(2, CupertinoIcons.doc_text, CupertinoIcons.doc_text_fill, 'Jobs', unselectedColor),
              _buildNavItem(3, CupertinoIcons.person, CupertinoIcons.person_fill, 'Profile', unselectedColor),
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
    Color unselectedColor,
  ) {
    final isSelected = index == currentIndex;

    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(index),
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSelected ? activeIcon : inactiveIcon,
              color: isSelected ? skyBlue : unselectedColor,
              size: 20.sp, // ছোট আইকন
            ),
            SizedBox(height: 2.h),
            Text(
              label,
              style: GoogleFonts.poppins(
                color: isSelected ? skyBlue : unselectedColor,
                fontSize: 9.sp, // ছোট টেক্সট
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                height: 1.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
