import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ১. GoRouter কনফিগারেশন (Navigation System)
final _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/main',
      builder: (context, state) => const MainWrapper(), // আপনার মেইন স্ক্রিন
    ),
  ],
);

void main() async {
  // ২. হোয়াইট স্ক্রিন ইস্যু ফিক্স করার জন্য বাইন্ডিং এনসিওর করা
  WidgetsFlutterBinding.ensureInitialized();
  
  // ৩. শেয়ারড প্রেফারেন্স এবং অন্যান্য প্লাগইন লোড হতে সময় দিলে এই ওয়েট টুকু দরকার
  await SharedPreferences.getInstance();

  runApp(
    // ৪. Riverpod ব্যবহারের জন্য ProviderScope দিয়ে র‍্যাপ করা
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // ৫. ScreenUtilInit দিয়ে রেসপন্সিভ ডিজাইন সেটআপ
    return ScreenUtilInit(
      designSize: const Size(360, 800), // স্ট্যান্ডার্ড ডিজাইন সাইজ
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
            // ৬. Google Fonts সেটআপ
            textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme),
          ),
        );
      },
    );
  }
}

// --- SplashScreen Section ---
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
    // এখানে চাইলে Dio দিয়ে ডাটা ফেচিং বা Prefs চেক করতে পারেন
    await Future.delayed(const Duration(milliseconds: 3000));
    if (mounted) {
      context.go('/main'); // GoRouter দিয়ে পরের পেজে যাওয়া
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

            // লোগো অ্যানিমেশন (Flutter Animate ব্যবহার করা হয়েছে)
            Image.asset(
              "assets/ultra5G.png",
              width: 200.w,
            ).animate()
             .fade(duration: 600.ms)
             .scale(delay: 200.ms, curve: Curves.backOut),

            SizedBox(height: 12.h),

            // টেক্সট অ্যানিমেশন
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

            // ফেসবুক স্টাইল লোডিং ডটস (Flutter Animate দিয়ে সিম্পল করা হয়েছে)
            Padding(
              padding: EdgeInsets.bottom(60.h),
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

// --- MainWrapper (এটি আপনার অ্যাপের মূল লেআউট হবে) ---
class MainWrapper extends StatelessWidget {
  const MainWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Easy Service Home")),
      body: const Center(
        child: Text("Welcome to Main Screen!"),
      ),
    );
  }
}
