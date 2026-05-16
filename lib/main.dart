import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart'; // ✅ নতুন

import 'firebase_options.dart';
import 'core/services/push_notification_service.dart';
import 'router/app_router.dart';
import 'widgets/app_bottom_nav_bar.dart';
import 'widgets/app_nav_rail.dart';
import 'widgets/app_top_bar.dart';
import 'widgets/app_drawer.dart';

// ============================================
// THEME PROVIDERS
// ============================================

final themeModeProvider =
    StateNotifierProvider<ThemeModeController, ThemeMode>((ref) {
  return ThemeModeController();
});

class ThemeModeController extends StateNotifier<ThemeMode> {
  ThemeModeController() : super(ThemeMode.system) {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final savedTheme = prefs.getString('app_theme');
    if (savedTheme != null) {
      state = _stringToThemeMode(savedTheme);
    }
  }

  Future<void> setTheme(ThemeMode mode) async {
    if (state == mode) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_theme', _themeModeToString(mode));
    state = mode;
  }

  String _themeModeToString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      default:
        return 'system';
    }
  }

  ThemeMode _stringToThemeMode(String value) {
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }
}

// ============================================
// AUTH PROVIDERS
// ============================================

final authProvider =
    StateNotifierProvider<AuthController, bool>((ref) {
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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // ✅ Initialize AdMob
  await MobileAds.instance.initialize();

  // Initialize Push Notification Service
  await PushNotificationService.instance.initialize();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
    ),
  );

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return ScreenUtilInit(
      designSize: const Size(360, 800),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp.router(
          debugShowCheckedModeBanner: false,
          title: 'Easy Service',
          theme: _buildLightTheme(),
          darkTheme: _buildDarkTheme(),
          themeMode: themeMode,
          routerConfig: appRouter,
        );
      },
    );
  }

  ThemeData _buildLightTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorSchemeSeed: const Color(0xFF29B6F6),
      scaffoldBackgroundColor: const Color(0xFF29B6F6),
      textTheme: GoogleFonts.poppinsTextTheme(ThemeData.light().textTheme),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF29B6F6),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: Color(0xFF29B6F6),
        unselectedItemColor: Colors.grey,
      ),
    );
  }

  ThemeData _buildDarkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorSchemeSeed: const Color(0xFF29B6F6),
      scaffoldBackgroundColor: const Color(0xFF1E1E1E),
      textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1E1E1E),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        color: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFF1E1E1E),
        selectedItemColor: Color(0xFF29B6F6),
        unselectedItemColor: Colors.grey,
      ),
    );
  }
}

// ============================================
// MAIN WRAPPER
// ============================================

class MainWrapper extends ConsumerStatefulWidget {
  final Widget child;
  const MainWrapper({super.key, required this.child});

  static bool _isDesktop(BuildContext ctx) =>
      MediaQuery.of(ctx).size.width >= 1100;
  static bool _isTablet(BuildContext ctx) =>
      MediaQuery.of(ctx).size.width >= 600 &&
      MediaQuery.of(ctx).size.width < 1100;
  static bool _isMobile(BuildContext ctx) =>
      MediaQuery.of(ctx).size.width < 600;

  @override
  ConsumerState<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends ConsumerState<MainWrapper> {
  StreamSubscription<NotificationEvent>? _pushTapSub;

  int _indexFromLocation(String location) {
    if (location.startsWith('/home')) return 0;
    if (location.startsWith('/reselling')) return 1;
    if (location.startsWith('/microjobs')) return 2;
    if (location.startsWith('/profile')) return 3;
    return 0;
  }

  void _onNavTap(BuildContext context, WidgetRef ref, int index) {
    ref.read(isDetailViewProvider.notifier).state = false;
    ref.read(detailViewTitleProvider.notifier).state = '';

    switch (index) {
      case 0: context.go('/home'); break;
      case 1: context.go('/reselling'); break;
      case 2: context.go('/microjobs'); break;
      case 3: context.go('/profile'); break;
    }
  }

  @override
  void initState() {
    super.initState();

    _pushTapSub = PushNotificationService.instance.onTap.listen((event) {
      if (mounted) {
        context.push('/notifications');
      }
    });
  }

  @override
  void dispose() {
    _pushTapSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    final currentIndex = _indexFromLocation(location);
    final isLoggedIn = ref.watch(authProvider);
    final isDesktop = MainWrapper._isDesktop(context);
    final isTablet = MainWrapper._isTablet(context);
    final isMobile = MainWrapper._isMobile(context);

    final isEditProfile = location.contains('edit_profile');
    final isPaymentPage = location == '/payment';

    final isDetailView = isPaymentPage || ref.watch(isDetailViewProvider);
    final detailTitle =
        isPaymentPage ? 'Payment' : ref.watch(detailViewTitleProvider);

    final animatedChild = widget.child
        .animate(key: ValueKey(location))
        .fadeIn(duration: 400.ms)
        .moveY(begin: 10, end: 0);

    final isDark = Theme.of(context).brightness == Brightness.dark;

    Widget bodyContainer() {
      double bodyRadius = isMobile ? 32.r : 24;
      return Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF121212) : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(bodyRadius),
            topRight: Radius.circular(bodyRadius),
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(bodyRadius),
            topRight: Radius.circular(bodyRadius),
          ),
          child: animatedChild,
        ),
      );
    }

    return PopScope(
      canPop: !isDetailView,
      onPopInvokedWithResult: (didPop, result) {},
      child: Scaffold(
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
        drawer: (isDetailView || isEditProfile)
            ? null
            : AppDrawer(
                isLoggedIn: isLoggedIn,
                isDesktop: isDesktop,
                isTablet: isTablet,
              ),
        bottomNavigationBar:
            (isMobile && (!isDetailView || isEditProfile))
                ? AppBottomNavBar(
                    currentIndex: currentIndex,
                    onTap: (i) => _onNavTap(context, ref, i),
                  )
                : null,
      ),
    );
  }
}
