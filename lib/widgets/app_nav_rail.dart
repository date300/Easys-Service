import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class AppNavRail extends StatelessWidget {
  final int currentIndex;
  final bool isDesktop;
  final void Function(int) onTap;

  static const Color skyBlue = Color(0xFF29B6F6);

  const AppNavRail({
    super.key,
    required this.currentIndex,
    required this.isDesktop,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: isDesktop ? 280 : 80,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            skyBlue,
            skyBlue.withOpacity(0.9),
            const Color(0xFF0288D1),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(4, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          // Logo Section
          Container(
            padding: EdgeInsets.all(20.w),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Icon(
                    Icons.shopping_bag_rounded,
                    color: Colors.white,
                    size: 28.sp,
                  ),
                ),
                if (isDesktop) ...[
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Text(
                      'Easy Service',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          // Navigation Items
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
              children: [
                _buildRailItem(index: 0, icon: Icons.home_rounded, label: 'Home'),
                SizedBox(height: 12.h),
                _buildRailItem(index: 1, icon: Icons.storefront_rounded, label: 'Reselling'),
                SizedBox(height: 12.h),
                _buildRailItem(index: 2, icon: Icons.assignment_rounded, label: 'Microjobs'),
                SizedBox(height: 12.h),
                _buildRailItem(index: 3, icon: Icons.campaign_rounded, label: 'Campaigns'),
                SizedBox(height: 12.h),
                _buildRailItem(index: 4, icon: Icons.person_rounded, label: 'Profile'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRailItem({
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
        padding: EdgeInsets.symmetric(
          horizontal: isDesktop ? 20.w : 16.w,
          vertical: 16.h,
        ),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(16.r),
          border: isSelected
              ? Border.all(color: Colors.white.withOpacity(0.3), width: 1)
              : null,
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: EdgeInsets.all(isSelected ? 10.w : 8.w),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white : Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12.r),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: Colors.white.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : [],
              ),
              child: Icon(
                icon,
                color: isSelected ? skyBlue : Colors.white,
                size: isSelected ? 24.sp : 22.sp,
              ),
            ),
            if (isDesktop) ...[
              SizedBox(width: 16.w),
              Expanded(
                child: AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 300),
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: isSelected ? 16.sp : 15.sp,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  ),
                  child: Text(label),
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: isSelected ? 8.w : 0,
                height: 8.w,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withOpacity(0.5),
                      blurRadius: 8,
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
