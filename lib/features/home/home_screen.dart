import 'package:flutter/material.dart';

/// Service Model
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

  // Theme Colors
  static const Color kPrimary = Color(0xFF0284C7);
  static const Color kAccent = Color(0xFF38BDF8);
  static const Color kBackground = Color(0xFFF0F7FF);
  static const Color kTextDark = Color(0xFF0F172A);
  static const Color kSkyBlue = Color(0xFFBAE6FD);   // ← আকাশী রঙ (এটাই বক্সের জন্য)

  // নতুন ১১টা সার্ভিস + iOS স্টাইল আইকন
  static const List<Service> _services = [
    Service(name: 'Mobile Recharge', icon: Icons.phone_iphone, color: Color(0xFF6366F1)),
    Service(name: 'Drive Offers', icon: Icons.directions_car_filled, color: Color(0xFF0284C7)),
    Service(name: 'Reselling', icon: Icons.storefront_outlined, color: Color(0xFFEA580C)),
    Service(name: 'Microjobs', icon: Icons.work_outline, color: Color(0xFF14B8A6)),
    Service(name: 'Loan Services', icon: Icons.payments_outlined, color: Color(0xFF22C55E)),
    Service(name: 'Campaigns', icon: Icons.campaign_outlined, color: Color(0xFF8B5CF6)),
    Service(name: 'Education Support', icon: Icons.school_outlined, color: Color(0xFFF59E0B)),
    Service(name: 'Easy Bus', icon: Icons.directions_bus_filled, color: Color(0xFF3B82F6)),
    Service(name: 'Easy Courier', icon: Icons.local_shipping_outlined, color: Color(0xFFF97316)),
    Service(name: 'Agro Projects', icon: Icons.agriculture, color: Color(0xFF4ADE80)),
    Service(name: 'Used Products', icon: Icons.inventory_2_outlined, color: Color(0xFF78716C)),
  ];

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;

    return Scaffold(
      backgroundColor: kBackground,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isTablet ? 30 : 20,
                  vertical: 24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildPromoBanner(context),
                    const SizedBox(height: 40),
                    const Text(
                      'Our Services',
                      style: TextStyle(
                        fontSize: 23,
                        fontWeight: FontWeight.bold,
                        color: kTextDark,
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildCategoriesGrid(isTablet),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPromoBanner(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 172,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [kPrimary, kAccent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(26),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -45,
            bottom: -45,
            child: Icon(Icons.bolt, size: 190, color: Colors.white.withOpacity(0.16)),
          ),
          const Padding(
            padding: EdgeInsets.all(28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Summer Sale!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 27,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Get up to 40% cashback',
                  style: TextStyle(color: Colors.white70, fontSize: 16.5),
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
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 130,        // এটা দিয়ে সব ডিভাইসে অটো রেস্পনসিভ
        mainAxisSpacing: 28,
        crossAxisSpacing: 22,
        childAspectRatio: 0.80,
      ),
      itemCount: _services.length,
      itemBuilder: (context, index) => _ServiceCard(service: _services[index]),
    );
  }
}

/// iOS স্টাইলের আকাশী বক্স সহ সার্ভিস কার্ড
class _ServiceCard extends StatelessWidget {
  final Service service;

  const _ServiceCard({required this.service, super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${service.name} আসছে শীঘ্রই 🚀'),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 1),
          ),
        );
      },
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: HomeScreen.kSkyBlue,     // ← আকাশী রঙ
              borderRadius: BorderRadius.circular(26),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Icon(
              service.icon,
              color: service.color,
              size: 42,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            service.name,
            style: const TextStyle(
              fontSize: 13.8,
              fontWeight: FontWeight.w600,
              color: HomeScreen.kTextDark,
              height: 1.3,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
