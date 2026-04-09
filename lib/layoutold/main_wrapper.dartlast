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
import '../features/profile/profile_screen.dart';
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
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF29B6F6),
              brightness: Brightness.light,
            ),
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

  // Breakpoints
  static bool _isDesktop(BuildContext ctx) =>
      MediaQuery.of(ctx).size.width >= 1100;
  static bool _isTablet(BuildContext ctx) =>
      MediaQuery.of(ctx).size.width >= 600 &&
      MediaQuery.of(ctx).size.width < 1100;
  static bool _isMobile(BuildContext ctx) =>
      MediaQuery.of(ctx).size.width < 600;

  // Responsive font size
  static double _fs(BuildContext ctx, double mobile, double tablet, double desktop) {
    if (_isDesktop(ctx)) return desktop;
    if (_isTablet(ctx)) return tablet;
    return mobile;
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
        label: 'Profile'),
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
        label: Text('Profile')),
  ];

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
      const ProfileScreen(),
    ];

    if (isLoading) {
      return const Scaffold(
        backgroundColor: skyBlue,
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    final bool isDesktop = _isDesktop(context);
    final bool isTablet = _isTablet(context);
    final bool isMobile = _isMobile(context);

    final Widget pageContent = isLoggedIn
        ? pages[currentIndex]
            .animate(key: ValueKey(currentIndex))
            .fadeIn(duration: 400.ms)
            .moveY(begin: 10, end: 0)
        : const RegistrationScreen().animate().fadeIn(duration: 400.ms);

    Widget bodyContainer() => Container(
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
            child: pageContent,
          ),
        );

    // ── Desktop & Tablet ──────────────────────────────────────────────
    if (isDesktop || isTablet) {
      return Scaffold(
        backgroundColor: skyBlue,
        drawer: _buildDrawer(context, isLoggedIn),
        body: SafeArea(
          child: Row(
            children: [
              if (isLoggedIn)
                NavigationRail(
                  backgroundColor: skyBlue,
                  selectedIndex: currentIndex,
                  onDestinationSelected: (i) =>
                      ref.read(navIndexProvider.notifier).state = i,
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
                      fontSize: _fs(context, 13, 13, 14)),
                  unselectedLabelTextStyle: GoogleFonts.poppins(
                      color: Colors.white.withOpacity(0.65),
                      fontSize: _fs(context, 12, 12, 13)),
                  indicatorColor: Colors.white.withOpacity(0.18),
                  leading: _railLeading(context, isDesktop),
                  destinations: _railDests,
                ),
              Expanded(
                child: Column(
                  children: [
                    _topBar(context, isLoggedIn, showMenuBtn: !isLoggedIn),
                    Expanded(child: bodyContainer()),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    // ── Mobile ────────────────────────────────────────────────────────
    return Scaffold(
      backgroundColor: skyBlue,
      drawer: _buildDrawer(context, isLoggedIn),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(56.h),
        child: AppBar(
          backgroundColor: skyBlue,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          title: Text(
            isLoggedIn ? 'Easy Service' : 'Create Account',
            style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: _fs(context, 18, 20, 22)),
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
      ),
      body: bodyContainer(),
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
                        fontSize: _fs(context, 11, 12, 13));
                  }
                  return GoogleFonts.poppins(
                      color: Colors.grey,
                      fontSize: _fs(context, 10, 11, 12));
                }),
                iconTheme:
                    WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) {
                    return IconThemeData(
                        color: skyBlue,
                        size: _fs(context, 24, 26, 28));
                  }
                  return IconThemeData(
                      color: Colors.grey,
                      size: _fs(context, 20, 22, 24));
                }),
              ),
              child: NavigationBar(
                backgroundColor: Colors.white,
                height: 65.h,
                selectedIndex: currentIndex,
                onDestinationSelected: (i) =>
                    ref.read(navIndexProvider.notifier).state = i,
                destinations: _bottomDests,
              ),
            )
          : const SizedBox.shrink(),
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

  Widget _topBar(BuildContext context, bool isLoggedIn,
      {required bool showMenuBtn}) {
    return Container(
      color: skyBlue,
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
                      fontSize: _fs(context, 18, 20, 22)),
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
    );
  }

  Widget _buildDrawer(BuildContext context, bool isLoggedIn) {
    final double drawerWidth = _isDesktop(context)
        ? 300
        : _isTablet(context)
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
              decoration: BoxDecoration(
                color: skyBlue,
                borderRadius:
                    const BorderRadius.only(bottomRight: Radius.circular(30)),
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
                    radius: _isDesktop(context) ? 32 : 28,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person_rounded,
                        color: skyBlue,
                        size: _isDesktop(context) ? 38 : 32),
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
                              fontSize: _fs(context, 15, 16, 17)),
                        ),
                        Text(
                          isLoggedIn
                              ? "user@easyservice.com"
                              : "Please login to continue",
                          style: GoogleFonts.poppins(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: _fs(context, 11, 12, 13)),
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
                    _buildDrawerItem(context,
                        Icons.account_balance_wallet_rounded, "Wallet",
                        onTap: () => Navigator.pop(context)),
                    _buildDrawerItem(context,
                        Icons.card_giftcard_rounded, "Voucher Balance",
                        onTap: () => Navigator.pop(context)),
                    _buildDrawerItem(context,
                        Icons.workspace_premium_rounded, "Royalty Salary",
                        onTap: () => Navigator.pop(context)),
                    const Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                      child: Divider(color: Color(0xFFEEEEEE), thickness: 1.5),
                    ),
                  ],
                  _buildDrawerItem(context,
                      Icons.support_agent_rounded, "Support Center",
                      onTap: () => Navigator.pop(context)),
                  _buildDrawerItem(
                      context, Icons.facebook_rounded, "Facebook Group",
                      iconColor: Colors.blue,
                      onTap: () => Navigator.pop(context)),
                  _buildDrawerItem(
                      context, Icons.smart_display_rounded, "YouTube Channel",
                      iconColor: Colors.red,
                      onTap: () => Navigator.pop(context)),
                  _buildDrawerItem(
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
                          fontSize: _fs(context, 14, 15, 16))),
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
      ),
    );
  }

  Widget _buildDrawerItem(BuildContext context, IconData icon, String title,
      {Color? iconColor, required VoidCallback onTap}) {
    return ListTile(
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      leading: Icon(icon,
          color: iconColor ?? skyBlue,
          size: _fs(context, 22, 24, 26)),
      title: Text(title,
          style: GoogleFonts.poppins(
              fontSize: _fs(context, 13, 14, 15),
              fontWeight: FontWeight.w500,
              color: Colors.black87)),
      trailing: Icon(Icons.arrow_forward_ios_rounded,
          size: _fs(context, 13, 14, 15),
          color: Colors.grey.shade400),
      onTap: onTap,
      splashColor: skyBlue.withOpacity(0.1),
    );
  }
}

