import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'layout/main_wrapper.dart';

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
      home: const SplashOrWrapper(),
    );
  }
}

// Decide whether to show SplashScreen or directly MainWrapper
class SplashOrWrapper extends StatelessWidget {
  const SplashOrWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return const SplashScreen(
      nextScreen: MainWrapper(),
    );
  }
}
