import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:lottie/lottie.dart';
import 'package:go_router/go_router.dart';

/// 1. Router Setup (GoRouter)
final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const HomeScreen(),
      ),
    ],
  );
});

void main() {
  runApp(
    // Riverpod ProviderScope
    const ProviderScope(child: MyApp()),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(goRouterProvider);

    // ScreenUtil Setup for Responsiveness
    return ScreenUtilInit(
      designSize: const Size(375, 812), // Standard iPhone X design size
      minTextAdapt: true,
      builder: (context, child) {
        return MaterialApp.router(
          debugShowCheckedModeBanner: false,
          routerConfig: router,
          theme: ThemeData(
            textTheme: GoogleFonts.poppinsTextTheme(), // Google Fonts Applied globally
          ),
        );
      },
    );
  }
}

/// Service Model
class Service {
  final String name;
  final IconData icon;
  final Color color;

  const Service({required this.name, required this.icon, required this.color});
}

/// 2. Riverpod Provider for Services (Here you can later use Dio to fetch from API)
final servicesProvider = Provider<List<Service>>((ref) {
  return const [
    Service(name: 'Recharge', icon: Icons.phone_iphone, color: Color(0xFF6366F1)),
    Service(name: 'Offers', icon: Icons.directions_car_filled, color: Color(0xFF0284C7)),
    Service(name: 'Resell', icon: Icons.storefront_outlined, color: Color(0xFFEA580C)),
    Service(name: 'Jobs', icon: Icons.work_outline, color: Color(0xFF14B8A6)),
    Service(name: 'Loan', icon: Icons.payments_outlined, color: Color(0xFF22C55E)),
    Service(name: 'Campaign', icon: Icons.campaign_outlined, color: Color(0xFF8B5CF6)),
    Service(name: 'Education', icon: Icons.school_outlined, color: Color(0xFFF59E0B)),
    Service(name: 'Bus', icon: Icons.directions_bus_filled, color: Color(0xFF3B82F6)),
    Service(name: 'Courier', icon: Icons.local_shipping_outlined, color: Color(0xFFF97316)),
    Service(name: 'Agro', icon: Icons.agriculture, color: Color(0xFF4ADE80)),
    Service(name: 'Used', icon: Icons.inventory_2_outlined, color: Color(0xFF78716C)),
  ];
});

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  static const Color kPrimary = Color(0xFF0284C7);
  static const Color kAccent = Color(0xFF38BDF8);
  static const Color kBackground = Color(0xFFF8FAFC);
  static const Color kTextDark = Color(0xFF0F172A);
  static const Color kSkyBlue = Color(0xFFE0F2FE);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final services = ref.watch(servicesProvider);

    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppBar(
        backgroundColor: kBackground,
        elevation: 0,
        title: Text(
          'Hello, User 👋',
          style: GoogleFonts.poppins(
            color: kTextDark,
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          // Cached Network Image for Profile Picture
          Padding(
            padding: EdgeInsets.only(right: 16.w),
            child: CircleAvatar(
              radius: 18.r,
              backgroundImage: const CachedNetworkImageProvider(
                'https://i.pravatar.cc/150?img=11', // Dummy Avatar
              ),
            ),
          )
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPromoBanner(context),
                  SizedBox(height: 24.h),
                  Text(
                    'Our Services',
                    style: GoogleFonts.poppins(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w700,
                      color: kTextDark,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  _buildCategoriesGrid(services),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPromoBanner(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 140.h,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [kPrimary, kAccent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Stack(
        children: [
          // Lottie Animation inside the banner
          Positioned(
            right: -20.w,
            bottom: -20.h,
            child: Lottie.network(
              'https://assets9.lottiefiles.com/packages/lf20_1y25qm1h.json', // Example Lottie url
              width: 150.w,
              height: 150.h,
              errorBuilder: (context, error, stackTrace) => 
                  Icon(Icons.bolt, size: 100.w, color: Colors.white24),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Summer Sale!',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 22.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  'Up to 40% cashback',
                  style: GoogleFonts.poppins(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 13.sp,
                  ),
                ),
              ],
            ),
          ),
        ],
      ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.2, end: 0),
    );
  }

  Widget _buildCategoriesGrid(List<Service> services) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 100.w, // Box size reduced using ScreenUtil
        mainAxisSpacing: 16.h,
        crossAxisSpacing: 16.w,
        childAspectRatio: 0.85, // Adjusted for smaller boxes
      ),
      itemCount: services.length,
      itemBuilder: (context, index) {
        return _ServiceCard(service: services[index])
            // Flutter Animate: Staggered animation for grid items
            .animate()
            .fade(delay: (index * 50).ms)
            .scale(delay: (index * 50).ms);
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
        // GoRouter or Dio action can be added here
      },
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16.w), // Smaller padding
            decoration: BoxDecoration(
              color: HomeScreen.kSkyBlue,
              borderRadius: BorderRadius.circular(20.r), // Responsive radius
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              service.icon,
              color: service.color,
              size: 28.sp, // Smaller Icon
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            service.name,
            style: GoogleFonts.poppins(
              fontSize: 11.sp, // Smaller text
              fontWeight: FontWeight.w600,
              color: HomeScreen.kTextDark,
              height: 1.2,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
