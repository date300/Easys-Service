
import 'package:flutter/material.dart';
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

    return SizedBox(
      width: drawerWidth,
      child: Drawer(
        backgroundColor: Colors.white,
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              height: MediaQuery.of(context).padding.top + 40,
              decoration: const BoxDecoration(
                color: skyBlue,
                borderRadius: BorderRadius.only(
                  bottomRight: Radius.circular(30),
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Menu Items
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                physics: const BouncingScrollPhysics(),
                children: [
                  // 1. Voucher Balance (শুধু লগইন করা ইউজারদের জন্য)
                  if (isLoggedIn)
                    _drawerItem(
                      context,
                      Icons.card_giftcard_rounded,
                      "Voucher Balance",
                      onTap: () {
                        Navigator.pop(context);
                        context.go('/voucher-balance');
                      },
                    ),

                  // 2. Royalty Salary (শুধু লগইন করা ইউজারদের জন্য)
                  if (isLoggedIn)
                    _drawerItem(
                      context,
                      Icons.workspace_premium_rounded,
                      "Royalty Salary",
                      onTap: () {
                        Navigator.pop(context);
                        context.go('/royalty-salary');
                      },
                    ),

                  // 3. Leaderboard (সবার জন্য)
                  _drawerItem(
                    context,
                    Icons.emoji_events_rounded,
                    "Leaderboard",
                    iconColor: Colors.amber,
                    onTap: () {
                      Navigator.pop(context);
                      context.go('/leaderboard');
                    },
                  ),

                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                    child: Divider(color: Color(0xFFEEEEEE), thickness: 1.5),
                  ),

                  // 4. Support Center
                  _drawerItem(
                    context,
                    Icons.support_agent_rounded,
                    "Support Center",
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
                    onTap: () {
                      Navigator.pop(context);
                      _launchURL('https://yourwebsite.com');
                    },
                  ),

                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                    child: Divider(color: Color(0xFFEEEEEE), thickness: 1.5),
                  ),

                  // 9. Privacy Policy
                  _drawerItem(
                    context,
                    Icons.privacy_tip_rounded,
                    "Privacy Policy",
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
                    onTap: () {
                      Navigator.pop(context);
                      context.go('/about');
                    },
                  ),
                ],
              ),
            ),

            // 12. Logout Button (শুধু লগইন করা ইউজারদের জন্য)
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

  Widget _drawerItem(
    BuildContext context,
    IconData icon,
    String title, {
    Color? iconColor,
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
          color: Colors.black87,
        ),
      ),
      trailing: Icon(Icons.arrow_forward_ios_rounded,
          size: 13, color: Colors.grey.shade400),
      onTap: onTap,
      splashColor: skyBlue.withOpacity(0.1),
    );
  }

  // URL লaunch করার জন্য হেল্পার মেথড
  void _launchURL(String url) async {
    // url_launcher প্যাকেজ ব্যবহার করুন
    // import 'package:url_launcher/url_launcher.dart';
    // if (await canLaunchUrl(Uri.parse(url))) {
    //   await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    // }
  }
}
