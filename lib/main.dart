// main.dart (FIXED: const MainWrapper removed from ShellRoute)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'features/home/home_screen.dart';
import 'features/reselling/reselling_screen.dart';
import 'features/microjobs/microjobs_screen.dart';
import 'features/campaigns/campaigns_screen.dart';
import 'features/drive/drive_screen.dart';
import 'features/auth/registration_screen.dart';

/// ONE single auth provider for the whole app
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

final GoRouter _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/registration',
      builder: (context, state) => const RegistrationScreen(),
    ),

    // ✅ IMPORTANT FIX: remove const here
    ShellRoute(
      builder: (context, state, child) => MainWrapper(child: child),
      routes: [
        GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
        GoRoute(path: '/reselling', builder: (context, state) => const ResellingScreen()),
        GoRoute(path: '/microjobs', builder: (context, state) => const MicrojobsScreen()),
        GoRoute(path: '/campaigns', builder: (context, state) => const CampaignsScreen()),
        GoRoute(path: '/drive', builder: (context, state) => const DriveScreen()),
      ],
    ),
  ],

  redirect: (context, state) async {
    final ref = ProviderScope.containerOf(context);

    // load auth state from prefs before redirect decision
    await ref.read(authLoadingProvider.future);

    final isLoggedIn = ref.read(authProvider);
    final goingToRegister = state.matchedLocation == '/registration';

    if (!isLoggedIn && !goingToRegister) return '/registration';
    if (isLoggedIn && goingToRegister) return '/home';
    return null;
  },
);

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
          routerConfig: _router,
        );
      },
    );
  }
}

class MainWrapper extends ConsumerWidget {
  final Widget child;
  const MainWrapper({super.key, required this.child});

  int _indexFromLocation(String location) {
    if (location == '/home') return 0;
    if (location == '/reselling') return 1;
    if (location == '/microjobs') return 2;
    if (location == '/campaigns') return 3;
    if (location == '/drive') return 4;
    return 0;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const Color skyBlue = Color(0xFF29B6F6);

    final location = GoRouterState.of(context).uri.toString();
    final currentIndex = _indexFromLocation(location);

    final isLoggedIn = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: skyBlue,
      drawer: Drawer(
        backgroundColor: Colors.white,
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.only(top: 60.h, bottom: 20.h, left: 20.w, right: 20.w),
              color: skyBlue,
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30.r,
                    backgroundColor: Colors.white,
                    child: const Icon(Icons.person, color: skyBlue),
                  ),
                  SizedBox(width: 15.w),
                  Text(
                    isLoggedIn ? "Easy User" : "Guest User",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16.sp,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(horizontal: 10.w),
                children: [
                  ListTile(
                    leading: const Icon(Icons.support_agent_rounded, color: Color(0xFF29B6F6)),
                    title: Text("Support", style: GoogleFonts.poppins(fontSize: 14.sp)),
                    onTap: () => Navigator.pop(context),
                  ),
                  ListTile(
                    leading: const Icon(Icons.logout, color: Color(0xFF29B6F6)),
                    title: Text("Logout", style: GoogleFonts.poppins(fontSize: 14.sp)),
                    onTap: () async {
                      await ref.read(authProvider.notifier).logout();
                      if (context.mounted) context.go('/registration');
                    },
                  ),
                ],
              ),
            ),
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
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 20.sp),
        ),
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
            case 4:
              context.go('/drive');
              break;
          }
        },
        destinations: const [
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
              icon: Icon(Icons.directions_car_outlined),
              selectedIcon: Icon(Icons.directions_car),
              label: 'Drive'),
        ],
      ),
    );
  }
}
