import 'package:flutter/material.dart';

/// Service model
class Service {
  final String name;
  final IconData icon;
  final Color color;

  const Service({
    required this.name,
    required this.icon,
    required this.color,
  });
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // Theme colors (easy to change later)
  static const Color kPrimary = Color(0xFF0284C7);
  static const Color kAccent = Color(0xFF38BDF8);
  static const Color kBackground = Color(0xFFF0F7FF);
  static const Color kTextDark = Color(0xFF0F172A);

  // All services in one place
  static const List<Service> _services = [
    Service(name: 'Ride', icon: Icons.drive_eta, color: Colors.blue),
    Service(name: 'Food', icon: Icons.fastfood, color: Colors.orange),
    Service(name: 'Mart', icon: Icons.shopping_bag, color: Colors.green),
    Service(name: 'Courier', icon: Icons.local_shipping, color: Colors.purple),
    Service(name: 'Pay', icon: Icons.account_balance_wallet, color: Colors.teal),
    Service(name: 'Health', icon: Icons.medical_services, color: Colors.red),
    Service(name: 'Tickets', icon: Icons.confirmation_number, color: Colors.indigo),
    Service(name: 'More', icon: Icons.grid_view_rounded, color: Colors.blueGrey),
  ];

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;

    return Scaffold(
      backgroundColor: kBackground,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSearchBar(),
                  const SizedBox(height: 25),
                  _buildPromoBanner(context),
                  const SizedBox(height: 30),
                  const Text(
                    'Our Services',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: kTextDark,
                    ),
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

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      floating: true,
      backgroundColor: kBackground,
      elevation: 0,
      title: const Text(
        'Vexylon Super App',
        style: TextStyle(color: kPrimary, fontWeight: FontWeight.bold),
      ),
      actions: [
        IconButton(
          onPressed: () => _showSnack(context, 'No new notifications 🎉'),
          icon: const Icon(Icons.notifications_active_outlined, color: kPrimary),
        ),
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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: const TextField(
        decoration: InputDecoration(
          icon: Icon(Icons.search, color: kPrimary),
          hintText: "Search services...",
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildPromoBanner(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 160,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [kPrimary, kAccent],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            bottom: -20,
            child: Icon(
              Icons.bolt,
              size: 150,
              color: Colors.white.withOpacity(0.2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(25),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Summer Sale!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  'Get up to 40% cashback',
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 15),
                ElevatedButton(
                  onPressed: () => _showSnack(context, 'Summer Sale activated! 🎉'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: kPrimary,
                    elevation: 0,
                  ),
                  child: const Text('Get Now'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesGrid(bool isTablet) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isTablet ? 6 : 4,
        mainAxisSpacing: 20,
        crossAxisSpacing: 15,
        childAspectRatio: 0.85,
      ),
      itemCount: _services.length,
      itemBuilder: (context, index) => _ServiceCard(service: _services[index]),
    );
  }

  void _showSnack(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 1)),
    );
  }
}

/// Reusable service card with ripple effect
class _ServiceCard extends StatelessWidget {
  final Service service;

  const _ServiceCard({required this.service, super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${service.name} service coming soon 🚀'),
            duration: const Duration(seconds: 1),
          ),
        );
        // TODO: Replace with Navigator.pushNamed('/ride') etc.
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.blueGrey.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              service.icon,
              color: service.color,
              size: 32,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            service.name,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: HomeScreen.kTextDark,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
