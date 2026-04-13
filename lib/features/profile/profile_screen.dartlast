import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'edit_profile/edit_profile_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  static const Color skyBlue = Color(0xFF29B6F6);

  @override
  Widget build(BuildContext context) {
    // ডেমো ডেটা - পরে আসল ডেটা দিয়ে রিপ্লেস করুন
    final userProfile = {
      'fullName': 'মোঃ রহিম উদ্দিন',
      'affiliateId': 'AFF123456',
      'profileImage': null, // নেটওয়ার্ক ইমেজ URL বা null
    };

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header with Profile Info (AppDrawer স্টাইলে)
            Container(
              width: double.infinity,
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 20,
                bottom: 25,
                left: 20,
                right: 20,
              ),
              decoration: const BoxDecoration(
                color: skyBlue,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30), // AppDrawer এর মতো
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                  // Profile Picture (AppDrawer স্টাইলে)
                  Container(
                    width: 80.w,
                    height: 80.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      border: Border.all(
                        color: Colors.white,
                        width: 3,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: userProfile['profileImage'] != null
                          ? Image.network(
                              userProfile['profileImage']!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return _buildDefaultAvatar(userProfile['fullName']!);
                              },
                            )
                          : _buildDefaultAvatar(userProfile['fullName']!),
                    ),
                  ),
                  SizedBox(height: 12.h),
                  
                  // Full Name
                  Text(
                    userProfile['fullName']!,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 8.h),
                  
                  // Affiliate ID with Copy Button (AppDrawer স্টাইলে)
                  GestureDetector(
                    onTap: () => _copyAffiliateId(context, userProfile['affiliateId']!),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 6.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.copy_rounded,
                            color: Colors.white,
                            size: 14.sp,
                          ),
                          SizedBox(width: 6.w),
                          Text(
                            'ID: ${userProfile['affiliateId']}',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 10.h),

            // Menu Items (AppDrawer স্টাইলে)
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(horizontal: 10.w),
                physics: const BouncingScrollPhysics(),
                children: [
                  // 1. Edit Profile
                  _buildProfileItem(
                    context,
                    Icons.edit_outlined,
                    "Edit Profile",
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const EditProfileScreen(),
                      ),
                    ),
                  ),

                  // 2. My Wallet
                  _buildProfileItem(
                    context,
                    Icons.account_balance_wallet_rounded,
                    "My Wallet",
                    onTap: () {
                      // Wallet page navigation
                    },
                  ),

                  // 3. History
                  _buildProfileItem(
                    context,
                    Icons.history_rounded,
                    "History",
                    onTap: () {
                      // History page navigation
                    },
                  ),

                  // 4. Language
                  _buildProfileItem(
                    context,
                    Icons.language_rounded,
                    "Language",
                    onTap: () {
                      _showLanguageDialog(context);
                    },
                  ),

                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 15.w),
                    child: Divider(color: const Color(0xFFEEEEEE), thickness: 1.5.h),
                  ),

                  // 5. Logout
                  _buildProfileItem(
                    context,
                    Icons.logout_rounded,
                    "Logout",
                    iconColor: Colors.orange,
                    textColor: Colors.orange,
                    onTap: () {
                      _showLogoutDialog(context);
                    },
                  ),

                  // 6. Delete Account
                  _buildProfileItem(
                    context,
                    Icons.delete_forever_rounded,
                    "Delete Account",
                    iconColor: Colors.red,
                    textColor: Colors.red,
                    onTap: () {
                      _showDeleteAccountDialog(context);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ডিফল্ট অ্যাভাটার (AppDrawer স্টাইলে)
  Widget _buildDefaultAvatar(String name) {
    return Container(
      color: skyBlue.withOpacity(0.1),
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : '?',
          style: GoogleFonts.poppins(
            color: skyBlue,
            fontSize: 32.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // Profile Item (AppDrawer এর _drawerItem মতো)
  Widget _buildProfileItem(
    BuildContext context,
    IconData icon,
    String title, {
    Color? iconColor,
    Color? textColor,
    required VoidCallback onTap,
  }) {
    return ListTile(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      leading: Icon(icon, color: iconColor ?? skyBlue, size: 24.sp),
      title: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 13.sp,
          fontWeight: FontWeight.w500,
          color: textColor ?? Colors.black87,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios_rounded,
        size: 13.sp,
        color: Colors.grey.shade400,
      ),
      onTap: onTap,
      splashColor: skyBlue.withOpacity(0.1),
    );
  }

  // Affiliate ID কপি করুন
  void _copyAffiliateId(BuildContext context, String affiliateId) {
    Clipboard.setData(ClipboardData(text: affiliateId));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Affiliate ID কপি করা হয়েছে!',
          style: GoogleFonts.poppins(fontSize: 12.sp),
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.r),
        ),
      ),
    );
  }

  // ল্যাঙ্গুয়েজ ডায়ালগ
  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Select Language',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _languageOption(context, 'English'),
            _languageOption(context, 'বাংলা'),
            _languageOption(context, 'हिंदी'),
          ],
        ),
      ),
    );
  }

  Widget _languageOption(BuildContext context, String language) {
    return ListTile(
      title: Text(language, style: GoogleFonts.poppins()),
      onTap: () {
        Navigator.pop(context);
      },
    );
  }

  // লগআউট কনফার্মেশন ডায়ালগ
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Logout',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Are you sure you want to logout?',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(color: Colors.grey),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Logout logic here
            },
            child: Text(
              'Logout',
              style: GoogleFonts.poppins(
                color: Colors.orange,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ডিলিট অ্যাকাউন্ট কনফার্মেশন ডায়ালগ
  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Delete Account',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: Colors.red,
          ),
        ),
        content: Text(
          'This action cannot be undone. All your data will be permanently deleted. Are you sure?',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(color: Colors.grey),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Delete account logic here
            },
            child: Text(
              'Delete',
              style: GoogleFonts.poppins(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
