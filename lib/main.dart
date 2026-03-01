import 'package:flutter/material.dart';
import 'dart:async';
import 'layout/main_wrapper.dart'; // পাথটি ঠিক আছে কিনা দেখে নিন

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
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

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _appearanceAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutCubic),
      ),
    );

    _loadAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.6, 1.0, curve: Curves.linear),
    );

    _controller.forward();

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
                const Spacer(flex: 4), // লোগোকে একটু নিচের দিকে নামানোর জন্য
                
                // লোগো এবং টেক্সট সেকশন
                Transform.scale(
                  scale: 0.95 + (0.05 * _appearanceAnimation.value),
                  child: Column(
                    children: [
                      // ১. লোগো সাইজ বড় (মোটা) করা হয়েছে
                      Image.asset(
                        "assets/ultra5G.png",
                        width: 210, // ২১০ করা হয়েছে যাতে মোটা দেখায়
                      ),
                      
                      // ২. লোগো ও টেক্সটের মাঝখানের দূরত্ব কমানো হয়েছে
                      const SizedBox(height: 4), 
                      
                      // ৩. টেক্সট সাদা কালার এবং সাইজ ছোট করা হয়েছে
                      const Text(
                        "Easy Service",
                        style: TextStyle(
                          fontSize: 28, // ৪২ থেকে কমিয়ে ২৮ করা হয়েছে
                          fontWeight: FontWeight.w700,
                          color: Colors.white, // হলুদ থেকে সাদা করা হয়েছে
                          letterSpacing: 1.2,
                          shadows: [
                            Shadow(
                              color: Colors.black12,
                              offset: Offset(0, 2),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(flex: 3),

                // ফেসবুক স্টাইল ডট লোডিং
                FadeTransition(
                  opacity: _loadAnimation,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 60.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(4, (index) => _buildLoadingDot(delay: index * 0.15)),
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

  Widget _buildLoadingDot({required double delay}) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        double scale = 1.0;
        double opacity = 0.3;
        
        if (_controller.value > (0.6 + delay) && _controller.value < (0.9 + delay)) {
          double progress = (_controller.value - (0.6 + delay)) / 0.3;
          scale = 1.0 + 0.25 * (progress < 0.5 ? progress * 2 : (1 - progress) * 2);
          opacity = 0.3 + 0.7 * (progress < 0.5 ? progress * 2 : (1 - progress) * 2);
        }

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 5),
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(opacity),
          ),
          transform: Matrix4.identity()..scale(scale),
        );
      },
    );
  }
}
