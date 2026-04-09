import 'dart:ui'; // ব্লার ইফেক্টের জন্য
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lottie/lottie.dart'; // লটি প্যাকেজ

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

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
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
// MAIN WRAPPER (এখানেই মূল পরিবর্তন করা হয়েছে)
// ============================================

class MainWrapper extends ConsumerWidget {
  final Widget child;
  const MainWrapper({super.key, required this.child});

  static bool _isDesktop(BuildContext ctx) => MediaQuery.of(ctx).size.width >= 1100;
  static bool _isTablet(BuildContext ctx) => MediaQuery.of(ctx).size.width >= 600 && MediaQuery.of(ctx).size.width < 1100;
  static bool _isMobile(BuildContext ctx) => MediaQuery.of(ctx).size.width < 600;

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
      case 0: context.go('/home'); break;
      case 1: context.go('/reselling'); break;
      case 2: context.go('/microjobs'); break;
      case 3: context.go('/campaigns'); break;
      case 4: context.go('/profile'); break;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).uri.toString();
    final currentIndex = _indexFromLocation(location);
    final isLoggedIn = ref.watch(authProvider);
    final isMobile = _isMobile(context);
    final isDetailView = ref.watch(isDetailViewProvider);
    final detailTitle = ref.watch(detailViewTitleProvider);

    return Scaffold(
      // ব্যাকগ্রাউন্ড সলিড কালারের বদলে স্ট্যাক ব্যবহার করে লটি যোগ করা হয়েছে
      body: Stack(
        children: [
          // ১. গ্লোবাল লটি অ্যানিমেশন (পুরো ব্যাকগ্রাউন্ড জুড়ে)
          Positioned.fill(
            child: Lottie.network(
              'https://lottie.host/81b37365-2244-4861-9c86-13d6a455a5b1/F0mJ3Z9oYv.json',
              fit: BoxFit.cover,
            ),
          ),
          
          // ২. আকাশী গ্লাস লেয়ার (ঝাপসা ইফেক্ট)
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: Container(
                color: const Color(0xFF29B6F6).withOpacity(0.4),
              ),
            ),
          ),

          // ৩. মেইন ইউআই (TopBar + Body)
          SafeArea(
            child: Row(
              children: [
                if ((_isDesktop(context) || _isTablet(context)) && !isDetailView)
                  AppNavRail(
                    currentIndex: currentIndex,
                    isDesktop: _isDesktop(context),
                    onTap: (i) => _onNavTap(context, ref, i),
                  ),
                Expanded(
                  child: Column(
                    children: [
                      // এখানে AppTopBar কল হচ্ছে (যা এখন স্বচ্ছ লাগবে)
                      AppTopBar(
                        isDetailView: isDetailView,
                        detailTitle: detailTitle,
                        isMobile: isMobile,
                        isLoggedIn: isLoggedIn,
                      ),
                      // বডি কন্টেইনার
                      Expanded(
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(isMobile && !isDetailView ? 32.r : 0),
                              topRight: Radius.circular(isMobile && !isDetailView ? 32.r : 0),
                            ),
                          ),
                          child: child
                              .animate(key: ValueKey(location))
                              .fadeIn(duration: 400.ms)
                              .moveY(begin: 10, end: 0),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      drawer: isDetailView
          ? null
          : AppDrawer(
              isLoggedIn: isLoggedIn,
              isDesktop: _isDesktop(context),
              isTablet: _isTablet(context),
            ),
      bottomNavigationBar: (isMobile && !isDetailView)
          ? AppBottomNavBar(
              currentIndex: currentIndex,
              onTap: (i) => _onNavTap(context, ref, i),
            )
          : null,
    );
  }
}
