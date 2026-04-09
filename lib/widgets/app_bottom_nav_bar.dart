import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class AppBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final void Function(int) onTap;

  static const Color premiumOrange = Color(0xFFF57224);

  const AppBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          height: 70.h,
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(index: 0, icon: Icons.home_rounded, label: 'Home'),
              _buildNavItem(index: 1, icon: Icons.storefront_rounded, label: 'Reselling'),
              _buildNavItem(index: 2, icon: Icons.assignment_rounded, label: 'Microjobs'),
              _buildNavItem(index: 3, icon: Icons.campaign_rounded, label: 'Campaigns'),
              _buildNavItem(index: 4, icon: Icons.person_rounded, label: 'Profile'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required String label,
  }) {
    final isSelected = index == currentIndex;

    return GestureDetector(
      onTap: () => onTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isSelected ? premiumOrange.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              padding: EdgeInsets.all(isSelected ? 6.w : 4.w),
              decoration: BoxDecoration(
                color: isSelected ? premiumOrange : Colors.transparent,
                borderRadius: BorderRadius.circular(12.r),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: premiumOrange.withOpacity(0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : [],
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : Colors.grey.shade400,
                size: isSelected ? 22.sp : 24.sp,
              ),
            ),
            SizedBox(height: 4.h),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 300),
              style: GoogleFonts.poppins(
                color: isSelected ? premiumOrange : Colors.grey.shade500,
                fontSize: isSelected ? 11.sp : 10.sp,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
              child: Text(label),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              margin: EdgeInsets.only(top: 4.h),
              height: 3.h,
              width: isSelected ? 20.w : 0,
              decoration: BoxDecoration(
                color: premiumOrange,
                borderRadius: BorderRadius.circular(2.r),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: premiumOrange.withOpacity(0.6),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : [],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
