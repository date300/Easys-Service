import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'features/home/home_screen.dart';
import 'features/reselling/reselling_screen.dart';
import 'features/microjobs/microjobs_screen.dart';
import 'features/campaigns/campaigns_screen.dart';
import 'features/profile/profile_screen.dart'; // Drive এর বদলে Profile
import 'features/auth/registration_screen.dart';

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

final GoRouter _router = GoRouter(
  initialLocation: '/home',
  routes: [
    GoRoute(
      path: '/registration',
      builder: (context, state) => const RegistrationScreen(),
    ),
    ShellRoute(
      builder: (context, state, child) => MainWrapper(child: child),
      routes: [
        GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
        GoRoute(path: '/reselling', builder: (context, state) => const ResellingScreen()),
        GoRoute(path: '/microjobs', builder: (context, state) => const MicrojobsScreen()),
        GoRoute(path: '/campaigns', builder: (context, state) => const CampaignsScreen()),
        GoRoute(path: '/profile', builder: (context, state) => const ProfileScreen()), // /drive -> /profile
      ],
    ),
  ],
  redirect: (context, state) async {
    final ref = ProviderScope.containerOf(context);
    await ref.read(authLoadingProvider.future);
    final isLoggedIn = ref.read(authProvider);
    final goingToRegister = state.matchedLocation == '/registration';
    if (!isLoggedIn && !goingToRegister) return '/registration';
    if (isLoggedIn && goingToRegister) return '/home';
    return null;
  },
);

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
          routerConfig: _router,
        );
      },
    );
  }
}

class MainWrapper extends ConsumerWidget {
  final Widget child;
  const MainWrapper({super.key, required this.child});

  static const Color skyBlue = Color(0xFF29B6F6);

  static bool _isDesktop(BuildContext ctx) =>
      MediaQuery.of(ctx).size.width >= 1100;
  static bool _isTablet(BuildContext ctx) =>
      MediaQuery.of(ctx).size.width >= 600 &&
      MediaQuery.of(ctx).size.width < 1100;

  int _indexFromLocation(String location) {
    if (location.startsWith('/home')) return 0;
    if (location.startsWith('/reselling')) return 1;
    if (location.startsWith('/microjobs')) return 2;
    if (location.startsWith('/campaigns')) return 3;
    if (location.startsWith('/profile')) return 4;
    return 0;
  }

  void _onNavTap(BuildContext context, int index) {
    switch (index) {
      case 0: context.go('/home'); break;
      case 1: context.go('/reselling'); break;
      case 2: context.go('/microjobs'); break;
      case 3: context.go('/campaigns'); break;
      case 4: context.go('/profile'); break;
    }
  }

  static const List<NavigationDestination> _bottomDests = [
    NavigationDestination(
        icon: Icon(Icons.home_outlined),
        selectedIcon: Icon(Icons.home),
        label: 'Home'),
    NavigationDestination(
        icon: Icon(Icons.storefront_outlined),
        selectedIcon: Icon(Icons.storefront),
        label: 'Reselling'),
    NavigationDestination(
        icon: Icon(Icons.assignment_outlined),
        selectedIcon: Icon(Icons.assignment),
        label: 'Microjobs'),
    NavigationDestination(
        icon: Icon(Icons.campaign_outlined),
        selectedIcon: Icon(Icons.campaign),
        label: 'Campaigns'),
    NavigationDestination(
        icon: Icon(Icons.person_outline_rounded),
        selectedIcon: Icon(Icons.person_rounded),
        label: 'Profile'), // Drive -> Profile
  ];

  static const List<NavigationRailDestination> _railDests = [
    NavigationRailDestination(
        icon: Icon(Icons.home_outlined),
        selectedIcon: Icon(Icons.home),
        label: Text('Home')),
    NavigationRailDestination(
        icon: Icon(Icons.storefront_outlined),
        selectedIcon: Icon(Icons.storefront),
        label: Text('Reselling')),
    NavigationRailDestination(
        icon: Icon(Icons.assignment_outlined),
        selectedIcon: Icon(Icons.assignment),
        label: Text('Microjobs')),
    NavigationRailDestination(
        icon: Icon(Icons.campaign_outlined),
        selectedIcon: Icon(Icons.campaign),
        label: Text('Campaigns')),
    NavigationRailDestination(
        icon: Icon(Icons.person_outline_rounded),
        selectedIcon: Icon(Icons.person_rounded),
        label: Text('Profile')), // Drive -> Profile
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).uri.toString();
    final currentIndex = _indexFromLocation(location);
    final isLoggedIn = ref.watch(authProvider);
    final isDesktop = _isDesktop(context);
    final isTablet = _isTablet(context);

    final animatedChild = child
        .animate(key: ValueKey(currentIndex))
        .fadeIn(duration: 400.ms)
        .moveY(begin: 10, end: 0);

    Widget bodyContainer({double radius = 32}) => Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(radius),
              topRight: Radius.circular(radius),
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(radius),
              topRight: Radius.circular(radius),
            ),
            child: animatedChild,
          ),
        );

    Widget drawer = _buildDrawer(context, ref, isLoggedIn);

    // ── Desktop & Tablet ─────────────────────────────────────────────
    if (isDesktop || isTablet) {
      return Scaffold(
        backgroundColor: skyBlue,
        drawer: drawer,
        body: SafeArea(
          child: Row(
            children: [
              NavigationRail(
                backgroundColor: skyBlue,
                selectedIndex: currentIndex,
                onDestinationSelected: (i) => _onNavTap(context, i),
                extended: isDesktop,
                labelType: isDesktop
                    ? NavigationRailLabelType.none
                    : NavigationRailLabelType.all,
                selectedIconTheme:
                    const IconThemeData(color: Colors.white, size: 26),
                unselectedIconTheme: IconThemeData(
                    color: Colors.white.withOpacity(0.55), size: 22),
                selectedLabelTextStyle: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: isDesktop ? 14 : 13),
                unselectedLabelTextStyle: GoogleFonts.poppins(
                    color: Colors.white.withOpacity(0.65),
                    fontSize: isDesktop ? 13 : 12),
                indicatorColor: Colors.white.withOpacity(0.18),
                leading: _railLeading(context, isDesktop),
                destinations: _railDests,
              ),
              Expanded(
                child: Column(
                  children: [
                    _topBar(context, isLoggedIn),
                    Expanded(child: bodyContainer(radius: 24)),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    // ── Mobile ───────────────────────────────────────────────────────
    return Scaffold(
      backgroundColor: skyBlue,
      drawer: drawer,
      appBar: AppBar(
        backgroundColor: skyBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Easy Service',
          style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold, fontSize: 20.sp),
        ),
        leading: Builder(
          builder: (ctx) => IconButton(
            icon: const Icon(Icons.menu_open_rounded, size: 28),
            onPressed: () => Scaffold.of(ctx).openDrawer(),
          ),
        ),
        actions: [
          IconButton(
              onPressed: () {},
              icon: const Icon(Icons.notifications_outlined))
        ],
      ),
      body: bodyContainer(radius: 32.r),
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          indicatorColor: skyBlue.withOpacity(0.15),
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return GoogleFonts.poppins(
                  color: skyBlue,
                  fontWeight: FontWeight.bold,
                  fontSize: 11.sp);
            }
            return GoogleFonts.poppins(color: Colors.grey, fontSize: 10.sp);
          }),
          iconTheme: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return IconThemeData(color: skyBlue, size: 26.sp);
            }
            return IconThemeData(color: Colors.grey, size: 22.sp);
          }),
        ),
        child: NavigationBar(
          backgroundColor: Colors.white,
          height: 65.h,
          selectedIndex: currentIndex,
          onDestinationSelected: (i) => _onNavTap(context, i),
          destinations: _bottomDests,
        ),
      ),
    );
  }

  Widget _railLeading(BuildContext context, bool isDesktop) {
    return Column(
      children: [
        const SizedBox(height: 16),
        Builder(
          builder: (ctx) => IconButton(
            icon: const Icon(Icons.menu_open_rounded,
                color: Colors.white, size: 28),
            onPressed: () => Scaffold.of(ctx).openDrawer(),
          ),
        ),
        if (isDesktop) ...[
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              'Easy Service',
              style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15),
            ),
          ),
        ],
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _topBar(BuildContext context, bool isLoggedIn) {
    return Container(
      color: skyBlue,
      height: 60,
      child: Row(
        children: [
          const SizedBox(width: 16),
          Expanded(
            child: Center(
              child: Text(
                'Easy Service',
                style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20),
              ),
            ),
          ),
          if (isLoggedIn)
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.notifications_outlined,
                  color: Colors.white),
            )
          else
            const SizedBox(width: 16),
        ],
      ),
    );
  }

  Widget _buildDrawer(
      BuildContext context, WidgetRef ref, bool isLoggedIn) {
    final isDesktop = _isDesktop(context);
    final isTablet = _isTablet(context);
    final double drawerWidth = isDesktop
        ? 300
        : isTablet
            ? 280
            : MediaQuery.of(context).size.width * 0.78;

    return SizedBox(
      width: drawerWidth,
      child: Drawer(
        backgroundColor: Colors.white,
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + 20,
                  bottom: 20,
                  left: 20,
                  right: 20),
              decoration: const BoxDecoration(
                color: skyBlue,
                borderRadius:
                    BorderRadius.only(bottomRight: Radius.circular(30)),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: const Icon(Icons.person_rounded,
                        color: skyBlue, size: 32),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isLoggedIn ? "Easy Service User" : "Guest User",
                          style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15),
                        ),
                        Text(
                          isLoggedIn
                              ? "user@easyservice.com"
                              : "Please login to continue",
                          style: GoogleFonts.poppins(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                physics: const BouncingScrollPhysics(),
                children: [
                  if (isLoggedIn) ...[
                    _drawerItem(context,
                        Icons.account_balance_wallet_rounded, "Wallet",
                        onTap: () => Navigator.pop(context)),
                    _drawerItem(context,
                        Icons.card_giftcard_rounded, "Voucher Balance",
                        onTap: () => Navigator.pop(context)),
                    _drawerItem(context,
                        Icons.workspace_premium_rounded, "Royalty Salary",
                        onTap: () => Navigator.pop(context)),
                    const Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                      child:
                          Divider(color: Color(0xFFEEEEEE), thickness: 1.5),
                    ),
                  ],
                  _drawerItem(context,
                      Icons.support_agent_rounded, "Support Center",
                      onTap: () => Navigator.pop(context)),
                  _drawerItem(
                      context, Icons.facebook_rounded, "Facebook Group",
                      iconColor: Colors.blue,
                      onTap: () => Navigator.pop(context)),
                  _drawerItem(
                      context, Icons.smart_display_rounded, "YouTube Channel",
                      iconColor: Colors.red,
                      onTap: () => Navigator.pop(context)),
                  _drawerItem(
                      context, Icons.telegram_rounded, "Telegram Group",
                      iconColor: Colors.blueAccent,
                      onTap: () => Navigator.pop(context)),
                ],
              ),
            ),
            if (isLoggedIn)
              Padding(
                padding: const EdgeInsets.fromLTRB(15, 10, 15, 25),
                child: ListTile(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  tileColor: Colors.red.withOpacity(0.1),
                  leading:
                      const Icon(Icons.logout_rounded, color: Colors.red),
                  title: Text("Logout",
                      style: GoogleFonts.poppins(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 14)),
                  onTap: () async {
                    Navigator.pop(context);
                    await ref.read(authProvider.notifier).logout();
                    if (context.mounted) context.go('/registration');
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _drawerItem(BuildContext context, IconData icon, String title,
      {Color? iconColor, required VoidCallback onTap}) {
    return ListTile(
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      leading: Icon(icon, color: iconColor ?? skyBlue, size: 24),
      title: Text(title,
          style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.black87)),
      trailing: Icon(Icons.arrow_forward_ios_rounded,
          size: 13, color: Colors.grey.shade400),
      onTap: onTap,
      splashColor: skyBlue.withOpacity(0.1),
    );
  }
}
