import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../../main.dart';

class UserProfile {
  final String fullName;
  final String referralCode;
  final String? profilePicture;
  final String idVerified; // ????

  UserProfile({
    required this.fullName,
    required this.referralCode,
    this.profilePicture,
    required this.idVerified,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      fullName: json['full_name'] ?? 'Guest User',
      referralCode: json['referral_code'] ?? 'N/A',
      profilePicture: json['profile_picture'],
      idVerified: json['id_verified'] ?? 'unverified',
    );
  }
}

final userProfileProvider = FutureProvider<UserProfile?>((ref) async {
  const String baseUrl = "https://easy.ltcminematrix.com/api";
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('jwt_token');

  if (token == null) return null;

  try {
    final response = await http.get(
      Uri.parse("$baseUrl/user/profile"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    ).timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['status'] == 'success') {
        return UserProfile.fromJson(data['user']);
      }
    }
  } catch (e) {
    debugPrint("Profile Fetch Error: $e");
    return null;
  }
  return null;
});

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  static const Color skyBlue = Color(0xFF29B6F6);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? const Color(0xFF121212) : Colors.white;
    final headerColor = isDark ? const Color(0xFF1E1E1E) : skyBlue;
    final avatarBgColor = isDark ? const Color(0xFF2C2C2C) : Colors.white;

    final profileAsync = ref.watch(userProfileProvider);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 20.h,
                bottom: 25.h,
                left: 20.w,
                right: 20.w,
              ),
              decoration: BoxDecoration(
                color: headerColor,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30.r),
                  bottomRight: Radius.circular(30.r),
                ),
              ),
              child: profileAsync.when(
                data: (user) => _buildProfileHeader(context, user, avatarBgColor, isDark),
                loading: () => const Center(child: CircularProgressIndicator(color: Colors.white)),
                error: (err, stack) => _buildGuestHeader(context, avatarBgColor, isDark),
              ),
            ),

            SizedBox(height: 10.h),

            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(horizontal: 10.w),
                physics: const BouncingScrollPhysics(),
                children: [
                  _buildThemeSelectorCard(context, ref, isDark),

                  SizedBox(height: 10.h),

                  _buildProfileItem(
                    context,
                    Icons.edit_outlined,
                    "Edit Profile",
                    isDark: isDark,
                    onTap: () {
                      ref.read(isDetailViewProvider.notifier).state = true;
                      ref.read(detailViewTitleProvider.notifier).state = 'Edit Profile';
                      context.push('/edit-profile');
                    },
                  ),

                  _buildProfileItem(
                    context,
                    Icons.account_balance_wallet_rounded,
                    "My Wallet",
                    isDark: isDark,
                    onTap: () {
                      HapticFeedback.lightImpact();
                      ref.read(isDetailViewProvider.notifier).state = true;
                      ref.read(detailViewTitleProvider.notifier).state = 'My Wallet';
                      context.push('/wallet');
                    },
                  ),

                  _buildProfileItem(
                    context,
                    Icons.history_rounded,
                    "History",
                    isDark: isDark,
                    onTap: () {
                      HapticFeedback.lightImpact();
                      ref.read(isDetailViewProvider.notifier).state = true;
                      ref.read(detailViewTitleProvider.notifier).state = 'History';
                      context.push('/wallet');
                    },
                  ),

                  _buildProfileItem(
                    context,
                    Icons.language_rounded,
                    "Language",
                    isDark: isDark,
                    onTap: () => _showLanguageDialog(context, isDark),
                  ),

                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 15.w),
                    child: Divider(
                      color: isDark ? const Color(0xFF333333) : const Color(0xFFEEEEEE),
                      thickness: 1.5.h,
                    ),
                  ),

                  _buildProfileItem(
                    context,
                    Icons.logout_rounded,
                    "Logout",
                    isDark: isDark,
                    iconColor: Colors.orange,
                    textColor: Colors.orange,
                    onTap: () => _showLogoutDialog(context, ref, isDark),
                  ),

                  _buildProfileItem(
                    context,
                    Icons.delete_forever_rounded,
                    "Delete Account",
                    isDark: isDark,
                    iconColor: Colors.red,
                    textColor: Colors.red,
                    onTap: () => _showDeleteAccountDialog(context, isDark),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, UserProfile? user, Color avatarBg, bool isDark) {
    final String name = user?.fullName ?? "No Name";
    final String id = user?.referralCode ?? "N/A";
    final String? img = user?.profilePicture;
    final bool isVerified = user?.idVerified == 'verified';

    return Column(
      children: [
        Container(
          width: 80.w,
          height: 80.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: avatarBg,
            border: Border.all(color: isDark ? skyBlue : Colors.white, width: 3),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5)),
            ],
          ),
          child: ClipOval(
            child: img != null && img.isNotEmpty
                ? Image.network(
                    img,
                    fit: BoxFit.cover,
                    errorBuilder: (c, e, s) => _buildDefaultAvatar(name, isDark),
                  )
                : _buildDefaultAvatar(name, isDark),
          ),
        ),
        SizedBox(height: 12.h),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                name,
                style: GoogleFonts.poppins(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(width: 6.w),
            Icon(
              isVerified ? Icons.verified : Icons.cancel,
              color: isVerified ? Colors.greenAccent : Colors.redAccent,
              size: 20.sp,
            ),
          ],
        ),
        SizedBox(height: 8.h),
        GestureDetector(
          onTap: () => _copyAffiliateId(context, id),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(color: Colors.white.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.copy_rounded, color: Colors.white, size: 14.sp),
                SizedBox(width: 6.w),
                Text('ID: $id', style: GoogleFonts.poppins(color: Colors.white, fontSize: 12.sp, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGuestHeader(BuildContext context, Color avatarBg, bool isDark) {
    return Column(
      children: [
        Container(
          width: 80.w, height: 80.w,
          decoration: BoxDecoration(shape: BoxShape.circle, color: avatarBg),
          child: Icon(Icons.person, size: 40.sp, color: skyBlue),
        ),
        SizedBox(height: 12.h),
        Text('Welcome Guest', style: GoogleFonts.poppins(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.bold)),
        SizedBox(height: 8.h),
        ElevatedButton(
          onPressed: () => context.go('/login'),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: skyBlue),
          child: const Text('Login / Register'),
        ),
      ],
    );
  }

  Widget _buildThemeSelectorCard(BuildContext context, WidgetRef ref, bool isDark) {
    final themeMode = ref.watch(themeModeProvider);
    const primaryColor = skyBlue;

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 6.w),
      elevation: isDark ? 0 : 2,
      color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
        side: isDark ? const BorderSide(color: Color(0xFF333333)) : BorderSide.none,
      ),
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.palette, color: primaryColor),
            title: Text('Theme Mode', style: GoogleFonts.poppins(fontSize: 14.sp, fontWeight: FontWeight.w600, color: isDark ? Colors.white : Colors.black87)),
          ),
          _buildThemeTile(ref, Icons.light_mode, 'Light Mode', ThemeMode.light, themeMode, isDark, primaryColor),
          _buildThemeTile(ref, Icons.dark_mode, 'Dark Mode', ThemeMode.dark, themeMode, isDark, primaryColor),
          _buildThemeTile(ref, Icons.settings_suggest, 'System Default', ThemeMode.system, themeMode, isDark, primaryColor),
        ],
      ),
    );
  }

  Widget _buildThemeTile(WidgetRef ref, IconData icon, String title, ThemeMode value, ThemeMode current, bool isDark, Color primary) {
    final isSelected = value == current;
    return ListTile(
      dense: true,
      leading: Icon(icon, color: isSelected ? primary : (isDark ? Colors.grey : Colors.black45), size: 20.sp),
      title: Text(title, style: GoogleFonts.poppins(fontSize: 13.sp, color: isSelected ? primary : (isDark ? Colors.white70 : Colors.black87))),
      trailing: isSelected ? Icon(Icons.check_circle, color: primary, size: 20.sp) : null,
      onTap: () => ref.read(themeModeProvider.notifier).setTheme(value),
    );
  }

  Widget _buildProfileItem(BuildContext context, IconData icon, String title, {required bool isDark, Color? iconColor, Color? textColor, required VoidCallback onTap}) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
      color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
        side: isDark ? const BorderSide(color: Color(0xFF333333)) : BorderSide.none,
      ),
      child: ListTile(
        leading: Icon(icon, color: iconColor ?? skyBlue, size: 22.sp),
        title: Text(title, style: GoogleFonts.poppins(fontSize: 13.sp, fontWeight: FontWeight.w500, color: textColor ?? (isDark ? Colors.white : Colors.black87))),
        trailing: Icon(Icons.arrow_forward_ios_rounded, size: 13.sp, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }

  Widget _buildDefaultAvatar(String name, bool isDark) {
    return Container(
      color: isDark ? const Color(0xFF2C2C2C) : skyBlue.withOpacity(0.1),
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : '?',
          style: GoogleFonts.poppins(color: skyBlue, fontSize: 32.sp, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  void _copyAffiliateId(BuildContext context, String id) {
    Clipboard.setData(ClipboardData(text: id));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('ID ??? ?????!'), behavior: SnackBarBehavior.floating),
    );
  }

  void _showLanguageDialog(BuildContext context, bool isDark) {
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        title: Text('Select Language', style: GoogleFonts.poppins(color: isDark ? Colors.white : Colors.black)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          ListTile(title: Text('English', style: TextStyle(color: isDark ? Colors.white : Colors.black)), onTap: () => Navigator.pop(c)),
          ListTile(title: Text('?????', style: TextStyle(color: isDark ? Colors.white : Colors.black)), onTap: () => Navigator.pop(c)),
        ]),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref, bool isDark) {
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        title: Text('Logout', style: TextStyle(color: isDark ? Colors.white : Colors.black)),
        content: Text('Are you sure?', style: TextStyle(color: isDark ? Colors.white70 : Colors.black)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Navigator.pop(c);
              await ref.read(authProvider.notifier).logout();
              if (context.mounted) context.go('/login');
            },
            child: const Text('Logout', style: TextStyle(color: Colors.orange)),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context, bool isDark) {
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        title: const Text('Delete Account', style: TextStyle(color: Colors.red)),
        content: const Text('This cannot be undone. Are you sure?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(c), child: const Text('Delete', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
  }
}
