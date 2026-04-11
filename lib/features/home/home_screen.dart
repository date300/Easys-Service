import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../core/guards/verification_guard.dart'; 
// ????? ??? provider ???? main.dart ???? ?? ????????? ???? ???? ????
import '../../main.dart'; 

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

final servicesProvider = Provider<List<Service>>((ref) {
  return const [
    Service(name: 'Recharge', icon: CupertinoIcons.device_phone_portrait, color: Color(0xFF6366F1), secondaryColor: Color(0xFF818CF8), route: '/recharge', requiresVerification: false),
    Service(name: 'Drive Offer', icon: CupertinoIcons.gift, color: Color(0xFF0284C7), secondaryColor: Color(0xFF38BDF8), route: '/drive', requiresVerification: false),
    Service(name: 'Reselling', icon: CupertinoIcons.bag, color: Color(0xFFEA580C), secondaryColor: Color(0xFFFB923C), route: '/reselling', requiresVerification: true),
    Service(name: 'Microjob', icon: CupertinoIcons.doc_text, color: Color(0xFF0D9488), secondaryColor: Color(0xFF2DD4BF), route: '/microjobs', requiresVerification: true),
    Service(name: 'Loan', icon: CupertinoIcons.money_dollar_circle, color: Color(0xFF16A34A), secondaryColor: Color(0xFF4ADE80), route: null),
    Service(name: 'Campaign', icon: Icons.campaign, color: Color(0xFF7C3AED), secondaryColor: Color(0xFFA78BFA), route: '/campaigns', requiresVerification: true),
    Service(name: 'Education', icon: CupertinoIcons.book, color: Color(0xFFD97706), secondaryColor: Color(0xFFFBBF24), route: null),
    Service(name: 'Easy Bus', icon: CupertinoIcons.bus, color: Color(0xFF2563EB), secondaryColor: Color(0xFF60A5FA), route: null),
    Service(name: 'Courier', icon: CupertinoIcons.cube_box, color: Color(0xFFEA580C), secondaryColor: Color(0xFFFB923C), route: null),
    Service(name: 'Agro', icon: CupertinoIcons.leaf_arrow_circlepath, color: Color(0xFF15803D), secondaryColor: Color(0xFF86EFAC), route: null),
    Service(name: 'Used Item', icon: CupertinoIcons.arrow_2_circlepath, color: Color(0xFF78716C), secondaryColor: Color(0xFFD6D3D1), route: null),
  ];
});

// See More অপশনটি কন্ট্রোল করার জন্য Provider
final isExpandedProvider = StateProvider<bool>((ref) => false);

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  static const Color kPrimary = Color(0xFF29B6F6); 
  static const Color kBackground = Color(0xFFF8FAFC); 
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
          constraints: BoxConstraints(maxWidth: isDesktop ? 1200 : double.infinity),
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
                      _buildCategoriesGrid(context, ref, services, isDesktop: isDesktop, screenWidth: screenWidth),
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
            Text('Our Services', style: GoogleFonts.poppins(fontSize: isDesktop ? 24 : 18.sp, fontWeight: FontWeight.bold, color: kTextDark)),
            Text('Everything you need in one place', style: GoogleFonts.poppins(fontSize: isDesktop ? 13 : 11.sp, color: kTextMid)),
          ],
        ),
        Text('See All', style: GoogleFonts.poppins(fontSize: isDesktop ? 13 : 12.sp, color: kPrimary, fontWeight: FontWeight.w600)),
      ],
    ).animate().fadeIn(duration: 500.ms).slideX();
  }

  Widget _buildCategoriesGrid(BuildContext context, WidgetRef ref, List<Service> services, {required bool isDesktop, required double screenWidth}) {
    int crossAxisCount = screenWidth >= 1200 ? 8 : (screenWidth >= 900 ? 6 : (screenWidth >= 600 ? 5 : 4));
    
    // Check if user clicked 'See More'
    final isExpanded = ref.watch(isExpandedProvider);
    
    // Calculate items for 2 rows
    final int initialItemsCount = crossAxisCount * 2;
    
    final displayedServices = isExpanded ? services : services.take(initialItemsCount).toList();

    return Column(
      children: [
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: isDesktop ? 24 : 20.h,
            crossAxisSpacing: isDesktop ? 20 : 15.w,
            childAspectRatio: 0.75,
          ),
          itemCount: displayedServices.length,
          itemBuilder: (context, index) {
            return _ServiceCard(service: displayedServices[index], isDesktop: isDesktop)
                .animate()
                .fade(duration: 400.ms, delay: (index * 40).ms)
                .scale(begin: const Offset(0.8, 0.8), curve: Curves.easeOutBack);
          },
        ),
        
        // Show 'See More' button if there are more items than initial count
        if (services.length > initialItemsCount)
          Padding(
            padding: EdgeInsets.only(top: 16.h),
            child: TextButton.icon(
              onPressed: () => ref.read(isExpandedProvider.notifier).state = !isExpanded,
              icon: Icon(isExpanded ? CupertinoIcons.chevron_up : CupertinoIcons.chevron_down, size: 16.sp, color: kPrimary),
              label: Text(
                isExpanded ? 'Show Less' : 'See More Services',
                style: GoogleFonts.poppins(fontSize: 13.sp, fontWeight: FontWeight.w600, color: kPrimary),
              ),
            ),
          ),
      ],
    );
  }
}

class _ServiceCard extends ConsumerWidget {
  final Service service;
  final bool isDesktop;

  const _ServiceCard({required this.service, this.isDesktop = false});

  void _navigateToDetail(BuildContext context, WidgetRef ref) {
    ref.read(isDetailViewProvider.notifier).state = true;
    ref.read(detailViewTitleProvider.notifier).state = service.name;
    context.go(service.route!);
  }

  void _onTap(BuildContext context, WidgetRef ref) {
    // Under construction check
    if (service.name == 'Loan' || service.name == 'Campaign') {
      return; 
    }

    if (service.route == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${service.name} coming Soon!', style: GoogleFonts.poppins(fontSize: 13.sp)),
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFF0F172A),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
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
        onVerified: () => _navigateToDetail(context, ref),
      );
    } else {
      _navigateToDetail(context, ref);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool isUnderConstruction = service.name == 'Loan' || service.name == 'Campaign';
    final bool hasRoute = service.route != null && !isUnderConstruction;

    return GestureDetector(
      onTap: () => _onTap(context, ref),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                height: isDesktop ? 65.w : 52.w,
                width: isDesktop ? 65.w : 52.w,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey.withOpacity(0.1), width: 1),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4)),
                  ],
                ),
                child: Center(
                  child: Icon(
                    service.icon,
                    color: hasRoute ? service.color : Colors.grey.shade400,
                    size: isDesktop ? 28.sp : 24.sp,
                  ),
                ),
              ),
              if (!hasRoute || isUnderConstruction)
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
                      isUnderConstruction ? Icons.construction : CupertinoIcons.lock_fill, 
                      size: 10.sp, 
                      color: Colors.grey.shade500
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: isDesktop ? 12.h : 8.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  isUnderConstruction ? 'Coming Soon!' : service.name,
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
              ),
              if (isUnderConstruction) ...[
                SizedBox(width: 4.w),
                Icon(Icons.construction, size: 12.sp, color: Colors.orange.shade700),
              ]
            ],
          ),
        ],
      ),
    );
  }
}
