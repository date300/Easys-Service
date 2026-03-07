import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

// ফিচার পেজগুলোর ইমপোর্ট (আপনার প্রোজেক্টের ডিরেক্টরি অনুযায়ী)
import '../features/home/home_screen.dart';
import '../features/reselling/reselling_screen.dart';
import '../features/microjobs/microjobs_screen.dart';
import '../features/campaigns/campaigns_screen.dart';
import '../features/drive/drive_screen.dart';

final navIndexProvider = StateProvider<int>((ref) => 0);

void main() {
  runApp(
    const ProviderScope(child: MyApp()),
  );
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

class MainWrapper extends ConsumerWidget {
  const MainWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(navIndexProvider);
    const Color skyBlue = Color(0xFF29B6F6);

    // ৫টি পেজের লিস্ট
    final List<Widget> pages = [
      const HomeScreen(),
      const ResellingScreen(),
      const MicrojobsScreen(),
      const CampaignsScreen(),
      const DriveScreen(),
    ];

    return Scaffold(
      backgroundColor: skyBlue,
      
      // ================== Modern Drawer / Sidebar ==================
      drawer: Drawer(
        backgroundColor: Colors.white,
        child: Column(
          children: [
            // কাস্টম মডার্ন হেডার
            Container(
              padding: EdgeInsets.only(top: 60.h, bottom: 20.h, left: 20.w, right: 20.w),
              decoration: BoxDecoration(
                color: skyBlue,
                borderRadius: BorderRadius.only(
                  bottomRight: Radius.circular(30.r),
                ),
                boxShadow: [
                  BoxShadow(
                    color: skyBlue.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  )
                ],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30.r,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person_rounded, color: skyBlue, size: 35.sp),
                  ),
                  SizedBox(width: 15.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Easy Service User",
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16.sp,
                          ),
                        ),
                        Text(
                          "user@easyservice.com",
                          style: GoogleFonts.poppins(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 12.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10.h),
            
            // সাইডবারের মেনু আইটেমগুলো
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(horizontal: 10.w),
                physics: const BouncingScrollPhysics(),
                children: [
                  _buildDrawerItem(Icons.account_balance_wallet_rounded, "Wallet", onTap: () {
                    Navigator.pop(context); // Drawer বন্ধ করার জন্য
                    // নেভিগেশন লজিক এখানে দিন
                  }),
                  _buildDrawerItem(Icons.card_giftcard_rounded, "Voucher Balance", onTap: () {
                    Navigator.pop(context);
                  }),
                  _buildDrawerItem(Icons.workspace_premium_rounded, "Royalty Salary", onTap: () {
                    Navigator.pop(context);
                  }),
                  
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 15.w),
                    child: Divider(color: Colors.grey.shade200, thickness: 1.5),
                  ),
                  
                  _buildDrawerItem(Icons.support_agent_rounded, "Support Center", onTap: () {
                    Navigator.pop(context);
                  }),
                  _buildDrawerItem(Icons.facebook_rounded, "Facebook Group", iconColor: Colors.blue, onTap: () {
                    Navigator.pop(context);
                  }),
                  _buildDrawerItem(Icons.smart_display_rounded, "YouTube Channel", iconColor: Colors.red, onTap: () {
                    Navigator.pop(context);
                  }),
                  _buildDrawerItem(Icons.telegram_rounded, "Telegram Group", iconColor: Colors.blueAccent, onTap: () {
                    Navigator.pop(context);
                  }),
                ],
              ),
            ),
            
            // মডার্ন লগআউট বাটন
            Padding(
              padding: EdgeInsets.only(left: 15.w, right: 15.w, bottom: 25.h, top: 10.h),
              child: ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.r),
                ),
                tileColor: Colors.red.withOpacity(0.1),
                leading: const Icon(Icons.logout_rounded, color: Colors.red),
                title: Text(
                  "Logout",
                  style: GoogleFonts.poppins(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 15.sp,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  // Logout Logic Here
                },
              ),
            ),
          ],
        ),
      ),
      // ==============================================================

      appBar: AppBar(
        backgroundColor: skyBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Easy Service',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 20.sp,
          ),
        ),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu_open_rounded, size: 28),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_outlined),
          ),
        ],
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
          child: pages[currentIndex]
              .animate(key: ValueKey(currentIndex))
              .fadeIn(duration: 400.ms)
              .moveY(begin: 10, end: 0),
        ),
      ),
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          indicatorColor: skyBlue.withOpacity(0.15),
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return GoogleFonts.poppins(color: skyBlue, fontWeight: FontWeight.bold, fontSize: 11.sp);
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
          height: 70.h,
          selectedIndex: currentIndex,
          onDestinationSelected: (index) =>
              ref.read(navIndexProvider.notifier).state = index,
          destinations: const [
            NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
            NavigationDestination(icon: Icon(Icons.storefront_outlined), selectedIcon: Icon(Icons.storefront), label: 'Reselling'),
            NavigationDestination(icon: Icon(Icons.assignment_outlined), selectedIcon: Icon(Icons.assignment), label: 'Microjobs'),
            NavigationDestination(icon: Icon(Icons.campaign_outlined), selectedIcon: Icon(Icons.campaign), label: 'Campaigns'),
            NavigationDestination(icon: Icon(Icons.directions_car_outlined), selectedIcon: Icon(Icons.directions_car), label: 'Drive'),
          ],
        ),
      ),
    );
  }

  // সাইডবার আইটেম তৈরির জন্য কাস্টম উইজেট মেথড
  Widget _buildDrawerItem(IconData icon, String title, {Color? iconColor, required VoidCallback onTap}) {
    return ListTile(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      leading: Icon(icon, color: iconColor ?? const Color(0xFF29B6F6), size: 24.sp),
      title: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 14.sp,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
      ),
      trailing: Icon(Icons.arrow_forward_ios_rounded, size: 14.sp, color: Colors.grey.shade400),
      onTap: onTap,
      splashColor: const Color(0xFF29B6F6).withOpacity(0.1),
    );
  }
}
