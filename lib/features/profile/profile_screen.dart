import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'edit_profile/edit_profile_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  static const Color skyBlue = Color(0xFF29B6F6);

  @override
  Widget build(BuildContext context) {
    // ডেমো ডেটা - পরে আসল ডেটা দিয়ে রিপ্লেস করুন
    final userProfile = {
      'fullName': 'মোঃ রহিম উদ্দিন',
      'profileImage': null, // নেটওয়ার্ক ইমেজ URL বা null
    };

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // প্রোফাইল হেডার সেকশন
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 30.h),
              decoration: const BoxDecoration(
                color: skyBlue,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                  // প্রোফাইল ছবি
                  Container(
                    width: 100.w,
                    height: 100.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      border: Border.all(
                        color: Colors.white,
                        width: 4,
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
                  SizedBox(height: 15.h),
                  
                  // ফুল নাম
                  Text(
                    userProfile['fullName']!,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            SizedBox(height: 20.h),

            // মেনু আইটেমগুলো
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
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
                    Icons.account_balance_wallet_outlined,
                    "My Wallet",
                    onTap: () {
                      // Wallet page navigation
                    },
                  ),

                  // 3. History
                  _buildProfileItem(
                    context,
                    Icons.history,
                    "History",
                    onTap: () {
                      // History page navigation
                    },
                  ),

                  // 4. Language
                  _buildProfileItem(
                    context,
                    Icons.language_outlined,
                    "Language",
                    onTap: () {
                      // Language selector
                      _showLanguageDialog(context);
                    },
                  ),

                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Divider(color: Color(0xFFEEEEEE), thickness: 1),
                  ),

                  // 5. Logout
                  _buildProfileItem(
                    context,
                    Icons.logout,
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
                    Icons.delete_forever_outlined,
                    "Delete Account",
                    iconColor: Colors.red,
                    textColor: Colors.red,
                    isLast: true,
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

  // ডিফল্ট অ্যাভাটার
  Widget _buildDefaultAvatar(String name) {
    return Container(
      color: skyBlue.withOpacity(0.1),
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : '?',
          style: GoogleFonts.poppins(
            color: skyBlue,
            fontSize: 40.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // প্রোফাইল আইটেম বিল্ডার
  Widget _buildProfileItem(
    BuildContext context,
    IconData icon,
    String title, {
    bool isLast = false,
    Color? iconColor,
    Color? textColor,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: ListTile(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        leading: Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: (iconColor ?? skyBlue).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(
            icon,
            color: iconColor ?? skyBlue,
            size: 22.sp,
          ),
        ),
        title: Text(
          title,
          style: GoogleFonts.poppins(
            color: textColor ?? Colors.black87,
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: Colors.grey.shade400,
          size: 20.sp,
        ),
        onTap: onTap ?? () {},
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
            _languageOption('English'),
            _languageOption('বাংলা'),
            _languageOption('हिंदी'),
          ],
        ),
      ),
    );
  }

  Widget _languageOption(String language) {
    return ListTile(
      title: Text(language, style: GoogleFonts.poppins()),
      onTap: () {
        // Language change logic
        Navigator.pop();
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
