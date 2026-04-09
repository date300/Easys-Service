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
    return Container(
      // ব্যাকগ্রাউন্ড এখন পুরোপুরি সাদা
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          height: 65.h, // হাইট কিছুটা কমিয়ে স্লিম করা হয়েছে
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, CupertinoIcons.house, CupertinoIcons.house_fill, 'Home'),
              _buildNavItem(1, CupertinoIcons.bag, CupertinoIcons.bag_fill, 'Reselling'),
              _buildNavItem(2, CupertinoIcons.doc_text, CupertinoIcons.doc_text_fill, 'Jobs'),
              _buildNavItem(3, CupertinoIcons.speaker_2, CupertinoIcons.speaker_2_fill, 'Campaign'),
              _buildNavItem(4, CupertinoIcons.person, CupertinoIcons.person_fill, 'Profile'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData inactiveIcon, IconData activeIcon, String label) {
    final isSelected = index == currentIndex;

    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // আইকনের পেছনের হাইলাইট এখন অনেক চিকন
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            padding: EdgeInsets.all(isSelected ? 5.w : 2.w), // প্যাডিং কমানো হয়েছে যেন মোটা না লাগে
            decoration: BoxDecoration(
              color: isSelected ? skyBlue.withOpacity(0.1) : Colors.transparent,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(
              isSelected ? activeIcon : inactiveIcon,
              color: isSelected ? skyBlue : Colors.grey.shade400,
              size: 22.sp, // আইকন সাইজ অপ্টিমাইজড
            ),
          ),
          SizedBox(height: 2.h),
          // লেবেল
          Text(
            label,
            style: GoogleFonts.poppins(
              color: isSelected ? skyBlue : Colors.grey.shade500,
              fontSize: 9.sp, // টেক্সট সাইজ কিছুটা ছোট করা হয়েছে স্লিম লুকের জন্য
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
          // নিচের ইন্ডিকেটর লাইনটিও চিকন করা হয়েছে
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            margin: EdgeInsets.only(top: 2.h),
            height: 1.5.h, // লাইনের থিকনেস কমানো হয়েছে
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
