import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

// ফিচার পেজগুলোর ইমপোর্ট
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

    // আপডেট করা ৫টি পেজের লিস্ট
    final List<Widget> pages = [
      const HomeScreen(),
      const ResellingScreen(),
      const MicrojobsScreen(),
      const CampaignsScreen(),
      const DriveScreen(),
    ];

    return Scaffold(
      backgroundColor: skyBlue,
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
}
