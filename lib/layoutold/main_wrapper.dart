
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
              seedColor: const Color(0xFFFF6600), // Daraz Orange
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
  static const Color darazOrange = Color(0xFFFF6600);

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
        backgroundColor: darazOrange,
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

    // Desktop & Tablet Layout
    if (isDesktop || isTablet) {
      return Scaffold(
        backgroundColor: darazOrange,
        drawer: _buildDrawer(context, isLoggedIn),
        body: SafeArea(
          child: Row(
            children: [
              if (isLoggedIn)
                _buildPremiumNavigationRail(context, currentIndex, isDesktop),
              Expanded(
                child: Column(
                  children: [
                    _topBar(context, isLoggedIn, showMenuBtn: !isLoggedIn),
                    Expanded(child: _buildBodyContainer(pageContent, isMobile)),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Mobile Layout with Daraz Style Bottom Nav
    return Scaffold(
      backgroundColor: darazOrange,
      drawer: _buildDrawer(context, isLoggedIn),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(56.h),
        child: AppBar(
          backgroundColor: darazOrange,
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
      body: _buildBodyContainer(pageContent, isMobile),
      bottomNavigationBar: isLoggedIn
          ? DarazStyleBottomNav(
              currentIndex: currentIndex,
              onTap: (index) => ref.read(navIndexProvider.notifier).state = index,
            )
          : const SizedBox.shrink(),
    );
  }

  Widget _buildBodyContainer(Widget child, bool isMobile) {
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
        child: child,
      ),
    );
  }

  Widget _buildPremiumNavigationRail(BuildContext context, int currentIndex, bool isDesktop) {
    final List<NavRailItem> railItems = [
      NavRailItem(Icons.home_outlined, Icons.home_rounded, 'Home'),
      NavRailItem(Icons.storefront_outlined, Icons.storefront_rounded, 'Reselling'),
      NavRailItem(Icons.assignment_outlined, Icons.assignment_rounded, 'Microjobs'),
      NavRailItem(Icons.campaign_outlined, Icons.campaign_rounded, 'Campaigns'),
      NavRailItem(Icons.person_outline_rounded, Icons.person_rounded, 'Profile'),
    ];

    return Container(
      width: isDesktop ? 280.w : 80.w,
      color: darazOrange,
      child: Column(
        children: [
          SizedBox(height: 20.h),
          // Logo area
          if (isDesktop)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Row(
                children: [
                  Container(
                    width: 40.w,
                    height: 40.h,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Icon(Icons.shopping_bag_rounded, color: darazOrange),
                  ),
                  SizedBox(width: 12.w),
                  Text(
                    'Easy Service',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20.sp,
                    ),
                  ),
                ],
              ),
            ),
          SizedBox(height: 30.h),
          // Menu button
          Builder(
            builder: (ctx) => IconButton(
              icon: const Icon(Icons.menu_open_rounded, color: Colors.white, size: 28),
              onPressed: () => Scaffold.of(ctx).openDrawer(),
            ),
          ),
          SizedBox(height: 20.h),
          // Navigation items
          Expanded(
            child: ListView.builder(
              itemCount: railItems.length,
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              itemBuilder: (context, index) {
                final item = railItems[index];
                final isSelected = currentIndex == index;

                return GestureDetector(
                  onTap: () => ref.read(navIndexProvider.notifier).state = index,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: EdgeInsets.only(bottom: 8.h),
                    padding: EdgeInsets.symmetric(
                      horizontal: isDesktop ? 16.w : 12.w,
                      vertical: 12.h,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.white.withOpacity(0.15) : Colors.transparent,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Row(
                      children: [
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          child: Icon(
                            isSelected ? item.activeIcon : item.icon,
                            key: ValueKey<bool>(isSelected),
                            color: isSelected ? Colors.white : Colors.white.withOpacity(0.6),
                            size: 24.sp,
                          ),
                        ),
                        if (isDesktop) ...[
                          SizedBox(width: 12.w),
                          AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 200),
                            style: GoogleFonts.poppins(
                              color: isSelected ? Colors.white : Colors.white.withOpacity(0.6),
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                              fontSize: 14.sp,
                            ),
                            child: Text(item.label),
                          ),
                        ],
                        if (isSelected)
                          Container(
                            margin: EdgeInsets.only(left: isDesktop ? 8.w : 0),
                            width: isDesktop ? 4.w : 4.w,
                            height: isDesktop ? 20.h : 4.h,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(2.r),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _topBar(BuildContext context, bool isLoggedIn, {required bool showMenuBtn}) {
    return Container(
      color: darazOrange,
      child: SizedBox(
        height: 60,
        child: Row(
          children: [
            if (showMenuBtn)
              Builder(
                builder: (ctx) => IconButton(
                  icon: const Icon(Icons.menu_open_rounded, color: Colors.white, size: 28),
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
                icon: const Icon(Icons.notifications_outlined, color: Colors.white),
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
                color: darazOrange,
                borderRadius:
                    const BorderRadius.only(bottomRight: Radius.circular(30)),
                boxShadow: [
                  BoxShadow(
                      color: darazOrange.withOpacity(0.3),
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
                        color: darazOrange,
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
          color: iconColor ?? darazOrange,
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
      splashColor: darazOrange.withOpacity(0.1),
    );
  }
}

// ==================== DARAZ STYLE BOTTOM NAVIGATION ====================

class DarazStyleBottomNav extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;

  const DarazStyleBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  State<DarazStyleBottomNav> createState() => _DarazStyleBottomNavState();
}

class _DarazStyleBottomNavState extends State<DarazStyleBottomNav> 
    with TickerProviderStateMixin {

  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;

  final List<NavItemData> items = [
    NavItemData(
      icon: Icons.home_outlined,
      activeIcon: Icons.home_rounded,
      label: 'Home',
      color: const Color(0xFFFF6600),
    ),
    NavItemData(
      icon: Icons.storefront_outlined,
      activeIcon: Icons.storefront_rounded,
      label: 'Resell',
      color: const Color(0xFFFF6600),
    ),
    NavItemData(
      icon: Icons.add_circle_outline_rounded,
      activeIcon: Icons.add_circle_rounded,
      label: 'Post',
      color: const Color(0xFFFF6600),
      isCenter: true,
    ),
    NavItemData(
      icon: Icons.campaign_outlined,
      activeIcon: Icons.campaign_rounded,
      label: 'Campaign',
      color: const Color(0xFFFF6600),
    ),
    NavItemData(
      icon: Icons.person_outline_rounded,
      activeIcon: Icons.person_rounded,
      label: 'Profile',
      color: const Color(0xFFFF6600),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      items.length,
      (index) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 300),
      ),
    );
    _animations = _controllers.map((controller) {
      return Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
          parent: controller,
          curve: Curves.easeOutBack,
        ),
      );
    }).toList();

    _controllers[widget.currentIndex].value = 1.0;
  }

  @override
  void didUpdateWidget(DarazStyleBottomNav oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      _controllers[oldWidget.currentIndex].reverse();
      _controllers[widget.currentIndex].forward();
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 85.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30.r),
          topRight: Radius.circular(30.r),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 30,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30.r),
          topRight: Radius.circular(30.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(items.length, (index) {
            final item = items[index];
            final isSelected = widget.currentIndex == index;

            if (item.isCenter) {
              return _buildCenterButton(item, index, isSelected);
            }

            return _buildNavItem(item, index, isSelected);
          }),
        ),
      ),
    );
  }

  Widget _buildNavItem(NavItemData item, int index, bool isSelected) {
    return GestureDetector(
      onTap: () => widget.onTap(index),
      child: AnimatedBuilder(
        animation: _animations[index],
        builder: (context, child) {
          final scale = 1 + (_animations[index].value * 0.2);
          final translateY = _animations[index].value * -12;

          return Container(
            width: 65.w,
            height: 70.h,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animated background container
                Transform.translate(
                  offset: Offset(0, translateY),
                  child: Transform.scale(
                    scale: scale,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 44.w,
                      height: 44.h,
                      decoration: BoxDecoration(
                        gradient: isSelected
                            ? LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  item.color.withOpacity(0.2),
                                  item.color.withOpacity(0.1),
                                ],
                              )
                            : null,
                        color: isSelected ? null : Colors.transparent,
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 250),
                        transitionBuilder: (child, animation) {
                          return ScaleTransition(
                            scale: animation,
                            child: FadeTransition(
                              opacity: animation,
                              child: child,
                            ),
                          );
                        },
                        child: Icon(
                          isSelected ? item.activeIcon : item.icon,
                          key: ValueKey<bool>(isSelected),
                          color: isSelected ? item.color : Colors.grey.shade400,
                          size: 24.sp,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 6.h),
                // Label
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 200),
                  style: GoogleFonts.poppins(
                    fontSize: 11.sp,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected ? item.color : Colors.grey.shade400,
                  ),
                  child: Text(item.label),
                ),
                // Animated indicator dot
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: EdgeInsets.only(top: 6.h),
                  width: isSelected ? 20.w : 0,
                  height: 4.h,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [item.color, item.color.withOpacity(0.7)],
                    ),
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCenterButton(NavItemData item, int index, bool isSelected) {
    return GestureDetector(
      onTap: () => widget.onTap(index),
      child: AnimatedBuilder(
        animation: _animations[index],
        builder: (context, child) {
          final scale = 1 + (_animations[index].value * 0.25);

          return Transform.scale(
            scale: scale,
            child: Container(
              width: 65.w,
              height: 65.h,
              margin: EdgeInsets.only(bottom: 25.h),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFFF6600),
                    Color(0xFFFF4500),
                    Color(0xFFFF3300),
                  ],
                ),
                borderRadius: BorderRadius.circular(22.r),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFF6600).withOpacity(0.5),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                    spreadRadius: 2,
                  ),
                  BoxShadow(
                    color: const Color(0xFFFF6600).withOpacity(0.3),
                    blurRadius: 40,
                    offset: const Offset(0, 20),
                  ),
                ],
              ),
              child: Icon(
                isSelected ? item.activeIcon : item.icon,
                color: Colors.white,
                size: 32.sp,
              ),
            ),
          );
        },
      ),
    );
  }
}

class NavItemData {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final Color color;
  final bool isCenter;

  NavItemData({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.color,
    this.isCenter = false,
  });
}

class NavRailItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  NavRailItem(this.icon, this.activeIcon, this.label);
}
