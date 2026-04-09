import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'router/app_router.dart';
import 'widgets/app_bottom_nav_bar.dart';
import 'widgets/app_nav_rail.dart';
import 'widgets/app_top_bar.dart';
import 'widgets/app_drawer.dart';

// ============================================
// PROVIDERS
// ============================================

final authProvider = StateNotifierProvider<AuthController, bool>((ref) {
  return AuthController();
});

class AuthController extends StateNotifier<bool> {
  AuthController() : super(false);

  Future<void> loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');
    state = token != null && token.isNotEmpty;
  }

  Future<void> loginWithToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('jwt_token', token);
    state = true;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
    state = false;
  }
}

final authLoadingProvider = FutureProvider<void>((ref) async {
  await ref.read(authProvider.notifier).loadFromPrefs();
});

final isDetailViewProvider = StateProvider<bool>((ref) => false);
final detailViewTitleProvider = StateProvider<String>((ref) => '');

// ============================================
// MAIN
// ============================================

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ScreenUtilInit(
      designSize: const Size(360, 800),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp.router(
          debugShowCheckedModeBanner: false,
          title: 'Easy Service',
          theme: ThemeData(
            useMaterial3: true,
            colorSchemeSeed: const Color(0xFF29B6F6),
            textTheme: GoogleFonts.poppinsTextTheme(),
          ),
          routerConfig: appRouter,
        );
      },
    );
  }
}

// ============================================
// MAIN WRAPPER
// ============================================

class MainWrapper extends ConsumerWidget {
  final Widget child;
  const MainWrapper({super.key, required this.child});

  static bool _isDesktop(BuildContext ctx) =>
      MediaQuery.of(ctx).size.width >= 1100;
  static bool _isTablet(BuildContext ctx) =>
      MediaQuery.of(ctx).size.width >= 600 &&
      MediaQuery.of(ctx).size.width < 1100;
  static bool _isMobile(BuildContext ctx) =>
      MediaQuery.of(ctx).size.width < 600;

  int _indexFromLocation(String location) {
    if (location.startsWith('/home')) return 0;
    if (location.startsWith('/reselling')) return 1;
    if (location.startsWith('/microjobs')) return 2;
    if (location.startsWith('/campaigns')) return 3;
    if (location.startsWith('/profile')) return 4;
    return 0;
  }

  void _onNavTap(BuildContext context, WidgetRef ref, int index) {
    ref.read(isDetailViewProvider.notifier).state = false;
    ref.read(detailViewTitleProvider.notifier).state = '';

    switch (index) {
      case 0:
        context.go('/home');
        break;
      case 1:
        context.go('/reselling');
        break;
      case 2:
        context.go('/microjobs');
        break;
      case 3:
        context.go('/campaigns');
        break;
      case 4:
        context.go('/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = GoRouter.of(context).location; // ✅ Web-ready
    final currentIndex = _indexFromLocation(location);
    final isLoggedIn = ref.watch(authProvider);
    final isDesktop = _isDesktop(context);
    final isTablet = _isTablet(context);
    final isMobile = _isMobile(context);

    final isEditProfile = location.contains('edit_profile');
    final isPaymentPage = location == '/payment';
    final isDetailView = isPaymentPage || ref.watch(isDetailViewProvider);
    final detailTitle =
        isPaymentPage ? 'Payment' : ref.watch(detailViewTitleProvider);

    final animatedChild = child
        .animate(key: ValueKey(location))
        .fadeIn(duration: 400.ms)
        .moveY(begin: 10, end: 0);

    Widget bodyContainer() {
      if (isDetailView || isEditProfile) {
        return Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.white,
          child: animatedChild,
        );
      }
      return Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(isMobile ? 32.r : 24),
            topRight: Radius.circular(isMobile ? 32.r : 24),
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(isMobile ? 32.r : 24),
            topRight: Radius.circular(isMobile ? 32.r : 24),
          ),
          child: animatedChild,
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF29B6F6),
      drawer: (isDetailView || isEditProfile)
          ? null
          : AppDrawer(
              isLoggedIn: isLoggedIn,
              isDesktop: isDesktop,
              isTablet: isTablet,
            ),
      body: SafeArea(
        top: !isEditProfile,
        child: Row(
          children: [
            if ((isDesktop || isTablet) && !isDetailView && !isEditProfile)
              AppNavRail(
                currentIndex: currentIndex,
                isDesktop: isDesktop,
                onTap: (i) => _onNavTap(context, ref, i),
              ),
            Expanded(
              child: Column(
                children: [
                  if (!isEditProfile)
                    AppTopBar(
                      isDetailView: isDetailView,
                      detailTitle: detailTitle,
                      isMobile: isMobile,
                      isLoggedIn: isLoggedIn,
                    ),
                  Expanded(child: bodyContainer()),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: (isMobile && (!isDetailView || isEditProfile))
          ? AppBottomNavBar(
              currentIndex: currentIndex,
              onTap: (i) => _onNavTap(context, ref, i),
            )
          : null,
    );
  }
}
