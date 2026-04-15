import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../core/guards/verification_guard.dart'; 
import '../../main.dart'; 

// ==================== MODELS ====================

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

class Product {
  final String id;
  final String name;
  final double price;
  final String imageUrl;
  final String? discountPrice;

  const Product({
    required this.id,
    required this.name,
    required this.price,
    required this.imageUrl,
    this.discountPrice,
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

// ==================== PROVIDERS ====================

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

final isExpandedProvider = StateProvider<bool>((ref) => false);

final featuredProductsProvider = Provider<List<Product>>((ref) {
  return const [
    Product(id: '1', name: 'Wireless Earbuds Pro', price: 2499.00, imageUrl: 'https://images.unsplash.com/photo-1590658268037-6bf12165a8df?w=400'),
    Product(id: '2', name: 'Smart Watch Series 7', price: 8999.00, imageUrl: 'https://images.unsplash.com/photo-1546868871-7041f2a55e12?w=400'),
    Product(id: '3', name: 'Portable Power Bank', price: 1899.00, imageUrl: 'https://images.unsplash.com/photo-1609091839311-d5365f9ff1c5?w=400'),
    Product(id: '4', name: 'Bluetooth Speaker', price: 3299.00, imageUrl: 'https://images.unsplash.com/photo-1608043152269-423dbba4e7e1?w=400'),
    Product(id: '5', name: 'Phone Case Premium', price: 799.00, imageUrl: 'https://images.unsplash.com/photo-1603313011101-320f26a4f6f6?w=400'),
    Product(id: '6', name: 'USB-C Cable 2M', price: 499.00, imageUrl: 'https://images.unsplash.com/photo-1625153669422-6b3c9a3b7c9f?w=400'),
    Product(id: '7', name: 'Wireless Charger Pad', price: 1599.00, imageUrl: 'https://images.unsplash.com/photo-1586816879360-004f5b0c51e3?w=400'),
    Product(id: '8', name: 'Car Phone Mount', price: 699.00, imageUrl: 'https://images.unsplash.com/photo-1616348436168-de43ad0db179?w=400'),
  ];
});

final bannerProvider = Provider<List<BannerItem>>((ref) {
  return const [
    BannerItem(
      id: '1',
      imageUrl: 'https://images.unsplash.com/photo-1607082348824-0a96f2a4b9da?w=800',
      title: 'Mega Sale',
      subtitle: 'Up to 50% off',
      bgColor: Color(0xFF6366F1),
    ),
    BannerItem(
      id: '2',
      imageUrl: 'https://images.unsplash.com/photo-1556742049-0cfed4f6a45d?w=800',
      title: 'New Arrivals',
      subtitle: 'Latest gadgets',
      bgColor: Color(0xFFEA580C),
    ),
    BannerItem(
      id: '3',
      imageUrl: 'https://images.unsplash.com/photo-1606107557195-0e29a4b5b4aa?w=800',
      title: 'Free Delivery',
      subtitle: 'On orders over ৳500',
      bgColor: Color(0xFF16A34A),
    ),
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
    final products = ref.watch(featuredProductsProvider);
    final banners = ref.watch(bannerProvider);
    final currentBannerIndex = ref.watch(currentBannerIndexProvider);
    final screenWidth = MediaQuery.of(context).size.width;

    final isDesktop = screenWidth >= 1024;
    final isTablet = screenWidth >= 600 && screenWidth < 1024;

    // ? DYNAMIC THEME COLORS
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final kBackground = isDark ? const Color(0xFF121212) : const Color(0xFFF8FAFC);
    final kTextDark = isDark ? Colors.white : const Color(0xFF0F172A);
    final kTextMid = isDark ? Colors.grey.shade400 : const Color(0xFF475569);
    final cardBackground = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final shadowColor = isDark ? Colors.black.withOpacity(0.3) : Colors.black.withOpacity(0.04);
    final borderColor = isDark ? const Color(0xFF333333) : Colors.grey.withOpacity(0.1);
    final lockBgColor = isDark ? const Color(0xFF2C2C2C) : const Color(0xFFF1F5F9);

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
                      // ==================== BANNER SLIDER ====================
                      _buildBannerSlider(
                        context,
                        banners,
                        currentBannerIndex,
                        isDesktop: isDesktop,
                        isTablet: isTablet,
                      ),
                      SizedBox(height: isDesktop ? 40 : 32.h),
                      
                      // ==================== SERVICES SECTION ====================
                      _buildSectionHeader(
                        context, 
                        isDesktop, 
                        kTextDark, 
                        kTextMid,
                        title: 'Our Services',
                        subtitle: 'Everything you need in one place',
                        showViewAll: true,
                      ),
                      SizedBox(height: isDesktop ? 28 : 20.h),
                      _buildCategoriesGrid(
                        context, 
                        ref, 
                        services, 
                        isDesktop: isDesktop, 
                        screenWidth: screenWidth,
                        cardBackground: cardBackground,
                        shadowColor: shadowColor,
                        borderColor: borderColor,
                        lockBgColor: lockBgColor,
                        kTextDark: kTextDark,
                      ),
                      
                      SizedBox(height: isDesktop ? 48 : 32.h),
                      
                      // ==================== PRODUCTS SECTION ====================
                      _buildSectionHeader(
                        context, 
                        isDesktop, 
                        kTextDark, 
                        kTextMid,
                        title: 'Featured Products',
                        subtitle: 'Trending items for you',
                        showViewAll: true,
                      ),
                      SizedBox(height: isDesktop ? 24 : 16.h),
                      _buildHorizontalProductList(
                        context,
                        products,
                        isDesktop: isDesktop,
                        cardBackground: cardBackground,
                        shadowColor: shadowColor,
                        kTextDark: kTextDark,
                        kTextMid: kTextMid,
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

  // ==================== BANNER SLIDER ====================
  Widget _buildBannerSlider(
    BuildContext context,
    List<BannerItem> banners,
    int currentIndex, {
    required bool isDesktop,
    required bool isTablet,
  }) {
    final bannerHeight = isDesktop ? 280.h : (isTablet ? 220.h : 180.h);

    return Column(
      children: [
        Container(
          height: bannerHeight,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16.r),
            child: Stack(
              children: [
                // PageView for banners
                PageView.builder(
                  controller: _bannerController,
                  onPageChanged: (index) {
                    ref.read(currentBannerIndexProvider.notifier).state = index;
                  },
                  itemCount: banners.length,
                  itemBuilder: (context, index) {
                    final banner = banners[index];
                    return GestureDetector(
                      onTap: () {
                        debugPrint('Banner tapped: ${banner.title}');
                      },
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          // Banner Image
                          Image.network(
                            banner.imageUrl,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                color: banner.bgColor ?? Colors.grey.shade300,
                                child: Center(
                                  child: CupertinoActivityIndicator(radius: 16.r),
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: banner.bgColor ?? Colors.grey.shade300,
                                child: Icon(
                                  CupertinoIcons.photo,
                                  size: 48.sp,
                                  color: Colors.white,
                                ),
                              );
                            },
                          ),
                          // Gradient Overlay
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withOpacity(0.6),
                                ],
                              ),
                            ),
                          ),
                          // Banner Text
                          if (banner.title != null || banner.subtitle != null)
                            Positioned(
                              bottom: 20.h,
                              left: 20.w,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (banner.title != null)
                                    Text(
                                      banner.title!,
                                      style: GoogleFonts.poppins(
                                        fontSize: isDesktop ? 24.sp : 20.sp,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  if (banner.subtitle != null)
                                    Text(
                                      banner.subtitle!,
                                      style: GoogleFonts.poppins(
                                        fontSize: isDesktop ? 14.sp : 12.sp,
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
                // Page Indicator Dots
                Positioned(
                  bottom: 12.h,
                  right: 20.w,
                  child: Row(
                    children: List.generate(
                      banners.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: EdgeInsets.symmetric(horizontal: 4.w),
                        width: currentIndex == index ? 20.w : 8.w,
                        height: 8.h,
                        decoration: BoxDecoration(
                          color: currentIndex == index
                              ? Colors.white
                              : Colors.white.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ).animate().fadeIn(duration: 600.ms).slideY(begin: -20, curve: Curves.easeOut),
      ],
    );
  }

  // ==================== SECTION HEADER ====================
  Widget _buildSectionHeader(
    BuildContext context, 
    bool isDesktop, 
    Color kTextDark, 
    Color kTextMid, {
    required String title,
    required String subtitle,
    bool showViewAll = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title, 
              style: GoogleFonts.poppins(
                fontSize: isDesktop ? 24 : 18.sp, 
                fontWeight: FontWeight.bold, 
                color: kTextDark,
              ),
            ),
            Text(
              subtitle, 
              style: GoogleFonts.poppins(
                fontSize: isDesktop ? 13 : 11.sp, 
                color: kTextMid,
              ),
            ),
          ],
        ),
        if (showViewAll)
          TextButton(
            onPressed: () {},
            style: TextButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'View All', 
                  style: GoogleFonts.poppins(
                    fontSize: isDesktop ? 13 : 12.sp, 
                    color: HomeScreen.kPrimary, 
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(width: 4.w),
                Icon(
                  CupertinoIcons.chevron_right,
                  size: 14.sp,
                  color: HomeScreen.kPrimary,
                ),
              ],
            ),
          ),
      ],
    ).animate().fadeIn(duration: 500.ms).slideX();
  }

  // ==================== SERVICES GRID ====================
  Widget _buildCategoriesGrid(
    BuildContext context, 
    WidgetRef ref, 
    List<Service> services, {
    required bool isDesktop, 
    required double screenWidth,
    required Color cardBackground,
    required Color shadowColor,
    required Color borderColor,
    required Color lockBgColor,
    required Color kTextDark,
  }) {
    int crossAxisCount = screenWidth >= 1200 ? 8 : (screenWidth >= 900 ? 6 : (screenWidth >= 600 ? 5 : 4));
    
    final isExpanded = ref.watch(isExpandedProvider);
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
            return _ServiceCard(
              service: displayedServices[index], 
              isDesktop: isDesktop,
              cardBackground: cardBackground,
              shadowColor: shadowColor,
              borderColor: borderColor,
              lockBgColor: lockBgColor,
              kTextDark: kTextDark,
            ).animate()
                .fade(duration: 400.ms, delay: (index * 40).ms)
                .scale(begin: const Offset(0.8, 0.8), curve: Curves.easeOutBack);
          },
        ),
        
        if (services.length > initialItemsCount)
          Padding(
            padding: EdgeInsets.only(top: 16.h),
            child: TextButton.icon(
              onPressed: () => ref.read(isExpandedProvider.notifier).state = !isExpanded,
              icon: Icon(
                isExpanded ? CupertinoIcons.chevron_up : CupertinoIcons.chevron_down, 
                size: 16.sp, 
                color: HomeScreen.kPrimary,
              ),
              label: Text(
                isExpanded ? 'Show Less' : 'See More Services',
                style: GoogleFonts.poppins(
                  fontSize: 13.sp, 
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
    List<Product> products, {
    required bool isDesktop,
    required Color cardBackground,
    required Color shadowColor,
    required Color kTextDark,
    required Color kTextMid,
  }) {
    return SizedBox(
      height: isDesktop ? 220.h : 200.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.only(
          left: isDesktop ? 0 : 10.w, 
          right: 20.w,
          top: 8.h,
          bottom: 8.h,
        ),
        itemCount: products.length,
        itemBuilder: (context, index) {
          return _ProductCard(
            product: products[index],
            isDesktop: isDesktop,
            cardBackground: cardBackground,
            shadowColor: shadowColor,
            kTextDark: kTextDark,
            kTextMid: kTextMid,
          ).animate()
            .fade(duration: 400.ms, delay: (index * 60).ms)
            .slideX(begin: 20, curve: Curves.easeOut);
        },
      ),
    );
  }
}

// ==================== SERVICE CARD ====================
class _ServiceCard extends ConsumerWidget {
  final Service service;
  final bool isDesktop;
  final Color cardBackground;
  final Color shadowColor;
  final Color borderColor;
  final Color lockBgColor;
  final Color kTextDark;

  const _ServiceCard({
    required this.service, 
    this.isDesktop = false,
    required this.cardBackground,
    required this.shadowColor,
    required this.borderColor,
    required this.lockBgColor,
    required this.kTextDark,
  });

  void _navigateToDetail(BuildContext context, WidgetRef ref) {
    ref.read(isDetailViewProvider.notifier).state = true;
    ref.read(detailViewTitleProvider.notifier).state = service.name;
    context.go(service.route!);
  }

  void _onTap(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (service.name == 'Loan' || service.name == 'Campaign') {
      return; 
    }

    if (service.route == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${service.name} coming Soon!', 
            style: GoogleFonts.poppins(fontSize: 13.sp),
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: isDark ? const Color(0xFF1E1E1E) : const Color(0xFF0F172A),
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
                  color: cardBackground,
                  shape: BoxShape.circle,
                  border: Border.all(color: borderColor, width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: shadowColor,
                      blurRadius: 10, 
                      offset: const Offset(0, 4),
                    ),
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
                      color: lockBgColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: cardBackground, width: 1.5),
                    ),
                    child: Icon(
                      isUnderConstruction ? Icons.construction : CupertinoIcons.lock_fill, 
                      size: 10.sp, 
                      color: Colors.grey.shade500,
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
                    color: hasRoute ? kTextDark : Colors.grey.shade500,
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

// ==================== PRODUCT CARD ====================
class _ProductCard extends StatelessWidget {
  final Product product;
  final bool isDesktop;
  final Color cardBackground;
  final Color shadowColor;
  final Color kTextDark;
  final Color kTextMid;

  const _ProductCard({
    required this.product,
    required this.isDesktop,
    required this.cardBackground,
    required this.shadowColor,
    required this.kTextDark,
    required this.kTextMid,
  });

  @override
  Widget build(BuildContext context) {
    final cardWidth = isDesktop ? 140.w : 130.w;
    final cardHeight = isDesktop ? 200.h : 180.h;
    final imageSize = isDesktop ? 120.w : 110.w;

    return GestureDetector(
      onTap: () {
        debugPrint('Tapped: ${product.name}');
      },
      child: Container(
        width: cardWidth,
        height: cardHeight,
        margin: EdgeInsets.only(right: 10.w),
        decoration: BoxDecoration(
          color: cardBackground,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: shadowColor,
              blurRadius: 8,
              offset: const Offset(0, 2),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image (Square 1:1)
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(12.r)),
              child: Container(
                width: cardWidth,
                height: imageSize,
                color: Colors.grey.shade100,
                child: Image.network(
                  product.imageUrl,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CupertinoActivityIndicator(radius: 12.r),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey.shade200,
                      child: Icon(
                        CupertinoIcons.photo,
                        size: 32.sp,
                        color: Colors.grey.shade400,
                      ),
                    );
                  },
                ),
              ),
            ),
            // Product Info
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(10.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Product Name (1 line, overflow hidden)
                    Text(
                      product.name,
                      style: GoogleFonts.poppins(
                        fontSize: isDesktop ? 12.sp : 11.sp,
                        fontWeight: FontWeight.w500,
                        color: kTextDark,
                        height: 1.3,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    // Price with ৳ symbol
                    Text(
                      '৳${product.price.toStringAsFixed(0)}',
                      style: GoogleFonts.poppins(
                        fontSize: isDesktop ? 14.sp : 13.sp,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF29B6F6),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
