import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'edit_profile/edit_profile_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  static const Color skyBlue = Color(0xFF29B6F6);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // ওপরে অল্প কিছু গ্যাপ দেওয়া হয়েছে যাতে দেখতে ভালো লাগে
            SizedBox(height: 20.h), 
            
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(horizontal: 10.w),
                physics: const BouncingScrollPhysics(),
                children: [
                  _buildProfileItem(
                    context,
                    Icons.edit_outlined,
                    "Edit Profile",
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const EditProfileScreen()),
                    ),
                  ),
                  _buildProfileItem(
                      context, Icons.wallet, "My Wallet"),
                  _buildProfileItem(
                      context, Icons.history, "Order History"),
                  _buildProfileItem(
                      context, Icons.settings, "Settings"),
                  _buildProfileItem(
                      context, Icons.help_outline, "Support Center"),
                  _buildProfileItem(
                      context, Icons.logout, "Logout",
                      isLast: true),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileItem(
    BuildContext context,
    IconData icon,
    String title, {
    bool isLast = false,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: isLast ? Colors.red : skyBlue),
      title: Text(title,
          style: GoogleFonts.poppins(
              color: isLast ? Colors.red : Colors.black87,
              fontSize: 14.sp)),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
      onTap: onTap ?? () {},
    );
  }
}
