import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:cached_network_image/cached_network_image.dart';

//--- ১. পপআপ বা স্টেট ম্যানেজমেন্ট (Riverpod) ---
final navIndexProvider = StateProvider<int>((ref) => 0);

void main() {
  runApp(
    const ProviderScope(
      child: EasyServiceApp(),
    ),
  );
}

//--- ২. GoRouter কনফিগারেশন ---
final _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const MainWrapper(),
    ),
  ],
);

class EasyServiceApp extends StatelessWidget {
  const EasyServiceApp({super.key});

  @override
  Widget build(BuildContext context) {
    // ৩. ScreenUtil ইনিশিয়ালাইজেশন (রেসপন্সিভ ডিজাইনের জন্য)
    return ScreenUtilInit(
      designSize: const Size(360, 800), // স্ট্যান্ডার্ড মোবাইল সাইজ
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp.router(
          debugShowCheckedModeBanner: false,
          title: 'Easy Service',
          theme: ThemeData(
            useMaterial3: true,
            textTheme: GoogleFonts.poppinsTextTheme(), // গ্লোবাল ফন্ট
          ),
          routerConfig: _router,
        );
      },
    );
  }
}

//--- ৪. মেইন র‍্যাপার (Main UI Structure) ---
class MainWrapper extends ConsumerWidget {
  const MainWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(navIndexProvider);
    const Color skyBlue = Color(0xFF29B6F6);

    // ৫টি ভিন্ন স্ক্রিনের লিস্ট
    final List<Widget> pages = [
      const ReusablePage(title: "Home", icon: Icons.home_rounded),
      const ReusablePage(title: "Reselling", icon: Icons.storefront_rounded),
      const ReusablePage(title: "Microjobs", icon: Icons.work_history_rounded),
      const ReusablePage(title: "Campaigns", icon: Icons.campaign_rounded),
      const ReusablePage(title: "Drive Offers", icon: Icons.directions_car_rounded),
    ];

    return Scaffold(
      backgroundColor: skyBlue,
      
      // সাইডবার (Drawer)
      drawer: _buildAppDrawer(context, skyBlue),

      appBar: AppBar(
        backgroundColor: skyBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Easy Service',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
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
            icon: const Icon(Icons.notifications_none_rounded),
          ),
        ],
      ),

      // রাউন্ডেড বডি উইথ অ্যানিমেশন
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30.r),
            topRight: Radius.circular(30.r),
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30.r),
            topRight: Radius.circular(30.r),
          ),
          child: pages[currentIndex]
              .animate(key: ValueKey(currentIndex))
              .fadeIn(duration: 400.ms)
              .moveY(begin: 10, end: 0),
        ),
      ),

      // প্রফেশনাল নেভিগেশন বার
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          indicatorColor: skyBlue.withOpacity(0.15),
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return GoogleFonts.poppins(
                fontSize: 11.sp, fontWeight: FontWeight.w600, color: skyBlue);
            }
            return GoogleFonts.poppins(fontSize: 10.sp, color: Colors.grey);
          }),
        ),
        child: NavigationBar(
          height: 70.h,
          backgroundColor: Colors.white,
          selectedIndex: currentIndex,
          onDestinationSelected: (index) => 
              ref.read(navIndexProvider.notifier).state = index,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined), 
              selectedIcon: Icon(Icons.home, color: skyBlue), 
              label: 'Home'),
            NavigationDestination(
              icon: Icon(Icons.storefront_outlined), 
              selectedIcon: Icon(Icons.storefront, color: skyBlue), 
              label: 'Reselling'),
            NavigationDestination(
              icon: Icon(Icons.work_outline), 
              selectedIcon: Icon(Icons.work, color: skyBlue), 
              label: 'Microjobs'),
            NavigationDestination(
              icon: Icon(Icons.campaign_outlined), 
              selectedIcon: Icon(Icons.campaign, color: skyBlue), 
              label: 'Campaigns'),
            NavigationDestination(
              icon: Icon(Icons.directions_car_outlined), 
              selectedIcon: Icon(Icons.directions_car, color: skyBlue), 
              label: 'Drive'),
          ],
        ),
      ),
    );
  }

  // ড্রয়ার ফাংশন
  Widget _buildAppDrawer(BuildContext context, Color themeColor) {
    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(color: themeColor),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person, color: themeColor, size: 40.sp),
            ),
            accountName: Text("Easy Service User", 
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
            accountEmail: const Text("support@easyservice.com"),
          ),
          _drawerItem(Icons.person_outline, "My Profile"),
          _drawerItem(Icons.history_rounded, "Transaction History"),
          _drawerItem(Icons.settings_outlined, "Settings"),
          const Spacer(),
          const Divider(),
          _drawerItem(Icons.logout_rounded, "Logout", color: Colors.red),
          SizedBox(height: 20.h),
        ],
      ),
    );
  }

  Widget _drawerItem(IconData icon, String title, {Color? color}) {
    return ListTile(
      leading: Icon(icon, color: color ?? Colors.black87),
      title: Text(title, style: GoogleFonts.poppins(fontSize: 14.sp, color: color)),
      onTap: () {},
    );
  }
}

//--- ৫. রিউজেবল পেজ টেম্পলেট (Lottie & Network Image সহ) ---
class ReusablePage extends StatelessWidget {
  final String title;
  final IconData icon;
  const ReusablePage({super.key, required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Lottie অ্যানিমেশন এক্সাম্পল (যদি অ্যাসেট থাকে)
          // Lottie.asset('assets/animations/welcome.json', height: 150.h),
          
          Icon(icon, size: 80.sp, color: const Color(0xFF29B6F6).withOpacity(0.5)),
          SizedBox(height: 20.h),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 24.sp, 
              fontWeight: FontWeight.bold,
              color: Colors.black87
            ),
          ),
          SizedBox(height: 10.h),
          Text(
            "Welcome to $title service section.\nProfessional UI is ready!",
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(fontSize: 14.sp, color: Colors.grey),
          ),
          SizedBox(height: 30.h),
          // Cached Network Image এক্সাম্পল
          ClipRRect(
            borderRadius: BorderRadius.circular(15.r),
            child: CachedNetworkImage(
              imageUrl: "https://via.placeholder.com/300x150/29B6F6/FFFFFF?text=Easy+Service+Banner",
              placeholder: (context, url) => const CircularProgressIndicator(),
              errorWidget: (context, url, error) => const Icon(Icons.error),
              height: 120.h,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
        ],
      ),
    );
  }
}
