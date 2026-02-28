import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F7FF),
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSearchBar(),
                  const SizedBox(height: 25),
                  _buildPromoBanner(),
                  const SizedBox(height: 30),
                  const Text(
                    'Our Services',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                  ),
                  const SizedBox(height: 15),
                  _buildCategoriesGrid(isTablet),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      floating: true,
      backgroundColor: const Color(0xFFF0F7FF),
      elevation: 0,
      title: const Text('Vexylon Super App', style: TextStyle(color: Color(0xFF0284C7), fontWeight: FontWeight.bold)),
      actions: [
        IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_active_outlined, color: Color(0xFF0284C7))),
        const SizedBox(width: 10),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: const TextField(
        decoration: InputDecoration(
          icon: Icon(Icons.search, color: Color(0xFF0284C7)),
          hintText: "Search services...",
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildPromoBanner() {
    return Container(
      width: double.infinity,
      height: 160,
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF0284C7), Color(0xFF38BDF8)]),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        children: [
          Positioned(right: -20, bottom: -20, child: Icon(Icons.bolt, size: 150, color: Colors.white.withOpacity(0.2))),
          Padding(
            padding: const EdgeInsets.all(25),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Summer Sale!', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                const Text('Get up to 40% cashback', style: TextStyle(color: Colors.white70)),
                const SizedBox(height: 15),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: const Color(0xFF0284C7)),
                  child: const Text('Get Now'),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildCategoriesGrid(bool isTablet) {
    final List<Map<String, dynamic>> items = [
      {'n': 'Ride', 'i': Icons.drive_eta, 'c': Colors.blue},
      {'n': 'Food', 'i': Icons.fastfood, 'c': Colors.orange},
      {'n': 'Mart', 'i': Icons.shopping_bag, 'c': Colors.green},
      {'n': 'Courier', 'i': Icons.local_shipping, 'c': Colors.purple},
      {'n': 'Pay', 'i': Icons.account_balance_wallet, 'c': Colors.teal},
      {'n': 'Health', 'i': Icons.medical_services, 'c': Colors.red},
      {'n': 'Tickets', 'i': Icons.confirmation_number, 'c': Colors.indigo},
      {'n': 'More', 'i': Icons.grid_view_rounded, 'c': Colors.blueGrey},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isTablet ? 6 : 4,
        mainAxisSpacing: 20,
        crossAxisSpacing: 15,
        childAspectRatio: 0.8,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        return Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18),
                  boxShadow: [BoxShadow(color: Colors.blueGrey.withOpacity(0.1), blurRadius: 10)]),
              child: Icon(items[index]['i'], color: items[index]['c'], size: 28),
            ),
            const SizedBox(height: 8),
            Text(items[index]['n'], style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
          ],
        );
      },
    );
  }
}
