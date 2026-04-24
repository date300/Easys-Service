import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';

// ==================== RIVERPOD PROVIDERS ====================

final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.system);

final productListProvider = StateNotifierProvider<ProductListNotifier, List<ProductModel>>((ref) {
  return ProductListNotifier();
});

class ProductListNotifier extends StateNotifier<List<ProductModel>> {
  ProductListNotifier() : super([
    ProductModel(
      id: '1',
      title: '3 Piece Exclusive',
      subtitle: '💗Exclusive Premium Collection',
      image: 'https://images.unsplash.com/photo-1595777457583-95e059d581b8?w=400',
      wholesalePrice: 1270,
      originalPrice: 1590,
      maxResalePrice: 1800,
      category: 'Fashion',
      rating: 4.8,
    ),
    ProductModel(
      id: '2',
      title: 'Smart Watch S2000 pro max',
      subtitle: '⌚️Latest Series',
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
      subtitle: '💥💥Premium Quality',
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
      subtitle: '🌬️Summer Essential',
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
      subtitle: '👔Stylish & Compact',
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
      subtitle: '⌚️Classic Design',
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
  final String? banglaLabel;
  final IconData icon;
  final String? imageUrl;
  final List<Color> gradientColors;
  final Color glowColor;

  CategoryStyle({
    required this.label,
    this.banglaLabel,
    required this.icon,
    this.imageUrl,
    required this.gradientColors,
    required this.glowColor,
  });
}

final Map<String, CategoryStyle> _categoryStyles = {
  'All': CategoryStyle(
    label: 'All',
    banglaLabel: 'সব',
    icon: Icons.apps_rounded,
    gradientColors: [const Color(0xFF0EA5E9), const Color(0xFF06B6D4)],
    glowColor: const Color(0xFF0EA5E9),
  ),
  'Smart Watch': CategoryStyle(
    label: 'Smart Watch',
    icon: Icons.watch_rounded,
    gradientColors: [const Color(0xFF6366F1), const Color(0xFF8B5CF6)],
    glowColor: const Color(0xFF6366F1),
  ),
  'Neckband': CategoryStyle(
    label: 'Neckband',
    icon: Icons.headphones_rounded,
    gradientColors: [const Color(0xFFEC4899), const Color(0xFFF43F5E)],
    glowColor: const Color(0xFFEC4899),
  ),
  'Airpods': CategoryStyle(
    label: 'Airpods',
    icon: Icons.earbuds_rounded,
    gradientColors: [const Color(0xFF10B981), const Color(0xFF14B8A6)],
    glowColor: const Color(0xFF10B981),
  ),
  'Power Bank': CategoryStyle(
    label: 'Power Bank',
    icon: Icons.battery_charging_full_rounded,
    gradientColors: [const Color(0xFFF59E0B), const Color(0xFFF97316)],
    glowColor: const Color(0xFFF59E0B),
  ),
  'Earphone': CategoryStyle(
    label: 'Earphone',
    icon: Icons.headset_mic_rounded,
    gradientColors: [const Color(0xFF3B82F6), const Color(0xFF0EA5E9)],
    glowColor: const Color(0xFF3B82F6),
  ),
  'Electronics': CategoryStyle(
    label: 'Electronics',
    banglaLabel: 'ইলেকট্রনিক্স',
    icon: Icons.devices_rounded,
    gradientColors: [const Color(0xFF6366F1), const Color(0xFF8B5CF6)],
    glowColor: const Color(0xFF6366F1),
  ),
  'Fashion': CategoryStyle(
    label: 'Fashion',
    banglaLabel: 'ফ্যাশন',
    icon: Icons.checkroom_rounded,
    gradientColors: [const Color(0xFF10B981), const Color(0xFF14B8A6)],
    glowColor: const Color(0xFF10B981),
  ),
  'Audio': CategoryStyle(
    label: 'Audio',
    banglaLabel: 'অডিও',
    icon: Icons.headphones_rounded,
    gradientColors: [const Color(0xFFEC4899), const Color(0xFFF43F5E)],
    glowColor: const Color(0xFFEC4899),
  ),
  'Watches': CategoryStyle(
    label: 'Watches',
    banglaLabel: 'ঘড়ি',
    icon: Icons.watch_rounded,
    gradientColors: [const Color(0xFFF59E0B), const Color(0xFFF97316)],
    glowColor: const Color(0xFFF59E0B),
  ),
  'Home': CategoryStyle(
    label: 'Home',
    banglaLabel: 'হোম',
    icon: Icons.home_rounded,
    gradientColors: [const Color(0xFF3B82F6), const Color(0xFF0EA5E9)],
    glowColor: const Color(0xFF3B82F6),
  ),
  'Sports': CategoryStyle(
    label: 'Sports',
    banglaLabel: 'স্পোর্টস',
    icon: Icons.sports_basketball_rounded,
    gradientColors: [const Color(0xFFEF4444), const Color(0xFFF97316)],
    glowColor: const Color(0xFFEF4444),
  ),
  'Beauty': CategoryStyle(
    label: 'Beauty',
    banglaLabel: 'বিউটি',
    icon: Icons.brush_rounded,
    gradientColors: [const Color(0xFFD946EF), const Color(0xFFA855F7)],
    glowColor: const Color(0xFFD946EF),
  ),
  'Books': CategoryStyle(
    label: 'Books',
    banglaLabel: 'বই',
    icon: Icons.menu_book_rounded,
    gradientColors: [const Color(0xFF8B5CF6), const Color(0xFF6366F1)],
    glowColor: const Color(0xFF8B5CF6),
  ),
  'Toys': CategoryStyle(
    label: 'Toys',
    banglaLabel: 'খেলনা',
    icon: Icons.toys_rounded,
    gradientColors: [const Color(0xFF06B6D4), const Color(0xFF22D3EE)],
    glowColor: const Color(0xFF06B6D4),
  ),
};

CategoryStyle _getCategoryStyle(String category) {
  return _categoryStyles[category] ?? CategoryStyle(
    label: category,
    icon: Icons.local_offer_rounded,
    gradientColors: [const Color(0xFF0EA5E9), const Color(0xFF38BDF8)],
    glowColor: const Color(0xFF0EA5E9),
  );
}

// ==================== COLOR TOKENS (iOS Soft) ====================

class AppColors {
  static const Color primaryLight = Color(0xFFFF2D55);
  static const Color primaryLightSoft = Color(0xFFFF6482);
  static const Color accentLight = Color(0xFF5856D6);
  static const Color successLight = Color(0xFF34C759);
  static const Color warningLight = Color(0xFFFF9500);
  static const Color dangerLight = Color(0xFFFF3B30);

  static const Color bgLight = Color(0xFFF2F2F7);
  static const Color surfaceLight = Colors.white;
  static const Color cardLight = Colors.white;
  static const Color textPrimaryLight = Color(0xFF1C1C1E);
  static const Color textSecondaryLight = Color(0xFF8E8E93);
  static const Color textMutedLight = Color(0xFFC7C7CC);
  static const Color borderLight = Color(0xFFE5E5EA);
  static const Color shadowLight = Color(0x1A000000);

  static const Color primaryDark = Color(0xFFFF6482);
  static const Color primaryDarkSoft = Color(0xFFFF8FAB);
  static const Color accentDark = Color(0xFF7B79E0);
  static const Color successDark = Color(0xFF30D158);
  static const Color warningDark = Color(0xFFFFB340);
  static const Color dangerDark = Color(0xFFFF453A);

  static const Color bgDark = Color(0xFF000000);
  static const Color surfaceDark = Color(0xFF1C1C1E);
  static const Color cardDark = Color(0xFF2C2C2E);
  static const Color textPrimaryDark = Color(0xFFFFFFFF);
  static const Color textSecondaryDark = Color(0xFF8E8E93);
  static const Color textMutedDark = Color(0xFF636366);
  static const Color borderDark = Color(0xFF38383A);
  static const Color shadowDark = Color(0x40FFFFFF);

  static bool _isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  static Color primary(BuildContext context) => _isDark(context) ? primaryDark : primaryLight;
  static Color primarySoft(BuildContext context) => _isDark(context) ? primaryDarkSoft : primaryLightSoft;
  static Color accent(BuildContext context) => _isDark(context) ? accentDark : accentLight;
  static Color success(BuildContext context) => _isDark(context) ? successDark : successLight;
  static Color warning(BuildContext context) => _isDark(context) ? warningDark : warningLight;
  static Color danger(BuildContext context) => _isDark(context) ? dangerDark : dangerLight;
  static Color bg(BuildContext context) => _isDark(context) ? bgDark : bgLight;
  static Color surface(BuildContext context) => _isDark(context) ? surfaceDark : surfaceLight;
  static Color card(BuildContext context) => _isDark(context) ? cardDark : cardLight;
  static Color textPrimary(BuildContext context) => _isDark(context) ? textPrimaryDark : textPrimaryLight;
  static Color textSecondary(BuildContext context) => _isDark(context) ? textSecondaryDark : textSecondaryLight;
  static Color textMuted(BuildContext context) => _isDark(context) ? textMutedDark : textMutedLight;
  static Color border(BuildContext context) => _isDark(context) ? borderDark : borderLight;
  static Color shadow(BuildContext context) => _isDark(context) ? shadowDark : shadowLight;
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
  double get discountPercent {
    if (originalPrice == null || originalPrice! <= 0) return 0;
    return ((originalPrice! - wholesalePrice) / originalPrice! * 100).roundToDouble();
  }
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

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: AppColors.bg(context),
        body: SafeArea(
          bottom: false,
          child: NestedScrollView(
            headerSliverBuilder: (_, __) => [
              SliverToBoxAdapter(child: _buildSearchBar()),
              SliverToBoxAdapter(child: _buildBannerCarousel()),
              SliverToBoxAdapter(child: _buildQuickActions()),
              SliverToBoxAdapter(
                child: _buildSectionHeader('Categories', onSeeAll: () {}),
              ),
              SliverToBoxAdapter(child: _buildCategoryFilter(allProducts)),
              SliverToBoxAdapter(
                child: _buildSectionHeader('Most Popular Products', onSeeAll: () {}),
              ),
              SliverToBoxAdapter(child: _buildTabBar(filtered.length, myResells.length)),
            ],
            body: TabBarView(
              controller: _tabController,
              children: [
                _buildProductsTab(filtered),
                _buildMyResellsTab(myResells),
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
                backgroundColor: AppColors.card(context),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14.r),
                ),
                child: Badge(
                  label: Text('${myResells.length}'),
                  child: Icon(Icons.analytics_rounded,
                      color: AppColors.primary(context), size: 18.sp),
                ),
              ).animate().scale(delay: 100.ms),
            SizedBox(height: 8.h),
            FloatingActionButton.extended(
              heroTag: 'add',
              onPressed: _showAddProductSheet,
              backgroundColor: AppColors.primary(context),
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.r),
              ),
              icon: Icon(Icons.add_rounded, size: 18.sp),
              label: Text(
                'Add Product',
                style: GoogleFonts.outfit(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ).animate().scale(delay: 150.ms),
          ],
        ),
      ),
    );
  }

  // ==================== SEARCH BAR (iOS Style) ====================
  Widget _buildSearchBar() {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 0),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        decoration: BoxDecoration(
          color: AppColors.card(context),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: _isSearchFocused
                ? AppColors.primary(context).withOpacity(0.4)
                : AppColors.border(context),
            width: _isSearchFocused ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow(context).withOpacity(0.15),
              blurRadius: 12,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          focusNode: _searchFocusNode,
          onChanged: (val) => setState(() => _searchQuery = val),
          style: GoogleFonts.outfit(
            fontSize: 14.sp,
            color: AppColors.textPrimary(context),
          ),
          decoration: InputDecoration(
            hintText: 'Search Products...',
            hintStyle: GoogleFonts.outfit(
              fontSize: 14.sp,
              color: AppColors.textMuted(context),
            ),
            prefixIcon: Icon(
              Icons.search_rounded,
              color: _isSearchFocused
                  ? AppColors.primary(context)
                  : AppColors.textMuted(context),
              size: 20.sp,
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
                        color: AppColors.border(context),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.close_rounded,
                        color: AppColors.textSecondary(context),
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

  // ==================== BANNER CAROUSEL ====================
  Widget _buildBannerCarousel() {
    final banners = [
      'https://images.unsplash.com/photo-1483985988355-763728e1935b?w=600',
      'https://images.unsplash.com/photo-1556742049-0cfed4f6a45d?w=600',
      'https://images.unsplash.com/photo-1607082348824-0a96f2a4b9da?w=600',
    ];

    return Container(
      height: 140.h,
      margin: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20.r),
        child: Stack(
          fit: StackFit.expand,
          children: [
            PageView.builder(
              itemCount: banners.length,
              itemBuilder: (context, index) {
                return Image.network(
                  banners[index],
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: AppColors.primary(context).withOpacity(0.1),
                    child: Center(
                      child: Text(
                        'অফার কিনুন',
                        style: GoogleFonts.outfit(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary(context),
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
                    Colors.black.withOpacity(0.4),
                    Colors.transparent,
                    Colors.transparent,
                  ],
                ),
              ),
            ),
            Positioned(
              left: 16.w,
              top: 20.h,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: AppColors.primary(context),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Text(
                      'Special Offer',
                      style: GoogleFonts.outfit(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'অফার কিনুন',
                    style: GoogleFonts.outfit(
                      fontSize: 22.sp,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    'Up to 50% Off',
                    style: GoogleFonts.outfit(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withOpacity(0.9),
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
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
  Widget _buildQuickActions() {
    final actions = [
      _QuickActionData(icon: Icons.fact_check_outlined, label: 'অর্ডার', color: const Color(0xFF34C759)),
      _QuickActionData(icon: Icons.storefront_outlined, label: 'ভেন্ডর লিস্ট', color: const Color(0xFFFF9500)),
      _QuickActionData(icon: Icons.grid_view_rounded, label: 'ক্যাটেগরি', color: const Color(0xFF5856D6)),
      _QuickActionData(icon: Icons.favorite_border_rounded, label: 'লেভেল করা\nপ্রোডাক্ট', color: const Color(0xFFFF2D55)),
    ];

    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: actions.map((action) {
          return GestureDetector(
            onTap: () => HapticFeedback.lightImpact(),
            child: Column(
              children: [
                Container(
                  width: 56.w,
                  height: 56.w,
                  decoration: BoxDecoration(
                    color: AppColors.card(context),
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(color: AppColors.border(context)),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.shadow(context).withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    action.icon,
                    color: action.color,
                    size: 24.sp,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  action.label,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary(context),
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(delay: (actions.indexOf(action) * 80).ms).scale(
            begin: const Offset(0.8, 0.8),
            curve: Curves.easeOutBack,
          );
        }).toList(),
      ),
    );
  }

  // ==================== SECTION HEADER ====================
  Widget _buildSectionHeader(String title, {required VoidCallback onSeeAll}) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 24.h, 16.w, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: GoogleFonts.outfit(
              fontSize: 18.sp,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary(context),
            ),
          ),
          GestureDetector(
            onTap: onSeeAll,
            child: Text(
              'See All',
              style: GoogleFonts.outfit(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== CATEGORY FILTER (iOS Style) ====================
  Widget _buildCategoryFilter(List<ProductModel> allProducts) {
    final categories = ref.read(productListProvider.notifier).categories;

    return SizedBox(
      height: 100.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 4.h),
        itemCount: categories.length,
        separatorBuilder: (_, __) => SizedBox(width: 12.w),
        itemBuilder: (_, i) {
          final cat = categories[i];
          final selected = _selectedCategory == cat;
          final style = _getCategoryStyle(cat);

          return GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() => _selectedCategory = cat);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutBack,
              width: 72.w,
              child: Column(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    width: 64.w,
                    height: 64.w,
                    decoration: BoxDecoration(
                      color: selected
                          ? style.gradientColors[0].withOpacity(0.15)
                          : AppColors.card(context),
                      borderRadius: BorderRadius.circular(18.r),
                      border: Border.all(
                        color: selected
                            ? style.gradientColors[0].withOpacity(0.4)
                            : AppColors.border(context),
                        width: selected ? 2 : 1,
                      ),
                      boxShadow: selected
                          ? [
                              BoxShadow(
                                color: style.glowColor.withOpacity(0.25),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : [
                              BoxShadow(
                                color: AppColors.shadow(context).withOpacity(0.08),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                    ),
                    child: Icon(
                      style.icon,
                      color: selected
                          ? style.gradientColors[0]
                          : AppColors.textSecondary(context),
                      size: 26.sp,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    cat,
                    style: GoogleFonts.outfit(
                      fontSize: 10.sp,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                      color: selected
                          ? style.gradientColors[0]
                          : AppColors.textSecondary(context),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    ).animate().fadeIn(delay: 300.ms);
  }

  // ==================== TAB BAR (iOS Style) ====================
  Widget _buildTabBar(int allCount, int myCount) {
    return Container(
      margin: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 4.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppColors.card(context),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.border(context)),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow(context).withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TabBar(
        controller: _tabController,
        labelStyle: GoogleFonts.outfit(
          fontSize: 13.sp,
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelStyle: GoogleFonts.outfit(
          fontSize: 13.sp,
          fontWeight: FontWeight.w500,
        ),
        labelColor: Colors.white,
        unselectedLabelColor: AppColors.textSecondary(context),
        indicator: BoxDecoration(
          color: AppColors.primary(context),
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary(context).withOpacity(0.25),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        splashFactory: NoSplash.splashFactory,
        overlayColor: WidgetStateProperty.all(Colors.transparent),
        tabs: [
          Tab(text: 'All ($allCount)'),
          Tab(text: 'My Sales ($myCount)'),
        ],
      ),
    ).animate().fadeIn(delay: 350.ms);
  }

  // ==================== PRODUCTS TAB ====================
  Widget _buildProductsTab(List<ProductModel> products) {
    if (products.isEmpty) return _buildEmptyState();

    return GridView.builder(
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 100.h),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12.w,
        mainAxisSpacing: 12.h,
        childAspectRatio: 0.58,
      ),
      itemCount: products.length,
      itemBuilder: (_, i) => _ProductCard(
        product: products[i],
        onResell: () => _showResellSheet(products[i]),
      )
          .animate()
          .fadeIn(delay: (i * 60).ms, duration: 350.ms)
          .slideY(begin: 0.08, curve: Curves.easeOut),
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
  Widget _buildMyResellsTab(List<ProductModel> myResells) {
    if (myResells.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(24.w),
              decoration: BoxDecoration(
                color: AppColors.primary(context).withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.inventory_2_outlined,
                size: 44.sp,
                color: AppColors.primary(context),
              ),
            ).animate().scale(duration: 500.ms, curve: Curves.elasticOut),
            SizedBox(height: 16.h),
            Text(
              'No active sales yet',
              style: GoogleFonts.outfit(
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary(context),
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              'Pick a product and set your margin',
              style: GoogleFonts.outfit(
                fontSize: 13.sp,
                color: AppColors.textSecondary(context),
              ),
            ),
            SizedBox(height: 20.h),
            GestureDetector(
              onTap: () => _tabController.animateTo(0),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: AppColors.primary(context),
                  borderRadius: BorderRadius.circular(14.r),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary(context).withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Text(
                  'Browse Products',
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
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
      itemCount: myResells.length,
      itemBuilder: (_, i) => _ActiveResellCard(
        product: myResells[i],
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
      )
          .animate()
          .fadeIn(delay: (i * 60).ms, duration: 300.ms)
          .slideX(begin: 0.05, curve: Curves.easeOut),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded,
              size: 48.sp, color: AppColors.textMuted(context)),
          SizedBox(height: 12.h),
          Text(
            'No products found',
            style: GoogleFonts.outfit(
              fontSize: 15.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary(context),
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== PRODUCT CARD (Screenshot Style) ====================

class _ProductCard extends StatefulWidget {
  final ProductModel product;
  final VoidCallback onResell;

  const _ProductCard({required this.product, required this.onResell});

  @override
  State<_ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<_ProductCard> {
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
            color: AppColors.card(context),
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(color: AppColors.border(context).withOpacity(0.6)),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadow(context).withOpacity(0.1),
                blurRadius: 16,
                offset: const Offset(0, 6),
                spreadRadius: -4,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(20.r)),
                    child: SizedBox(
                      height: 130.h,
                      width: double.infinity,
                      child: Image.network(
                        widget.product.image,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            color: AppColors.bg(context),
                            child: Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    AppColors.primary(context)),
                              ),
                            ),
                          );
                        },
                        errorBuilder: (_, __, ___) => Container(
                          color: AppColors.bg(context),
                          child: Center(
                            child: Icon(
                              Icons.image_not_supported_outlined,
                              color: AppColors.textMuted(context),
                              size: 28.sp,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (widget.product.isReselling)
                    Positioned(
                      top: 10,
                      left: 10,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: AppColors.success(context),
                          borderRadius: BorderRadius.circular(8.r),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.success(context).withOpacity(0.4),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.check_rounded, color: Colors.white, size: 10.sp),
                            SizedBox(width: 3.w),
                            Text(
                              'Active',
                              style: GoogleFonts.outfit(
                                fontSize: 9.sp,
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: AppColors.card(context).withOpacity(0.92),
                        borderRadius: BorderRadius.circular(10.r),
                        border: Border.all(
                            color: AppColors.border(context).withOpacity(0.5)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.star_rounded,
                              color: const Color(0xFFFFCC02), size: 11.sp),
                          SizedBox(width: 2.w),
                          Text(
                            widget.product.rating.toString(),
                            style: GoogleFonts.outfit(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary(context),
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
                  padding: EdgeInsets.all(12.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.product.title,
                        style: GoogleFonts.outfit(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary(context),
                          height: 1.3,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (widget.product.subtitle != null) ...[
                        SizedBox(height: 3.h),
                        Text(
                          widget.product.subtitle!,
                          style: GoogleFonts.outfit(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textSecondary(context),
                            height: 1.2,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      SizedBox(height: 8.h),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '\u09F3${widget.product.wholesalePrice.toInt()}',
                            style: GoogleFonts.outfit(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primary(context),
                            ),
                          ),
                          SizedBox(width: 6.w),
                          if (widget.product.originalPrice != null)
                            Text(
                              '\u09F3${widget.product.originalPrice!.toInt()}',
                              style: GoogleFonts.outfit(
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textMuted(context),
                                decoration: TextDecoration.lineThrough,
                                decorationThickness: 1.5,
                              ),
                            ),
                        ],
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: widget.onResell,
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(vertical: 9.h),
                          decoration: BoxDecoration(
                            color: AppColors.primary(context),
                            borderRadius: BorderRadius.circular(12.r),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary(context).withOpacity(0.2),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_rounded,
                                color: Colors.white,
                                size: 14.sp,
                              ),
                              SizedBox(width: 4.w),
                              Text(
                                'Resell',
                                style: GoogleFonts.outfit(
                                  fontSize: 11.sp,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
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
  final VoidCallback onStop;

  const _ActiveResellCard({
    required this.product,
    required this.onStop,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColors.card(context),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.border(context).withOpacity(0.6)),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow(context).withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
            spreadRadius: -2,
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14.r),
            child: SizedBox(
              width: 66.w,
              height: 66.w,
              child: Image.network(
                product.image,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: AppColors.bg(context),
                  child: Icon(
                    Icons.image_not_supported_outlined,
                    color: AppColors.textMuted(context),
                    size: 24.sp,
                  ),
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
                  product.title,
                  style: GoogleFonts.outfit(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary(context),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Text(
                      'Sell: ',
                      style: GoogleFonts.outfit(
                        fontSize: 11.sp,
                        color: AppColors.textSecondary(context),
                      ),
                    ),
                    Text(
                      '\u09F3${product.myPrice.toInt()}',
                      style: GoogleFonts.outfit(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary(context),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4.h),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                  decoration: BoxDecoration(
                    color: AppColors.success(context).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(
                        color: AppColors.success(context).withOpacity(0.25)),
                  ),
                  child: Text(
                    'Profit \u09F3${product.myMargin.toInt()}',
                    style: GoogleFonts.outfit(
                      fontSize: 10.sp,
                      color: AppColors.success(context),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                SizedBox(height: 10.h),
                Row(
                  children: [
                    _MiniButton(
                      icon: Icons.stop_circle_outlined,
                      label: 'Stop',
                      color: AppColors.danger(context),
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
    final maxMargin = widget.product.maxMargin;
    final sellPrice = widget.product.wholesalePrice + _margin;

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24.h,
      ),
      decoration: BoxDecoration(
        color: AppColors.card(context),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
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
                color: AppColors.border(context),
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
                  borderRadius: BorderRadius.circular(14.r),
                  child: SizedBox(
                    width: 52.w,
                    height: 52.w,
                    child: Image.network(widget.product.image, fit: BoxFit.cover),
                  ),
                ),
                SizedBox(width: 14.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.product.title,
                        style: GoogleFonts.outfit(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary(context),
                        ),
                      ),
                      Text(
                        'Wholesale: \u09F3${widget.product.wholesalePrice.toInt()}',
                        style: GoogleFonts.outfit(
                          fontSize: 12.sp,
                          color: AppColors.textSecondary(context),
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
              style: GoogleFonts.outfit(
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary(context),
              ),
            ),
          ),
          SizedBox(height: 10.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '\u09F30',
                  style: GoogleFonts.outfit(
                    fontSize: 12.sp,
                    color: AppColors.textMuted(context),
                  ),
                ),
                Text(
                  '\u09F3${maxMargin.toInt()}',
                  style: GoogleFonts.outfit(
                    fontSize: 12.sp,
                    color: AppColors.textMuted(context),
                  ),
                ),
              ],
            ),
          ),
          Slider(
            value: _margin,
            min: 0,
            max: maxMargin,
            divisions: maxMargin.toInt(),
            activeColor: AppColors.primary(context),
            inactiveColor: AppColors.border(context),
            thumbColor: AppColors.primary(context),
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
                      color: AppColors.bg(context),
                      borderRadius: BorderRadius.circular(14.r),
                      border: Border.all(color: AppColors.border(context)),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Margin',
                          style: GoogleFonts.outfit(
                            fontSize: 11.sp,
                            color: AppColors.textMuted(context),
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          '\u09F3${_margin.toInt()}',
                          style: GoogleFonts.outfit(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.w800,
                            color: AppColors.success(context),
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
                      color: AppColors.primary(context).withOpacity(0.06),
                      borderRadius: BorderRadius.circular(14.r),
                      border: Border.all(
                          color: AppColors.primary(context).withOpacity(0.2)),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Sell Price',
                          style: GoogleFonts.outfit(
                            fontSize: 11.sp,
                            color: AppColors.textMuted(context),
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          '\u09F3${sellPrice.toInt()}',
                          style: GoogleFonts.outfit(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary(context),
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
                  color: AppColors.primary(context),
                  borderRadius: BorderRadius.circular(16.r),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary(context).withOpacity(0.3),
                      blurRadius: 14,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Text(
                  'Start Reselling',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w800,
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
    'Electronics',
    'Smart Watch',
    'Neckband',
    'Airpods',
    'Power Bank',
    'Earphone',
    'Fashion',
    'Home',
    'Sports',
    'Beauty',
    'Books',
    'Toys',
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
    if (_titleController.text.isEmpty ||
        _priceController.text.isEmpty ||
        _maxPriceController.text.isEmpty) {
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
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24.h,
      ),
      decoration: BoxDecoration(
        color: AppColors.card(context),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
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
                  color: AppColors.border(context),
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
                      color: AppColors.primary(context).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                    child: Icon(
                      Icons.add_box_rounded,
                      color: AppColors.primary(context),
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
                          style: GoogleFonts.outfit(
                            fontSize: 17.sp,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary(context),
                          ),
                        ),
                        Text(
                          'Fill the details to list your product',
                          style: GoogleFonts.outfit(
                            fontSize: 12.sp,
                            color: AppColors.textMuted(context),
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
              icon: Icons.label_outline,
            ),
            SizedBox(height: 14.h),
            _buildTextField(
              label: 'Subtitle (with emoji)',
              hint: 'e.g. 💥Premium Quality',
              controller: _subtitleController,
              icon: Icons.short_text_rounded,
            ),
            SizedBox(height: 14.h),
            _buildTextField(
              label: 'Image URL',
              hint: 'Paste product image link (optional)',
              controller: _imageController,
              icon: Icons.image_outlined,
            ),
            SizedBox(height: 14.h),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    label: 'Wholesale Price',
                    hint: 'Buying price',
                    controller: _priceController,
                    icon: Icons.attach_money_rounded,
                    keyboardType: TextInputType.number,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: _buildTextField(
                    label: 'Original Price',
                    hint: 'MRP (optional)',
                    controller: _originalPriceController,
                    icon: Icons.money_off_csred_rounded,
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            SizedBox(height: 14.h),
            _buildTextField(
              label: 'Max Resale Price',
              hint: 'Maximum you can sell for',
              controller: _maxPriceController,
              icon: Icons.trending_up_rounded,
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 18.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Text(
                'Select Category',
                style: GoogleFonts.outfit(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary(context),
                ),
              ),
            ),
            SizedBox(height: 10.h),
            SizedBox(
              height: 44.h,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
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
                        gradient: selected
                            ? LinearGradient(
                                colors: style.gradientColors,
                              )
                            : null,
                        color: selected ? null : AppColors.bg(context),
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                          color: selected
                              ? Colors.transparent
                              : AppColors.border(context),
                        ),
                        boxShadow: selected
                            ? [
                                BoxShadow(
                                  color: style.glowColor.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ]
                            : null,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            style.icon,
                            size: 15.sp,
                            color: selected
                                ? Colors.white
                                : style.gradientColors[0],
                          ),
                          SizedBox(width: 6.w),
                          Text(
                            cat,
                            style: GoogleFonts.outfit(
                              fontSize: 12.sp,
                              fontWeight:
                                  selected ? FontWeight.w700 : FontWeight.w500,
                              color: selected
                                  ? Colors.white
                                  : AppColors.textSecondary(context),
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
                    color: AppColors.primary(context),
                    borderRadius: BorderRadius.circular(16.r),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary(context).withOpacity(0.3),
                        blurRadius: 14,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Text(
                    'Add Product',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w800,
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
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.outfit(
              fontSize: 12.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary(context),
            ),
          ),
          SizedBox(height: 6.h),
          Container(
            decoration: BoxDecoration(
              color: AppColors.bg(context),
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(color: AppColors.border(context)),
            ),
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              style: GoogleFonts.outfit(
                fontSize: 14.sp,
                color: AppColors.textPrimary(context),
              ),
              decoration: InputDecoration(
                prefixIcon: Icon(
                  icon,
                  color: AppColors.textMuted(context),
                  size: 18.sp,
                ),
                hintText: hint,
                hintStyle: GoogleFonts.outfit(
                  fontSize: 13.sp,
                  color: AppColors.textMuted(context),
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
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(
                color: widget.color.withOpacity(0.22), width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(widget.icon, size: 12.sp, color: widget.color),
              SizedBox(width: 4.w),
              Text(
                widget.label,
                style: GoogleFonts.outfit(
                  fontSize: 10.sp,
                  color: widget.color,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
