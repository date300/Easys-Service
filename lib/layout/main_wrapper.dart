import 'package:flutter/material.dart';

import '../features/home/home_screen.dart';
import '../features/feed/feed_screen.dart';
import '../features/profile/profile_screen.dart';

class MainWrapper extends StatefulWidget {
  const MainWrapper({super.key});

  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    HomeScreen(),
    FeedScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // স্ক্যাফোল্ডের ব্যাকগ্রাউন্ড আকাশি রাখলাম যাতে gap না দেখায়
      backgroundColor: const Color(0xFF29B6F6),

      // আকাশি AppBar (আগের মতোই)
      appBar: AppBar(
        backgroundColor: const Color(0xFF29B6F6),
        foregroundColor: Colors.white,
        elevation: 0,                    // shadow কমিয়ে সুন্দর লাগবে
        title: const Text(
          'Life Good',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        leading: IconButton(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Drawer খুলবে')),
            );
          },
          icon: const Icon(Icons.menu),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_outlined),
          ),
        ],
      ),

      // 🌟 এখানেই ম্যাজিক! কুনা বাঁকানো white body
      body: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
        child: Container(
          color: Colors.white,
          child: IndexedStack(
            index: _currentIndex,
            children: _pages,
          ),
        ),
      ),

      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.explore_outlined),
            selectedIcon: Icon(Icons.explore),
            label: 'Feed',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
