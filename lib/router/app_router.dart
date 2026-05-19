import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../features/vendor_apply/vendor_apply_page.dart';
import '../features/royalty_salary/royalty_salary_page.dart';
import '../screens/splash/splash_screen.dart';
import '../features/recharge/recharge_screen.dart';
import '../features/drive/drive_screen.dart';
import '../features/home/home_screen.dart';
import '../features/reselling/reselling_screen.dart';
import '../features/microjobs/microjobs_screen.dart';
import '../features/campaigns/campaigns_screen.dart';
import '../features/profile/profile_screen.dart';
import '../features/profile/edit_profile/edit_profile_screen.dart';
import '../features/auth/registration_screen.dart';
import '../features/auth/login_screen.dart';
import '../features/payment/payment_gateway_screen.dart';
import '../modules/notifications/notification_screen.dart';
import '../main.dart';
import '../features/voucher_balance/voucher_balance_page.dart';
import '../features/reselling/product_details_page.dart';
import '../features/referral/referral_page.dart';
import '../features/matrix/matrix_income.dart';
import '../features/wallet/wallet_page.dart';
import '../features/wallet/pages/transaction_list_page.dart';
import '../features/wallet/pages/daily_income_page.dart';
import '../features/wallet/pages/weekly_income_page.dart';
import '../features/wallet/pages/monthly_income_page.dart';
import '../features/leaderboard/leaderboard_page.dart';   // ← নতুন import
import '../features/withdraw/withdraw_page.dart';
// ==================== HELPERS ====================

Future<bool> _resetDetailProviders(BuildContext context, GoRouterState state) async {
  final container = ProviderScope.containerOf(context);
  Future.delayed(const Duration(milliseconds: 400), () {
    container.read(isDetailViewProvider.notifier).state = false;
    container.read(detailViewTitleProvider.notifier).state = '';
  });
  return true;
}

GoRoute _detailRoute({
  required String path,
  required Widget Function(BuildContext, GoRouterState) builder,
}) {
  return GoRoute(
    path: path,
    onExit: _resetDetailProviders,
    builder: builder,
  );
}

// ==================== ROUTER ====================

final GoRouter appRouter = GoRouter(
  initialLocation: '/splash',

  routes: [
    GoRoute(
      path: '/splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/registration',
      builder: (context, state) => const RegistrationScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/notifications',
      builder: (context, state) => const NotificationScreen(),
    ),

    ShellRoute(
      builder: (context, state, child) => MainWrapper(child: child),
      routes: [
        GoRoute(
          path: '/home',
          builder: (context, state) => const HomeScreen(),
        ),
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
        _detailRoute(
          path: '/edit-profile',
          builder: (context, state) => const EditProfileScreen(),
        ),
        _detailRoute(
  path: '/withdraw',
  builder: (context, state) => const WithdrawLedgerPage(),
),
        _detailRoute(
          path: '/vendor-apply',
          builder: (context, state) => const VendorApplyPage(),
        ),
        _detailRoute(
          path: '/royalty-salary',
          builder: (context, state) => const RoyaltySalaryPage(),
        ),
        _detailRoute(
          path: '/wallet',
          builder: (context, state) => const WalletPage(),
        ),
        _detailRoute(
          path: '/transactions',
          builder: (context, state) => const TransactionListPage(),
        ),
        _detailRoute(
          path: '/daily-income',
          builder: (context, state) => const DailyIncomePage(),
        ),
        _detailRoute(
          path: '/weekly-income',
          builder: (context, state) => const WeeklyIncomePage(),
        ),
        _detailRoute(
          path: '/monthly-income',
          builder: (context, state) => const MonthlyIncomePage(),
        ),
        _detailRoute(
          path: '/leaderboard',                                    // ← নতুন route
          builder: (context, state) => const LeaderboardPage(),
        ),
        GoRoute(
          path: '/profile',
          builder: (context, state) => const ProfileScreen(),
        ),
        _detailRoute(
          path: '/voucher-balance',
          builder: (context, state) => const VoucherBalancePage(),
        ),
        _detailRoute(
          path: '/referral',
          builder: (context, state) => const ReferralPage(),
        ),
        _detailRoute(
          path: '/matrix-income',
          builder: (context, state) => const MatrixIncomePage(),
        ),
        _detailRoute(
          path: '/product/:id',
          builder: (context, state) => ProductDetailsPage(
            productId: state.pathParameters['id']!,
          ),
        ),
        // FIXED: Payment route with proper extra handling
        GoRoute(
          path: '/payment',
          builder: (context, state) {
            final extra = state.extra as Map<String, dynamic>?;
            return PaymentGatewayScreen(
              amount: extra?['amount'] ?? 300.00,
              purpose: extra?['purpose'] ?? 'Account Verification Fee',
              onPaymentSuccess: extra?['onSuccess'],
              onPaymentFailed: extra?['onFailed'],
            );
          },
        ),
      ],
    ),
  ],

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
