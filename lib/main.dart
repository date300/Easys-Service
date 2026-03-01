import 'package:flutter/material.dart';
import 'dart:async';
import 'layout/main_wrapper.dart'; // পাথ সঠিক আছে কিনা নিশ্চিত হয়ে নিন

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
                const Spacer(flex: 3),
                
                // লোগো এবং টেক্সট সেকশন
                Transform.scale(
                  scale: 0.95 + (0.05 * _appearanceAnimation.value),
                  child: Column(
                    children: [
                      Image.asset(
                        "assets/ultra5G.png",
                        width: 170, // আপনার চাহিদা মতো বড় সাইজ
                      ),
                      const SizedBox(height: 12), // লোগো ও টেক্সটের মাঝে কম দূরত্ব
                      
                      Text(
                        "Easy Service",
                        style: TextStyle(
                          fontSize: 42,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.5,
                          foreground: Paint()
                            ..shader = const LinearGradient(
                              colors: [
                                Color(0xFFFFD700),
                                Color(0xFFFFB900),
                                Color(0xFFFFD700),
                              ],
                            ).createShader(const Rect.fromLTWH(0.0, 0.0, 300.0, 70.0)),
                          shadows: [
                            const Shadow(
                              color: Colors.black38,
                              offset: Offset(1, 2),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(flex: 2),

                // ফেসবুক স্টাইল ডট লোডিং সিস্টেম
                FadeTransition(
                  opacity: _loadAnimation,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 60.0), // সংশোধিত প্যাডিং
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
        
        // ডট এনিমেশন লজিক
        if (_controller.value > (0.6 + delay) && _controller.value < (0.9 + delay)) {
          double progress = (_controller.value - (0.6 + delay)) / 0.3;
          scale = 1.0 + 0.3 * (progress < 0.5 ? progress * 2 : (1 - progress) * 2);
          opacity = 0.3 + 0.7 * (progress < 0.5 ? progress * 2 : (1 - progress) * 2);
        }

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 5),
          width: 12,
          height: 12,
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
