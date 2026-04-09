import 'dart:ui'; // ব্লার ইফেক্টের জন্য প্রয়োজন
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart'; // লটি প্যাকেজটি অবশ্যই থাকতে হবে

// আপনার প্রোপ্রাইডার ইম্পোর্ট (আপনার প্রোজেক্ট পাথ অনুযায়ী ঠিক করে নিন)
import '../main.dart'; 

class AppTopBar extends ConsumerWidget {
  final bool isDetailView;
  final String detailTitle;
  final bool isMobile;
  final bool isLoggedIn;

  static const Color skyBlue = Color(0xFF29B6F6);

  const AppTopBar({
    super.key,
    required this.isDetailView,
    required this.detailTitle,
    required this.isMobile,
    required this.isLoggedIn,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ClipRRect( // ব্লার যেন বারের বাইরে ছড়িয়ে না যায়
      child: SizedBox(
        height: isMobile ? 65.h : 70, // অ্যানিমেশন দেখানোর জন্য হাইট সামান্য বাড়ানো হয়েছে
        child: Stack(
          children: [
            // ১. ব্যাকগ্রাউন্ডে লটি অ্যানিমেশন
            Positioned.fill(
              child: Lottie.network(
                'https://lottie.host/81b37365-2244-4861-9c86-13d6a455a5b1/F0mJ3Z9oYv.json', // একটি প্রিমিয়াম লটি লিংক দেওয়া হয়েছে
                fit: BoxFit.cover,
                repeat: true,
              ),
            ),

            // ২. ঝাপসা আকাশী লেয়ার (Blur + Color Overlay)
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10), // ঝাপসা করার পরিমাণ
                child: Container(
                  color: skyBlue.withOpacity(0.45), // আকাশী কালারের স্বচ্ছ আস্তর
                ),
              ),
            ),

            // ৩. মেইন কন্টেন্ট (আইকন ও টাইটেল)
            SafeArea(
              bottom: false,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.w),
                child: Row(
                  children: [
                    if (isDetailView)
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_rounded,
                            color: Colors.white, size: 22),
                        onPressed: () {
                          // আপনার অরিজিনাল লজিক
                          ref.read(isDetailViewProvider.notifier).state = false;
                          ref.read(detailViewTitleProvider.notifier).state = '';
                          context.go('/home');
                        },
                      )
                    else
                      Builder(
                        builder: (ctx) => IconButton(
                          icon: const Icon(Icons.menu_open_rounded,
                              color: Colors.white, size: 28),
                          onPressed: () => Scaffold.of(ctx).openDrawer(),
                        ),
                      ),
                    
                    Expanded(
                      child: Center(
                        child: Text(
                          isDetailView ? detailTitle : 'Easy Service',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: isMobile ? 18.sp : 20,
                            letterSpacing: 0.5,
                            shadows: [
                              Shadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    if (!isDetailView && isLoggedIn)
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.notifications_outlined,
                            color: Colors.white, size: 26),
                      )
                    else
                      SizedBox(width: 48.w), // ব্যালেন্স রাখার জন্য গ্যাপ
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
