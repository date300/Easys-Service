import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../features/home/home_screen.dart';
import '../features/reselling/reselling_screen.dart';
import '../features/microjobs/microjobs_screen.dart';
import '../features/campaigns/campaigns_screen.dart';
import '../features/profile/profile_screen.dart'; // Drive → Profile
import 'registration_screen.dart';

final navIndexProvider = StateProvider<int>((ref) => 0);
final authProvider = StateProvider<bool>((ref) => false);
final authLoadingProvider = StateProvider<bool>((ref) => true);

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

final GoRouter _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const MainWrapper(),
    ),
  ],
);

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
            textTheme: GoogleFonts.poppinsTextTheme(),
          ),
          routerConfig: _router,
        );
      },
    );
  }
}

class MainWrapper extends ConsumerStatefulWidget {
  const MainWrapper({super.key});

  @override
  ConsumerState<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends ConsumerState<MainWrapper> {
  static const Color skyBlue = Color(0xFF29B6F6);

  // ── Breakpoints ──────────────────────────────────────────────
  static bool _isDesktop(BuildContext ctx) =>
      MediaQuery.of(ctx).size.width >= 1100;
  static bool _isTablet(BuildContext ctx) =>
      MediaQuery.of(ctx).size.width >= 600 &&
      MediaQuery.of(ctx).size.width < 1100;

  // ── Navigation Destinations ───────────────────────────────────
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
        label: 'Profile'), // Drive → Profile
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
        label: Text('Profile')), // Drive → Profile
  ];

  // ─────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');
    if (token != null && token.isNotEmpty) {
      ref.read(authProvider.notifier).state = true;
    }
    ref.read(authLoadingProvider.notifier).state = false;
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = ref.watch(navIndexProvider);
    final isLoggedIn = ref.watch(authProvider);
    final isLoading = ref.watch(authLoadingProvider);

    final List<Widget> pages = [
      const HomeScreen(),
      const ResellingScreen(),
      const MicrojobsScreen(),
      const CampaignsScreen(),
      const ProfileScreen(), // Drive → Profile
    ];

    if (isLoading) {
      return const Scaffold(
        backgroundColor: skyBlue,
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    final bool isDesktop = _isDesktop(context);
    final bool isTablet = _isTablet(context);

    // Shared animated content
    final Widget pageContent = isLoggedIn
        ? pages[currentIndex]
            .animate(key: ValueKey(currentIndex))
            .fadeIn(duration: 400.ms)
            .moveY(begin: 10, end: 0)
        : const RegistrationScreen().animate().fadeIn(duration: 400.ms);

    // White rounded container
    Widget bodyContainer({bool roundLeft = true, bool roundRight = true}) =>
        Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: roundLeft ? const Radius.circular(32) : Radius.zero,
              topRight: roundRight ? const Radius.circular(32) : Radius.zero,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: roundLeft ? const Radius.circular(32) : Radius.zero,
              topRight: roundRight ? const Radius.circular(32) : Radius.zero,
            ),
            child: pageContent,
          ),
        );

    // ── Desktop & Tablet layout ───────────────────────────────
    if (isDesktop || isTablet) {
      return Scaffold(
        backgroundColor: skyBlue,
        drawer: _buildDrawer(isLoggedIn),
        body: Row(
          children: [
            // Side NavigationRail (only when logged in)
            if (isLoggedIn)
              NavigationRail(
                backgroundColor: skyBlue,
                selectedIndex: currentIndex,
                onDestinationSelected: (i) =>
                    ref.read(navIndexProvider.notifier).state = i,
                extended: isDesktop, // full-width labels on desktop
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
                    fontSize: 13),
                unselectedLabelTextStyle: GoogleFonts.poppins(
                    color: Colors.white.withOpacity(0.65), fontSize: 12),
                indicatorColor: Colors.white.withOpacity(0.18),
                leading: _railLeading(isDesktop),
                destinations: _railDests,
              ),

            // Main area
            Expanded(
              child: Column(
                children: [
                  // Top bar
                  _topBar(context, isLoggedIn, showMenuBtn: !isLoggedIn),
                  // Content
                  Expanded(child: bodyContainer()),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // ── Mobile layout ────────────────────────────────────────
    return Scaffold(
      backgroundColor: skyBlue,
      drawer: _buildDrawer(isLoggedIn),
      appBar: AppBar(
        backgroundColor: skyBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          isLoggedIn ? 'Easy Service' : 'Create Account',
          style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold, fontSize: 20.sp),
        ),
        leading: Builder(
          builder: (ctx) => IconButton(
            icon: const Icon(Icons.menu_open_rounded, size: 28),
            onPressed: () => Scaffold.of(ctx).openDrawer(),
          ),
        ),
        actions: isLoggedIn
            ? [
                IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.notifications_outlined))
              ]
            : [],
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(32.r),
            topRight: Radius.circular(32.r),
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(32.r),
            topRight: Radius.circular(32.r),
          ),
          child: pageContent,
        ),
      ),
      bottomNavigationBar: isLoggedIn
          ? NavigationBarTheme(
              data: NavigationBarThemeData(
                indicatorColor: skyBlue.withOpacity(0.15),
                labelTextStyle:
                    WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) {
                    return GoogleFonts.poppins(
                        color: skyBlue,
                        fontWeight: FontWeight.bold,
                        fontSize: 11.sp);
                  }
                  return GoogleFonts.poppins(
                      color: Colors.grey, fontSize: 10.sp);
                }),
                iconTheme:
                    WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) {
                    return IconThemeData(color: skyBlue, size: 26.sp);
                  }
                  return IconThemeData(color: Colors.grey, size: 22.sp);
                }),
              ),
              child: NavigationBar(
                backgroundColor: Colors.white,
                height: 70.h,
                selectedIndex: currentIndex,
                onDestinationSelected: (i) =>
                    ref.read(navIndexProvider.notifier).state = i,
                destinations: _bottomDests,
              ),
            )
          : const SizedBox.shrink(),
    );
  }

  // ── Rail leading (menu + optional title) ─────────────────────
  Widget _railLeading(bool isDesktop) {
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

  // ── Shared top bar for tablet/desktop ─────────────────────────
  Widget _topBar(BuildContext context, bool isLoggedIn,
      {required bool showMenuBtn}) {
    return Container(
      color: skyBlue,
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: 60,
          child: Row(
            children: [
              if (showMenuBtn)
                Builder(
                  builder: (ctx) => IconButton(
                    icon: const Icon(Icons.menu_open_rounded,
                        color: Colors.white, size: 28),
                    onPressed: () => Scaffold.of(ctx).openDrawer(),
                  ),
                )
              else
                const SizedBox(width: 16),
              Expanded(
                child: Center(
                  child: Text(
                    isLoggedIn ? 'Easy Service' : 'Create Account',
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
        ),
      ),
    );
  }

  // ── Drawer ────────────────────────────────────────────────────
  Widget _buildDrawer(bool isLoggedIn) {
    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.only(
                top: 60.h, bottom: 20.h, left: 20.w, right: 20.w),
            decoration: BoxDecoration(
              color: skyBlue,
              borderRadius:
                  BorderRadius.only(bottomRight: Radius.circular(30.r)),
              boxShadow: [
                BoxShadow(
                    color: skyBlue.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 5))
              ],
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30.r,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person_rounded,
                      color: skyBlue, size: 35.sp),
                ),
                SizedBox(width: 15.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isLoggedIn ? "Easy Service User" : "Guest User",
                        style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16.sp),
                      ),
                      Text(
                        isLoggedIn
                            ? "user@easyservice.com"
                            : "Please login to continue",
                        style: GoogleFonts.poppins(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 12.sp),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 10.h),
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: 10.w),
              physics: const BouncingScrollPhysics(),
              children: [
                if (isLoggedIn) ...[
                  _buildDrawerItem(
                      Icons.account_balance_wallet_rounded, "Wallet",
                      onTap: () => Navigator.pop(context)),
                  _buildDrawerItem(
                      Icons.card_giftcard_rounded, "Voucher Balance",
                      onTap: () => Navigator.pop(context)),
                  _buildDrawerItem(
                      Icons.workspace_premium_rounded, "Royalty Salary",
                      onTap: () => Navigator.pop(context)),
                  Padding(
                    padding: EdgeInsets.symmetric(
                        vertical: 10.h, horizontal: 15.w),
                    child: Divider(
                        color: Colors.grey.shade200, thickness: 1.5),
                  ),
                ],
                _buildDrawerItem(
                    Icons.support_agent_rounded, "Support Center",
                    onTap: () => Navigator.pop(context)),
                _buildDrawerItem(
                    Icons.facebook_rounded, "Facebook Group",
                    iconColor: Colors.blue,
                    onTap: () => Navigator.pop(context)),
                _buildDrawerItem(
                    Icons.smart_display_rounded, "YouTube Channel",
                    iconColor: Colors.red,
                    onTap: () => Navigator.pop(context)),
                _buildDrawerItem(
                    Icons.telegram_rounded, "Telegram Group",
                    iconColor: Colors.blueAccent,
                    onTap: () => Navigator.pop(context)),
              ],
            ),
          ),
          if (isLoggedIn)
            Padding(
              padding: EdgeInsets.only(
                  left: 15.w, right: 15.w, bottom: 25.h, top: 10.h),
              child: ListTile(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.r)),
                tileColor: Colors.red.withOpacity(0.1),
                leading:
                    const Icon(Icons.logout_rounded, color: Colors.red),
                title: Text("Logout",
                    style: GoogleFonts.poppins(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 15.sp)),
                onTap: () async {
                  Navigator.pop(context);
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.remove('jwt_token');
                  ref.read(authProvider.notifier).state = false;
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title,
      {Color? iconColor, required VoidCallback onTap}) {
    return ListTile(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r)),
      leading:
          Icon(icon, color: iconColor ?? skyBlue, size: 24.sp),
      title: Text(title,
          style: GoogleFonts.poppins(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: Colors.black87)),
      trailing: Icon(Icons.arrow_forward_ios_rounded,
          size: 14.sp, color: Colors.grey.shade400),
      onTap: onTap,
      splashColor: skyBlue.withOpacity(0.1),
    );
  }
}
