import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';

// ==================== THEME PROVIDERS ====================

final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.system);

// ==================== COLOR TOKENS ====================

class AppColors {
  // Light — Sky/Cyan palette
  static const Color primaryLight = Color(0xFF0EA5E9);      // sky-500
  static const Color primaryLightSoft = Color(0xFF38BDF8);  // sky-400
  static const Color accentLight = Color(0xFF06B6D4);       // cyan-500
  static const Color successLight = Color(0xFF10B981);
  static const Color warningLight = Color(0xFFF59E0B);
  static const Color dangerLight = Color(0xFFEF4444);

  static const Color bgLight = Color(0xFFF0F9FF);           // sky-50
  static const Color surfaceLight = Colors.white;
  static const Color cardLight = Colors.white;
  static const Color textPrimaryLight = Color(0xFF0C1A2E);
  static const Color textSecondaryLight = Color(0xFF475569);
  static const Color textMutedLight = Color(0xFF94A3B8);
  static const Color borderLight = Color(0xFFE0F2FE);       // sky-100
  static const Color shadowLight = Color(0x120EA5E9);

  // Dark — Sky/Cyan palette
  static const Color primaryDark = Color(0xFF38BDF8);
  static const Color primaryDarkSoft = Color(0xFF7DD3FC);
  static const Color accentDark = Color(0xFF22D3EE);
  static const Color successDark = Color(0xFF34D399);
  static const Color warningDark = Color(0xFFFBBF24);
  static const Color dangerDark = Color(0xFFF87171);

  static const Color bgDark = Color(0xFF020B18);
  static const Color surfaceDark = Color(0xFF0D1F35);
  static const Color cardDark = Color(0xFF102840);
  static const Color textPrimaryDark = Color(0xFFE2F4FF);
  static const Color textSecondaryDark = Color(0xFF7DD3FC);
  static const Color textMutedDark = Color(0xFF38BDF8);
  static const Color borderDark = Color(0xFF1E3A52);
  static const Color shadowDark = Color(0x2038BDF8);

  static bool _isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  static Color primary(BuildContext context) =>
      _isDark(context) ? primaryDark : primaryLight;
  static Color primarySoft(BuildContext context) =>
      _isDark(context) ? primaryDarkSoft : primaryLightSoft;
  static Color accent(BuildContext context) =>
      _isDark(context) ? accentDark : accentLight;
  static Color success(BuildContext context) =>
      _isDark(context) ? successDark : successLight;
  static Color warning(BuildContext context) =>
      _isDark(context) ? warningDark : warningLight;
  static Color danger(BuildContext context) =>
      _isDark(context) ? dangerDark : dangerLight;
  static Color bg(BuildContext context) =>
      _isDark(context) ? bgDark : bgLight;
  static Color surface(BuildContext context) =>
      _isDark(context) ? surfaceDark : surfaceLight;
  static Color card(BuildContext context) =>
      _isDark(context) ? cardDark : cardLight;
  static Color textPrimary(BuildContext context) =>
      _isDark(context) ? textPrimaryDark : textPrimaryLight;
  static Color textSecondary(BuildContext context) =>
      _isDark(context) ? textSecondaryDark : textSecondaryLight;
  static Color textMuted(BuildContext context) =>
      _isDark(context) ? textMutedDark : textMutedLight;
  static Color border(BuildContext context) =>
      _isDark(context) ? borderDark : borderLight;
  static Color shadow(BuildContext context) =>
      _isDark(context) ? shadowDark : shadowLight;
}

// ==================== DATA MODELS ====================

class ProductModel {
  final String id;
  final String title;
  final String image;
  final double wholesalePrice;
  final double maxResalePrice;
  final String category;
  final double rating;
  final int totalSold;
  bool isReselling;
  double myMargin;

  ProductModel({
    required this.id,
    required this.title,
    required this.image,
    required this.wholesalePrice,
    required this.maxResalePrice,
    required this.category,
    required this.rating,
    required this.totalSold,
    this.isReselling = false,
    this.myMargin = 0,
  });

  double get myPrice => wholesalePrice + myMargin;
  double get maxMargin => maxResalePrice - wholesalePrice;
}

// ==================== DUMMY DATA ====================

final List<ProductModel> _dummyProducts = [
  ProductModel(
    id: '1',
    title: 'Wireless Earbuds Pro',
    image: 'https://images.unsplash.com/photo-1590658268037-6bf12165a8df?w=400',
    wholesalePrice: 850,
    maxResalePrice: 1400,
    category: 'Electronics',
    rating: 4.8,
    totalSold: 234,
  ),
  ProductModel(
    id: '2',
    title: 'Smart Watch Series',
    image: 'https://images.unsplash.com/photo-1546868871-7041f2a55e12?w=400',
    wholesalePrice: 650,
    maxResalePrice: 1100,
    category: 'Watches',
    rating: 4.5,
    totalSold: 189,
  ),
  ProductModel(
    id: '3',
    title: 'Premium Headphones',
    image: 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=400',
    wholesalePrice: 1200,
    maxResalePrice: 1900,
    category: 'Audio',
    rating: 4.9,
    totalSold: 312,
  ),
  ProductModel(
    id: '4',
    title: 'Power Bank 20000mAh',
    image: 'https://images.unsplash.com/photo-1609091839311-d5365f9ff1c5?w=400',
    wholesalePrice: 1500,
    maxResalePrice: 2500,
    category: 'Electronics',
    rating: 4.7,
    totalSold: 156,
  ),
  ProductModel(
    id: '5',
    title: 'Leather Mini Wallet',
    image: 'https://images.unsplash.com/photo-1624114545437-f1b17c603a3a?w=400',
    wholesalePrice: 780,
    maxResalePrice: 1300,
    category: 'Fashion',
    rating: 4.6,
    totalSold: 98,
  ),
  ProductModel(
    id: '6',
    title: 'Bluetooth Speaker',
    image: 'https://images.unsplash.com/photo-1608043152269-423dbba4e7e1?w=400',
    wholesalePrice: 900,
    maxResalePrice: 1600,
    category: 'Audio',
    rating: 4.4,
    totalSold: 267,
  ),
];

const List<String> _categories = [
  'All',
  'Electronics',
  'Watches',
  'Audio',
  'Fashion',
];

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

  List<ProductModel> get _filteredProducts {
    return _dummyProducts.where((p) {
      final matchCat =
          _selectedCategory == 'All' || p.category == _selectedCategory;
      final matchSearch =
          p.title.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchCat && matchSearch;
    }).toList();
  }

  List<ProductModel> get _myResells =>
      _dummyProducts.where((p) => p.isReselling).toList();

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

  // ==================== BUILD ====================
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: AppColors.bg(context),
        body: SafeArea(
          bottom: false,
          child: NestedScrollView(
            headerSliverBuilder: (_, __) => [
              SliverToBoxAdapter(child: _buildSearchBar()),
              SliverToBoxAdapter(child: _buildCategoryFilter()),
              SliverToBoxAdapter(child: _buildTabBar()),
            ],
            body: TabBarView(
              controller: _tabController,
              children: [
                _buildProductsTab(),
                _buildMyResellsTab(),
              ],
            ),
          ),
        ),
        floatingActionButton: _myResells.isNotEmpty
            ? FloatingActionButton.extended(
                onPressed: () => _tabController.animateTo(1),
                backgroundColor: AppColors.primary(context),
                elevation: 4,
                icon: Icon(Icons.analytics_rounded, size: 16.sp),
                label: Text(
                  'My Sales',
                  style: GoogleFonts.outfit(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )
            : null,
      ),
    );
  }

  // ==================== SEARCH BAR ====================
  Widget _buildSearchBar() {
    return Padding(
      padding: EdgeInsets.fromLTRB(18.w, 12.h, 18.w, 0),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        decoration: BoxDecoration(
          color: AppColors.card(context),
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: _isSearchFocused
                ? AppColors.primary(context).withOpacity(0.6)
                : AppColors.border(context),
            width: _isSearchFocused ? 1.5 : 1,
          ),
          boxShadow: _isSearchFocused
              ? [
                  BoxShadow(
                    color: AppColors.primary(context).withOpacity(0.08),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    color: AppColors.shadow(context),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: TextField(
          controller: _searchController,
          focusNode: _searchFocusNode,
          onChanged: (val) => setState(() => _searchQuery = val),
          style: GoogleFonts.outfit(
            fontSize: 13.sp,
            color: AppColors.textPrimary(context),
          ),
          decoration: InputDecoration(
            hintText: 'Search products...',
            hintStyle: GoogleFonts.outfit(
              fontSize: 13.sp,
              color: AppColors.textMuted(context),
            ),
            prefixIcon: Icon(
              Icons.search_rounded,
              color: _isSearchFocused
                  ? AppColors.primary(context)
                  : AppColors.textMuted(context),
              size: 18.sp,
            ),
            suffixIcon: _searchQuery.isNotEmpty
                ? GestureDetector(
                    onTap: () {
                      _searchController.clear();
                      setState(() => _searchQuery = '');
                    },
                    child: Container(
                      margin: EdgeInsets.all(9.w),
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
                : Padding(
                    padding: EdgeInsets.all(9.w),
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.primary(context).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(7.r),
                      ),
                      child: Icon(
                        Icons.tune_rounded,
                        color: AppColors.primary(context),
                        size: 14.sp,
                      ),
                    ),
                  ),
            filled: false,
            border: InputBorder.none,
            contentPadding:
                EdgeInsets.symmetric(horizontal: 4.w, vertical: 12.h),
          ),
        ),
      ),
    ).animate().fadeIn(delay: 200.ms);
  }

  // ==================== CATEGORY FILTER ====================
  Widget _buildCategoryFilter() {
    return SizedBox(
      height: 46.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.fromLTRB(18.w, 8.h, 18.w, 0),
        itemCount: _categories.length,
        separatorBuilder: (_, __) => SizedBox(width: 7.w),
        itemBuilder: (_, i) {
          final cat = _categories[i];
          final selected = _selectedCategory == cat;
          return GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() => _selectedCategory = cat);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: selected
                    ? AppColors.primary(context)
                    : AppColors.card(context),
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(
                  color: selected
                      ? Colors.transparent
                      : AppColors.border(context),
                ),
                boxShadow: selected
                    ? [
                        BoxShadow(
                          color: AppColors.primary(context).withOpacity(0.25),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ]
                    : null,
              ),
              child: Text(
                cat,
                style: GoogleFonts.outfit(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w600,
                  color: selected
                      ? Colors.white
                      : AppColors.textSecondary(context),
                ),
              ),
            ),
          );
        },
      ),
    ).animate().fadeIn(delay: 280.ms);
  }

  // ==================== TAB BAR ====================
  Widget _buildTabBar() {
    return Container(
      margin: EdgeInsets.fromLTRB(18.w, 10.h, 18.w, 3.h),
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: AppColors.card(context),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColors.border(context)),
      ),
      child: TabBar(
        controller: _tabController,
        labelStyle: GoogleFonts.outfit(
          fontSize: 12.sp,
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelStyle: GoogleFonts.outfit(
          fontSize: 12.sp,
          fontWeight: FontWeight.w400,
        ),
        labelColor: Colors.white,
        unselectedLabelColor: AppColors.textSecondary(context),
        indicator: BoxDecoration(
          color: AppColors.primary(context),
          borderRadius: BorderRadius.circular(11.r),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary(context).withOpacity(0.28),
              blurRadius: 7,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        splashFactory: NoSplash.splashFactory,
        overlayColor: WidgetStateProperty.all(Colors.transparent),
        tabs: [
          Tab(text: 'All Products (${_filteredProducts.length})'),
          Tab(text: 'My Sales (${_myResells.length})'),
        ],
      ),
    ).animate().fadeIn(delay: 320.ms);
  }

  // ==================== PRODUCTS TAB ====================
  Widget _buildProductsTab() {
    final products = _filteredProducts;
    if (products.isEmpty) return _buildEmptyState();

    return GridView.builder(
      padding: EdgeInsets.fromLTRB(14.w, 12.h, 14.w, 90.h),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10.w,
        mainAxisSpacing: 10.h,
        childAspectRatio: 0.63,
      ),
      itemCount: products.length,
      itemBuilder: (_, i) => _ProductCard(
        product: products[i],
      )
          .animate()
          .fadeIn(delay: (i * 50).ms, duration: 300.ms)
          .slideY(begin: 0.07, curve: Curves.easeOut),
    );
  }

  // ==================== MY RESELLS TAB ====================
  Widget _buildMyResellsTab() {
    if (_myResells.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(22.w),
              decoration: BoxDecoration(
                color: AppColors.primary(context).withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.inventory_2_outlined,
                size: 40.sp,
                color: AppColors.primary(context),
              ),
            ).animate().scale(duration: 500.ms, curve: Curves.elasticOut),
            SizedBox(height: 14.h),
            Text(
              'No active sales yet',
              style: GoogleFonts.outfit(
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary(context),
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              'Pick a product and set your margin',
              style: GoogleFonts.outfit(
                fontSize: 12.sp,
                color: AppColors.textMuted(context),
              ),
            ),
            SizedBox(height: 16.h),
            GestureDetector(
              onTap: () => _tabController.animateTo(0),
              child: Container(
                padding:
                    EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: AppColors.primary(context),
                  borderRadius: BorderRadius.circular(12.r),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary(context).withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Text(
                  'Browse Products',
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 13.sp,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.fromLTRB(14.w, 12.h, 14.w, 90.h),
      itemCount: _myResells.length,
      itemBuilder: (_, i) => _ActiveResellCard(
        product: _myResells[i],
        onStop: () => setState(() => _myResells[i].isReselling = false),
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
              size: 46.sp, color: AppColors.textMuted(context)),
          SizedBox(height: 12.h),
          Text(
            'No products found',
            style: GoogleFonts.outfit(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary(context),
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== PRODUCT CARD ====================
class _ProductCard extends StatefulWidget {
  final ProductModel product;

  const _ProductCard({required this.product});

  @override
  State<_ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<_ProductCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        HapticFeedback.lightImpact();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.card(context),
            borderRadius: BorderRadius.circular(17.r),
            border: Border.all(color: AppColors.border(context)),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadow(context),
                blurRadius: 12,
                offset: const Offset(0, 4),
                spreadRadius: -2,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image
              Stack(
                children: [
                  ClipRRect(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(17.r)),
                    child: SizedBox(
                      height: 118.h,
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
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 7.w, vertical: 3.h),
                        decoration: BoxDecoration(
                          color: AppColors.success(context),
                          borderRadius: BorderRadius.circular(7.r),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.success(context).withOpacity(0.4),
                              blurRadius: 5,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.check_rounded,
                                color: Colors.white, size: 9.sp),
                            SizedBox(width: 2.w),
                            Text(
                              'Active',
                              style: GoogleFonts.outfit(
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
                      padding: EdgeInsets.symmetric(
                          horizontal: 6.w, vertical: 3.h),
                      decoration: BoxDecoration(
                        color: AppColors.card(context).withOpacity(0.92),
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(
                            color: AppColors.border(context).withOpacity(0.6)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.star_rounded,
                              color: const Color(0xFFFFCC02), size: 10.sp),
                          SizedBox(width: 2.w),
                          Text(
                            widget.product.rating.toString(),
                            style: GoogleFonts.outfit(
                              fontSize: 9.sp,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              // Info
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(10.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.product.title,
                        style: GoogleFonts.outfit(
                          fontSize: 11.5.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary(context),
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 5.h),
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 5.w, vertical: 2.h),
                            decoration: BoxDecoration(
                              color: AppColors.primary(context).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(5.r),
                            ),
                            child: Text(
                              '৳${widget.product.wholesalePrice.toInt()}',
                              style: GoogleFonts.outfit(
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary(context),
                              ),
                            ),
                          ),
                          SizedBox(width: 4.w),
                          Flexible(
                            child: Text(
                              '+৳${widget.product.maxMargin.toInt()}',
                              style: GoogleFonts.outfit(
                                fontSize: 9.5.sp,
                                color: AppColors.success(context),
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 3.h),
                      Text(
                        '${widget.product.totalSold} sold',
                        style: GoogleFonts.outfit(
                          fontSize: 9.sp,
                          color: AppColors.textMuted(context),
                        ),
                      ),
                      const Spacer(),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(vertical: 8.h),
                        decoration: BoxDecoration(
                          color: AppColors.primary(context),
                          borderRadius: BorderRadius.circular(10.r),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary(context).withOpacity(0.25),
                              blurRadius: 7,
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
                              size: 12.sp,
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              'Resell',
                              style: GoogleFonts.outfit(
                                fontSize: 10.5.sp,
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
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
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.card(context),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.border(context)),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow(context),
            blurRadius: 10,
            offset: const Offset(0, 3),
            spreadRadius: -2,
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12.r),
            child: SizedBox(
              width: 62.w,
              height: 62.w,
              child: Image.network(
                product.image,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: AppColors.bg(context),
                  child: Icon(
                    Icons.image_not_supported_outlined,
                    color: AppColors.textMuted(context),
                    size: 22.sp,
                  ),
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
                  style: GoogleFonts.outfit(
                    fontSize: 12.5.sp,
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
                      'Sell Price: ',
                      style: GoogleFonts.outfit(
                        fontSize: 10.sp,
                        color: AppColors.textSecondary(context),
                      ),
                    ),
                    Text(
                      '৳${product.myPrice.toInt()}',
                      style: GoogleFonts.outfit(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary(context),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4.h),
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 7.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: AppColors.success(context).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(7.r),
                    border: Border.all(
                        color: AppColors.success(context).withOpacity(0.25)),
                  ),
                  child: Text(
                    'Profit ৳${product.myMargin.toInt()}',
                    style: GoogleFonts.outfit(
                      fontSize: 9.5.sp,
                      color: AppColors.success(context),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                SizedBox(height: 8.h),
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

// ==================== HELPER WIDGETS ====================

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
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 5.h),
          decoration: BoxDecoration(
            color: widget.color.withOpacity(_pressed ? 0.18 : 0.1),
            borderRadius: BorderRadius.circular(9.r),
            border: Border.all(
                color: widget.color.withOpacity(0.22), width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(widget.icon, size: 11.sp, color: widget.color),
              SizedBox(width: 3.w),
              Text(
                widget.label,
                style: GoogleFonts.outfit(
                  fontSize: 9.5.sp,
                  color: widget.color,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
