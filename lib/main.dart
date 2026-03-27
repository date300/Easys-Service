import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// ইমপোর্ট সেকশন (আপনার ফাইল পাথ অনুযায়ী)
import 'layout/main_wrapper.dart';
import 'features/auth/registration_screen.dart';
import 'features/home/home_screen.dart';
import 'features/campaigns/campaigns_screen.dart';
import 'features/drive/drive_screen.dart';
import 'features/microjobs/microjobs_screen.dart';
import 'features/profile/profile_screen.dart';
import 'features/reselling/reselling_screen.dart';

// GoRouter কনফিগারেশন
final _router = GoRouter(
  initialLocation: '/',
  routes: [
    // ১. স্প্ল্যাশ স্ক্রিন (রুট পাথ)
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashScreen(),
    ),
    
    // ২. রেজিস্ট্রেশন পেজ
    GoRoute(
      path: '/registration',
      builder: (context, state) => const RegistrationScreen(),
    ),

    // ৩. মেইন অ্যাপের সব পেজ (লিংকের মাধ্যমে ঢোকার জন্য আলাদা রাউট)
    // যদি আপনি চান 'MainWrapper' (যেমন বটম ন্যাভিগেশন) বজায় থাকুক, তবে ShellRoute ব্যবহার করা ভালো।
    // এখানে সাধারণ রাউট হিসেবে দেখানো হলো:
    
    GoRoute(
      path: '/home',
      builder: (context, state) => const MainWrapper(child: HomeScreen()), 
    ),
    GoRoute(
      path: '/campaigns',
      builder: (context, state) => const MainWrapper(child: CampaignsScreen()),
    ),
    GoRoute(
      path: '/drive',
      builder: (context, state) => const MainWrapper(child: DriveScreen()),
    ),
    GoRoute(
      path: '/microjobs',
      builder: (context, state) => const MainWrapper(child: MicrojobsScreen()),
    ),
    GoRoute(
      path: '/reselling',
      builder: (context, state) => const MainWrapper(child: ResellingScreen()),
    ),
    GoRoute(
      path: '/profile',
      builder: (context, state) => const MainWrapper(child: ProfileScreen()),
    ),
  ],
);

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 800),
      builder: (context, child) {
        return MaterialApp.router(
          debugShowCheckedModeBanner: false,
          routerConfig: _router,
          theme: ThemeData(useMaterial3: true),
        );
      },
    );
  }
}
