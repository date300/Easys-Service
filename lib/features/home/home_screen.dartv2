import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../main.dart';
import '../reselling/reselling_screen.dart';
import '../reselling/product_model.dart';

// ==================== MODELS ====================

class Service {
  final String name;
  final IconData icon;
  final Color color;
  final Color secondaryColor;
  final String? route;
  final bool requiresVerification;
  final bool isComingSoon;

  const Service({
    required this.name,
    required this.icon,
    required this.color,
    required this.secondaryColor,
    this.route,
    this.requiresVerification = true,
    this.isComingSoon = false,
  });
}

class BannerItem {
  final String id;
  final String imageUrl;
  final String? title;
  final String? subtitle;
  final Color? bgColor;
  final String? route;

  const BannerItem({
    required this.id,
    required this.imageUrl,
    this.title,
    this.subtitle,
    this.bgColor,
    this.route,
  });
}

// ==================== HOME PROFILE PROVIDER ====================

class HomeUserProfile {
  final String idVerified;
  HomeUserProfile({required this.idVerified});

  factory HomeUserProfile.fromJson(Map<String, dynamic> json) {
    return HomeUserProfile(
      idVerified: json['id_verified'] ?? 'unverified',
    );
  }
}

final homeProfileProvider = FutureProvider<HomeUserProfile?>((ref) async {
  const String baseUrl = "https://api.easysarvice.com/api";
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('jwt_token');

  if (token == null) return null;

  try {
    final response = await http.get(
      Uri.parse("$baseUrl/user/profile"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    ).timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['status'] == 'success') {
        return HomeUserProfile.fromJson(data['user']);
      }
    }
  } catch (e) {
    debugPrint("Home Profile Fetch Error: $e");
    return null;
  }
  return null;
});

// ==================== PROVIDERS ====================

final servicesProvider = Provider<List<Service>>((ref) {
  return const [
    Service(name: 'Recharge', icon: CupertinoIcons.device_phone_portrait, color: Color(0xFF6366F1), secondaryColor: Color(0xFF818CF8), route: '/recharge', requiresVerification: false),
    Service(name: 'Drive Offer', icon: CupertinoIcons.gift, color: Color(0xFF0284C7), secondaryColor: Color(0xFF38BDF8), route: '/drive', requiresVerification: false),
    Service(name: 'Bonus', icon: CupertinoIcons.star_circle, color: Color(0xFFF59E0B), secondaryColor: Color(0xFFFCD34D), route: null, requiresVerification: false),
    Service(name: 'Reselling', icon: CupertinoIcons.bag, color: Color(0xFFEA580C), secondaryColor: Color(0xFFFB923C), route: '/reselling', requiresVerification: true),
    Service(name: 'Used Item', icon: CupertinoIcons.arrow_2_circlepath, color: Color(0xFF78716C), secondaryColor: Color(0xFFD6D3D1), route: null, requiresVerification: false),
    Service(name: 'Microjob', icon: CupertinoIcons.doc_text, color: Color(0xFF0D9488), secondaryColor: Color(0xFF2DD4BF), route: '/microjobs', requiresVerification: true),
    Service(name: 'Education', icon: CupertinoIcons.book, color: Color(0xFFD97706), secondaryColor: Color(0xFFFBBF24), route: null, requiresVerification: false),
    Service(name: 'To-let', icon: Icons.real_estate_agent, color: Color(0xFF9333EA), secondaryColor: Color(0xFFC084FC), route: null, requiresVerification: false),
    Service(name: 'Easy Bus', icon: CupertinoIcons.bus, color: Color(0xFF2563EB), secondaryColor: Color(0xFF60A5FA), route: null, requiresVerification: false),
    Service(name: 'Courier', icon: CupertinoIcons.cube_box, color: Color(0xFFEA580C), secondaryColor: Color(0xFFFB923C), route: null, requiresVerification: false),
    Service(name: 'Agro', icon: CupertinoIcons.leaf_arrow_circlepath, color: Color(0xFF15803D), secondaryColor: Color(0xFF86EFAC), route: null, requiresVerification: false),
    Service(name: 'Loan', icon: Icons.hardware, color: Color(0xFF16A34A), secondaryColor: Color(0xFF4ADE80), route: null, requiresVerification: false, isComingSoon: true),
    Service(name: 'Campaign', icon: Icons.hardware, color: Color(0xFF7C3AED), secondaryColor: Color(0xFFA78BFA), route: '/campaigns', requiresVerification: true, isComingSoon: true),
  ];
});

final isExpandedProvider = StateProvider<bool>((ref) => false);

final bannerProvider = Provider<List<BannerItem>>((ref) {
  return const [
    BannerItem(id: '1', imageUrl: 'https://images.unsplash.com/photo-1607082348824-0a96f2a4b9da?w=800', title: 'Mega Sale', subtitle: 'Up to 50% off', bgColor: Color(0xFF6366F1)),
    BannerItem(id: '2', imageUrl: 'https://images.unsplash.com/photo-1556742049-0cfed4f6a45d?w=800', title: 'New Arrivals', subtitle: 'Latest gadgets', bgColor: Color(0xFFEA580C)),
    BannerItem(id: '3', imageUrl: 'https://images.unsplash.com/photo-1606107557195-0e29a4b5b4aa?w=800', title: 'Free Delivery', subtitle: 'On orders over ?500', bgColor: Color(0xFF16A34A)),
  ];
});

final currentBannerIndexProvider = StateProvider<int>((ref) => 0);

// ==================== HOME SCREEN ====================

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});
  static const Color kPrimary = Color(0xFF29B6F6);

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late PageController _bannerController;

  @override
  void initState() {
    super.initState();
    _bannerController = PageController();
    _startAutoSlide();

    Future.microtask(() {
      ref.read(productListProvider.notifier).fetchProducts();
    });
  }

  @override
  void dispose() {
    _bannerController.dispose();
    super.dispose();
  }

  void _startAutoSlide() {
    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;
      final banners = ref.read(bannerProvider);
      final currentIndex = ref.read(currentBannerIndexProvider);
      final nextIndex = (currentIndex + 1) % banners.length;

      if (_bannerController.hasClients) {
        _bannerController.animateToPage(
          nextIndex,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
      ref.read(currentBannerIndexProvider.notifier).state = nextIndex;
      _startAutoSlide();
    });
  }

  @override
  Widget build(BuildContext context) {
    final services = ref.watch(servicesProvider);
    final products = ref.watch(productListProvider);
    final banners = ref.watch(bannerProvider);
    final currentBannerIndex = ref.watch(currentBannerIndexProvider);
    final profileAsync = ref.watch(homeProfileProvider);
    final screenWidth = MediaQuery.of(context).size.width;

    final isDesktop = screenWidth >= 1024;
    final isTablet = screenWidth >= 600 && screenWidth < 1024;
    final isSmall = screenWidth < 360;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final kBackground = isDark ? const Color(0xFF121212) : const Color(0xFFF8FAFC);
    final kTextDark = isDark ? Colors.white : const Color(0xFF0F172A);
    final kTextMid = isDark ? Colors.grey.shade400 : const Color(0xFF475569);
    final cardBackground = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final shadowColor = isDark ? Colors.black.withOpacity(0.3) : Colors.black.withOpacity(0.04);
    final borderColor = isDark ? const Color(0xFF333333) : Colors.grey.withOpacity(0.1);
    final lockBgColor = isDark ? const Color(0xFF2C2C2C) : const Color(0xFFF1F5F9);

    final hPadding = isDesktop ? 32.w : isTablet ? 20.w : isSmall ? 12.w : 16.w;
    final vPadding = isDesktop ? 24.h : isTablet ? 20.h : 16.h;

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
                  padding: EdgeInsets.symmetric(horizontal: hPadding, vertical: vPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildBannerSlider(
                        context,
                        banners,
                        currentBannerIndex,
                        isDesktop: isDesktop,
                        isTablet: isTablet,
                        isSmall: isSmall,
                      ),
                      SizedBox(height: isDesktop ? 24.h : 16.h),

                      // ==================== UNVERIFIED BANNER ====================
                      profileAsync.when(
                        data: (user) {
                          if (user?.idVerified != 'unverified') return const SizedBox.shrink();
                          return Padding(
                            padding: EdgeInsets.only(bottom: isDesktop ? 20.h : 14.h),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              decoration: BoxDecoration(
                                color: Colors.orange.withOpacity(isDark ? 0.15 : 0.1),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: Colors.orange.withOpacity(0.5),
                                  width: 1.2,
                                ),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.warning_amber_rounded,
                                    color: Colors.orange,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      'Your account is not verified yet. You need to verify your account to use this feature.',
                                      style: GoogleFonts.poppins(
                                        fontSize: isSmall ? 10.5.sp : 11.sp,
                                        color: isDark
                                            ? Colors.orange.shade200
                                            : Colors.orange.shade900,
                                        fontWeight: FontWeight.w500,
                                        height: 1.4,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  ElevatedButton(
                                    onPressed: () => context.go('/payment'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.orange,
                                      foregroundColor: Colors.white,
                                      padding: EdgeInsets.symmetric(
                                        horizontal: isSmall ? 10.w : 14.w,
                                        vertical: 8.h,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      elevation: 0,
                                      minimumSize: Size.zero,
                                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    child: Text(
                                      'Verify Now',
                                      style: GoogleFonts.poppins(
                                        fontSize: isSmall ? 10.sp : 11.sp,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                        loading: () => const SizedBox.shrink(),
                        error: (_, __) => const SizedBox.shrink(),
                      ),
                      // ==================== END UNVERIFIED BANNER ====================

                      _buildSectionHeader(
                        context,
                        isDesktop,
                        isSmall,
                        kTextDark,
                        kTextMid,
                        title: 'Services',
                        subtitle: 'All you need',
                        showViewAll: true,
                      ),
                      SizedBox(height: isDesktop ? 20.h : 12.h),
                      _buildCategoriesGrid(
                        context,
                        ref,
                        services,
                        isDesktop: isDesktop,
                        isTablet: isTablet,
                        isSmall: isSmall,
                        screenWidth: screenWidth,
                        cardBackground: cardBackground,
                        shadowColor: shadowColor,
                        borderColor: borderColor,
                        lockBgColor: lockBgColor,
                        kTextDark: kTextDark,
                      ),

                      SizedBox(height: isDesktop ? 32.h : 20.h),

                      _buildSectionHeader(
                        context,
                        isDesktop,
                        isSmall,
                        kTextDark,
                        kTextMid,
                        title: 'Products',
                        subtitle: 'Trending now',
                        showViewAll: true,
                      ),
                      SizedBox(height: isDesktop ? 16.h : 10.h),
                      _buildHorizontalProductList(
                        context,
                        ref,
                        products,
                        isDesktop: isDesktop,
                        isTablet: isTablet,
                        isSmall: isSmall,
                        cardBackground: cardBackground,
                        shadowColor: shadowColor,
                        kTextDark: kTextDark,
                        kTextMid: kTextMid,
                      ),

                      SizedBox(height: 20.h),
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

  // ==================== BANNER SLIDER ====================
  Widget _buildBannerSlider(
    BuildContext context,
    List<BannerItem> banners,
    int currentIndex, {
    required bool isDesktop,
    required bool isTablet,
    required bool isSmall,
  }) {
    final bannerHeight = isDesktop ? 180.h : isTablet ? 140.h : isSmall ? 100.h : 120.h;

    return Container(
      height: bannerHeight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 3)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.r),
        child: Stack(
          children: [
            PageView.builder(
              controller: _bannerController,
              onPageChanged: (index) => ref.read(currentBannerIndexProvider.notifier).state = index,
              itemCount: banners.length,
              itemBuilder: (context, index) {
                final banner = banners[index];
                return GestureDetector(
                  onTap: () => debugPrint('Banner: ${banner.title}'),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        banner.imageUrl,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) => loadingProgress == null
                            ? child
                            : Container(
                                color: banner.bgColor,
                                child: Center(child: CupertinoActivityIndicator(radius: 12.r)),
                              ),
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: banner.bgColor,
                          child: Icon(CupertinoIcons.photo, size: 32.sp, color: Colors.white),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.transparent, Colors.black.withOpacity(0.5)],
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: isSmall ? 8.h : 12.h,
                        left: isSmall ? 10.w : 14.w,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (banner.title != null)
                              Text(
                                banner.title!,
                                style: GoogleFonts.poppins(
                                  fontSize: isSmall ? 14.sp : isTablet ? 16.sp : 18.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            if (banner.subtitle != null)
                              Text(
                                banner.subtitle!,
                                style: GoogleFonts.poppins(
                                  fontSize: isSmall ? 10.sp : isTablet ? 11.sp : 12.sp,
                                  color: Colors.white.withOpacity(0.9),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            Positioned(
              bottom: isSmall ? 6.h : 8.h,
              right: isSmall ? 10.w : 14.w,
              child: Row(
                children: List.generate(
                  banners.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: EdgeInsets.symmetric(horizontal: 3.w),
                    width: currentIndex == index ? 16.w : 6.w,
                    height: isSmall ? 5.h : 6.h,
                    decoration: BoxDecoration(
                      color: currentIndex == index ? Colors.white : Colors.white.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(3.r),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 500.ms);
  }

  // ==================== SECTION HEADER ====================
  Widget _buildSectionHeader(
    BuildContext context,
    bool isDesktop,
    bool isSmall,
    Color kTextDark,
    Color kTextMid, {
    required String title,
    required String subtitle,
    bool showViewAll = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: isSmall ? 14.sp : isDesktop ? 18.sp : 16.sp,
                fontWeight: FontWeight.bold,
                color: kTextDark,
              ),
            ),
            Text(
              subtitle,
              style: GoogleFonts.poppins(
                fontSize: isSmall ? 10.sp : isDesktop ? 12.sp : 11.sp,
                color: kTextMid,
              ),
            ),
          ],
        ),
        if (showViewAll)
          TextButton(
            onPressed: () {},
            style: TextButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'See All',
                  style: GoogleFonts.poppins(
                    fontSize: isSmall ? 10.sp : 11.sp,
                    color: HomeScreen.kPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(width: 2.w),
                Icon(CupertinoIcons.chevron_right, size: isSmall ? 10.sp : 12.sp, color: HomeScreen.kPrimary),
              ],
            ),
          ),
      ],
    ).animate().fadeIn(duration: 400.ms);
  }

  // ==================== CATEGORIES GRID ====================
  Widget _buildCategoriesGrid(
    BuildContext context,
    WidgetRef ref,
    List<Service> services, {
    required bool isDesktop,
    required bool isTablet,
    required bool isSmall,
    required double screenWidth,
    required Color cardBackground,
    required Color shadowColor,
    required Color borderColor,
    required Color lockBgColor,
    required Color kTextDark,
  }) {
    int crossAxisCount = isSmall
        ? 4
        : (screenWidth >= 1200
            ? 8
            : (screenWidth >= 900
                ? 6
                : (screenWidth >= 600 ? 5 : 4)));
    final isExpanded = ref.watch(isExpandedProvider);
    final initialItemsCount = crossAxisCount * 2;
    final displayedServices = isExpanded ? services : services.take(initialItemsCount).toList();

    return Column(
      children: [
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: isSmall ? 8.h : isTablet ? 12.h : 16.h,
            crossAxisSpacing: isSmall ? 6.w : isTablet ? 10.w : 12.w,
            childAspectRatio: isSmall ? 0.7 : 0.75,
          ),
          itemCount: displayedServices.length,
          itemBuilder: (context, index) {
            return _ServiceCard(
              service: displayedServices[index],
              isDesktop: isDesktop,
              isSmall: isSmall,
              cardBackground: cardBackground,
              shadowColor: shadowColor,
              borderColor: borderColor,
              lockBgColor: lockBgColor,
              kTextDark: kTextDark,
            ).animate().fade(duration: 300.ms, delay: (index * 30).ms).scale(
                  begin: const Offset(0.9, 0.9),
                  curve: Curves.easeOut,
                );
          },
        ),
        if (services.length > initialItemsCount)
          Padding(
            padding: EdgeInsets.only(top: 8.h),
            child: TextButton.icon(
              onPressed: () => ref.read(isExpandedProvider.notifier).state = !isExpanded,
              icon: Icon(
                isExpanded ? CupertinoIcons.chevron_up : CupertinoIcons.chevron_down,
                size: isSmall ? 12.sp : 14.sp,
                color: HomeScreen.kPrimary,
              ),
              label: Text(
                isExpanded ? 'Less' : 'More',
                style: GoogleFonts.poppins(
                  fontSize: isSmall ? 10.sp : 11.sp,
                  fontWeight: FontWeight.w600,
                  color: HomeScreen.kPrimary,
                ),
              ),
            ),
          ),
      ],
    );
  }

  // ==================== HORIZONTAL PRODUCT LIST ====================
  Widget _buildHorizontalProductList(
    BuildContext context,
    WidgetRef ref,
    List<ProductModel> products, {
    required bool isDesktop,
    required bool isTablet,
    required bool isSmall,
    required Color cardBackground,
    required Color shadowColor,
    required Color kTextDark,
    required Color kTextMid,
  }) {
    if (products.isEmpty) {
      return SizedBox(
        height: isSmall ? 175.h : isTablet ? 195.h : 205.h,
        child: const Center(child: CupertinoActivityIndicator()),
      );
    }

    return SizedBox(
      height: isSmall ? 175.h : isTablet ? 195.h : 205.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.only(left: isSmall ? 2.w : 4.w, right: 10.w, top: 4.h, bottom: 4.h),
        itemCount: products.length,
        itemBuilder: (context, index) {
          return _ProductCard(
            product: products[index],
            isDesktop: isDesktop,
            isSmall: isSmall,
            cardBackground: cardBackground,
            shadowColor: shadowColor,
            kTextDark: kTextDark,
            kTextMid: kTextMid,
            onTap: () {
              ref.read(isDetailViewProvider.notifier).state = true;
              ref.read(detailViewTitleProvider.notifier).state = products[index].title;
              context.push('/product/${products[index].id}');
            },
          ).animate().fade(duration: 300.ms, delay: (index * 40).ms).slideX(begin: 10, curve: Curves.easeOut);
        },
      ),
    );
  }
}

// ==================== SERVICE CARD ====================
class _ServiceCard extends ConsumerWidget {
  final Service service;
  final bool isDesktop;
  final bool isSmall;
  final Color cardBackground;
  final Color shadowColor;
  final Color borderColor;
  final Color lockBgColor;
  final Color kTextDark;

  const _ServiceCard({
    required this.service,
    this.isDesktop = false,
    this.isSmall = false,
    required this.cardBackground,
    required this.shadowColor,
    required this.borderColor,
    required this.lockBgColor,
    required this.kTextDark,
  });

  void _navigateToDetail(BuildContext context, WidgetRef ref) {
    ref.read(isDetailViewProvider.notifier).state = true;
    ref.read(detailViewTitleProvider.notifier).state = service.name;
    context.push(service.route!);
  }

  void _onTap(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (service.route == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          '${service.name} coming soon!',
          style: GoogleFonts.poppins(fontSize: isSmall ? 11.sp : 12.sp),
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : const Color(0xFF0F172A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
        duration: const Duration(seconds: 1),
      ));
      return;
    }
    _navigateToDetail(context, ref);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final iconSize = isSmall ? 20.sp : isDesktop ? 26.sp : 22.sp;
    final containerSize = isSmall ? 42.w : isDesktop ? 58.w : 48.w;
    final comingSoonFontSize = isSmall ? 7.5.sp : isDesktop ? 10.sp : 8.5.sp;

    return GestureDetector(
      onTap: () => _onTap(context, ref),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            height: containerSize,
            width: containerSize,
            decoration: BoxDecoration(
              color: cardBackground,
              shape: BoxShape.circle,
              border: Border.all(color: borderColor, width: 0.5),
              boxShadow: [BoxShadow(color: shadowColor, blurRadius: 6, offset: const Offset(0, 2))],
            ),
            child: Center(child: Icon(service.icon, color: service.color, size: iconSize)),
          ),
          SizedBox(height: isSmall ? 4.h : 6.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  service.isComingSoon ? 'Coming\nSoon' : service.name,
                  style: GoogleFonts.poppins(
                    fontSize: service.isComingSoon
                        ? comingSoonFontSize
                        : (isSmall ? 9.sp : isDesktop ? 11.sp : 10.sp),
                    fontWeight: FontWeight.w500,
                    color: service.isComingSoon ? Colors.grey : kTextDark,
                    height: 1.1,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ==================== PRODUCT CARD ====================
class _ProductCard extends StatelessWidget {
  final ProductModel product;
  final bool isDesktop;
  final bool isSmall;
  final Color cardBackground;
  final Color shadowColor;
  final Color kTextDark;
  final Color kTextMid;
  final VoidCallback onTap;

  const _ProductCard({
    required this.product,
    required this.isDesktop,
    this.isSmall = false,
    required this.cardBackground,
    required this.shadowColor,
    required this.kTextDark,
    required this.kTextMid,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cardWidth = isSmall ? 100.w : isDesktop ? 130.w : 115.w;
    final imageSize = isSmall ? 85.w : isDesktop ? 110.w : 95.w;

    final hasDiscount = product.originalPrice != null && product.originalPrice! > product.wholesalePrice;
    final discountPercent = hasDiscount
        ? (((product.originalPrice! - product.wholesalePrice) / product.originalPrice!) * 100).round()
        : 0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: cardWidth,
        margin: EdgeInsets.only(right: isSmall ? 6.w : 8.w),
        decoration: BoxDecoration(
          color: cardBackground,
          borderRadius: BorderRadius.circular(10.r),
          boxShadow: [
            BoxShadow(color: shadowColor, blurRadius: 6, offset: const Offset(0, 2), spreadRadius: 0),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(10.r)),
                  child: SizedBox(
                    width: cardWidth,
                    height: imageSize,
                    child: Image.network(
                      product.image,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) => loadingProgress == null
                          ? child
                          : Center(child: CupertinoActivityIndicator(radius: isSmall ? 10.r : 12.r)),
                      errorBuilder: (_, __, ___) => Container(
                        color: Colors.grey.shade200,
                        child: Icon(CupertinoIcons.photo, size: isSmall ? 24.sp : 28.sp, color: Colors.grey.shade400),
                      ),
                    ),
                  ),
                ),
                if (hasDiscount)
                  Positioned(
                    top: 6,
                    left: 6,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF3B30),
                        borderRadius: BorderRadius.circular(5.r),
                      ),
                      child: Text(
                        '-$discountPercent%',
                        style: GoogleFonts.poppins(
                          fontSize: 8.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                Positioned(
                  top: 6,
                  right: 6,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
                    decoration: BoxDecoration(
                      color: cardBackground.withOpacity(0.92),
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(CupertinoIcons.star_fill, color: const Color(0xFFFFCC02), size: 9.sp),
                        SizedBox(width: 2.w),
                        Text(
                          product.rating.toString(),
                          style: GoogleFonts.poppins(
                            fontSize: 8.sp,
                            fontWeight: FontWeight.w700,
                            color: kTextDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.all(isSmall ? 6.w : 8.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    product.title,
                    style: GoogleFonts.poppins(
                      fontSize: isSmall ? 9.sp : 10.sp,
                      fontWeight: FontWeight.w500,
                      color: kTextDark,
                      height: 1.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    '?${product.wholesalePrice.toInt()}',
                    style: GoogleFonts.poppins(
                      fontSize: isSmall ? 11.sp : 12.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF29B6F6),
                    ),
                  ),
                  if (hasDiscount) ...[
                    SizedBox(height: 1.h),
                    Text(
                      '?${product.originalPrice!.toInt()}',
                      style: GoogleFonts.poppins(
                        fontSize: 9.sp,
                        fontWeight: FontWeight.w400,
                        color: kTextMid,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
