
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../screens/splash/splash_screen.dart';
import '../features/recharge/recharge_screen.dart';
import '../features/drive/drive_screen.dart';
import '../features/home/home_screen.dart';
import '../features/reselling/reselling_screen.dart';
import '../features/microjobs/microjobs_screen.dart';
import '../features/campaigns/campaigns_screen.dart';
import '../features/profile/profile_screen.dart';
import '../features/auth/registration_screen.dart';
import '../features/auth/login_screen.dart';
import '../features/payment/payment_gateway_screen.dart';
import '../modules/notifications/notification_screen.dart'; // ← নতুন ইমপোর্ট
import '../main.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/splash',

  routes: [
    // Splash
    GoRoute(
      path: '/splash',
      builder: (context, state) => const SplashScreen(),
    ),

    // Registration
    GoRoute(
      path: '/registration',
      builder: (context, state) => const RegistrationScreen(),
    ),

    // Login
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),

    // 🔥 NOTIFICATION — ShellRoute-এর বাইরে (Full Screen)
    GoRoute(
      path: '/notifications',
      builder: (context, state) => const NotificationScreen(),
    ),

    // ShellRoute — Bottom Nav + AppTopBar সহ
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

  // Redirect logic
  redirect: (context, state) async {
    final ref = ProviderScope.containerOf(context);
    await ref.read(authLoadingProvider.future);
    final isLoggedIn = ref.read(authProvider);

    final loc = state.matchedLocation;
    final isSplash = loc == '/splash';
    final isRegister = loc == '/registration';
    final isLogin = loc == '/login';
    final isNotification = loc == '/notifications'; // ← নতুন চেক

    // Splash এ থাকলে redirect নেই
    if (isSplash) return null;

    // 🔥 NOTIFICATION: Login না থাকলে login এ পাঠাও
    if (!isLoggedIn && isNotification) return '/login';

    // Login নেই + auth page এও নেই → login এ পাঠাও
    if (!isLoggedIn && !isRegister && !isLogin && !isNotification) return '/login';

    // Login আছে + auth page এ যাওয়ার চেষ্টা → home এ পাঠাও
    if (isLoggedIn && (isLogin || isRegister)) return '/home';

    return null;
  },
);
