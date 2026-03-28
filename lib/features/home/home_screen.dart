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
  final Color secondaryColor;

  const Service({
    required this.name,
    required this.icon,
    required this.color,
    required this.secondaryColor,
  });
}

/// Riverpod Provider
final servicesProvider = Provider<List<Service>>((ref) {
  return const [
    Service(
      name: 'Recharge',
      icon: Icons.sim_card_outlined,
      color: Color(0xFF6366F1),
      secondaryColor: Color(0xFF818CF8),
    ),
    Service(
      name: 'Drive Offer',
      icon: Icons.local_taxi_outlined,
      color: Color(0xFF0284C7),
      secondaryColor: Color(0xFF38BDF8),
    ),
    Service(
      name: 'Reselling',
      icon: Icons.store_outlined,
      color: Color(0xFFEA580C),
      secondaryColor: Color(0xFFFB923C),
    ),
    Service(
      name: 'Microjob',
      icon: Icons.handyman_outlined,
      color: Color(0xFF0D9488),
      secondaryColor: Color(0xFF2DD4BF),
    ),
    Service(
      name: 'Loan',
      icon: Icons.account_balance_outlined,
      color: Color(0xFF16A34A),
      secondaryColor: Color(0xFF4ADE80),
    ),
    Service(
      name: 'Campaign',
      icon: Icons.campaign_outlined,
      color: Color(0xFF7C3AED),
      secondaryColor: Color(0xFFA78BFA),
    ),
    Service(
      name: 'Education',
      icon: Icons.menu_book_outlined,
      color: Color(0xFFD97706),
      secondaryColor: Color(0xFFFBBF24),
    ),
    Service(
      name: 'Easy Bus',
      icon: Icons.airport_shuttle_outlined,
      color: Color(0xFF2563EB),
      secondaryColor: Color(0xFF60A5FA),
    ),
    Service(
      name: 'Courier',
      icon: Icons.local_shipping_outlined,
      color: Color(0xFFEA580C),
      secondaryColor: Color(0xFFFB923C),
    ),
    Service(
      name: 'Agro',
      icon: Icons.grass_outlined,
      color: Color(0xFF15803D),
      secondaryColor: Color(0xFF86EFAC),
    ),
    Service(
      name: 'Used Item',
      icon: Icons.autorenew_outlined,
      color: Color(0xFF78716C),
      secondaryColor: Color(0xFFD6D3D1),
    ),
  ];
});

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  static const Color kPrimary = Color(0xFF0284C7);
  static const Color kAccent = Color(0xFF38BDF8);
  static const Color kBackground = Color(0xFFF0F9FF);
  static const Color kTextDark = Color(0xFF0F172A);
  static const Color kTextMid = Color(0xFF475569);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final services = ref.watch(servicesProvider);
    final screenWidth = MediaQuery.of(context).size.width;

    // Responsive breakpoints
    final isDesktop = screenWidth >= 1024;
    final isTablet = screenWidth >= 600 && screenWidth < 1024;

    return Scaffold(
      backgroundColor: kBackground,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: isDesktop ? 1200 : double.infinity,
            ),
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isDesktop ? 48 : isTablet ? 32 : 20.w,
                      vertical: isDesktop ? 40 : 24.h,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionHeader(context, isDesktop),
                        SizedBox(height: isDesktop ? 28 : 20.h),
                        _buildCategoriesGrid(
                          services,
                          isDesktop: isDesktop,
                          isTablet: isTablet,
                          screenWidth: screenWidth,
                        ),
                        SizedBox(height: 40.h),
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

  Widget _buildSectionHeader(BuildContext context, bool isDesktop) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Our Services',
              style: GoogleFonts.poppins(
                fontSize: isDesktop ? 24 : 20.sp,
                fontWeight: FontWeight.bold,
                color: kTextDark,
              ),
            ),
            Text(
              'Explore all available services',
              style: GoogleFonts.poppins(
                fontSize: isDesktop ? 13 : 12.sp,
                color: kTextMid,
              ),
            ),
          ],
        ),
        Text(
          'See All →',
          style: GoogleFonts.poppins(
            fontSize: isDesktop ? 13 : 12.sp,
            color: kPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    ).animate().fadeIn(duration: 500.ms).slideX();
  }

  Widget _buildCategoriesGrid(
    List<Service> services, {
    required bool isDesktop,
    required bool isTablet,
    required double screenWidth,
  }) {
    // Responsive column count
    int crossAxisCount;
    if (screenWidth >= 1200) {
      crossAxisCount = 6;
    } else if (screenWidth >= 900) {
      crossAxisCount = 5;
    } else if (screenWidth >= 600) {
      crossAxisCount = 4;
    } else if (screenWidth >= 400) {
      crossAxisCount = 4;
    } else {
      crossAxisCount = 3;
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: isDesktop ? 24 : 18.h,
        crossAxisSpacing: isDesktop ? 20 : 14.w,
        childAspectRatio: 0.8,
      ),
      itemCount: services.length,
      itemBuilder: (context, index) {
        return _ServiceCard(
          service: services[index],
          isDesktop: isDesktop,
        )
            .animate()
            .fade(duration: 400.ms, delay: (index * 50).ms)
            .scale(
              begin: const Offset(0.75, 0.75),
              curve: Curves.easeOutBack,
            );
      },
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final Service service;
  final bool isDesktop;

  const _ServiceCard({required this.service, this.isDesktop = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // GoRouter navigation
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(isDesktop ? 18 : 14.w),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  service.color.withOpacity(0.15),
                  service.secondaryColor.withOpacity(0.08),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(isDesktop ? 22 : 20.r),
              border: Border.all(
                color: service.color.withOpacity(0.18),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: service.color.withOpacity(0.12),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              service.icon,
              color: service.color,
              size: isDesktop ? 30 : 26.sp,
            ),
          ),
          SizedBox(height: isDesktop ? 10 : 8.h),
          Text(
            service.name,
            style: GoogleFonts.poppins(
              fontSize: isDesktop ? 12 : 10.5.sp,
              fontWeight: FontWeight.w600,
              color: HomeScreen.kTextDark,
              height: 1.2,
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
