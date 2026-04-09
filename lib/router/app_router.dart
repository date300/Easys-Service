// app_router.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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
  initialLocation: '/home',
  routes: [
    // Registration — আলাদা Page, কোনো MainWrapper নেই
    GoRoute(
      path: '/registration',
      builder: (context, state) => const RegistrationScreen(),
    ),

    // ShellRoute — Home, Drive, Reselling, Microjobs, Campaigns, Profile, Payment
    ShellRoute(
      builder: (context, state, child) => MainWrapper(
        child: child,
        // default: isDetailView=false, except Payment
      ),
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

        // Payment — MainWrapper with isDetailView=true
        GoRoute(
          path: '/payment',
          builder: (context, state) {
            final extra = state.extra as Map<String, dynamic>?;
            return MainWrapper(
              isDetailView: true, // hide bottom nav + appbar customization
              child: PaymentGatewayScreen(
                amount: extra?['amount'] ?? 199.00,
                purpose: extra?['purpose'] ?? 'Account Verification Fee',
                onPaymentSuccess: extra?['onSuccess'],
              ),
            );
          },
        ),
      ],
    ),
  ],

  // Redirect logic: login check
  redirect: (context, state) async {
    final ref = ProviderScope.containerOf(context);
    await ref.read(authLoadingProvider.future);
    final isLoggedIn = ref.read(authProvider);
    final loc = state.matchedLocation;
    final goingToRegister = loc == '/registration';

    if (!isLoggedIn && !goingToRegister) return '/registration';
    if (isLoggedIn && goingToRegister) return '/home';
    return null;
  },
);
