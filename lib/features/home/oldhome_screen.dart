import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

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

/// Riverpod Provider (পরে Dio দিয়ে API থেকে ডেটা আনলে এখানে যুক্ত করতে পারবেন)
final servicesProvider = Provider<List<Service>>((ref) {
  return const [
    Service(name: 'Recharge', icon: Icons.phone_iphone, color: Color(0xFF6366F1)),
    Service(name: 'Drive Offer', icon: Icons.directions_car_filled, color: Color(0xFF0284C7)),
    Service(name: 'Reselling', icon: Icons.storefront_outlined, color: Color(0xFFEA580C)),
    Service(name: 'Microjob', icon: Icons.work_outline, color: Color(0xFF14B8A6)),
    Service(name: 'Loan', icon: Icons.payments_outlined, color: Color(0xFF22C55E)),
    Service(name: 'Campaign', icon: Icons.campaign_outlined, color: Color(0xFF8B5CF6)),
    Service(name: 'Education', icon: Icons.school_outlined, color: Color(0xFFF59E0B)),
    Service(name: 'Easy Bus', icon: Icons.directions_bus_filled, color: Color(0xFF3B82F6)),
    Service(name: 'Courier', icon: Icons.local_shipping_outlined, color: Color(0xFFF97316)),
    Service(name: 'Agro', icon: Icons.agriculture, color: Color(0xFF4ADE80)),
    Service(name: 'Used Item', icon: Icons.inventory_2_outlined, color: Color(0xFF78716C)),
  ];
});

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  // Theme Colors
  static const Color kPrimary = Color(0xFF0284C7);
  static const Color kAccent = Color(0xFF38BDF8);
  static const Color kBackground = Color(0xFFF0F7FF);
  static const Color kTextDark = Color(0xFF0F172A);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final services = ref.watch(servicesProvider);

    return Scaffold(
      backgroundColor: kBackground,
      // অ্যাপবার ডিলিট করা হয়েছে। শুধু বডি রাখা হলো।
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 20.w, // রেস্পনসিভ প্যাডিং
                  vertical: 24.h,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildPromoBanner(context),
                    SizedBox(height: 32.h),
                    Text(
                      'Our Services',
                      style: GoogleFonts.poppins(
                        fontSize: 20.sp, // রেস্পনসিভ ফন্ট
                        fontWeight: FontWeight.bold,
                        color: kTextDark,
                      ),
                    ).animate().fadeIn(duration: 500.ms).slideX(), // টেক্সট অ্যানিমেশন
                    SizedBox(height: 20.h),
                    _buildCategoriesGrid(services),
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
      height: 150.h,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [kPrimary, kAccent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22.r),
        boxShadow: [
          BoxShadow(
            color: kPrimary.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -30.w,
            bottom: -30.h,
            child: Icon(
              Icons.bolt,
              size: 160.sp,
              color: Colors.white.withOpacity(0.15),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(24.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Summer Sale!',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  'Get up to 40% cashback',
                  style: GoogleFonts.poppins(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14.sp,
                  ),
                ),
              ],
            ),
          ),
        ],
      ).animate().fadeIn(duration: 600.ms).scale(begin: const Offset(0.95, 0.95)),
    );
  }

  Widget _buildCategoriesGrid(List<Service> services) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 90.w, // বক্সের সাইজ বেশ ছোট করা হয়েছে
        mainAxisSpacing: 20.h,
        crossAxisSpacing: 16.w,
        childAspectRatio: 0.75, // আইকন এবং টেক্সট সুন্দরভাবে বসার জন্য রেশিও
      ),
      itemCount: services.length,
      itemBuilder: (context, index) {
        return _ServiceCard(service: services[index])
            .animate()
            .fade(duration: 400.ms, delay: (index * 40).ms)
            .scale(begin: const Offset(0.8, 0.8), curve: Curves.easeOutBack); // কিউট বাউন্স অ্যানিমেশন
      },
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final Service service;

  const _ServiceCard({required this.service});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // GoRouter নেভিগেশন এখানে দিতে পারবেন
      },
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16.w), // ছোট প্যাডিং
            decoration: BoxDecoration(
              // ম্যাজিক এখানে: আইকনের নিজস্ব কালারের ১০% অপাসিটি ব্যাকগ্রাউন্ড হিসেবে কাজ করবে!
              color: service.color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20.r), // গোলগাল সুন্দর শেপ
              border: Border.all(
                color: service.color.withOpacity(0.05), // হালকা বর্ডার 
                width: 1,
              ),
            ),
            child: Icon(
              service.icon,
              color: service.color,
              size: 28.sp, // আইকনের সাইজ ছোট ও কিউট
            ),
          ),
          SizedBox(height: 10.h),
          Text(
            service.name,
            style: GoogleFonts.poppins(
              fontSize: 11.sp, // টেক্সট সাইজ রেস্পনসিভ ও ছোট
              fontWeight: FontWeight.w600,
              color: HomeScreen.kTextDark,
              height: 1.2,
            ),
            textAlign: TextAlign.center,
            maxLines: 2, // ২ লাইনের বেশি হলে ডট ডট আসবে
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
