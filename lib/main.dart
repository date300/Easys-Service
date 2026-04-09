import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'router/app_router.dart';

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

class MainWrapper extends ConsumerStatefulWidget {
  final Widget child;
  const MainWrapper({super.key, required this.child});

  @override
  ConsumerState<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends ConsumerState<MainWrapper> {
  static const Color skyBlue = Color(0xFF29B6F6);
  static const Color premiumOrange = Color(0xFFF57224);
  static const Color premiumDark = Color(0xFF1A1A2E);
  static const Color darazPink = Color(0xFFFF6B9D);
  static const Color darazOrange = Color(0xFFFF8E53);

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
    return 0;
  }

  void _onNavTap(BuildContext context, int index) {
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
    }
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    final currentIndex = _indexFromLocation(location);
    final isLoggedIn = ref.watch(authProvider);
    final isDesktop = _isDesktop(context);
    final isTablet = _isTablet(context);
    final isMobile = _isMobile(context);

    final isPaymentPage = location == '/payment';
    final isProfilePage = location == '/profile';
    final isDetailView = isPaymentPage || isProfilePage || ref.watch(isDetailViewProvider);
    final detailTitle = isPaymentPage 
        ? 'Payment' 
        : isProfilePage 
            ? 'Profile' 
            : ref.watch(detailViewTitleProvider);

    final animatedChild = widget.child
        .animate(key: ValueKey(location))
        .fadeIn(duration: 400.ms)
        .moveY(begin: 10, end: 0);

    Widget bodyContainer() {
      if (isDetailView) {
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

    return PopScope(
      canPop: !isDetailView,
      onPopInvokedWithResult: (didPop, result) {
        if (isDetailView && !didPop) {
          ref.read(isDetailViewProvider.notifier).state = false;
          ref.read(detailViewTitleProvider.notifier).state = '';
        }
      },
      child: Scaffold(
        backgroundColor: skyBlue,
        drawer: isDetailView ? null : _buildDrawer(context, ref, isLoggedIn),
        body: SafeArea(
          child: Row(
            children: [
              if ((isDesktop || isTablet) && !isDetailView)
                _buildPremiumNavigationRail(context, currentIndex, isDesktop),
              Expanded(
                child: Column(
                  children: [
                    _buildTopBar(
                      context,
                      ref,
                      isLoggedIn,
                      isDetailView: isDetailView,
                      detailTitle: detailTitle,
                      isMobile: isMobile,
                    ),
                    Expanded(child: bodyContainer()),
                  ],
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: (isMobile && !isDetailView)
            ? _buildPremiumBottomNav(context, currentIndex)
            : null,
      ),
    );
  }

  // ============================================
  // 🎨 PREMIUM BOTTOM NAVIGATION BAR (DARAZ STYLE)
  // ============================================
  Widget _buildPremiumBottomNav(BuildContext context, int currentIndex) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          height: 70.h,
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                index: 0,
                currentIndex: currentIndex,
                icon: Icons.home_rounded,
                label: 'Home',
                onTap: () => _onNavTap(context, 0),
              ),
              _buildNavItem(
                index: 1,
                currentIndex: currentIndex,
                icon: Icons.storefront_rounded,
                label: 'Reselling',
                onTap: () => _onNavTap(context, 1),
              ),
              _buildCenterButton(
                currentIndex: currentIndex,
                onTap: () => _onNavTap(context, 2),
              ),
              _buildNavItem(
                index: 3,
                currentIndex: currentIndex,
                icon: Icons.campaign_rounded,
                label: 'Campaigns',
                onTap: () => _onNavTap(context, 3),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required int currentIndex,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final isSelected = index == currentIndex;
    
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isSelected ? premiumOrange.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              padding: EdgeInsets.all(isSelected ? 6.w : 4.w),
              decoration: BoxDecoration(
                color: isSelected ? premiumOrange : Colors.transparent,
                borderRadius: BorderRadius.circular(12.r),
                boxShadow: isSelected ? [
                  BoxShadow(
                    color: premiumOrange.withOpacity(0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ] : [],
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : Colors.grey.shade400,
                size: isSelected ? 22.sp : 24.sp,
              ),
            ),
            SizedBox(height: 4.h),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 300),
              style: GoogleFonts.poppins(
                color: isSelected ? premiumOrange : Colors.grey.shade500,
                fontSize: isSelected ? 11.sp : 10.sp,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
              child: Text(label),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              margin: EdgeInsets.only(top: 4.h),
              height: 3.h,
              width: isSelected ? 20.w : 0,
              decoration: BoxDecoration(
                color: premiumOrange,
                borderRadius: BorderRadius.circular(2.r),
                boxShadow: isSelected ? [
                  BoxShadow(
                    color: premiumOrange.withOpacity(0.6),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ] : [],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCenterButton({
    required int currentIndex,
    required VoidCallback onTap,
  }) {
    final isSelected = currentIndex == 2;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 56.w,
        height: 56.w,
        margin: EdgeInsets.only(bottom: 8.h),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              darazPink,
              darazOrange,
            ],
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: darazPink.withOpacity(0.4),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
          border: Border.all(
            color: Colors.white,
            width: 3.w,
          ),
        ),
        child: Center(
          child: Icon(
            Icons.assignment_rounded,
            color: Colors.white,
            size: 28.sp,
          ),
        ),
      ).animate(
        onPlay: (controller) => controller.repeat(reverse: true),
      ).scale(
        begin: const Offset(1, 1),
        end: const Offset(1.05, 1.05),
        duration: 2.seconds,
        curve: Curves.easeInOut,
      ),
    );
  }

  // ============================================
  // 💎 PREMIUM NAVIGATION RAIL (TABLET/DESKTOP)
  // ============================================
  Widget _buildPremiumNavigationRail(BuildContext context, int currentIndex, bool isDesktop) {
    return Container(
      width: isDesktop ? 280 : 80,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            skyBlue,
            skyBlue.withOpacity(0.9),
            const Color(0xFF0288D1),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(4, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(20.w),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Icon(
                    Icons.shopping_bag_rounded,
                    color: Colors.white,
                    size: 28.sp,
                  ),
                ),
                if (isDesktop) ...[
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Text(
                      'Easy Service',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
              children: [
                _buildRailItem(
                  index: 0,
                  currentIndex: currentIndex,
                  icon: Icons.home_rounded,
                  label: 'Home',
                  isDesktop: isDesktop,
                  onTap: () => _onNavTap(context, 0),
                ),
                SizedBox(height: 12.h),
                _buildRailItem(
                  index: 1,
                  currentIndex: currentIndex,
                  icon: Icons.storefront_rounded,
                  label: 'Reselling',
                  isDesktop: isDesktop,
                  onTap: () => _onNavTap(context, 1),
                ),
                SizedBox(height: 12.h),
                _buildRailItem(
                  index: 2,
                  currentIndex: currentIndex,
                  icon: Icons.assignment_rounded,
                  label: 'Microjobs',
                  isDesktop: isDesktop,
                  onTap: () => _onNavTap(context, 2),
                ),
                SizedBox(height: 12.h),
                _buildRailItem(
                  index: 3,
                  currentIndex: currentIndex,
                  icon: Icons.campaign_rounded,
                  label: 'Campaigns',
                  isDesktop: isDesktop,
                  onTap: () => _onNavTap(context, 3),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRailItem({
    required int index,
    required int currentIndex,
    required IconData icon,
    required String label,
    required bool isDesktop,
    required VoidCallback onTap,
  }) {
    final isSelected = index == currentIndex;
    
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.symmetric(
          horizontal: isDesktop ? 20.w : 16.w,
          vertical: 16.h,
        ),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(16.r),
          border: isSelected ? Border.all(
            color: Colors.white.withOpacity(0.3),
            width: 1,
          ) : null,
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: EdgeInsets.all(isSelected ? 10.w : 8.w),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white : Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12.r),
                boxShadow: isSelected ? [
                  BoxShadow(
                    color: Colors.white.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ] : [],
              ),
              child: Icon(
                icon,
                color: isSelected ? skyBlue : Colors.white,
                size: isSelected ? 24.sp : 22.sp,
              ),
            ),
            if (isDesktop) ...[
              SizedBox(width: 16.w),
              Expanded(
                child: AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 300),
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: isSelected ? 16.sp : 15.sp,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  ),
                  child: Text(label),
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: isSelected ? 8.w : 0,
                height: 8.w,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withOpacity(0.5),
                      blurRadius: 8,
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ============================================
  // TOP BAR
  // ============================================
  Widget _buildTopBar(
    BuildContext context,
    WidgetRef ref,
    bool isLoggedIn, {
    required bool isDetailView,
    required String detailTitle,
    required bool isMobile,
  }) {
    return Container(
      color: skyBlue,
      height: isMobile ? 56.h : 60,
      child: Row(
        children: [
          SizedBox(width: 8.w),
          if (isDetailView)
            IconButton(
              icon: const Icon(Icons.arrow_back_ios_rounded,
                  color: Colors.white, size: 24),
              onPressed: () {
                ref.read(isDetailViewProvider.notifier).state = false;
                ref.read(detailViewTitleProvider.notifier).state = '';
                context.go('/home');
              },
            )
          else
            Builder(
              builder: (ctx) => IconButton(
                icon: const Icon(Icons.menu_open_rounded,
                    color: Colors.white, size: 28),
                onPressed: () => Scaffold.of(ctx).openDrawer(),
              ),
            ),
          SizedBox(width: 8.w),
          Expanded(
            child: Center(
              child: Text(
                isDetailView ? detailTitle : 'Easy Service',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: isMobile ? 20.sp : 20,
                ),
              ),
            ),
          ),
          if (!isDetailView && isLoggedIn)
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.notifications_outlined,
                  color: Colors.white),
            )
          else
            SizedBox(width: 48.w),
        ],
      ),
    );
  }

  // ============================================
  // DRAWER
  // ============================================
  Widget _buildDrawer(BuildContext context, WidgetRef ref, bool isLoggedIn) {
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
                    _drawerItem(context, Icons.account_balance_wallet_rounded,
                        "Wallet",
                        onTap: () => Navigator.pop(context)),
                    _drawerItem(
                        context, Icons.card_giftcard_rounded, "Voucher Balance",
                        onTap: () => Navigator.pop(context)),
                    _drawerItem(context, Icons.workspace_premium_rounded,
                        "Royalty Salary",
                        onTap: () => Navigator.pop(context)),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                      child: Divider(color: Color(0xFFEEEEEE), thickness: 1.5),
                    ),
                  ],
                  _drawerItem(
                      context, Icons.support_agent_rounded, "Support Center",
                      onTap: () => Navigator.pop(context)),
                  _drawerItem(context, Icons.facebook_rounded, "Facebook Group",
                      iconColor: Colors.blue,
                      onTap: () => Navigator.pop(context)),
                  _drawerItem(context, Icons.smart_display_rounded,
                      "YouTube Channel",
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
