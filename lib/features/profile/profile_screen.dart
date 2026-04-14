import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'edit_profile/edit_profile_screen.dart';

// Import your providers - adjust path as needed
// Ensure this points to the file where themeModeProvider and userProfileProvider are defined
import '../../main.dart'; 

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  static const Color skyBlue = Color(0xFF29B6F6);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ? Theme DYNAMIC Colors
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? const Color(0xFF121212) : Colors.white;
    final headerColor = isDark ? const Color(0xFF1E1E1E) : skyBlue;
    final textColor = isDark ? Colors.white : Colors.black87;
    final avatarBgColor = isDark ? const Color(0xFF2C2C2C) : Colors.white;

    // API থেকে প্রোফাইল ডাটা রিড করা হচ্ছে (যেটা AppDrawer এর জন্য বানানো হয়েছিল)
    final profileAsync = ref.watch(userProfileProvider);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header with Profile Info
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
              // AsyncValue হ্যান্ডেল করা হচ্ছে রিয়েল ডাটা দেখানোর জন্য
              child: profileAsync.when(
                data: (user) => _buildProfileHeader(context, user, avatarBgColor, isDark),
                loading: () => const Center(child: CircularProgressIndicator(color: Colors.white)),
                error: (err, stack) => _buildGuestHeader(context, avatarBgColor, isDark),
              ),
            ),

            SizedBox(height: 10.h),

            // Menu Items
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(horizontal: 10.w),
                physics: const BouncingScrollPhysics(),
                children: [
                  // ? 0. Theme Selector
                  _buildThemeSelectorCard(context, ref, isDark),

                  SizedBox(height: 10.h),

                  // 1. Edit Profile
                  _buildProfileItem(
                    context,
                    Icons.edit_outlined,
                    "Edit Profile",
                    isDark: isDark,
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
                    isDark: isDark,
                    onTap: () {
                      // Wallet page navigation
                    },
                  ),

                  // 3. History
                  _buildProfileItem(
                    context,
                    Icons.history_rounded,
                    "History",
                    isDark: isDark,
                    onTap: () {
                      // History page navigation
                    },
                  ),

                  // 4. Language
                  _buildProfileItem(
                    context,
                    Icons.language_rounded,
                    "Language",
                    isDark: isDark,
                    onTap: () {
                      _showLanguageDialog(context, isDark);
                    },
                  ),

                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 15.w),
                    child: Divider(
                      color: isDark ? const Color(0xFF333333) : const Color(0xFFEEEEEE),
                      thickness: 1.5.h,
                    ),
                  ),

                  // 5. Logout
                  _buildProfileItem(
                    context,
                    Icons.logout_rounded,
                    "Logout",
                    isDark: isDark,
                    iconColor: Colors.orange,
                    textColor: Colors.orange,
                    onTap: () {
                      _showLogoutDialog(context, ref, isDark);
                    },
                  ),

                  // 6. Delete Account
                  _buildProfileItem(
                    context,
                    Icons.delete_forever_rounded,
                    "Delete Account",
                    isDark: isDark,
                    iconColor: Colors.red,
                    textColor: Colors.red,
                    onTap: () {
                      _showDeleteAccountDialog(context, isDark);
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

  // ==========================================
  // Header Widgets
  // ==========================================

  Widget _buildProfileHeader(BuildContext context, dynamic user, Color avatarBg, bool isDark) {
    // userProfileProvider থেকে আসা ডাটা এক্সট্র্যাক্ট করা
    final String name = user?.fullName ?? "No Name";
    final String id = user?.referralCode ?? "N/A";
    final String? img = user?.profilePicture;

    return Column(
      children: [
        // Profile Picture
        Container(
          width: 80.w,
          height: 80.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: avatarBg,
            border: Border.all(
              color: isDark ? const Color(0xFF29B6F6) : Colors.white,
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
            child: img != null && img.isNotEmpty
                ? Image.network(
                    img,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return _buildDefaultAvatar(name, isDark);
                    },
                  )
                : _buildDefaultAvatar(name, isDark),
          ),
        ),
        SizedBox(height: 12.h),

        // Full Name
        Text(
          name,
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

        // Affiliate ID with Copy Button
        GestureDetector(
          onTap: () => _copyAffiliateId(context, id),
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
                  'ID: $id',
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
    );
  }

  Widget _buildGuestHeader(BuildContext context, Color avatarBg, bool isDark) {
    return Column(
      children: [
        Container(
          width: 80.w,
          height: 80.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: avatarBg,
            border: Border.all(
              color: isDark ? const Color(0xFF29B6F6) : Colors.white,
              width: 3,
            ),
          ),
          child: Icon(Icons.person, size: 40.sp, color: isDark ? const Color(0xFF29B6F6) : skyBlue),
        ),
        SizedBox(height: 12.h),
        Text(
          'Welcome Guest',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8.h),
        ElevatedButton(
          onPressed: () => context.go('/login'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: skyBlue,
          ),
          child: const Text('Login / Register'),
        ),
      ],
    );
  }

  Widget _buildDefaultAvatar(String name, bool isDark) {
    return Container(
      color: isDark ? const Color(0xFF2C2C2C) : skyBlue.withOpacity(0.1),
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : '?',
          style: GoogleFonts.poppins(
            color: isDark ? const Color(0xFF29B6F6) : skyBlue,
            fontSize: 32.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // ==========================================
  // Helper Widgets
  // ==========================================

  Widget _buildThemeSelectorCard(BuildContext context, WidgetRef ref, bool isDark) {
    final themeMode = ref.watch(themeModeProvider);
    final primaryColor = isDark ? const Color(0xFF29B6F6) : skyBlue;

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 6.w),
      elevation: isDark ? 0 : 2,
      color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
        side: isDark
            ? const BorderSide(color: Color(0xFF333333), width: 1)
            : BorderSide.none,
      ),
      child: Column(
        children: [
          ListTile(
            leading: Icon(Icons.palette, color: primaryColor, size: 24.sp),
            title: Text(
              'Theme Mode',
              style: GoogleFonts.poppins(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            subtitle: Text(
              _getThemeLabel(themeMode),
              style: GoogleFonts.poppins(
                fontSize: 11.sp,
                color: isDark ? Colors.grey : Colors.grey.shade600,
              ),
            ),
          ),
          Divider(height: 1, color: isDark ? const Color(0xFF333333) : const Color(0xFFEEEEEE)),
          _buildThemeTile(
            context, ref,
            icon: Icons.light_mode, title: 'Light Mode', value: ThemeMode.light,
            currentMode: themeMode, isDark: isDark, primaryColor: primaryColor,
          ),
          _buildThemeTile(
            context, ref,
            icon: Icons.dark_mode, title: 'Dark Mode', value: ThemeMode.dark,
            currentMode: themeMode, isDark: isDark, primaryColor: primaryColor,
          ),
          _buildThemeTile(
            context, ref,
            icon: Icons.settings_suggest, title: 'System Default', value: ThemeMode.system,
            currentMode: themeMode, isDark: isDark, primaryColor: primaryColor,
          ),
        ],
      ),
    );
  }

  Widget _buildThemeTile(
    BuildContext context,
    WidgetRef ref, {
    required IconData icon,
    required String title,
    required ThemeMode value,
    required ThemeMode currentMode,
    required bool isDark,
    required Color primaryColor,
  }) {
    final isSelected = value == currentMode;

    return ListTile(
      dense: true,
      leading: Icon(
        icon,
        color: isSelected ? primaryColor : (isDark ? Colors.grey : Colors.grey.shade600),
        size: 20.sp,
      ),
      title: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 13.sp,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          color: isSelected ? primaryColor : (isDark ? Colors.white70 : Colors.black87),
        ),
      ),
      trailing: isSelected
          ? Icon(Icons.check_circle, color: primaryColor, size: 20.sp)
          : Icon(Icons.circle_outlined, size: 20.sp, color: isDark ? Colors.grey.shade700 : Colors.grey.shade400),
      onTap: () {
        ref.read(themeModeProvider.notifier).setTheme(value);
      },
    );
  }

  String _getThemeLabel(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'Light Mode Active';
      case ThemeMode.dark:
        return 'Dark Mode Active';
      default:
        return 'Following System';
    }
  }

  Widget _buildProfileItem(
    BuildContext context,
    IconData icon,
    String title, {
    required bool isDark,
    Color? iconColor,
    Color? textColor,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
      elevation: isDark ? 0 : 1,
      color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
        side: isDark
            ? const BorderSide(color: Color(0xFF333333), width: 1)
            : BorderSide.none,
      ),
      child: ListTile(
        leading: Icon(
            icon,
            color: iconColor ?? (isDark ? const Color(0xFF29B6F6) : skyBlue),
            size: 22.sp),
        title: Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 13.sp,
            fontWeight: FontWeight.w500,
            color: textColor ?? (isDark ? Colors.white : Colors.black87),
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios_rounded,
          size: 13.sp,
          color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
        ),
        onTap: onTap,
        splashColor: skyBlue.withOpacity(0.1),
      ),
    );
  }

  void _copyAffiliateId(BuildContext context, String affiliateId) {
    Clipboard.setData(ClipboardData(text: affiliateId));
    final isDark = Theme.of(context).brightness == Brightness.dark;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Affiliate ID Copy করা হয়েছে!',
          style: GoogleFonts.poppins(fontSize: 12.sp),
        ),
        backgroundColor: isDark ? const Color(0xFF29B6F6) : Colors.green,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.r),
        ),
      ),
    );
  }

  // Dialogs
  void _showLanguageDialog(BuildContext context, bool isDark) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        title: Text(
          'Select Language',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _languageOption(context, 'English', isDark),
            _languageOption(context, 'বাংলা', isDark),
            _languageOption(context, 'Español', isDark),
          ],
        ),
      ),
    );
  }

  Widget _languageOption(BuildContext context, String language, bool isDark) {
    return ListTile(
      title: Text(
        language,
        style: GoogleFonts.poppins(
          color: isDark ? Colors.white : Colors.black,
        ),
      ),
      onTap: () {
        Navigator.pop(context);
      },
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref, bool isDark) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        title: Text(
          'Logout',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        content: Text(
          'Are you sure you want to logout?',
          style: GoogleFonts.poppins(
            color: isDark ? Colors.white70 : Colors.black87,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(color: isDark ? Colors.grey : Colors.grey.shade600),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              // Logout logic calling your auth provider
              try {
                // await ref.read(authProvider.notifier).logout();
                if (context.mounted) context.go('/login');
              } catch (e) {
                debugPrint("Logout error: $e");
              }
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

  void _showDeleteAccountDialog(BuildContext context, bool isDark) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        title: Text(
          'Delete Account',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: Colors.red,
          ),
        ),
        content: Text(
          'This action cannot be undone. All your data will be permanently deleted. Are you sure?',
          style: GoogleFonts.poppins(
            color: isDark ? Colors.white70 : Colors.black87,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(color: isDark ? Colors.grey : Colors.grey.shade600),
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
