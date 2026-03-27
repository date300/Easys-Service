import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import 'features/home/home_screen.dart';
import 'features/reselling/reselling_screen.dart';
import 'features/microjobs/microjobs_screen.dart';
import 'features/campaigns/campaigns_screen.dart';
import 'features/drive/drive_screen.dart';
import 'features/auth/registration_screen.dart';

// ১. authProvider ডিফাইন করা (লগইন স্টেট রাখার জন্য)
final authProvider = StateProvider<bool>((ref) => false);

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: MyApp()));
}

// ২. গো-রাউটার কনফিগারেশন (রিডাইরেক্ট লজিকসহ)
final GoRouter _router = GoRouter(
  initialLocation: '/home',
  
  // রিডাইরেক্ট লজিক: এখানে চেক করা হবে ইউজার লগইন আছে কি না
  redirect: (BuildContext context, GoRouterState state) {
    final container = ProviderScope.containerOf(context);
    final isLoggedIn = container.read(authProvider); // কারেন্ট লগইন স্ট্যাটাস
    final isGoingToRegister = state.matchedLocation == '/registration';

    // যদি লগইন না থাকে এবং ইউজার রেজিস্ট্রেশন পেজে না থাকে, তবে তাকে রেজিস্ট্রেশন পেজে পাঠাও
    if (!isLoggedIn && !isGoingToRegister) {
      return '/registration';
    }

    // যদি লগইন করা থাকে এবং ইউজার রেজিস্ট্রেশন পেজে যেতে চায়, তবে তাকে হোমে পাঠাও
    if (isLoggedIn && isGoingToRegister) {
      return '/home';
    }

    // অন্যথায় যে পেজে যেতে চায় সেখানেই যেতে দাও
    return null;
  },
  
  routes: [
    GoRoute(
      path: '/registration',
      builder: (context, state) => const RegistrationScreen(),
    ),
    ShellRoute(
      builder: (context, state, child) {
        return MainWrapper(child: child);
      },
      routes: [
        GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
        GoRoute(path: '/reselling', builder: (context, state) => const ResellingScreen()),
        GoRoute(path: '/microjobs', builder: (context, state) => const MicrojobsScreen()),
        GoRoute(path: '/campaigns', builder: (context, state) => const CampaignsScreen()),
        GoRoute(path: '/drive', builder: (context, state) => const DriveScreen()),
      ],
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
            colorSchemeSeed: const Color(0xFF29B6F6),
            textTheme: GoogleFonts.poppinsTextTheme(),
          ),
          routerConfig: _router,
        );
      },
    );
  }
}

// ৩. MainWrapper এ লগআউট বাটন যোগ করার সুযোগ থাকে (নিচে পরিবর্তন নেই, আগের মতই)
class MainWrapper extends ConsumerWidget {
  final Widget child;
  const MainWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const Color skyBlue = Color(0xFF29B6F6);

    int getCurrentIndex(BuildContext context) {
      final String location = GoRouterState.of(context).uri.toString();
      if (location == '/home') return 0;
      if (location == '/reselling') return 1;
      if (location == '/microjobs') return 2;
      if (location == '/campaigns') return 3;
      if (location == '/drive') return 4;
      return 0;
    }

    final currentIndex = getCurrentIndex(context);

    return Scaffold(
      backgroundColor: skyBlue,
      drawer: _buildDrawer(context, skyBlue, ref), // ref পাস করা হয়েছে লগআউটের জন্য
      appBar: AppBar(
        backgroundColor: skyBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text('Easy Service', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 20.sp)),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu_open_rounded, size: 28),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(topLeft: Radius.circular(32.r), topRight: Radius.circular(32.r)),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.only(topLeft: Radius.circular(32.r), topRight: Radius.circular(32.r)),
          child: child
              .animate(key: ValueKey(currentIndex))
              .fadeIn(duration: 400.ms)
              .moveY(begin: 10, end: 0),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        backgroundColor: Colors.white,
        height: 70.h,
        selectedIndex: currentIndex,
        onDestinationSelected: (index) {
          switch (index) {
            case 0: context.go('/home'); break;
            case 1: context.go('/reselling'); break;
            case 2: context.go('/microjobs'); break;
            case 3: context.go('/campaigns'); break;
            case 4: context.go('/drive'); break;
          }
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.storefront_outlined), selectedIcon: Icon(Icons.storefront), label: 'Reselling'),
          NavigationDestination(icon: Icon(Icons.assignment_outlined), selectedIcon: Icon(Icons.assignment), label: 'Microjobs'),
          NavigationDestination(icon: Icon(Icons.campaign_outlined), selectedIcon: Icon(Icons.campaign), label: 'Campaigns'),
          NavigationDestination(icon: Icon(Icons.directions_car_outlined), selectedIcon: Icon(Icons.directions_car), label: 'Drive'),
        ],
      ),
    );
  }

  Widget _buildDrawer(BuildContext context, Color skyBlue, WidgetRef ref) {
    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.only(top: 60.h, bottom: 20.h, left: 20.w, right: 20.w),
            color: skyBlue,
            child: Row(
              children: [
                CircleAvatar(radius: 30.r, backgroundColor: Colors.white, child: Icon(Icons.person, color: skyBlue)),
                SizedBox(width: 15.w),
                Text("Easy User", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16.sp)),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: 10.w),
              children: [
                _buildDrawerItem(Icons.account_balance_wallet, "Wallet", onTap: () => Navigator.pop(context)),
                _buildDrawerItem(Icons.support_agent, "Support", onTap: () => Navigator.pop(context)),
                // লগআউট বাটন (লগইন স্টেট ফলস করে দিবে)
                _buildDrawerItem(Icons.logout, "Logout", onTap: () {
                   ref.read(authProvider.notifier).state = false;
                   context.go('/registration');
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, {required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF29B6F6)),
      title: Text(title, style: GoogleFonts.poppins(fontSize: 14.sp)),
      onTap: onTap,
    );
  }
}
