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
  static const Color kSurface = Color(0xFFFFFFFF);
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
                        _buildTopBar(context, isDesktop),
                        SizedBox(height: isDesktop ? 32 : 24.h),
                        isDesktop
                            ? _buildDesktopBanner(context)
                            : _buildMobileBanner(context),
                        SizedBox(height: isDesktop ? 48 : 32.h),
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

  Widget _buildTopBar(BuildContext context, bool isDesktop) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Good Morning 👋',
              style: GoogleFonts.poppins(
                fontSize: isDesktop ? 14 : 13.sp,
                color: kTextMid,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              'What do you need?',
              style: GoogleFonts.poppins(
                fontSize: isDesktop ? 22 : 18.sp,
                fontWeight: FontWeight.bold,
                color: kTextDark,
              ),
            ),
          ],
        ),
        Row(
          children: [
            _TopIconButton(icon: Icons.search_rounded),
            SizedBox(width: 10.w),
            _TopIconButton(icon: Icons.notifications_outlined),
            SizedBox(width: 10.w),
            Container(
              width: isDesktop ? 42 : 38.w,
              height: isDesktop ? 42 : 38.w,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [kPrimary, kAccent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(
                Icons.person_outline_rounded,
                color: Colors.white,
                size: isDesktop ? 20 : 18.sp,
              ),
            ),
          ],
        ),
      ],
    ).animate().fadeIn(duration: 500.ms).slideY(begin: -0.2);
  }

  Widget _buildMobileBanner(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 160.h,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0369A1), Color(0xFF0284C7), Color(0xFF38BDF8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: kPrimary.withOpacity(0.35),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Decorative circles
          Positioned(
            right: -20.w,
            top: -20.h,
            child: Container(
              width: 120.w,
              height: 120.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.08),
              ),
            ),
          ),
          Positioned(
            right: 30.w,
            bottom: -30.h,
            child: Container(
              width: 90.w,
              height: 90.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.06),
              ),
            ),
          ),
          Positioned(
            right: 24.w,
            top: 0,
            bottom: 0,
            child: Icon(
              Icons.bolt_rounded,
              size: 100.sp,
              color: Colors.white.withOpacity(0.12),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    '🔥 Limited Time',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'Summer Sale!',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 26.sp,
                    fontWeight: FontWeight.bold,
                    height: 1.1,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'Get up to 40% cashback on all services',
                  style: GoogleFonts.poppins(
                    color: Colors.white.withOpacity(0.88),
                    fontSize: 12.sp,
                  ),
                ),
                SizedBox(height: 12.h),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    'Claim Now →',
                    style: GoogleFonts.poppins(
                      color: kPrimary,
                      fontSize: 11.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms).scale(begin: const Offset(0.96, 0.96));
  }

  Widget _buildDesktopBanner(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0369A1), Color(0xFF0284C7), Color(0xFF38BDF8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: kPrimary.withOpacity(0.3),
            blurRadius: 30,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -40,
            top: -40,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.06),
              ),
            ),
          ),
          Positioned(
            right: 80,
            bottom: -50,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.05),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 32),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '🔥 Limited Time Offer',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Summer Sale!',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Get up to 40% cashback on all services',
                        style: GoogleFonts.poppins(
                          color: Colors.white.withOpacity(0.88),
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: Text(
                          'Claim Now →',
                          style: GoogleFonts.poppins(
                            color: kPrimary,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.bolt_rounded,
                  size: 140,
                  color: Color(0x1AFFFFFF),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms).scale(begin: const Offset(0.97, 0.97));
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

class _TopIconButton extends StatelessWidget {
  final IconData icon;
  const _TopIconButton({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38.w,
      height: 38.w,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Icon(
        icon,
        color: HomeScreen.kTextDark,
        size: 18.sp,
      ),
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
