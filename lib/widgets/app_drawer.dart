import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../main.dart';

class UserProfile {
  final String fullName;
  final String referralCode;
  final String? profilePicture;
  final String idVerified;

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

final drawerProfileProvider = FutureProvider<UserProfile?>((ref) async {
  const String baseUrl = "https://api.easysarvice.com/api";
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
    debugPrint("Drawer Profile Fetch Error: $e");
    return null;
  }
  return null;
});

// ==================== DRAWER ====================

class AppDrawer extends ConsumerStatefulWidget {
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
  ConsumerState<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends ConsumerState<AppDrawer> {
  // ==================== REWARDED AD ====================
  RewardedAd? _rewardedAd;
  bool _isAdLoaded = false;
  bool _isAdShowing = false;

  // Test Rewarded Ad Unit ID
  static const String _rewardedAdUnitId =
      'ca-app-pub-3940256099942544/5224354917';

  @override
  void initState() {
    super.initState();
    _loadRewardedAd();
  }

  void _loadRewardedAd() {
    RewardedAd.load(
      adUnitId: _rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          setState(() {
            _rewardedAd = ad;
            _isAdLoaded = true;
          });
          debugPrint('Drawer Rewarded Ad Loaded');
        },
        onAdFailedToLoad: (error) {
          setState(() => _isAdLoaded = false);
          debugPrint('Drawer Rewarded Ad Failed: ${error.message}');
        },
      ),
    );
  }

  /// Ad দেখিয়ে navigate করে।
  /// Ad load না হলে সরাসরি navigate করে (UX নষ্ট না করতে)।
  void _navigateWithAd(VoidCallback onRewardEarned) {
    // Ad already showing থাকলে skip
    if (_isAdShowing) return;

    if (!_isAdLoaded || _rewardedAd == null) {
      // Ad ready না — সরাসরি navigate
      onRewardEarned();
      _loadRewardedAd(); // পরেরবারের জন্য load
      return;
    }

    setState(() => _isAdShowing = true);

    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        setState(() {
          _rewardedAd = null;
          _isAdLoaded = false;
          _isAdShowing = false;
        });
        _loadRewardedAd();
        // Ad দেখা শেষ কিন্তু reward পায়নি — navigate করব না
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        setState(() {
          _rewardedAd = null;
          _isAdLoaded = false;
          _isAdShowing = false;
        });
        debugPrint('Ad Show Failed: ${error.message}');
        // Fail হলে সরাসরি navigate
        onRewardEarned();
        _loadRewardedAd();
      },
    );

    _rewardedAd!.show(
      onUserEarnedReward: (ad, reward) {
        // Reward পেলে navigate
        onRewardEarned();
      },
    );

    _rewardedAd = null;
  }

  @override
  void dispose() {
    _rewardedAd?.dispose();
    super.dispose();
  }
  // ==================== END REWARDED AD ====================

  @override
  Widget build(BuildContext context) {
    final double drawerWidth = widget.isDesktop
        ? 300
        : widget.isTablet
            ? 280
            : MediaQuery.of(context).size.width * 0.78;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final drawerBackground = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subTextColor = isDark ? Colors.grey.shade400 : Colors.grey.shade600;
    final dividerColor = isDark ? const Color(0xFF333333) : const Color(0xFFEEEEEE);
    final avatarBgColor = isDark ? const Color(0xFF2C2C2C) : Colors.white;
    final splashColor = isDark
        ? AppDrawer.skyBlue.withOpacity(0.15)
        : AppDrawer.skyBlue.withOpacity(0.1);

    final profileAsync = ref.watch(drawerProfileProvider);

    return SizedBox(
      width: drawerWidth,
      child: Drawer(
        backgroundColor: drawerBackground,
        child: Column(
          children: [
            // ==================== HEADER ====================
            Container(
              width: double.infinity,
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 20,
                bottom: 25,
                left: 20,
                right: 20,
              ),
              decoration: const BoxDecoration(
                color: AppDrawer.skyBlue,
                borderRadius: BorderRadius.only(
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: widget.isLoggedIn
                  ? profileAsync.when(
                      data: (user) =>
                          _buildProfileHeader(context, user, avatarBgColor, isDark),
                      loading: () => const Center(
                          child: CircularProgressIndicator(color: Colors.white)),
                      error: (err, stack) => _buildGuestHeader(context),
                    )
                  : _buildGuestHeader(context),
            ),

            // ==================== MENU ITEMS ====================
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                physics: const BouncingScrollPhysics(),
                children: [

                  // 1. Voucher Balance
                  if (widget.isLoggedIn)
                    _drawerItem(
                      context,
                      Icons.card_giftcard_rounded,
                      "Voucher Balance",
                      textColor: textColor,
                      subTextColor: subTextColor,
                      splashColor: splashColor,
                      onTap: () {
                        _navigateWithAd(() {
                          Navigator.pop(context);
                          ref.read(isDetailViewProvider.notifier).state = true;
                          ref.read(detailViewTitleProvider.notifier).state = 'Voucher Balance';
                          context.push('/voucher-balance');
                        });
                      },
                    ),

                  // 2. Vendor Apply
                  if (widget.isLoggedIn)
                    _drawerItem(
                      context,
                      Icons.storefront_rounded,
                      "Vendor Apply",
                      iconColor: Colors.orange,
                      textColor: textColor,
                      subTextColor: subTextColor,
                      splashColor: splashColor,
                      onTap: () {
                        _navigateWithAd(() {
                          Navigator.pop(context);
                          ref.read(isDetailViewProvider.notifier).state = true;
                          ref.read(detailViewTitleProvider.notifier).state = 'Vendor Apply';
                          context.push('/vendor-apply');
                        });
                      },
                    ),

                  // 3. Royalty Salary
                  if (widget.isLoggedIn)
                    _drawerItem(
                      context,
                      Icons.workspace_premium_rounded,
                      "Royalty Salary",
                      textColor: textColor,
                      subTextColor: subTextColor,
                      splashColor: splashColor,
                      onTap: () {
                        _navigateWithAd(() {
                          Navigator.pop(context);
                          ref.read(isDetailViewProvider.notifier).state = true;
                          ref.read(detailViewTitleProvider.notifier).state = 'Royalty Salary';
                          context.push('/royalty-salary');
                        });
                      },
                    ),

                  // 4. My Referrals
                  if (widget.isLoggedIn)
                    _drawerItem(
                      context,
                      Icons.group_add_rounded,
                      "My Referrals",
                      iconColor: Colors.purple,
                      textColor: textColor,
                      subTextColor: subTextColor,
                      splashColor: splashColor,
                      onTap: () {
                        _navigateWithAd(() {
                          Navigator.pop(context);
                          ref.read(isDetailViewProvider.notifier).state = true;
                          ref.read(detailViewTitleProvider.notifier).state = 'My Referrals';
                          context.push('/referral');
                        });
                      },
                    ),

                  // 5. Matrix Income
                  if (widget.isLoggedIn)
                    _drawerItem(
                      context,
                      Icons.account_tree_rounded,
                      "Matrix Income",
                      iconColor: Colors.teal,
                      textColor: textColor,
                      subTextColor: subTextColor,
                      splashColor: splashColor,
                      onTap: () {
                        _navigateWithAd(() {
                          Navigator.pop(context);
                          ref.read(isDetailViewProvider.notifier).state = true;
                          ref.read(detailViewTitleProvider.notifier).state = 'Matrix Income';
                          context.push('/matrix-income');
                        });
                      },
                    ),

                  // 6. My Wallet
                  if (widget.isLoggedIn)
                    _drawerItem(
                      context,
                      Icons.account_balance_wallet_rounded,
                      "My Wallet",
                      iconColor: Colors.green,
                      textColor: textColor,
                      subTextColor: subTextColor,
                      splashColor: splashColor,
                      onTap: () {
                        _navigateWithAd(() {
                          Navigator.pop(context);
                          ref.read(isDetailViewProvider.notifier).state = true;
                          ref.read(detailViewTitleProvider.notifier).state = 'My Wallet';
                          context.push('/wallet');
                        });
                      },
                    ),

                  // 7. Leaderboard (Ad ছাড়া — public page)
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
                    child: Divider(color: dividerColor, thickness: 1.5),
                  ),

                  // 8. Support Center (Ad ছাড়া)
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

                  // 9. Facebook (Ad ছাড়া)
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

                  // 10. YouTube (Ad ছাড়া)
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

                  // 11. Telegram (Ad ছাড়া)
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

                  // 12. Website (Ad ছাড়া)
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
                    child: Divider(color: dividerColor, thickness: 1.5),
                  ),

                  // 13. Privacy Policy (Ad ছাড়া)
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

                  // 14. Terms & Conditions (Ad ছাড়া)
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

                  // 15. About Us (Ad ছাড়া)
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

            // ==================== LOGOUT ====================
            if (widget.isLoggedIn)
              Padding(
                padding: const EdgeInsets.fromLTRB(15, 10, 15, 25),
                child: ListTile(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
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
                    try {
                      await ref.read(authProvider.notifier).logout();
                      if (context.mounted) context.go('/registration');
                    } catch (e) {
                      debugPrint("Logout error: $e");
                    }
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ==================== PROFILE HEADER ====================
  Widget _buildProfileHeader(
      BuildContext context, UserProfile? user, Color avatarBg, bool isDark) {
    final String name = user?.fullName ?? "No Name";
    final String id = user?.referralCode ?? "N/A";
    final String? img = user?.profilePicture;
    final bool isVerified = user?.idVerified == 'verified';

    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: avatarBg,
            border: Border.all(color: Colors.white, width: 3),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5)),
            ],
          ),
          child: ClipOval(
            child: img != null && img.isNotEmpty
                ? Image.network(
                    img,
                    fit: BoxFit.cover,
                    errorBuilder: (c, e, s) =>
                        _buildDefaultAvatar(name, isDark),
                  )
                : _buildDefaultAvatar(name, isDark),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                name,
                style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 6),
            Icon(
              isVerified ? Icons.verified : Icons.cancel,
              color: isVerified ? Colors.greenAccent : Colors.redAccent,
              size: 20,
            ),
          ],
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => _copyAffiliateId(context, id, isDark),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.copy_rounded, color: Colors.white, size: 14),
                const SizedBox(width: 6),
                Text(
                  'ID: $id',
                  style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGuestHeader(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.2)),
          child: const Icon(Icons.person_outline_rounded,
              color: Colors.white, size: 40),
        ),
        const SizedBox(height: 12),
        Text('Welcome Guest',
            style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () {
            Navigator.pop(context);
            context.go('/login');
          },
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20)),
            child: Text(
              'Login / Register',
              style: GoogleFonts.poppins(
                  color: AppDrawer.skyBlue,
                  fontSize: 12,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDefaultAvatar(String name, bool isDark) {
    return Container(
      color: isDark
          ? const Color(0xFF2C2C2C)
          : AppDrawer.skyBlue.withOpacity(0.1),
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : '?',
          style: GoogleFonts.poppins(
              color: AppDrawer.skyBlue,
              fontSize: 32,
              fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  void _copyAffiliateId(
      BuildContext context, String affiliateId, bool isDark) {
    Clipboard.setData(ClipboardData(text: affiliateId));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            Text('Affiliate ID copied!', style: GoogleFonts.poppins()),
        backgroundColor:
            isDark ? const Color(0xFF29B6F6) : Colors.green,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

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
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      leading:
          Icon(icon, color: iconColor ?? AppDrawer.skyBlue, size: 24),
      title: Text(
        title,
        style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: textColor),
      ),
      trailing: Icon(Icons.arrow_forward_ios_rounded,
          size: 13, color: subTextColor),
      onTap: onTap,
      splashColor: splashColor,
    );
  }

  void _launchURL(String url) async {
    debugPrint("Launching $url");
  }
}
