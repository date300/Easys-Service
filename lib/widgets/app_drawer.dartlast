import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

// Import your providers - adjust path as needed
import '../main.dart';

class AppDrawer extends ConsumerWidget {
  final bool isLoggedIn;
  final bool isDesktop;
  final bool isTablet;

  static const Color skyBlue = Color(0xFF29B6F6);

  const AppDrawer({
    super.key,
    required this.isLoggedIn,
    required this.isDesktop,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final double drawerWidth = isDesktop
        ? 300
        : isTablet
            ? 280
            : MediaQuery.of(context).size.width * 0.78;

    // 🔥 DYNAMIC THEME COLORS
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final drawerBackground = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subTextColor = isDark ? Colors.grey.shade400 : Colors.grey.shade600;
    final dividerColor = isDark ? const Color(0xFF333333) : const Color(0xFFEEEEEE);
    final avatarBgColor = isDark ? const Color(0xFF2C2C2C) : Colors.white;
    final menuItemBg = isDark ? const Color(0xFF252525) : Colors.transparent;
    final splashColor = isDark ? skyBlue.withOpacity(0.15) : skyBlue.withOpacity(0.1);

    final userProfile = isLoggedIn
        ? {
            'fullName': 'মোঃ রahim মিয়া',
            'affiliateId': 'AFF123456',
            'profileImage': null,
          }
        : null;

    return SizedBox(
      width: drawerWidth,
      child: Drawer(
        backgroundColor: drawerBackground,  // 🔥 DYNAMIC
        child: Column(
          children: [
            // Header with Profile Info
            Container(
              width: double.infinity,
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 20,
                bottom: 25,
                left: 20,
                right: 20,
              ),
              decoration: const BoxDecoration(
                color: skyBlue,  // Header always skyBlue
                borderRadius: BorderRadius.only(
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: isLoggedIn && userProfile != null
                  ? Column(
                      children: [
                        // Profile Picture
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: avatarBgColor,  // 🔥 DYNAMIC
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
                                      return _buildDefaultAvatar(userProfile['fullName']!, isDark);
                                    },
                                  )
                                : _buildDefaultAvatar(userProfile['fullName']!, isDark),
                          ),
                        ),
                        const SizedBox(height: 12),
                        
                        // Full Name
                        Text(
                          userProfile['fullName']!,
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        
                        // Affiliate ID with Copy Button
                        GestureDetector(
                          onTap: () => _copyAffiliateId(context, userProfile['affiliateId']!, isDark),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.3),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.copy_rounded,
                                  color: Colors.white,
                                  size: 14,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'ID: ${userProfile['affiliateId']}',
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    )
                  : // Guest User Header
                  Column(
                      children: [
                        Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.2),
                          ),
                          child: const Icon(
                            Icons.person_outline_rounded,
                            color: Colors.white,
                            size: 40,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Welcome Guest',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                            context.go('/login');
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'Login / Register',
                              style: GoogleFonts.poppins(
                                color: skyBlue,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
            ),

            // Menu Items
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                physics: const BouncingScrollPhysics(),
                children: [
                  // 1. Voucher Balance
                  if (isLoggedIn)
                    _drawerItem(
                      context,
                      Icons.card_giftcard_rounded,
                      "Voucher Balance",
                      textColor: textColor,
                      subTextColor: subTextColor,
                      splashColor: splashColor,
                      onTap: () {
                        Navigator.pop(context);
                        context.go('/voucher-balance');
                      },
                    ),

                  // 2. Royalty Salary
                  if (isLoggedIn)
                    _drawerItem(
                      context,
                      Icons.workspace_premium_rounded,
                      "Royalty Salary",
                      textColor: textColor,
                      subTextColor: subTextColor,
                      splashColor: splashColor,
                      onTap: () {
                        Navigator.pop(context);
                        context.go('/royalty-salary');
                      },
                    ),

                  // 3. Leaderboard
                  _drawerItem(
                    context,
                    Icons.emoji_events_rounded,
                    "Leaderboard",
                    iconColor: Colors.amber,
                    textColor: textColor,
                    subTextColor: subTextColor,
                    splashColor: splashColor,
                    onTap: () {
                      Navigator.pop(context);
                      context.go('/leaderboard');
                    },
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                    child: Divider(color: dividerColor, thickness: 1.5),  // 🔥 DYNAMIC
                  ),

                  // 4. Support Center
                  _drawerItem(
                    context,
                    Icons.support_agent_rounded,
                    "Support Center",
                    textColor: textColor,
                    subTextColor: subTextColor,
                    splashColor: splashColor,
                    onTap: () {
                      Navigator.pop(context);
                      context.go('/support');
                    },
                  ),

                  // 5. Facebook
                  _drawerItem(
                    context,
                    Icons.facebook_rounded,
                    "Facebook",
                    iconColor: Colors.blue,
                    textColor: textColor,
                    subTextColor: subTextColor,
                    splashColor: splashColor,
                    onTap: () {
                      Navigator.pop(context);
                      _launchURL('https://facebook.com/yourpage');
                    },
                  ),

                  // 6. YouTube
                  _drawerItem(
                    context,
                    Icons.smart_display_rounded,
                    "YouTube",
                    iconColor: Colors.red,
                    textColor: textColor,
                    subTextColor: subTextColor,
                    splashColor: splashColor,
                    onTap: () {
                      Navigator.pop(context);
                      _launchURL('https://youtube.com/yourchannel');
                    },
                  ),

                  // 7. Telegram
                  _drawerItem(
                    context,
                    Icons.telegram_rounded,
                    "Telegram",
                    iconColor: Colors.blueAccent,
                    textColor: textColor,
                    subTextColor: subTextColor,
                    splashColor: splashColor,
                    onTap: () {
                      Navigator.pop(context);
                      _launchURL('https://t.me/yourgroup');
                    },
                  ),

                  // 8. Website
                  _drawerItem(
                    context,
                    Icons.language_rounded,
                    "Website",
                    iconColor: Colors.green,
                    textColor: textColor,
                    subTextColor: subTextColor,
                    splashColor: splashColor,
                    onTap: () {
                      Navigator.pop(context);
                      _launchURL('https://yourwebsite.com');
                    },
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                    child: Divider(color: dividerColor, thickness: 1.5),  // 🔥 DYNAMIC
                  ),

                  // 9. Privacy Policy
                  _drawerItem(
                    context,
                    Icons.privacy_tip_rounded,
                    "Privacy Policy",
                    textColor: textColor,
                    subTextColor: subTextColor,
                    splashColor: splashColor,
                    onTap: () {
                      Navigator.pop(context);
                      context.go('/privacy-policy');
                    },
                  ),

                  // 10. Terms & Conditions
                  _drawerItem(
                    context,
                    Icons.description_rounded,
                    "Terms & Conditions",
                    textColor: textColor,
                    subTextColor: subTextColor,
                    splashColor: splashColor,
                    onTap: () {
                      Navigator.pop(context);
                      context.go('/terms');
                    },
                  ),

                  // 11. About Us
                  _drawerItem(
                    context,
                    Icons.info_rounded,
                    "About Us",
                    textColor: textColor,
                    subTextColor: subTextColor,
                    splashColor: splashColor,
                    onTap: () {
                      Navigator.pop(context);
                      context.go('/about');
                    },
                  ),
                ],
              ),
            ),

            // 12. Logout Button
            if (isLoggedIn)
              Padding(
                padding: const EdgeInsets.fromLTRB(15, 10, 15, 25),
                child: ListTile(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  tileColor: Colors.red.withOpacity(0.1),
                  leading: const Icon(Icons.logout_rounded, color: Colors.red),
                  title: Text(
                    "Logout",
                    style: GoogleFonts.poppins(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  onTap: () async {
                    Navigator.pop(context);
                    await ref.read(authProvider.notifier).logout();
                    if (context.mounted) context.go('/registration');
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Default Avatar with Dynamic Color
  Widget _buildDefaultAvatar(String name, bool isDark) {
    return Container(
      color: isDark ? const Color(0xFF2C2C2C) : skyBlue.withOpacity(0.1),
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : '?',
          style: GoogleFonts.poppins(
            color: isDark ? skyBlue : skyBlue,
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // Copy Affiliate ID with Dynamic Snackbar
  void _copyAffiliateId(BuildContext context, String affiliateId, bool isDark) {
    Clipboard.setData(ClipboardData(text: affiliateId));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Affiliate ID কপি করা হয়েছে!',
          style: GoogleFonts.poppins(),
        ),
        backgroundColor: isDark ? const Color(0xFF29B6F6) : Colors.green,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  // Drawer Item with Dynamic Colors
  Widget _drawerItem(
    BuildContext context,
    IconData icon,
    String title, {
    Color? iconColor,
    required Color textColor,
    required Color subTextColor,
    required Color splashColor,
    required VoidCallback onTap,
  }) {
    return ListTile(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      leading: Icon(icon, color: iconColor ?? skyBlue, size: 24),
      title: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: textColor,  // 🔥 DYNAMIC
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios_rounded,
        size: 13, 
        color: subTextColor,  // 🔥 DYNAMIC
      ),
      onTap: onTap,
      splashColor: splashColor,  // 🔥 DYNAMIC
    );
  }

  // URL Launch
  void _launchURL(String url) async {
    // url_launcher implement করুন
  }
}
