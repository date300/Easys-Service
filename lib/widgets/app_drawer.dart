import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

// Import your providers – adjust path as needed
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
            // Header (Icon and Profile Info fully removed)
            Container(
              width: double.infinity,
              height: MediaQuery.of(context).padding.top + 40, // Height adjusted
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
                  if (isLoggedIn) ...[
                    _drawerItem(
                      context,
                      Icons.account_balance_wallet_rounded,
                      "Wallet",
                      onTap: () => Navigator.pop(context),
                    ),
                    _drawerItem(
                      context,
                      Icons.card_giftcard_rounded,
                      "Voucher Balance",
                      onTap: () => Navigator.pop(context),
                    ),
                    _drawerItem(
                      context,
                      Icons.workspace_premium_rounded,
                      "Royalty Salary",
                      onTap: () => Navigator.pop(context),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                      child: Divider(color: Color(0xFFEEEEEE), thickness: 1.5),
                    ),
                  ],
                  _drawerItem(
                    context,
                    Icons.support_agent_rounded,
                    "Support Center",
                    onTap: () => Navigator.pop(context),
                  ),
                  _drawerItem(
                    context,
                    Icons.facebook_rounded,
                    "Facebook Group",
                    iconColor: Colors.blue,
                    onTap: () => Navigator.pop(context),
                  ),
                  _drawerItem(
                    context,
                    Icons.smart_display_rounded,
                    "YouTube Channel",
                    iconColor: Colors.red,
                    onTap: () => Navigator.pop(context),
                  ),
                  _drawerItem(
                    context,
                    Icons.telegram_rounded,
                    "Telegram Group",
                    iconColor: Colors.blueAccent,
                    onTap: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Logout Button
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
}
