import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

// ১. স্টেট ম্যানেজমেন্ট (Riverpod Provider)
final navIndexProvider = StateProvider<int>((ref) => 0);

void main() {
  runApp(
    const ProviderScope(child: MyApp()),
  );
}

// ২. GoRouter সেটআপ
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
    // ৩. ScreenUtilInit (এটি না দিলে স্ক্রিন সাদা হয়ে থাকে)
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
            // Google Fonts সেটআপ
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
      _buildPageContent("Home Screen"),
      _buildPageContent("Reselling Screen"),
      _buildPageContent("Microjobs Screen"),
      _buildPageContent("Campaigns Screen"),
      _buildPageContent("Drive Offers Screen"),
    ];

    return Scaffold(
      // আপনার দেওয়া সেই লেআউট ব্যাকগ্রাউন্ড
      backgroundColor: skyBlue,

      // সাইডবার (Drawer) - যা খোলার ব্যবস্থা আছে
      drawer: Drawer(
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(color: skyBlue),
              accountName: Text("Easy Service User", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
              accountEmail: const Text("user@easyservice.com"),
              currentAccountPicture: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.person, color: skyBlue, size: 40),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text("Home"),
              onTap: () => Navigator.pop(context),
            ),
            const Spacer(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text("Logout", style: TextStyle(color: Colors.red)),
              onTap: () {},
            ),
            SizedBox(height: 20.h),
          ],
        ),
      ),

      appBar: AppBar(
        backgroundColor: skyBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Easy Service',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 20.sp, // ScreenUtil size
          ),
        ),
        // সাইডবার খোলার বাটন
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

      // 🌟 আপনার প্রিয় বাঁকানো (Rounded Top) বডি লেআউট
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
              .animate(key: ValueKey(currentIndex)) // flutter_animate যোগ করা হয়েছে
              .fadeIn(duration: 400.ms)
              .moveY(begin: 10, end: 0),
        ),
      ),

      // ৫টি বাটন সহ প্রফেশনাল নেভিগেশন বার
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

  // পেজের ভেতরের কন্টেন্ট
  Widget _buildPageContent(String title) {
    return Center(
      child: Text(
        title,
        style: GoogleFonts.poppins(fontSize: 20.sp, fontWeight: FontWeight.w500, color: Colors.grey),
      ),
    );
  }
}
