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
import '../modules/notifications/notification_screen.dart';
import '../main.dart';

// ==================== HELPERS ====================

/// রুট থেকে বের হওয়ার সময় Provider রিসেট করে দেয়
Future<bool> _resetDetailProviders(BuildContext context) async {
  final container = ProviderScope.containerOf(context);
  container.read(isDetailViewProvider.notifier).state = false;
  container.read(detailViewTitleProvider.notifier).state = '';
  return true; // true দিলে pop allow হবে
}

/// Detail Route বানানোর হেল্পার — onExit auto-থাকবে
GoRoute _detailRoute({
  required String path,
  required Widget Function(BuildContext, GoRouterState) builder,
}) {
  return GoRoute(
    path: path,
    onExit: _resetDetailProviders, // ⭐ এটাই মূল কাজ
    builder: builder,
  );
}

// ==================== ROUTER ====================

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

    // Notification (Full Screen)
    GoRoute(
      path: '/notifications',
      builder: (context, state) => const NotificationScreen(),
    ),

    // ShellRoute — Bottom Nav + AppTopBar
    ShellRoute(
      builder: (context, state, child) => MainWrapper(child: child),
      routes: [
        // Home (এটা detail না, তাই সরাসরি GoRoute)
        GoRoute(
          path: '/home',
          builder: (context, state) => const HomeScreen(),
        ),

        // ⭐ Detail Routes — _detailRoute() দিয়ে বানানো
        _detailRoute(
          path: '/drive',
          builder: (context, state) => const DriveScreen(),
        ),
        _detailRoute(
          path: '/reselling',
          builder: (context, state) => const ResellingScreen(),
        ),
        _detailRoute(
          path: '/microjobs',
          builder: (context, state) => const MicrojobsScreen(),
        ),
        _detailRoute(
          path: '/campaigns',
          builder: (context, state) => const CampaignsScreen(),
        ),
        _detailRoute(
          path: '/recharge',
          builder: (context, state) => const RechargeScreen(),
        ),

        // Profile — যদি এটাও detail হয় তাহলে _detailRoute() করুন
        GoRoute(
          path: '/profile',
          builder: (context, state) => const ProfileScreen(),
        ),

        // Payment
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

  // Redirect logic (আগের মতোই)
  redirect: (context, state) async {
    final ref = ProviderScope.containerOf(context);
    await ref.read(authLoadingProvider.future);
    final isLoggedIn = ref.read(authProvider);

    final loc = state.matchedLocation;
    final isSplash = loc == '/splash';
    final isRegister = loc == '/registration';
    final isLogin = loc == '/login';
    final isNotification = loc == '/notifications';

    if (isSplash) return null;
    if (!isLoggedIn && isNotification) return '/login';
    if (!isLoggedIn && !isRegister && !isLogin && !isNotification) return '/login';
    if (isLoggedIn && (isLogin || isRegister)) return '/home';

    return null;
  },
);
