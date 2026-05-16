import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class MicrojobsScreen extends StatefulWidget {
  const MicrojobsScreen({super.key});

  @override
  State<MicrojobsScreen> createState() => _MicrojobsScreenState();
}

class _MicrojobsScreenState extends State<MicrojobsScreen> {
  RewardedAd? _rewardedAd;
  bool _isRewardedLoaded = false;

  // ✅ আপনার আসল Rewarded Ad ID
  static const String _rewardedAdUnitId =
      'ca-app-pub-9354625065393218/3725985999';

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
            _isRewardedLoaded = true;
          });
        },
        onAdFailedToLoad: (error) {
          debugPrint('Rewarded Ad failed: ${error.message}');
          setState(() => _isRewardedLoaded = false);
        },
      ),
    );
  }

  void _showRewardedAd() {
    if (_rewardedAd == null) return;

    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        setState(() => _isRewardedLoaded = false);
        _loadRewardedAd(); // পরেরবারের জন্য reload
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        debugPrint('Rewarded Ad show failed: ${error.message}');
      },
    );

    _rewardedAd!.show(
      onUserEarnedReward: (ad, reward) {
        // ✅ User ad দেখা শেষ করলে এখানে reward দিন
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '🎉 আপনি ${reward.amount} ${reward.type} পেয়েছেন!',
              style: GoogleFonts.poppins(fontSize: 13.sp),
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      },
    );

    _rewardedAd = null;
  }

  @override
  void dispose() {
    _rewardedAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.assignment_turned_in_rounded,
              size: 80.sp,
              color: Colors.grey[300],
            ),
            SizedBox(height: 16.h),
            Text(
              "Microjobs Portal",
              style: GoogleFonts.poppins(
                fontSize: 22.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              "Coming Soon!",
              style: GoogleFonts.poppins(
                fontSize: 14.sp,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 40.h),

            // ✅ Rewarded Ad Button
            ElevatedButton.icon(
              onPressed: _isRewardedLoaded ? _showRewardedAd : null,
              icon: const Icon(Icons.card_giftcard),
              label: Text(
                _isRewardedLoaded
                    ? '🎁 Ad দেখো, Reward নাও!'
                    : 'Ad লোড হচ্ছে...',
                style: GoogleFonts.poppins(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.grey[300],
                padding: EdgeInsets.symmetric(
                  horizontal: 28.w,
                  vertical: 14.h,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
