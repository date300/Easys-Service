import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';

// ==================== RIVERPOD PROVIDERS ====================

final productListProvider = StateNotifierProvider<ProductListNotifier, List<ProductModel>>((ref) {
  return ProductListNotifier();
});

class ProductListNotifier extends StateNotifier<List<ProductModel>> {
  ProductListNotifier() : super([
    ProductModel(
      id: '1',
      title: '3 Piece Exclusive',
      subtitle: 'â¨Exclusive Premium Collection',
      image: 'https://images.unsplash.com/photo-1595777457583-95e059d581b8?w=400',
      wholesalePrice: 1270,
      originalPrice: 1590,
      maxResalePrice: 1800,
      category: 'Fashion',
      rating: 4.8,
    ),
    ProductModel(
      id: '2',
      title: 'Smart Watch S2000',
      subtitle: 'âLatest Series',
      image: 'https://images.unsplash.com/photo-1546868871-7041f2a55e12?w=400',
      wholesalePrice: 950,
      originalPrice: 1300,
      maxResalePrice: 1500,
      category: 'Smart Watch',
      rating: 4.5,
    ),
    ProductModel(
      id: '3',
      title: 'Walar Mr Thin 6500',
      subtitle: 'ðPremium Quality',
      image: 'https://images.unsplash.com/photo-1608571423902-eed4a5ad8108?w=400',
      wholesalePrice: 570,
      originalPrice: 980,
      maxResalePrice: 1200,
      category: 'Fashion',
      rating: 4.6,
    ),
    ProductModel(
      id: '4',
      title: 'Mini Portable Fan',
      subtitle: 'ðSummer Essential',
      image: 'https://images.unsplash.com/photo-1618941716939-553df3c6c278?w=400',
      wholesalePrice: 450,
      originalPrice: 720,
      maxResalePrice: 900,
      category: 'Electronics',
      rating: 4.3,
    ),
    ProductModel(
      id: '5',
      title: 'Leather Card Holder',
      subtitle: 'ð¼Stylish & Compact',
      image: 'https://images.unsplash.com/photo-1624114545437-f1b17c603a3a?w=400',
      wholesalePrice: 380,
      originalPrice: 650,
      maxResalePrice: 800,
      category: 'Fashion',
      rating: 4.4,
    ),
    ProductModel(
      id: '6',
      title: 'Premium Wrist Watch',
      subtitle: 'âClassic Design',
      image: 'https://images.unsplash.com/photo-1524592094714-0f0654e20314?w=400',
      wholesalePrice: 1100,
      originalPrice: 1600,
      maxResalePrice: 2000,
      category: 'Smart Watch',
      rating: 4.7,
    ),
  ]);

  void addProduct(ProductModel product) {
    state = [...state, product];
  }

  void updateProduct(ProductModel updated) {
    state = state.map((p) => p.id == updated.id ? updated : p).toList();
  }

  void removeProduct(String id) {
    state = state.where((p) => p.id != id).toList();
  }

  List<String> get categories {
    final cats = state.map((p) => p.category).toSet().toList();
    cats.sort();
    return ['All', ...cats];
  }
}

// ==================== CATEGORY CONFIG ====================

class CategoryStyle {
  final String label;
  final IconData icon;
  final Color color;

  CategoryStyle({
    required this.label,
    required this.icon,
    required this.color,
  });
}

final Map<String, CategoryStyle> _categoryStyles = {
  'All': CategoryStyle(label: 'All', icon: CupertinoIcons.square_grid_2x2, color: const Color(0xFF29B6F6)),
  'Smart Watch': CategoryStyle(label: 'Smart Watch', icon: CupertinoIcons.clock, color: const Color(0xFF6366F1)),
  'Neckband': CategoryStyle(label: 'Neckband', icon: CupertinoIcons.headphones, color: const Color(0xFFEC4899)),
  'Airpods': CategoryStyle(label: 'Airpods', icon: CupertinoIcons.music_note, color: const Color(0xFF10B981)),
  'Power Bank': CategoryStyle(label: 'Power Bank', icon: CupertinoIcons.battery_100, color: const Color(0xFFF59E0B)),
  'Earphone': CategoryStyle(label: 'Earphone', icon: CupertinoIcons.mic, color: const Color(0xFF3B82F6)),
  'Electronics': CategoryStyle(label: 'Electronics', icon: CupertinoIcons.device_phone_portrait, color: const Color(0xFF6366F1)),
  'Fashion': CategoryStyle(label: 'Fashion', icon: CupertinoIcons.bag, color: const Color(0xFF10B981)),
  'Audio': CategoryStyle(label: 'Audio', icon: CupertinoIcons.volume_up, color: const Color(0xFFEC4899)),
  'Watches': CategoryStyle(label: 'Watches', icon: CupertinoIcons.clock, color: const Color(0xFFF59E0B)),
  'Home': CategoryStyle(label: 'Home', icon: CupertinoIcons.house, color: const Color(0xFF3B82F6)),
  'Sports': CategoryStyle(label: 'Sports', icon: CupertinoIcons.bolt, color: const Color(0xFFEF4444)),
  'Beauty': CategoryStyle(label: 'Beauty', icon: CupertinoIcons.heart, color: const Color(0xFFD946EF)),
  'Books': CategoryStyle(label: 'Books', icon: CupertinoIcons.book, color: const Color(0xFF8B5CF6)),
  'Toys': CategoryStyle(label: 'Toys', icon: CupertinoIcons.gift, color: const Color(0xFF06B6D4)),
};

CategoryStyle _getCategoryStyle(String category) {
  return _categoryStyles[category] ?? CategoryStyle(
    label: category,
    icon: CupertinoIcons.tag,
    color: const Color(0xFF29B6F6),
  );
}

// ==================== DATA MODEL ====================

class ProductModel {
  final String id;
  final String title;
  final String? subtitle;
  final String image;
  final double wholesalePrice;
  final double? originalPrice;
  final double maxResalePrice;
  final String category;
  final double rating;
  bool isReselling;
  double myMargin;

  ProductModel({
    required this.id,
    required this.title,
    this.subtitle,
    required this.image,
    required this.wholesalePrice,
    this.originalPrice,
    required this.maxResalePrice,
    required this.category,
    required this.rating,
    this.isReselling = false,
    this.myMargin = 0,
  });

  double get myPrice => wholesalePrice + myMargin;
  double get maxMargin => maxResalePrice - wholesalePrice;
}

// ==================== MAIN SCREEN ====================

class ResellingScreen extends ConsumerStatefulWidget {
  const ResellingScreen({super.key});

  @override
  ConsumerState<ResellingScreen> createState() => _ResellingScreenState();
}

class _ResellingScreenState extends ConsumerState<ResellingScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  String _selectedCategory = 'All';
  String _searchQuery = '';
  bool _isSearchFocused = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (mounted) setState(() {});
    });
    _searchFocusNode.addListener(() {
      if (mounted) setState(() => _isSearchFocused = _searchFocusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  List<ProductModel> _filterProducts(List<ProductModel> all) {
    return all.where((p) {
      final matchCat = _selectedCategory == 'All' || p.category == _selectedCategory;
      final matchSearch = p.title.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchCat && matchSearch;
    }).toList();
  }

  void _showAddProductSheet() {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddProductBottomSheet(
        onProductAdded: (product) {
          ref.read(productListProvider.notifier).addProduct(product);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final allProducts = ref.watch(productListProvider);
    final filtered = _filterProducts(allProducts);
    final myResells = allProducts.where((p) => p.isReselling).toList();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final kBackground = isDark ? const Color(0xFF121212) : const Color(0xFFF8FAFC);
    final kTextDark = isDark ? Colors.white : const Color(0xFF0F172A);
    final kTextMid = isDark ? Colors.grey.shade400 : const Color(0xFF475569);
    final cardBackground = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final shadowColor = isDark ? Colors.black.withOpacity(0.3) : Colors.black.withOpacity(0.04);
    final borderColor = isDark ? const Color(0xFF333333) : Colors.grey.withOpacity(0.1);
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 1024;
    final isTablet = screenWidth >= 600 && screenWidth < 1024;
    final isSmall = screenWidth < 360;
    final hPadding = isDesktop ? 32.w : isTablet ? 20.w : isSmall ? 12.w : 16.w;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: kBackground,
        body: SafeArea(
          bottom: false,
          child: NestedScrollView(
            physics: const BouncingScrollPhysics(),
            headerSliverBuilder: (_, __) => [
              SliverToBoxAdapter(child: _buildSearchBar(hPadding, isSmall, kTextDark, kTextMid, cardBackground, shadowColor, borderColor)),
              SliverToBoxAdapter(child: _buildBannerSlider(isSmall, isTablet, isDesktop)),
              SliverToBoxAdapter(child: _buildQuickActions(hPadding, isSmall, isDesktop, cardBackground, shadowColor, borderColor, kTextDark)),
              SliverToBoxAdapter(child: _buildSectionHeader(hPadding, isSmall, isDesktop, kTextDark, kTextMid, title: 'Categories', subtitle: 'Browse by category', showViewAll: true)),
              SliverToBoxAdapter(child: _buildCategoryFilter(allProducts, isSmall, isDesktop, cardBackground, shadowColor, borderColor, kTextDark)),
              SliverToBoxAdapter(child: _buildSectionHeader(hPadding, isSmall, isDesktop, kTextDark, kTextMid, title: 'Most Popular Products', subtitle: 'Trending now', showViewAll: true)),
              SliverToBoxAdapter(child: _buildCustomTabBar(filtered.length, myResells.length, hPadding, isSmall, cardBackground, borderColor, kTextDark, kTextMid)),
            ],
            body: TabBarView(
              controller: _tabController,
              physics: const BouncingScrollPhysics(),
              children: [
                _buildProductsTab(filtered, isSmall, isDesktop, isTablet, cardBackground, shadowColor, kTextDark, kTextMid),
                _buildMyResellsTab(myResells, isSmall, cardBackground, shadowColor, borderColor, kTextDark, kTextMid),
              ],
            ),
          ),
        ),
        floatingActionButton: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (myResells.isNotEmpty)
              FloatingActionButton.small(
                heroTag: 'sales',
                onPressed: () => _tabController.animateTo(1),
                backgroundColor: cardBackground,
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                child: Badge(
                  label: Text('${myResells.length}'),
                  child: Icon(CupertinoIcons.chart_bar, color: const Color(0xFF29B6F6), size: 18.sp),
                ),
              ).animate().scale(delay: 100.ms),
            SizedBox(height: 8.h),
            FloatingActionButton.extended(
              heroTag: 'add',
              onPressed: _showAddProductSheet,
              backgroundColor: const Color(0xFF29B6F6),
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
              icon: Icon(CupertinoIcons.add, size: 18.sp, color: Colors.white),
              label: Text(
                'Add Product',
                style: GoogleFonts.poppins(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ).animate().scale(delay: 150.ms),
          ],
        ),
      ),
    );
  }

  // ==================== SEARCH BAR ====================
  Widget _buildSearchBar(double hPadding, bool isSmall, Color kTextDark, Color kTextMid, Color cardBackground, Color shadowColor, Color borderColor) {
    return Padding(
      padding: EdgeInsets.fromLTRB(hPadding, 12.h, hPadding, 0),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        decoration: BoxDecoration(
          color: cardBackground,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: _isSearchFocused ? const Color(0xFF29B6F6).withOpacity(0.5) : borderColor,
            width: _isSearchFocused ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: shadowColor,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          focusNode: _searchFocusNode,
          onChanged: (val) => setState(() => _searchQuery = val),
          style: GoogleFonts.poppins(
            fontSize: isSmall ? 12.sp : 13.sp,
            color: kTextDark,
          ),
          decoration: InputDecoration(
            hintText: 'Search Products...',
            hintStyle: GoogleFonts.poppins(
              fontSize: isSmall ? 12.sp : 13.sp,
              color: kTextMid,
            ),
            prefixIcon: Icon(
              CupertinoIcons.search,
              color: _isSearchFocused ? const Color(0xFF29B6F6) : kTextMid,
              size: isSmall ? 18.sp : 20.sp,
            ),
            suffixIcon: _searchQuery.isNotEmpty
                ? GestureDetector(
                    onTap: () {
                      _searchController.clear();
                      setState(() => _searchQuery = '');
                    },
                    child: Container(
                      margin: EdgeInsets.all(10.w),
                      decoration: BoxDecoration(
                        color: borderColor,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        CupertinoIcons.xmark,
                        color: kTextMid,
                        size: 12.sp,
                      ),
                    ),
                  )
                : null,
            filled: false,
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 14.h),
          ),
        ),
      ),
    ).animate().fadeIn(delay: 200.ms);
  }

  // ==================== BANNER SLIDER ====================
  Widget _buildBannerSlider(bool isSmall, bool isTablet, bool isDesktop) {
    final banners = [
      'https://images.unsplash.com/photo-1483985988355-763728e1935b?w=600',
      'https://images.unsplash.com/photo-1556742049-0cfed4f6a45d?w=600',
      'https://images.unsplash.com/photo-1607082348824-0a96f2a4b9da?w=600',
    ];
    final bannerHeight = isDesktop ? 160.h : isTablet ? 130.h : isSmall ? 100.h : 120.h;

    return Container(
      height: bannerHeight,
      margin: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.r),
        child: Stack(
          fit: StackFit.expand,
          children: [
            PageView.builder(
              itemCount: banners.length,
              itemBuilder: (context, index) {
                return Image.network(
                  banners[index],
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      color: const Color(0xFF29B6F6).withOpacity(0.1),
                      child: Center(child: CupertinoActivityIndicator(radius: 12.r)),
                    );
                  },
                  errorBuilder: (_, __, ___) => Container(
                    color: const Color(0xFF29B6F6).withOpacity(0.1),
                    child: Center(
                      child: Text(
                        'Banner Image',
                        style: GoogleFonts.poppins(
                          fontSize: 22.sp,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF29B6F6),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Colors.black.withOpacity(0.3),
                    Colors.transparent,
                    Colors.transparent,
                  ],
                ),
              ),
            ),
            Positioned(
              left: 14.w,
              top: 20.h,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFF29B6F6),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Text(
                      'Special Offer',
                      style: GoogleFonts.poppins(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Big Sale!',
                    style: GoogleFonts.poppins(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(color: Colors.black.withOpacity(0.3), blurRadius: 6, offset: const Offset(0, 2)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 250.ms).slideY(begin: 0.05);
  }

  // ==================== QUICK ACTIONS ====================
  Widget _buildQuickActions(double hPadding, bool isSmall, bool isDesktop, Color cardBackground, Color shadowColor, Color borderColor, Color kTextDark) {
    final actions = [
      _QuickActionData(icon: CupertinoIcons.doc_text, label: 'Orders', color: const Color(0xFF6366F1)),
      _QuickActionData(icon: CupertinoIcons.person_2, label: 'Customers', color: const Color(0xFF0284C7)),
      _QuickActionData(icon: CupertinoIcons.square_grid_2x2, label: 'Categories', color: const Color(0xFFEA580C)),
      _QuickActionData(icon: CupertinoIcons.heart, label: 'Wishlist', color: const Color(0xFF29B6F6)),
    ];

    return Padding(
      padding: EdgeInsets.fromLTRB(hPadding, 20.h, hPadding, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: actions.map((action) {
          final iconSize = isSmall ? 20.sp : isDesktop ? 24.sp : 22.sp;
          final containerSize = isSmall ? 44.w : isDesktop ? 56.w : 48.w;

          return GestureDetector(
            onTap: () => HapticFeedback.lightImpact(),
            child: Column(
              children: [
                Container(
                  width: containerSize,
                  height: containerSize,
                  decoration: BoxDecoration(
                    color: cardBackground,
                    shape: BoxShape.circle,
                    border: Border.all(color: borderColor, width: 0.5),
                    boxShadow: [
                      BoxShadow(color: shadowColor, blurRadius: 6, offset: const Offset(0, 2)),
                    ],
                  ),
                  child: Center(
                    child: Icon(action.icon, color: action.color, size: iconSize),
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  action.label,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: isSmall ? 9.sp : 10.sp,
                    fontWeight: FontWeight.w500,
                    color: kTextDark,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(delay: (actions.indexOf(action) * 80).ms).scale(
            begin: const Offset(0.85, 0.85),
            curve: Curves.easeOutBack,
          );
        }).toList(),
      ),
    );
  }

  // ==================== SECTION HEADER ====================
  Widget _buildSectionHeader(double hPadding, bool isSmall, bool isDesktop, Color kTextDark, Color kTextMid, {required String title, required String subtitle, bool showViewAll = false}) {
    return Padding(
      padding: EdgeInsets.fromLTRB(hPadding, 24.h, hPadding, 0),
      child: Row(
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
                      color: const Color(0xFF29B6F6),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(width: 2.w),
                  Icon(CupertinoIcons.chevron_right, size: isSmall ? 10.sp : 12.sp, color: const Color(0xFF29B6F6)),
                ],
              ),
            ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms);
  }

  // ==================== CATEGORY FILTER ====================
  Widget _buildCategoryFilter(List<ProductModel> allProducts, bool isSmall, bool isDesktop, Color cardBackground, Color shadowColor, Color borderColor, Color kTextDark) {
    final categories = ref.read(productListProvider.notifier).categories;

    return SizedBox(
      height: isSmall ? 90.h : 100.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 4.h),
        itemCount: categories.length,
        separatorBuilder: (_, __) => SizedBox(width: 12.w),
        itemBuilder: (_, i) {
          final cat = categories[i];
          final selected = _selectedCategory == cat;
          final style = _getCategoryStyle(cat);
          final iconSize = isSmall ? 20.sp : isDesktop ? 26.sp : 22.sp;
          final containerSize = isSmall ? 44.w : isDesktop ? 56.w : 50.w;

          return GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() => _selectedCategory = cat);
            },
            child: Column(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  width: containerSize,
                  height: containerSize,
                  decoration: BoxDecoration(
                    color: selected ? style.color.withOpacity(0.15) : cardBackground,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: selected ? style.color.withOpacity(0.5) : borderColor,
                      width: selected ? 2 : 0.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: shadowColor,
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Icon(
                      style.icon,
                      color: selected ? style.color : kTextDark.withOpacity(0.6),
                      size: iconSize,
                    ),
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  cat,
                  style: GoogleFonts.poppins(
                    fontSize: isSmall ? 9.sp : 10.sp,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    color: selected ? style.color : kTextDark,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          );
        },
      ),
    ).animate().fadeIn(delay: 300.ms);
  }

  // ==================== CUSTOM TAB BAR ====================
  Widget _buildCustomTabBar(int allCount, int myCount, double hPadding, bool isSmall, Color cardBackground, Color borderColor, Color kTextDark, Color kTextMid) {
    return Container(
      margin: EdgeInsets.fromLTRB(hPadding, 16.h, hPadding, 4.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: cardBackground,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => _tabController.animateTo(0),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding: EdgeInsets.symmetric(vertical: 10.h),
                decoration: BoxDecoration(
                  color: _tabController.index == 0 ? const Color(0xFF29B6F6) : Colors.transparent,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Text(
                  'All Products ($allCount)',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: isSmall ? 11.sp : 12.sp,
                    fontWeight: FontWeight.w600,
                    color: _tabController.index == 0 ? Colors.white : kTextMid,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => _tabController.animateTo(1),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding: EdgeInsets.symmetric(vertical: 10.h),
                decoration: BoxDecoration(
                  color: _tabController.index == 1 ? const Color(0xFF29B6F6) : Colors.transparent,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Text(
                  'My Sales ($myCount)',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: isSmall ? 11.sp : 12.sp,
                    fontWeight: FontWeight.w600,
                    color: _tabController.index == 1 ? Colors.white : kTextMid,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 350.ms);
  }

  // ==================== PRODUCTS TAB ====================
  Widget _buildProductsTab(List<ProductModel> products, bool isSmall, bool isDesktop, bool isTablet, Color cardBackground, Color shadowColor, Color kTextDark, Color kTextMid) {
    if (products.isEmpty) return _buildEmptyState(kTextMid);

    final crossAxisCount = isSmall ? 2 : (isTablet ? 3 : 2);
    final childAspectRatio = isSmall ? 0.62 : 0.58;

    return GridView.builder(
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 100.h),
      physics: const BouncingScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 10.w,
        mainAxisSpacing: 10.h,
        childAspectRatio: childAspectRatio,
      ),
      itemCount: products.length,
      itemBuilder: (_, i) => _ResellProductCard(
        product: products[i],
        isSmall: isSmall,
        cardBackground: cardBackground,
        shadowColor: shadowColor,
        kTextDark: kTextDark,
        kTextMid: kTextMid,
        onResell: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ProductDetailsPage(
                product: products[i],
                onStartResell: (margin) {
                  final updated = ProductModel(
                    id: products[i].id,
                    title: products[i].title,
                    subtitle: products[i].subtitle,
                    image: products[i].image,
                    wholesalePrice: products[i].wholesalePrice,
                    originalPrice: products[i].originalPrice,
                    maxResalePrice: products[i].maxResalePrice,
                    category: products[i].category,
                    rating: products[i].rating,
                    isReselling: true,
                    myMargin: margin,
                  );
                  ref.read(productListProvider.notifier).updateProduct(updated);
                },
              ),
            ),
          );
        },
      ).animate().fadeIn(delay: (i * 50).ms, duration: 300.ms).slideY(begin: 0.06, curve: Curves.easeOut),
    );
  }

  void _showResellSheet(ProductModel product) {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ResellBottomSheet(
        product: product,
        onConfirm: (margin) {
          final updated = ProductModel(
            id: product.id,
            title: product.title,
            subtitle: product.subtitle,
            image: product.image,
            wholesalePrice: product.wholesalePrice,
            originalPrice: product.originalPrice,
            maxResalePrice: product.maxResalePrice,
            category: product.category,
            rating: product.rating,
            isReselling: true,
            myMargin: margin,
          );
          ref.read(productListProvider.notifier).updateProduct(updated);
        },
      ),
    );
  }

  // ==================== MY RESELLS TAB ====================
  Widget _buildMyResellsTab(List<ProductModel> myResells, bool isSmall, Color cardBackground, Color shadowColor, Color borderColor, Color kTextDark, Color kTextMid) {
    if (myResells.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(24.w),
              decoration: BoxDecoration(
                color: const Color(0xFF29B6F6).withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(CupertinoIcons.cube_box, size: 44.sp, color: const Color(0xFF29B6F6)),
            ).animate().scale(duration: 500.ms, curve: Curves.elasticOut),
            SizedBox(height: 16.h),
            Text(
              'No active sales yet',
              style: GoogleFonts.poppins(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: kTextDark,
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              'Pick a product and set your margin',
              style: GoogleFonts.poppins(
                fontSize: 13.sp,
                color: kTextMid,
              ),
            ),
            SizedBox(height: 20.h),
            GestureDetector(
              onTap: () => _tabController.animateTo(0),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: const Color(0xFF29B6F6),
                  borderRadius: BorderRadius.circular(12.r),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF29B6F6).withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Text(
                  'Browse Products',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14.sp,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 100.h),
      physics: const BouncingScrollPhysics(),
      itemCount: myResells.length,
      itemBuilder: (_, i) => _ActiveResellCard(
        product: myResells[i],
        isSmall: isSmall,
        cardBackground: cardBackground,
        shadowColor: shadowColor,
        borderColor: borderColor,
        kTextDark: kTextDark,
        kTextMid: kTextMid,
        onStop: () {
          final updated = ProductModel(
            id: myResells[i].id,
            title: myResells[i].title,
            subtitle: myResells[i].subtitle,
            image: myResells[i].image,
            wholesalePrice: myResells[i].wholesalePrice,
            originalPrice: myResells[i].originalPrice,
            maxResalePrice: myResells[i].maxResalePrice,
            category: myResells[i].category,
            rating: myResells[i].rating,
            isReselling: false,
            myMargin: 0,
          );
          ref.read(productListProvider.notifier).updateProduct(updated);
        },
      ).animate().fadeIn(delay: (i * 60).ms, duration: 300.ms).slideX(begin: 0.05, curve: Curves.easeOut),
    );
  }

  Widget _buildEmptyState(Color kTextMid) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(CupertinoIcons.search, size: 48.sp, color: kTextMid),
          SizedBox(height: 12.h),
          Text(
            'No products found',
            style: GoogleFonts.poppins(
              fontSize: 15.sp,
              fontWeight: FontWeight.w500,
              color: kTextMid,
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== RESELL PRODUCT CARD ====================

class _ResellProductCard extends StatefulWidget {
  final ProductModel product;
  final bool isSmall;
  final Color cardBackground;
  final Color shadowColor;
  final Color kTextDark;
  final Color kTextMid;
  final VoidCallback onResell;

  const _ResellProductCard({
    required this.product,
    required this.isSmall,
    required this.cardBackground,
    required this.shadowColor,
    required this.kTextDark,
    required this.kTextMid,
    required this.onResell,
  });

  @override
  State<_ResellProductCard> createState() => _ResellProductCardState();
}

class _ResellProductCardState extends State<_ResellProductCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: Container(
          decoration: BoxDecoration(
            color: widget.cardBackground,
            borderRadius: BorderRadius.circular(12.r),
            boxShadow: [
              BoxShadow(
                color: widget.shadowColor,
                blurRadius: 6,
                offset: const Offset(0, 2),
                spreadRadius: 0,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(12.r)),
                    child: SizedBox(
                      height: widget.isSmall ? 110.h : 125.h,
                      width: double.infinity,
                      child: Image.network(
                        widget.product.image,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            color: const Color(0xFF29B6F6).withOpacity(0.05),
                            child: Center(child: CupertinoActivityIndicator(radius: 12.r)),
                          );
                        },
                        errorBuilder: (_, __, ___) => Container(
                          color: Colors.grey.shade100,
                          child: Center(
                            child: Icon(CupertinoIcons.photo, color: Colors.grey.shade400, size: 28.sp),
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (widget.product.isReselling)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 3.h),
                        decoration: BoxDecoration(
                          color: const Color(0xFF34C759),
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(CupertinoIcons.checkmark_alt, color: Colors.white, size: 9.sp),
                            SizedBox(width: 2.w),
                            Text(
                              'Active',
                              style: GoogleFonts.poppins(
                                fontSize: 8.5.sp,
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
                      decoration: BoxDecoration(
                        color: widget.cardBackground.withOpacity(0.92),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(CupertinoIcons.star_fill, color: const Color(0xFFFFCC02), size: 10.sp),
                          SizedBox(width: 2.w),
                          Text(
                            widget.product.rating.toString(),
                            style: GoogleFonts.poppins(
                              fontSize: 9.sp,
                              fontWeight: FontWeight.w700,
                              color: widget.kTextDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(10.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.product.title,
                        style: GoogleFonts.poppins(
                          fontSize: widget.isSmall ? 10.sp : 11.sp,
                          fontWeight: FontWeight.w600,
                          color: widget.kTextDark,
                          height: 1.3,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (widget.product.subtitle != null) ...[
                        SizedBox(height: 2.h),
                        Text(
                          widget.product.subtitle!,
                          style: GoogleFonts.poppins(
                            fontSize: 9.sp,
                            fontWeight: FontWeight.w400,
                            color: widget.kTextMid,
                            height: 1.2,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      SizedBox(height: 6.h),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '\u09F3${widget.product.wholesalePrice.toInt()}',
                            style: GoogleFonts.poppins(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF29B6F6),
                            ),
                          ),
                          SizedBox(width: 5.w),
                          if (widget.product.originalPrice != null)
                            Text(
                              '\u09F3${widget.product.originalPrice!.toInt()}',
                              style: GoogleFonts.poppins(
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w500,
                                color: widget.kTextMid,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                        ],
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: widget.onResell,
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(vertical: 8.h),
                          decoration: BoxDecoration(
                            color: const Color(0xFF29B6F6),
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(CupertinoIcons.add, color: Colors.white, size: 12.sp),
                              SizedBox(width: 4.w),
                              Text(
                                'Resell',
                                style: GoogleFonts.poppins(
                                  fontSize: 10.5.sp,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
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
}

// ==================== ACTIVE RESELL CARD ====================

class _ActiveResellCard extends StatelessWidget {
  final ProductModel product;
  final bool isSmall;
  final Color cardBackground;
  final Color shadowColor;
  final Color borderColor;
  final Color kTextDark;
  final Color kTextMid;
  final VoidCallback onStop;

  const _ActiveResellCard({
    required this.product,
    required this.isSmall,
    required this.cardBackground,
    required this.shadowColor,
    required this.borderColor,
    required this.kTextDark,
    required this.kTextMid,
    required this.onStop,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: cardBackground,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: 6,
            offset: const Offset(0, 2),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10.r),
            child: SizedBox(
              width: 60.w,
              height: 60.w,
              child: Image.network(
                product.image,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(child: CupertinoActivityIndicator(radius: 10.r));
                },
                errorBuilder: (_, __, ___) => Container(
                  color: Colors.grey.shade100,
                  child: Icon(CupertinoIcons.photo, color: Colors.grey.shade400, size: 22.sp),
                ),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.title,
                  style: GoogleFonts.poppins(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: kTextDark,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Text(
                      'Sell: ',
                      style: GoogleFonts.poppins(
                        fontSize: 11.sp,
                        color: kTextMid,
                      ),
                    ),
                    Text(
                      '\u09F3${product.myPrice.toInt()}',
                      style: GoogleFonts.poppins(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF29B6F6),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4.h),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFF34C759).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Text(
                    'Profit \u09F3${product.myMargin.toInt()}',
                    style: GoogleFonts.poppins(
                      fontSize: 9.5.sp,
                      color: const Color(0xFF34C759),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                SizedBox(height: 8.h),
                Row(
                  children: [
                    _MiniButton(
                      icon: CupertinoIcons.stop_circle,
                      label: 'Stop',
                      color: const Color(0xFFFF3B30),
                      onTap: onStop,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== RESELL BOTTOM SHEET ====================

class ResellBottomSheet extends StatefulWidget {
  final ProductModel product;
  final Function(double margin) onConfirm;

  const ResellBottomSheet({
    super.key,
    required this.product,
    required this.onConfirm,
  });

  @override
  State<ResellBottomSheet> createState() => _ResellBottomSheetState();
}

class _ResellBottomSheetState extends State<ResellBottomSheet> {
  double _margin = 0;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBackground = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final kTextDark = isDark ? Colors.white : const Color(0xFF0F172A);
    final kTextMid = isDark ? Colors.grey.shade400 : const Color(0xFF475569);
    final borderColor = isDark ? const Color(0xFF333333) : Colors.grey.withOpacity(0.1);

    final maxMargin = widget.product.maxMargin;
    final sellPrice = widget.product.wholesalePrice + _margin;

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24.h,
      ),
      decoration: BoxDecoration(
        color: cardBackground,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              margin: EdgeInsets.only(top: 12.h),
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: borderColor,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
          ),
          SizedBox(height: 20.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12.r),
                  child: SizedBox(
                    width: 52.w,
                    height: 52.w,
                    child: Image.network(
                      widget.product.image,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: Colors.grey.shade100,
                        child: Icon(CupertinoIcons.photo, color: Colors.grey.shade400),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 14.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.product.title,
                        style: GoogleFonts.poppins(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.bold,
                          color: kTextDark,
                        ),
                      ),
                      Text(
                        'Wholesale: \u09F3${widget.product.wholesalePrice.toInt()}',
                        style: GoogleFonts.poppins(
                          fontSize: 12.sp,
                          color: kTextMid,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 24.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Text(
              'Set Your Margin',
              style: GoogleFonts.poppins(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
                color: kTextDark,
              ),
            ),
          ),
          SizedBox(height: 10.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('\u09F30', style: GoogleFonts.poppins(fontSize: 12.sp, color: kTextMid)),
                Text('\u09F3${maxMargin.toInt()}', style: GoogleFonts.poppins(fontSize: 12.sp, color: kTextMid)),
              ],
            ),
          ),
          Slider(
            value: _margin,
            min: 0,
            max: maxMargin,
            divisions: maxMargin.toInt(),
            activeColor: const Color(0xFF29B6F6),
            inactiveColor: borderColor,
            thumbColor: const Color(0xFF29B6F6),
            onChanged: (val) => setState(() => _margin = val),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(14.w),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF2C2C2C) : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: borderColor),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Margin',
                          style: GoogleFonts.poppins(fontSize: 11.sp, color: kTextMid),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          '\u09F3${_margin.toInt()}',
                          style: GoogleFonts.poppins(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF34C759),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(14.w),
                    decoration: BoxDecoration(
                      color: const Color(0xFF29B6F6).withOpacity(0.06),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: const Color(0xFF29B6F6).withOpacity(0.2)),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Sell Price',
                          style: GoogleFonts.poppins(fontSize: 11.sp, color: kTextMid),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          '\u09F3${sellPrice.toInt()}',
                          style: GoogleFonts.poppins(
                            fontSize: 20.sp,
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
          SizedBox(height: 20.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: GestureDetector(
              onTap: () {
                HapticFeedback.mediumImpact();
                widget.onConfirm(_margin);
                Navigator.pop(context);
              },
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 16.h),
                decoration: BoxDecoration(
                  color: const Color(0xFF29B6F6),
                  borderRadius: BorderRadius.circular(14.r),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF29B6F6).withOpacity(0.3),
                      blurRadius: 14,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Text(
                  'Start Reselling',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 12.h),
        ],
      ),
    ).animate().slideY(begin: 0.15, duration: 300.ms, curve: Curves.easeOut);
  }
}

// ==================== ADD PRODUCT BOTTOM SHEET ====================

class AddProductBottomSheet extends StatefulWidget {
  final Function(ProductModel product) onProductAdded;

  const AddProductBottomSheet({super.key, required this.onProductAdded});

  @override
  State<AddProductBottomSheet> createState() => _AddProductBottomSheetState();
}

class _AddProductBottomSheetState extends State<AddProductBottomSheet> {
  final _titleController = TextEditingController();
  final _subtitleController = TextEditingController();
  final _imageController = TextEditingController();
  final _priceController = TextEditingController();
  final _originalPriceController = TextEditingController();
  final _maxPriceController = TextEditingController();

  String _selectedCategory = 'Electronics';
  final List<String> _availableCategories = [
    'Electronics', 'Smart Watch', 'Neckband', 'Airpods',
    'Power Bank', 'Earphone', 'Fashion', 'Home',
    'Sports', 'Beauty', 'Books', 'Toys',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _subtitleController.dispose();
    _imageController.dispose();
    _priceController.dispose();
    _originalPriceController.dispose();
    _maxPriceController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_titleController.text.isEmpty || _priceController.text.isEmpty || _maxPriceController.text.isEmpty) {
      HapticFeedback.heavyImpact();
      return;
    }

    final wholesale = double.tryParse(_priceController.text) ?? 0;
    final original = double.tryParse(_originalPriceController.text) ?? 0;
    final maxResale = double.tryParse(_maxPriceController.text) ?? 0;

    if (wholesale <= 0 || maxResale <= wholesale) return;

    final product = ProductModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleController.text.trim(),
      subtitle: _subtitleController.text.trim().isNotEmpty ? _subtitleController.text.trim() : null,
      image: _imageController.text.trim().isNotEmpty
          ? _imageController.text.trim()
          : 'https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=400',
      wholesalePrice: wholesale,
      originalPrice: original > 0 ? original : null,
      maxResalePrice: maxResale,
      category: _selectedCategory,
      rating: 4.5,
    );

    widget.onProductAdded(product);
    HapticFeedback.mediumImpact();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBackground = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final kTextDark = isDark ? Colors.white : const Color(0xFF0F172A);
    final kTextMid = isDark ? Colors.grey.shade400 : const Color(0xFF475569);
    final borderColor = isDark ? const Color(0xFF333333) : Colors.grey.withOpacity(0.1);

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24.h,
      ),
      decoration: BoxDecoration(
        color: cardBackground,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                margin: EdgeInsets.only(top: 12.h),
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: borderColor,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),
            SizedBox(height: 24.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: const Color(0xFF29B6F6).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                    child: Icon(
                      CupertinoIcons.add_circled,
                      color: const Color(0xFF29B6F6),
                      size: 24.sp,
                    ),
                  ),
                  SizedBox(width: 14.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Add New Product',
                          style: GoogleFonts.poppins(
                            fontSize: 17.sp,
                            fontWeight: FontWeight.bold,
                            color: kTextDark,
                          ),
                        ),
                        Text(
                          'Fill the details to list your product',
                          style: GoogleFonts.poppins(
                            fontSize: 12.sp,
                            color: kTextMid,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24.h),
            _buildTextField(
              label: 'Product Title',
              hint: 'e.g. Wireless Earbuds Pro',
              controller: _titleController,
              icon: CupertinoIcons.tag,
              kTextDark: kTextDark,
              kTextMid: kTextMid,
              borderColor: borderColor,
              isDark: isDark,
            ),
            SizedBox(height: 14.h),
            _buildTextField(
              label: 'Subtitle (with emoji)',
              hint: 'e.g. â¨Premium Quality',
              controller: _subtitleController,
              icon: CupertinoIcons.textformat,
              kTextDark: kTextDark,
              kTextMid: kTextMid,
              borderColor: borderColor,
              isDark: isDark,
            ),
            SizedBox(height: 14.h),
            _buildTextField(
              label: 'Image URL',
              hint: 'Paste product image link (optional)',
              controller: _imageController,
              icon: CupertinoIcons.photo,
              kTextDark: kTextDark,
              kTextMid: kTextMid,
              borderColor: borderColor,
              isDark: isDark,
            ),
            SizedBox(height: 14.h),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    label: 'Wholesale Price',
                    hint: 'Buying price',
                    controller: _priceController,
                    icon: CupertinoIcons.money_dollar_circle,
                    keyboardType: TextInputType.number,
                    kTextDark: kTextDark,
                    kTextMid: kTextMid,
                    borderColor: borderColor,
                    isDark: isDark,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: _buildTextField(
                    label: 'Original Price',
                    hint: 'MRP (optional)',
                    controller: _originalPriceController,
                    icon: CupertinoIcons.tag_circle,
                    keyboardType: TextInputType.number,
                    kTextDark: kTextDark,
                    kTextMid: kTextMid,
                    borderColor: borderColor,
                    isDark: isDark,
                  ),
                ),
              ],
            ),
            SizedBox(height: 14.h),
            _buildTextField(
              label: 'Max Resale Price',
              hint: 'Maximum you can sell for',
              controller: _maxPriceController,
              icon: CupertinoIcons.arrow_up_circle,
              keyboardType: TextInputType.number,
              kTextDark: kTextDark,
              kTextMid: kTextMid,
              borderColor: borderColor,
              isDark: isDark,
            ),
            SizedBox(height: 18.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Text(
                'Select Category',
                style: GoogleFonts.poppins(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.bold,
                  color: kTextDark,
                ),
              ),
            ),
            SizedBox(height: 10.h),
            SizedBox(
              height: 44.h,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                itemCount: _availableCategories.length,
                separatorBuilder: (_, __) => SizedBox(width: 8.w),
                itemBuilder: (_, i) {
                  final cat = _availableCategories[i];
                  final selected = _selectedCategory == cat;
                  final style = _getCategoryStyle(cat);
                  return GestureDetector(
                    onTap: () => setState(() => _selectedCategory = cat),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 9.h),
                      decoration: BoxDecoration(
                        color: selected ? style.color.withOpacity(0.15) : (isDark ? const Color(0xFF2C2C2C) : const Color(0xFFF1F5F9)),
                        borderRadius: BorderRadius.circular(10.r),
                        border: Border.all(
                          color: selected ? style.color.withOpacity(0.5) : borderColor,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            style.icon,
                            size: 15.sp,
                            color: selected ? style.color : kTextMid,
                          ),
                          SizedBox(width: 6.w),
                          Text(
                            cat,
                            style: GoogleFonts.poppins(
                              fontSize: 12.sp,
                              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                              color: selected ? style.color : kTextMid,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 24.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: GestureDetector(
                onTap: _submit,
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFF29B6F6),
                    borderRadius: BorderRadius.circular(14.r),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF29B6F6).withOpacity(0.3),
                        blurRadius: 14,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Text(
                    'Add Product',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 12.h),
          ],
        ),
      ),
    ).animate().slideY(begin: 0.15, duration: 300.ms, curve: Curves.easeOut);
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required IconData icon,
    required Color kTextDark,
    required Color kTextMid,
    required Color borderColor,
    required bool isDark,
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: kTextDark,
            ),
          ),
          SizedBox(height: 6.h),
          Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF2C2C2C) : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: borderColor),
            ),
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              style: GoogleFonts.poppins(
                fontSize: 14.sp,
                color: kTextDark,
              ),
              decoration: InputDecoration(
                prefixIcon: Icon(icon, color: kTextMid, size: 18.sp),
                hintText: hint,
                hintStyle: GoogleFonts.poppins(
                  fontSize: 13.sp,
                  color: kTextMid,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 14.h),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== HELPER CLASSES & WIDGETS ====================

class _QuickActionData {
  final IconData icon;
  final String label;
  final Color color;

  _QuickActionData({required this.icon, required this.label, required this.color});
}

class _MiniButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _MiniButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  State<_MiniButton> createState() => _MiniButtonState();
}

class _MiniButtonState extends State<_MiniButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        HapticFeedback.lightImpact();
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.93 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
          decoration: BoxDecoration(
            color: widget.color.withOpacity(_pressed ? 0.18 : 0.1),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(widget.icon, size: 12.sp, color: widget.color),
              SizedBox(width: 4.w),
              Text(
                widget.label,
                style: GoogleFonts.poppins(
                  fontSize: 10.sp,
                  color: widget.color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==================== PRODUCT DETAILS PAGE ====================

class ProductDetailsPage extends StatefulWidget {
  final ProductModel product;
  final Function(double margin) onStartResell;

  const ProductDetailsPage({
    super.key,
    required this.product,
    required this.onStartResell,
  });

  @override
  State<ProductDetailsPage> createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage>
    with SingleTickerProviderStateMixin {
  final PageController _imagePageController = PageController();
  int _currentImageIndex = 0;
  bool _isWishlisted = false;
  bool _showFullDescription = false;
  late AnimationController _heartAnimController;

  late List<String> _productImages;

  @override
  void initState() {
    super.initState();
    _heartAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _productImages = [
      widget.product.image,
      widget.product.image.replaceAll('w=400', 'w=401'),
      widget.product.image.replaceAll('w=400', 'w=402'),
      widget.product.image.replaceAll('w=400', 'w=403'),
    ];
  }

  @override
  void dispose() {
    _imagePageController.dispose();
    _heartAnimController.dispose();
    super.dispose();
  }

  void _showResellSheet() {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ResellBottomSheet(
        product: widget.product,
        onConfirm: (margin) {
          widget.onStartResell(margin);
          Navigator.pop(context);
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final kBackground = isDark ? const Color(0xFF121212) : const Color(0xFFF8FAFC);
    final kTextDark = isDark ? Colors.white : const Color(0xFF0F172A);
    final kTextMid = isDark ? Colors.grey.shade400 : const Color(0xFF64748B);
    final cardBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final borderColor = isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE8EDF2);

    final discount = widget.product.originalPrice != null
        ? (((widget.product.originalPrice! - widget.product.wholesalePrice) /
                    widget.product.originalPrice!) *
                100)
            .toStringAsFixed(0)
        : null;

    final maxProfit = widget.product.maxResalePrice - widget.product.wholesalePrice;

    return Scaffold(
      backgroundColor: kBackground,
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(isDark, kTextDark),
      body: Stack(
        children: [
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildImageSlider(isDark, cardBg),
                _buildPriceSection(isDark, kTextDark, kTextMid, cardBg, borderColor, discount),
                SizedBox(height: 8.h),
                _buildProfitBanner(isDark, maxProfit),
                SizedBox(height: 8.h),
                _buildDeliveryInfo(isDark, cardBg, kTextDark, kTextMid, borderColor),
                SizedBox(height: 8.h),
                _buildHighlights(isDark, cardBg, kTextDark, kTextMid, borderColor),
                SizedBox(height: 8.h),
                _buildDescription(isDark, cardBg, kTextDark, kTextMid, borderColor),
                SizedBox(height: 8.h),
                _buildSellerInfo(isDark, cardBg, kTextDark, kTextMid, borderColor),
                SizedBox(height: 8.h),
                _buildRatings(isDark, cardBg, kTextDark, kTextMid, borderColor),
                SizedBox(height: 100.h),
              ],
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildBottomBar(isDark, cardBg, kTextDark, kTextMid, borderColor),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(bool isDark, Color kTextDark) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          margin: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E1E).withOpacity(0.9) : Colors.white.withOpacity(0.9),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            CupertinoIcons.chevron_left,
            color: kTextDark,
            size: 18.sp,
          ),
        ),
      ),
      actions: [
        GestureDetector(
          onTap: () {
            setState(() => _isWishlisted = !_isWishlisted);
            _heartAnimController.forward(from: 0);
            HapticFeedback.lightImpact();
          },
          child: Container(
            margin: EdgeInsets.all(8.w),
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E1E).withOpacity(0.9) : Colors.white.withOpacity(0.9),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Icon(
                _isWishlisted ? CupertinoIcons.heart_fill : CupertinoIcons.heart,
                key: ValueKey(_isWishlisted),
                color: _isWishlisted ? const Color(0xFFFF3B30) : Colors.grey,
                size: 18.sp,
              ),
            ),
          ),
        ),
        GestureDetector(
          onTap: () {},
          child: Container(
            margin: EdgeInsets.only(right: 12.w, top: 8.w, bottom: 8.w),
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E1E).withOpacity(0.9) : Colors.white.withOpacity(0.9),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              CupertinoIcons.share,
              color: Colors.grey,
              size: 18.sp,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImageSlider(bool isDark, Color cardBg) {
    return Container(
      height: 320.h,
      color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
      child: Stack(
        children: [
          PageView.builder(
            controller: _imagePageController,
            itemCount: _productImages.length,
            onPageChanged: (i) => setState(() => _currentImageIndex = i),
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.all(24.w),
                child: Image.network(
                  _productImages[index],
                  fit: BoxFit.contain,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CupertinoActivityIndicator(
                        radius: 14.r,
                        color: const Color(0xFFFF6600),
                      ),
                    );
                  },
                  errorBuilder: (_, __, ___) => Center(
                    child: Icon(
                      CupertinoIcons.photo,
                      color: Colors.grey.shade300,
                      size: 60.sp,
                    ),
                  ),
                ),
              );
            },
          ),
          Positioned(
            left: 0,
            top: 60.h,
            child: Column(
              children: List.generate(_productImages.length, (i) {
                final selected = _currentImageIndex == i;
                return GestureDetector(
                  onTap: () {
                    _imagePageController.animateToPage(
                      i,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: EdgeInsets.symmetric(vertical: 4.h, horizontal: 8.w),
                    width: selected ? 46.w : 42.w,
                    height: selected ? 46.w : 42.w,
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(
                        color: selected ? const Color(0xFFFF6600) : Colors.grey.withOpacity(0.25),
                        width: selected ? 2 : 1,
                      ),
                      boxShadow: selected
                          ? [
                              BoxShadow(
                                color: const Color(0xFFFF6600).withOpacity(0.2),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : [],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(7.r),
                      child: Image.network(
                        _productImages[i],
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Icon(
                          CupertinoIcons.photo,
                          color: Colors.grey.shade300,
                          size: 18.sp,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          Positioned(
            bottom: 12.h,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_productImages.length, (i) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: EdgeInsets.symmetric(horizontal: 3.w),
                  width: _currentImageIndex == i ? 20.w : 6.w,
                  height: 6.h,
                  decoration: BoxDecoration(
                    color: _currentImageIndex == i
                        ? const Color(0xFFFF6600)
                        : Colors.grey.withOpacity(0.35),
                    borderRadius: BorderRadius.circular(3.r),
                  ),
                );
              }),
            ),
          ),
          if (widget.product.originalPrice != null)
            Positioned(
              top: 48.h,
              right: 12.w,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF6600),
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Text(
                  '-${((( widget.product.originalPrice! - widget.product.wholesalePrice) / widget.product.originalPrice!) * 100).toStringAsFixed(0)}%',
                  style: GoogleFonts.poppins(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ).animate().scale(delay: 300.ms, curve: Curves.elasticOut),
            ),
        ],
      ),
    );
  }

  Widget _buildPriceSection(bool isDark, Color kTextDark, Color kTextMid, Color cardBg, Color borderColor, String? discount) {
    return Container(
      color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '\u09F3${widget.product.wholesalePrice.toInt()}',
                style: GoogleFonts.poppins(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFFF6600),
                ),
              ),
              SizedBox(width: 10.w),
              if (widget.product.originalPrice != null) ...[
                Text(
                  '\u09F3${widget.product.originalPrice!.toInt()}',
                  style: GoogleFonts.poppins(
                    fontSize: 14.sp,
                    color: kTextMid,
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
                SizedBox(width: 8.w),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF6600).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  child: Text(
                    '-$discount%',
                    style: GoogleFonts.poppins(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFFFF6600),
                    ),
                  ),
                ),
              ],
            ],
          ).animate().fadeIn(delay: 100.ms).slideX(begin: -0.05),
          SizedBox(height: 10.h),
          Text(
            widget.product.title,
            style: GoogleFonts.poppins(
              fontSize: 15.sp,
              fontWeight: FontWeight.w600,
              color: kTextDark,
              height: 1.35,
            ),
          ).animate().fadeIn(delay: 150.ms),
          if (widget.product.subtitle != null) ...[
            SizedBox(height: 4.h),
            Text(
              widget.product.subtitle!,
              style: GoogleFonts.poppins(
                fontSize: 12.sp,
                color: kTextMid,
              ),
            ),
          ],
          SizedBox(height: 12.h),
          Divider(color: borderColor, height: 1),
          SizedBox(height: 12.h),
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: const Color(0xFF34C759).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6.r),
                  border: Border.all(color: const Color(0xFF34C759).withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(CupertinoIcons.star_fill, color: const Color(0xFFFFCC02), size: 13.sp),
                    SizedBox(width: 4.w),
                    Text(
                      widget.product.rating.toString(),
                      style: GoogleFonts.poppins(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF34C759),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 10.w),
              Text(
                '(234 ratings)',
                style: GoogleFonts.poppins(fontSize: 11.sp, color: kTextMid),
              ),
              SizedBox(width: 8.w),
              Text('|', style: TextStyle(color: borderColor)),
              SizedBox(width: 8.w),
              Text(
                '1.2k sold',
                style: GoogleFonts.poppins(
                  fontSize: 11.sp,
                  color: kTextMid,
                ),
              ),
            ],
          ).animate().fadeIn(delay: 200.ms),
          SizedBox(height: 12.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(color: borderColor),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(CupertinoIcons.tag, size: 12.sp, color: const Color(0xFF29B6F6)),
                SizedBox(width: 4.w),
                Text(
                  widget.product.category,
                  style: GoogleFonts.poppins(
                    fontSize: 11.sp,
                    color: const Color(0xFF29B6F6),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfitBanner(bool isDark, double maxProfit) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 12.w),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A73E8), Color(0xFF29B6F6)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF29B6F6).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(CupertinoIcons.money_dollar_circle, color: Colors.white, size: 22.sp),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Resell à¦à¦°à§ à¦à¦¯à¦¼ à¦à¦°à§à¦¨!',
                  style: GoogleFonts.poppins(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'à¦¸à¦°à§à¦¬à§à¦à§à¦ \u09F3${maxProfit.toInt()} à¦ªà¦°à§à¦¯à¦¨à§à¦¤ à¦²à¦¾à¦­ à¦à¦°à¦¤à§ à¦ªà¦¾à¦°à¦¬à§à¦¨',
                  style: GoogleFonts.poppins(
                    fontSize: 11.sp,
                    color: Colors.white.withOpacity(0.85),
                  ),
                ),
              ],
            ),
          ),
          Icon(CupertinoIcons.chevron_right, color: Colors.white.withOpacity(0.7), size: 16.sp),
        ],
      ),
    ).animate().fadeIn(delay: 250.ms).slideY(begin: 0.05);
  }

  Widget _buildDeliveryInfo(bool isDark, Color cardBg, Color kTextDark, Color kTextMid, Color borderColor) {
    final items = [
      _InfoRow(icon: CupertinoIcons.location, color: const Color(0xFF34C759), title: 'à¦¡à§à¦²à¦¿à¦­à¦¾à¦°à¦¿', value: 'à¦¢à¦¾à¦à¦¾à¦¯à¦¼ à§¨-à§© à¦¦à¦¿à¦¨ â¢ à¦¸à¦¾à¦°à¦¾à¦¦à§à¦¶à§ à§ª-à§­ à¦¦à¦¿à¦¨'),
      _InfoRow(icon: CupertinoIcons.return_icon, color: const Color(0xFF29B6F6), title: 'à¦°à¦¿à¦à¦¾à¦°à§à¦¨', value: 'à§­ à¦¦à¦¿à¦¨à§à¦° à¦®à¦§à§à¦¯à§ à¦«à§à¦°à¦¤ à¦¦à§à¦à¦¯à¦¼à¦¾ à¦¯à¦¾à¦¬à§'),
      _InfoRow(icon: CupertinoIcons.shield_fill, color: const Color(0xFF6366F1), title: 'à¦à¦¯à¦¼à¦¾à¦°à§à¦¨à§à¦à¦¿', value: 'à§¬ à¦®à¦¾à¦¸à§à¦° à¦à¦¯à¦¼à¦¾à¦°à§à¦¨à§à¦à¦¿'),
      _InfoRow(icon: CupertinoIcons.checkmark_seal, color: const Color(0xFFFF6600), title: 'à¦à¦¥à§à¦¨à¦à¦¿à¦', value: 'à§§à§¦à§¦% à¦à¦°à¦¿à¦à¦¿à¦¨à¦¾à¦² à¦ªà§à¦°à§à¦¡à¦¾à¦à§à¦ à¦à§à¦¯à¦¾à¦°à¦¾à¦¨à§à¦à¦¿'),
    ];

    return Container(
      color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'à¦¡à§à¦²à¦¿à¦­à¦¾à¦°à¦¿ à¦ à¦°à¦¿à¦à¦¾à¦°à§à¦¨',
            style: GoogleFonts.poppins(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: kTextDark,
            ),
          ),
          SizedBox(height: 12.h),
          ...items.asMap().entries.map((entry) => _buildInfoRow(
                entry.value,
                kTextDark,
                kTextMid,
                borderColor,
                isLast: entry.key == items.length - 1,
              )),
        ],
      ),
    ).animate().fadeIn(delay: 300.ms);
  }

  Widget _buildInfoRow(_InfoRow data, Color kTextDark, Color kTextMid, Color borderColor, {bool isLast = false}) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 10.h),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: data.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(data.icon, color: data.color, size: 16.sp),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.title,
                      style: GoogleFonts.poppins(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: kTextDark,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      data.value,
                      style: GoogleFonts.poppins(
                        fontSize: 11.sp,
                        color: kTextMid,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (!isLast) Divider(color: borderColor, height: 1),
      ],
    );
  }

  Widget _buildHighlights(bool isDark, Color cardBg, Color kTextDark, Color kTextMid, Color borderColor) {
    final highlights = [
      'â à¦à¦à§à¦à¦®à¦¾à¦¨à§à¦° à¦®à§à¦à§à¦°à¦¿à¦¯à¦¼à¦¾à¦² à¦¬à§à¦¯à¦¬à¦¹à¦¾à¦° à¦à¦°à¦¾ à¦¹à¦¯à¦¼à§à¦à§',
      'â à¦¦à§à¦°à§à¦à¦¸à§à¦¥à¦¾à¦¯à¦¼à§ à¦à¦¬à¦ à¦à§à¦à¦¸à¦',
      'â à¦¹à¦¾à¦²à¦à¦¾ à¦à¦à¦¨à§à¦° à¦¡à¦¿à¦à¦¾à¦à¦¨',
      'â à¦¸à¦¹à¦à§ à¦ªà¦°à¦¿à¦·à§à¦à¦¾à¦° à¦à¦°à¦¾ à¦¯à¦¾à¦¯à¦¼',
      'â à¦¬à¦¿à¦­à¦¿à¦¨à§à¦¨ à¦¸à¦¾à¦à¦à§ à¦ªà¦¾à¦à¦¯à¦¼à¦¾ à¦¯à¦¾à¦¯à¦¼',
    ];

    return Container(
      color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(CupertinoIcons.star_circle_fill, color: const Color(0xFFFF6600), size: 18.sp),
              SizedBox(width: 8.w),
              Text(
                'à¦ªà§à¦°à§à¦¡à¦¾à¦à§à¦ à¦¹à¦¾à¦à¦²à¦¾à¦à¦à¦¸',
                style: GoogleFonts.poppins(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: kTextDark,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          ...highlights.map((h) => Padding(
                padding: EdgeInsets.only(bottom: 8.h),
                child: Text(
                  h,
                  style: GoogleFonts.poppins(
                    fontSize: 12.sp,
                    color: kTextMid,
                    height: 1.5,
                  ),
                ),
              )),
        ],
      ),
    ).animate().fadeIn(delay: 350.ms);
  }

  Widget _buildDescription(bool isDark, Color cardBg, Color kTextDark, Color kTextMid, Color borderColor) {
    const fullDesc =
        'à¦à¦ à¦ªà§à¦°à§à¦¡à¦¾à¦à§à¦à¦à¦¿ à¦¸à¦°à§à¦¬à§à¦à§à¦ à¦®à¦¾à¦¨à§à¦° à¦à¦¾à¦à¦à¦¾à¦®à¦¾à¦² à¦¦à¦¿à¦¯à¦¼à§ à¦¤à§à¦°à¦¿à¥¤ à¦à¦®à¦¾à¦¦à§à¦° à¦¦à¦à§à¦· à¦à¦¾à¦°à¦¿à¦à¦°à¦°à¦¾ à¦ªà§à¦°à¦¤à¦¿à¦à¦¿ à¦ªà¦£à§à¦¯ à¦¯à¦¤à§à¦¨ à¦¸à¦¹à¦à¦¾à¦°à§ à¦¤à§à¦°à¦¿ à¦à¦°à§à¦à§à¦¨à¥¤ '
        'à¦à¦à¦¿ à¦¦à§à¦¨à¦¨à§à¦¦à¦¿à¦¨ à¦¬à§à¦¯à¦¬à¦¹à¦¾à¦°à§à¦° à¦à¦¨à§à¦¯ à¦à¦ªà¦¯à§à¦à§à¦¤ à¦à¦¬à¦ à¦¦à§à¦°à§à¦à¦¸à§à¦¥à¦¾à¦¯à¦¼à§à¥¤ à¦¬à¦¿à¦­à¦¿à¦¨à§à¦¨ à¦°à¦ à¦ à¦¡à¦¿à¦à¦¾à¦à¦¨à§ à¦ªà¦¾à¦à¦¯à¦¼à¦¾ à¦¯à¦¾à¦¯à¦¼à¥¤ '
        'à¦¬à¦¿à¦¶à§à¦· à¦à¦°à§ à¦¯à¦¾à¦°à¦¾ à¦¸à§à¦à¦¾à¦à¦²à¦¿à¦¶ à¦à¦¬à¦ à¦à§à¦à¦¸à¦ à¦ªà¦£à§à¦¯ à¦à§à¦à¦à¦à§à¦¨ à¦¤à¦¾à¦¦à§à¦° à¦à¦¨à§à¦¯ à¦à¦à¦¿ à¦ªà¦¾à¦°à¦«à§à¦à§à¦ à¦à¦¯à¦¼à§à¦¸à¥¤ '
        'à¦à§à¦¨à§ à¦ªà§à¦°à¦¶à§à¦¨ à¦¥à¦¾à¦à¦²à§ à¦à¦®à¦¾à¦¦à§à¦° à¦¸à¦¾à¦¥à§ à¦¯à§à¦à¦¾à¦¯à§à¦ à¦à¦°à§à¦¨à¥¤ à¦à¦®à¦°à¦¾ à¦¸à¦°à§à¦¬à¦¦à¦¾ à¦à¦ªà¦¨à¦¾à¦° à¦¸à§à¦¬à¦¾à¦¯à¦¼ à¦¨à¦¿à¦¯à¦¼à§à¦à¦¿à¦¤à¥¤';

    final shortDesc = fullDesc.substring(0, 120) + '...';

    return Container(
      color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(CupertinoIcons.doc_text, color: const Color(0xFF29B6F6), size: 18.sp),
              SizedBox(width: 8.w),
              Text(
                'à¦¬à¦¿à¦¸à§à¦¤à¦¾à¦°à¦¿à¦¤ à¦¬à¦¿à¦¬à¦°à¦£',
                style: GoogleFonts.poppins(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: kTextDark,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          AnimatedCrossFade(
            firstChild: Text(
              shortDesc,
              style: GoogleFonts.poppins(
                fontSize: 12.5.sp,
                color: kTextDark.withOpacity(0.8),
                height: 1.7,
              ),
            ),
            secondChild: Text(
              fullDesc,
              style: GoogleFonts.poppins(
                fontSize: 12.5.sp,
                color: kTextDark.withOpacity(0.8),
                height: 1.7,
              ),
            ),
            crossFadeState: _showFullDescription
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 300),
          ),
          SizedBox(height: 10.h),
          GestureDetector(
            onTap: () => setState(() => _showFullDescription = !_showFullDescription),
            child: Row(
              children: [
                Text(
                  _showFullDescription ? 'à¦à¦® à¦¦à§à¦à§à¦¨' : 'à¦à¦°à¦ à¦¦à§à¦à§à¦¨',
                  style: GoogleFonts.poppins(
                    fontSize: 12.sp,
                    color: const Color(0xFF29B6F6),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(width: 4.w),
                AnimatedRotation(
                  turns: _showFullDescription ? 0.5 : 0,
                  duration: const Duration(milliseconds: 300),
                  child: Icon(
                    CupertinoIcons.chevron_down,
                    size: 14.sp,
                    color: const Color(0xFF29B6F6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 400.ms);
  }

  Widget _buildSellerInfo(bool isDark, Color cardBg, Color kTextDark, Color kTextMid, Color borderColor) {
    return Container(
      color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'à¦¬à¦¿à¦à§à¦°à§à¦¤à¦¾à¦° à¦¤à¦¥à§à¦¯',
            style: GoogleFonts.poppins(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: kTextDark,
            ),
          ),
          SizedBox(height: 14.h),
          Row(
            children: [
              Container(
                width: 46.w,
                height: 46.w,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF6600), Color(0xFFFF9500)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    'BD',
                    style: GoogleFonts.poppins(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'BD Wholesale Hub',
                          style: GoogleFonts.poppins(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.bold,
                            color: kTextDark,
                          ),
                        ),
                        SizedBox(width: 6.w),
                        Icon(CupertinoIcons.checkmark_seal_fill,
                            color: const Color(0xFF29B6F6), size: 14.sp),
                      ],
                    ),
                    Text(
                      'â­ 4.9 â¢ 2.3k+ à¦¬à¦¿à¦à§à¦°à¦¯à¦¼ â¢ 98% à¦ªà¦à¦¿à¦à¦¿à¦­ à¦°à¦¿à¦­à¦¿à¦',
                      style: GoogleFonts.poppins(fontSize: 11.sp, color: kTextMid),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFFF6600)),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  'à¦­à¦¿à¦à¦¿à¦',
                  style: GoogleFonts.poppins(
                    fontSize: 11.sp,
                    color: const Color(0xFFFF6600),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: 450.ms);
  }

  Widget _buildRatings(bool isDark, Color cardBg, Color kTextDark, Color kTextMid, Color borderColor) {
    final reviews = [
      _Review(name: 'à¦°à¦¾à¦¹à§à¦²à¦¾ à¦¬à§à¦à¦®', rating: 5, text: 'à¦à¦¸à¦¾à¦§à¦¾à¦°à¦£ à¦ªà§à¦°à§à¦¡à¦¾à¦à§à¦! à¦®à¦¾à¦¨ à¦à¦¨à§à¦ à¦­à¦¾à¦²à§, à¦¦à¦¾à¦® à¦à¦à¦¦à¦® à¦¸à¦¾à¦¶à§à¦°à¦¯à¦¼à§à¥¤', time: 'à§¨ à¦¦à¦¿à¦¨ à¦à¦à§'),
      _Review(name: 'à¦à¦°à¦¿à¦® à¦¸à¦¾à¦¹à§à¦¬', rating: 4, text: 'à¦ªà§à¦°à§à¦¡à¦¾à¦à§à¦ à¦­à¦¾à¦²à§ à¦à¦¿à¦¨à§à¦¤à§ à¦¡à§à¦²à¦¿à¦­à¦¾à¦°à¦¿ à¦à¦à¦à§ à¦¦à§à¦°à¦¿ à¦¹à¦¯à¦¼à§à¦à§à¥¤', time: 'à§« à¦¦à¦¿à¦¨ à¦à¦à§'),
      _Review(name: 'à¦¸à¦¾à¦²à¦®à¦¾ à¦à¦¾à¦¨à¦®', rating: 5, text: 'à¦à§à¦¬à¦ à¦­à¦¾à¦²à§ à¦à§à¦¯à¦¼à¦¾à¦²à¦¿à¦à¦¿à¥¤ à¦à¦¬à¦¾à¦° à¦à¦¿à¦¨à¦¬à¥¤', time: 'à§§ à¦¸à¦ªà§à¦¤à¦¾à¦¹ à¦à¦à§'),
    ];

    return Container(
      color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'à¦°à¦¿à¦­à¦¿à¦ à¦ à¦°à§à¦à¦¿à¦',
                style: GoogleFonts.poppins(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: kTextDark,
                ),
              ),
              TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'à¦¸à¦¬ à¦¦à§à¦à§à¦¨',
                  style: GoogleFonts.poppins(
                    fontSize: 12.sp,
                    color: const Color(0xFF29B6F6),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          Row(
            children: [
              Column(
                children: [
                  Text(
                    widget.product.rating.toString(),
                    style: GoogleFonts.poppins(
                      fontSize: 40.sp,
                      fontWeight: FontWeight.bold,
                      color: kTextDark,
                    ),
                  ),
                  Row(
                    children: List.generate(
                      5,
                      (i) => Icon(
                        i < widget.product.rating.floor()
                            ? CupertinoIcons.star_fill
                            : CupertinoIcons.star,
                        color: const Color(0xFFFFCC02),
                        size: 14.sp,
                      ),
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    '234 à¦°à¦¿à¦­à¦¿à¦',
                    style: GoogleFonts.poppins(fontSize: 11.sp, color: kTextMid),
                  ),
                ],
              ),
              SizedBox(width: 20.w),
              Expanded(
                child: Column(
                  children: [5, 4, 3, 2, 1].map((star) {
                    final widths = [0.75, 0.15, 0.05, 0.03, 0.02];
                    return Padding(
                      padding: EdgeInsets.symmetric(vertical: 2.h),
                      child: Row(
                        children: [
                          Text(
                            '$star',
                            style: GoogleFonts.poppins(fontSize: 11.sp, color: kTextMid),
                          ),
                          SizedBox(width: 4.w),
                          Icon(CupertinoIcons.star_fill, color: const Color(0xFFFFCC02), size: 10.sp),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4.r),
                              child: LinearProgressIndicator(
                                value: widths[5 - star],
                                backgroundColor: Colors.grey.withOpacity(0.15),
                                valueColor: AlwaysStoppedAnimation(
                                  star >= 4
                                      ? const Color(0xFF34C759)
                                      : star == 3
                                          ? const Color(0xFFFFCC02)
                                          : const Color(0xFFFF3B30),
                                ),
                                minHeight: 6.h,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Divider(color: borderColor, height: 1),
          SizedBox(height: 12.h),
          ...reviews.asMap().entries.map((entry) {
            final r = entry.value;
            return Container(
              margin: EdgeInsets.only(bottom: 12.h),
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(color: borderColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 32.w,
                        height: 32.w,
                        decoration: BoxDecoration(
                          color: const Color(0xFF29B6F6).withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            r.name[0],
                            style: GoogleFonts.poppins(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF29B6F6),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              r.name,
                              style: GoogleFonts.poppins(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w600,
                                color: kTextDark,
                              ),
                            ),
                            Row(
                              children: [
                                ...List.generate(
                                  5,
                                  (i) => Icon(
                                    i < r.rating ? CupertinoIcons.star_fill : CupertinoIcons.star,
                                    color: const Color(0xFFFFCC02),
                                    size: 11.sp,
                                  ),
                                ),
                                SizedBox(width: 6.w),
                                Text(
                                  r.time,
                                  style: GoogleFonts.poppins(fontSize: 10.sp, color: kTextMid),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    r.text,
                    style: GoogleFonts.poppins(
                      fontSize: 12.sp,
                      color: kTextMid,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: (entry.key * 80 + 500).ms);
          }),
        ],
      ),
    ).animate().fadeIn(delay: 500.ms);
  }

  Widget _buildBottomBar(bool isDark, Color cardBg, Color kTextDark, Color kTextMid, Color borderColor) {
    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 24.h),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
        border: Border(top: BorderSide(color: borderColor, width: 1)),
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'à¦¹à§à¦²à¦¸à§à¦² à¦ªà§à¦°à¦¾à¦à¦¸',
                style: GoogleFonts.poppins(fontSize: 10.sp, color: kTextMid),
              ),
              Text(
                '\u09F3${widget.product.wholesalePrice.toInt()}',
                style: GoogleFonts.poppins(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFFF6600),
                ),
              ),
            ],
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: GestureDetector(
              onTap: _showResellSheet,
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 14.h),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
