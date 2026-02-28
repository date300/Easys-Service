import 'package:flutter/material.dart';
import 'layout/main_wrapper.dart';
import 'screens/splash_screen.dart';   // ← এটা যোগ করো

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
      home: const SplashScreen(),   // ← এটা চেঞ্জ করো
    );
  }
}
