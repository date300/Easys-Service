import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

// আপনার ফিচার স্ক্রিনগুলো ইম্পোর্ট করুন
import 'features/home/home_screen.dart';
import 'features/reselling/reselling_screen.dart';
import 'features/microjobs/microjobs_screen.dart';
import 'features/campaigns/campaigns_screen.dart';
import 'features/drive/drive_screen.dart';
import 'features/auth/registration_screen.dart'; // রেজিস্ট্রেশন স্ক্রিন

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: MyApp()));
}

// কেন ShellRoute? এতে আপনার সাইডবার এবং বটম ন্যাভ ঠিক থাকবে কিন্তু মাঝখানের কন্টেন্ট লিঙ্কের সাথে বদলাবে।
final GoRouter _router = GoRouter(
  initialLocation: '/home',
  routes: [
    // রেজিস্ট্রেশন আলাদা পেজ (মেনু ছাড়া)
    GoRoute(
      path: '/registration',
      builder: (context, state) => const RegistrationScreen(),
    ),
    
    // মেইন অ্যাপের ভেতরকার পেজগুলো (মেনুসহ)
    ShellRoute(
      builder: (context, state, child) {
        return MainWrapper(child: child); // এখানে child পাস করা হচ্ছে
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

class MainWrapper extends ConsumerWidget {
  final Widget child; // এরর সমাধান করার জন্য এটি যোগ করা হয়েছে
  const MainWrapper({super.key, required this.child}); 

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const Color skyBlue = Color(0xFF29B6F6);

    // বর্তমান লোকেশন অনুযায়ী ইনডেক্স বের করা
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
      drawer: _buildDrawer(context, skyBlue),
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
          child: child // এখানে ডাইনামিক পেজ লোড হবে
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
          // ইনডেক্স অনুযায়ী রাউটে নেভিগেট করা
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

  // ড্রয়ার মেথড
  Widget _buildDrawer(BuildContext context, Color skyBlue) {
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
                _buildDrawerItem(Icons.app_registration, "Register", onTap: () {
                   Navigator.pop(context);
                   context.push('/registration'); // লিঙ্কের মাধ্যমে যাওয়া
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
