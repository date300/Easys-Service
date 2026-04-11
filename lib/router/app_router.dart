import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
// আপনার স্প্ল্যাশ স্ক্রিন ফাইলটি ইমপোর্ট করুন (পাথ ঠিক আছে কি না দেখে নিন)
import '../screens/splash/splash_screen.dart'; 
import '../features/recharge/recharge_screen.dart';
import '../features/drive/drive_screen.dart';
import '../features/home/home_screen.dart';
import '../features/reselling/reselling_screen.dart';
import '../features/microjobs/microjobs_screen.dart';
import '../features/campaigns/campaigns_screen.dart';
import '../features/profile/profile_screen.dart';
import '../features/auth/registration_screen.dart';
import '../features/payment/payment_gateway_screen.dart';
import '../main.dart';

final GoRouter appRouter = GoRouter(
  // ১. অ্যাপ শুরু হবে স্প্ল্যাশ স্ক্রিন দিয়ে
  initialLocation: '/splash', 
  
  routes: [
    // ২. স্প্ল্যাশ স্ক্রিন রাউট (এটি ShellRoute এর বাইরে থাকবে)
    GoRoute(
      path: '/splash',
      builder: (context, state) => const SplashScreen(),
    ),

    GoRoute(
      path: '/registration',
      builder: (context, state) => const RegistrationScreen(),
    ),

    // ShellRoute — সব পেজ এখানে (Bottom Nav + AppTopBar সহ)
    ShellRoute(
      builder: (context, state, child) => MainWrapper(child: child),
      routes: [
        GoRoute(
          path: '/home',
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: '/drive',
          builder: (context, state) => const DriveScreen(),
        ),
        GoRoute(
          path: '/reselling',
          builder: (context, state) => const ResellingScreen(),
        ),
        GoRoute(
          path: '/microjobs',
          builder: (context, state) => const MicrojobsScreen(),
        ),
        GoRoute(
          path: '/campaigns',
          builder: (context, state) => const CampaignsScreen(),
        ),
        GoRoute(
          path: '/profile',
          builder: (context, state) => const ProfileScreen(),
        ),
                GoRoute(
          path: '/recharge',
          builder: (context, state) => const RechargeScreen(),
        ),

        GoRoute(
          path: '/payment',
          builder: (context, state) {
            final extra = state.extra as Map<String, dynamic>?;
            return PaymentGatewayScreen(
              amount: extra?['amount'] ?? 199.00,
              purpose: extra?['purpose'] ?? 'Account Verification Fee',
              onPaymentSuccess: extra?['onSuccess'],
            );
          },
        ),
      ],
    ),
  ],

  // ৩. রিডাইরেক্ট লজিক আপডেট
  redirect: (context, state) async {
    final ref = ProviderScope.containerOf(context);
    await ref.read(authLoadingProvider.future);
    final isLoggedIn = ref.read(authProvider);
    
    final loc = state.matchedLocation;
    final isSplash = loc == '/splash'; // স্প্ল্যাশ স্ক্রিনে আছে কি না
    final isRegister = loc == '/registration';

    // যদি স্প্ল্যাশ স্ক্রিনে থাকে, তবে কোনো রিডাইরেক্ট হবে না (এনিমেশন শেষ হতে দিন)
    if (isSplash) return null;

    // লগইন না থাকলে এবং রেজিস্ট্রেশন পেজে না থাকলে রেজিস্ট্রেশনে পাঠাবে
    if (!isLoggedIn && !isRegister) return '/registration';
    
    // লগইন থাকলে এবং রেজিস্ট্রেশন পেজে যাওয়ার চেষ্টা করলে হোমে পাঠাবে
    if (isLoggedIn && isRegister) return '/home';

    return null;
  },
);
