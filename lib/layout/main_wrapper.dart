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
      // 🌟 আকাশি কালারের AppBar (Life Good অ্যাপের স্টাইলে)
      appBar: AppBar(
        backgroundColor: const Color(0xFF29B6F6), // আকাশি রং (sky blue)
        foregroundColor: Colors.white,
        elevation: 2,
        title: const Text(
          'Life Good',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        leading: IconButton(
          onPressed: () {
            // এখানে Drawer খুলবে (পরে যোগ করবো চাইলে)
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Drawer খুলবে')),
            );
          },
          icon: const Icon(Icons.menu),
        ),
        actions: [
          IconButton(
            onPressed: () {
              // নোটিফিকেশন স্ক্রিনে যাবে
            },
            icon: const Icon(Icons.notifications_outlined),
          ),
        ],
      ),

      // পেজগুলো মেমরিতে থাকবে
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
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
