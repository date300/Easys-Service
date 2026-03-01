import 'package:flutter/material.dart';
import 'dart:async';
import 'layout/main_wrapper.dart'; // নিশ্চিত করুন এই পাথটি ঠিক আছে

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        // Material 3 এর সাথে হালকা নীল থিম
        colorSchemeSeed: const Color(0xFF0284C7),
      ),
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _appearanceAnimation;
  late Animation<double> _loadAnimation;

  @override
  void initState() {
    super.initState();

    // মোট এনিমেশন কন্ট্রোলার (লোগো, টেক্সট এবং লোডিং সবার জন্য)
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000), // একটু বেশি সময় ধরে এনিমেশন
    );

    // লোগো এবং টেক্সট একসাথে স্ক্রিনে আসার জন্য
    _appearanceAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutCubic),
      ),
    );

    // নিচের লোডিং ডটগুলোর এনিমেশন
    _loadAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.6, 1.0, curve: Curves.linear),
    );

    _controller.forward(); // এনিমেশন শুরু করুন

    // ২.৫ সেকেন্ড পর MainWrapper এ নেভিগেশন
    Timer(const Duration(milliseconds: 2500), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 700),
            pageBuilder: (context, animation, secondaryAnimation) =>
                const MainWrapper(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // আপনার চাওয়া অনুযায়ী সলিড আকাশী কালার ব্যাকগ্রাউন্ড
      backgroundColor: const Color(0xFF0EA5E9),

      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Center(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Opacity(
                opacity: _appearanceAnimation.value,
                child: child,
              );
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // ১. লোগো এবং ২. টেক্সট একসাথে অ্যানিমেট হবে
                Transform.scale(
                  scale: 0.95 + (0.05 * _appearanceAnimation.value),
                  child: Column(
                    children: [
                      // ৩. লোগো আরও মোটা এবং আকর্ষণীয়, কোনো সাদা শ্যাডো নেই
                      Container(
                        child: Image.asset(
                          "assets/ultra5G.png", // লোগোর ফাইল পাথ
                          width: 170, // সাইজ কিছুটা বাড়ানো হয়েছে
                          // এটার সাথে লোগো মোটা করার জন্য শ্যাডো বাদ দেওয়া হয়েছে
                        ),
                      ),
                      
                      // লোগো এবং টেক্সটের মধ্যে দূরত্ব কমিয়ে দেওয়া হয়েছে
                      const SizedBox(height: 12),

                      // ৪. Easy Service টেক্সট আকর্ষণীয় ডিজাইন (গোল্ডেন কালার)
                      const Text(
                        "Easy Service",
                        style: TextStyle(
                          fontSize: 42,
                          fontWeight: FontWeight.w800, // আরও বোল্ড
                          letterSpacing: 1.5,
                          // গোল্ডেন গ্রেডিয়েন্ট এবং শ্যাডো দিয়ে আকর্ষণীয় লুক
                          foreground: Paint()
                            ..shader = const LinearGradient(
                              colors: [
                                Color(0xFFFFD700), // উজ্জ্বল গোল্ড
                                Color(0xFFFFB900), // গাঢ় গোল্ড
                                Color(0xFFFFD700), // উজ্জ্বল গোল্ড
                              ],
                              stops: [0.0, 0.5, 1.0],
                            ).createShader(
                                const Rect.fromLTWH(0.0, 0.0, 300.0, 70.0)),
                          shadows: [
                            Shadow(
                              color: Colors.black38,
                              offset: Offset(1, 2),
                              blurRadius: 4,
                            ),
                            Shadow(
                              color: Color(0xFFFFB900).withOpacity(0.5),
                              blurRadius: 15, // হালকা একটা গোল্ডেন গ্লো
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // ৫. নিচের দিকে ফেসবুকের মতো লোডিং সিস্টেম (ডট এনিমেশন)
                const Spacer(), // লোগো এবং লোডিংয়ের মাঝখানে গ্যাপ

                // লোডিং ইন্ডিকেটর যা অ্যাপে প্রবেশের অনুভূতি দেয়
                FadeTransition(
                  opacity: _loadAnimation,
                  child: Transform.translate(
                    offset: Offset(0, 50 - (50 * _loadAnimation.value)),
                    child: Padding(
                      padding: const Padding(bottom: 50.0), // নিচে থেকে দূরত্ব
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildLoadingDot(delay: 0.0),
                          _buildLoadingDot(delay: 0.2),
                          _buildLoadingDot(delay: 0.4),
                          _buildLoadingDot(delay: 0.6),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // লোডিং ডট তৈরি করার ফাংশন
  Widget _buildLoadingDot({required double delay}) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        double scale = 1.0;
        double opacity = 0.5;
        
        // ডটগুলোর পর্যায়ক্রমিক এনিমেশন
        if (_controller.value > (0.6 + delay) && _controller.value < (0.9 + delay)) {
          double progress = (_controller.value - (0.6 + delay)) / 0.3;
          // সাইজ এবং অপাসিটি বাড়ানো
          scale = 1.0 + 0.3 * (progress < 0.5 ? progress * 2 : (1 - progress) * 2);
          opacity = 0.5 + 0.5 * (progress < 0.5 ? progress * 2 : (1 - progress) * 2);
        }

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 5),
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(opacity),
            // ডটের চারপাশে হালকা গ্লো
            boxShadow: [
              if (opacity > 0.8)
                BoxShadow(
                  color: Colors.white.withOpacity(0.4),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
            ],
          ),
          transform: Matrix4.identity()..scale(scale),
        );
      },
    );
  }
}
