import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../core/guards/verification_guard.dart'; // ????? ?????????? ?????

/// Service Model (????? ????? ???????? ????)
class Service {
  final String name;
  final IconData icon;
  final Color color;
  final Color secondaryColor;
  final String? route;
  final bool requiresVerification;

  const Service({
    required this.name,
    required this.icon,
    required this.color,
    required this.secondaryColor,
    this.route,
    this.requiresVerification = true,
  });
}

/// Riverpod Provider (????? ???????? ????, ???? ???????? ????????? Cupertino ??? ?????)
final servicesProvider = Provider<List<Service>>((ref) {
  return const [
    Service(
      name: 'Recharge',
      icon: CupertinoIcons.device_phone_portrait,
      color: Color(0xFF6366F1),
      secondaryColor: Color(0xFF818CF8),
      route: null,
    ),
    Service(
      name: 'Drive Offer',
      icon: CupertinoIcons.gift,
      color: Color(0xFF0284C7),
      secondaryColor: Color(0xFF38BDF8),
      route: '/drive',
      requiresVerification: false,
    ),
    Service(
      name: 'Reselling',
      icon: CupertinoIcons.bag,
      color: Color(0xFFEA580C),
      secondaryColor: Color(0xFFFB923C),
      route: '/reselling',
      requiresVerification: true,
    ),
    Service(
      name: 'Microjob',
      icon: CupertinoIcons.doc_text,
      color: Color(0xFF0D9488),
      secondaryColor: Color(0xFF2DD4BF),
      route: '/microjobs',
      requiresVerification: true,
    ),
    Service(
      name: 'Loan',
      icon: CupertinoIcons.money_dollar_circle,
      color: Color(0xFF16A34A),
      secondaryColor: Color(0xFF4ADE80),
      route: null,
    ),
    Service(
      name: 'Campaign',
      icon: CupertinoIcons.speaker_2,
      color: Color(0xFF7C3AED),
      secondaryColor: Color(0xFFA78BFA),
      route: '/campaigns',
      requiresVerification: true,
    ),
    Service(
      name: 'Education',
      icon: CupertinoIcons.book,
      color: Color(0xFFD97706),
      secondaryColor: Color(0xFFFBBF24),
      route: null,
    ),
    Service(
      name: 'Easy Bus',
      icon: CupertinoIcons.bus,
      color: Color(0xFF2563EB),
      secondaryColor: Color(0xFF60A5FA),
      route: null,
    ),
    Service(
      name: 'Courier',
      icon: CupertinoIcons.cube_box,
      color: Color(0xFFEA580C),
      secondaryColor: Color(0xFFFB923C),
      route: null,
    ),
    Service(
      name: 'Agro',
      icon: CupertinoIcons.leaf_arrow_circlepath,
      color: Color(0xFF15803D),
      secondaryColor: Color(0xFF86EFAC),
      route: null,
    ),
    Service(
      name: 'Used Item',
      icon: CupertinoIcons.arrow_2_circlepath,
      color: Color(0xFF78716C),
      secondaryColor: Color(0xFFD6D3D1),
      route: null,
    ),
  ];
});

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  static const Color kPrimary = Color(0xFF29B6F6); // ????? ???? ???
  static const Color kBackground = Color(0xFFF8FAFC); // ????? ???? ?????????????
  static const Color kTextDark = Color(0xFF0F172A);
  static const Color kTextMid = Color(0xFF475569);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final services = ref.watch(servicesProvider);
    final screenWidth = MediaQuery.of(context).size.width;

    final isDesktop = screenWidth >= 1024;
    final isTablet = screenWidth >= 600 && screenWidth < 1024;

    return Container(
      color: kBackground,
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
                        context,
                        services,
                        isDesktop: isDesktop,
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
                fontSize: isDesktop ? 24 : 18.sp,
                fontWeight: FontWeight.bold,
                color: kTextDark,
              ),
            ),
            Text(
              'Everything you need in one place',
              style: GoogleFonts.poppins(
                fontSize: isDesktop ? 13 : 11.sp,
                color: kTextMid,
              ),
            ),
          ],
        ),
        Text(
          'See All',
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
    BuildContext context,
    List<Service> services, {
    required bool isDesktop,
    required double screenWidth,
  }) {
    int crossAxisCount;
    if (screenWidth >= 1200) {
      crossAxisCount = 8;
    } else if (screenWidth >= 900) {
      crossAxisCount = 6;
    } else if (screenWidth >= 600) {
      crossAxisCount = 5;
    } else {
      crossAxisCount = 4; // ??????? ??? ????, ????? ???????? ????
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: isDesktop ? 24 : 20.h,
        crossAxisSpacing: isDesktop ? 20 : 15.w,
        childAspectRatio: 0.75, // ????? ????? ????
      ),
      itemCount: services.length,
      itemBuilder: (context, index) {
        return _ServiceCard(
          service: services[index],
          isDesktop: isDesktop,
        )
            .animate()
            .fade(duration: 400.ms, delay: (index * 40).ms)
            .scale(
              begin: const Offset(0.8, 0.8),
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

  // ????? ???????? ????? ???? (Verification Guard ??)
  void _onTap(BuildContext context) {
    if (service.route == null) {
      // Coming Soon Notification
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${service.name} ? Coming Soon!',
            style: GoogleFonts.poppins(fontSize: 13.sp),
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFF0F172A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    if (service.requiresVerification) {
      VerificationGuard.check(
        context,
        amount: 199.00,
        purpose: 'Account Verification Fee',
        onVerified: () {
          context.go(service.route!);
        },
      );
    } else {
      context.go(service.route!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool hasRoute = service.route != null;

    return GestureDetector(
      onTap: () => _onTap(context),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              // ????? ??? ?????? ??????? ?????????
              Container(
                height: isDesktop ? 65.w : 52.w,
                width: isDesktop ? 65.w : 52.w,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.grey.withOpacity(0.1),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    service.icon,
                    // ?? ????? ????, ????? ????? ???????? ?????
                    color: hasRoute ? service.color : Colors.grey.shade400,
                    size: isDesktop ? 28.sp : 24.sp,
                  ),
                ),
              ),
              // ??? ???????????? ???? ????? ?? ????
              if (!hasRoute)
                Positioned(
                  right: -2,
                  top: -2,
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                    child: Icon(
                      CupertinoIcons.lock_fill,
                      size: 10.sp,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: isDesktop ? 12.h : 8.h),
          // ????? ??????
          Text(
            service.name,
            style: GoogleFonts.poppins(
              fontSize: isDesktop ? 12.sp : 10.sp,
              fontWeight: hasRoute ? FontWeight.w500 : FontWeight.w400,
              color: hasRoute ? HomeScreen.kTextDark : Colors.grey.shade500,
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
