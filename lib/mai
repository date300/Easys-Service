import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

// আপনার নিজের ফাইলগুলো ইমপোর্ট করুন
import 'layout/main_wrapper.dart'; 

// ১. GoRouter কনফিগারেশন
final _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/main', // এই পাথে আমরা নেভিগেট করবো
      builder: (context, state) => const MainWrapper(), // আপনার layout/main_wrapper.dart ফাইল থেকে আসবে
    ),
  ],
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SharedPreferences.getInstance();

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
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
          routerConfig: _router,
          theme: ThemeData(
            useMaterial3: true,
            colorSchemeSeed: const Color(0xFF0284C7),
            textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme),
          ),
        );
      },
    );
  }
}

// --- SplashScreen ---
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNext();
  }

  _navigateToNext() async {
    // ৩ সেকেন্ড পর হোমপেজে যাবে
    await Future.delayed(const Duration(milliseconds: 3000));
    if (mounted) {
      // GoRouter ব্যবহার করে /main রাউটে পাঠানো হচ্ছে
      context.go('/main'); 
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0EA5E9),
      body: SizedBox(
        width: 1.sw,
        height: 1.sh,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(flex: 4),

            // লোগো সেকশন
            Image.asset(
              "assets/ultra5G.png",
              width: 200.w,
              errorBuilder: (context, error, stackTrace) => 
                  Icon(Icons.flash_on, size: 100.w, color: Colors.white),
            ).animate()
             .fade(duration: 600.ms)
             .scale(delay: 200.ms, curve: Curves.easeOutBack),

            SizedBox(height: 12.h),

            Text(
              "Easy Service",
              style: TextStyle(
                fontSize: 28.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1.5,
              ),
            ).animate()
             .fadeIn(delay: 400.ms)
             .slideY(begin: 0.2, end: 0),

            const Spacer(flex: 3),

            // লোডিং ডটস
            Padding(
              padding: EdgeInsets.only(bottom: 60.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(4, (index) {
                  return Container(
                    margin: EdgeInsets.symmetric(horizontal: 4.w),
                    width: 10.w,
                    height: 10.w,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ).animate(onPlay: (controller) => controller.repeat())
                   .scale(
                     delay: (index * 150).ms, 
                     duration: 600.ms, 
                     begin: const Offset(1, 1), 
                     end: const Offset(1.4, 1.4)
                   )
                   .then()
                   .scale(duration: 600.ms);
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
