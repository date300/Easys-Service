import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'product_model.dart';
import 'resell_bottom_sheet.dart';
import 'add_product_bottom_sheet.dart';
import '../../main.dart';

// ==================== RIVERPOD PROVIDERS ====================

final productListProvider = StateNotifierProvider<ProductListNotifier, List<ProductModel>>((ref) {
  return ProductListNotifier();
});

class ProductListNotifier extends StateNotifier<List<ProductModel>> {
  ProductListNotifier() : super([]);

  Future<void> fetchProducts() async {
    try {
      final response = await http.get(
        Uri.parse('https://easy.ltcminematrix.com/api/products'),
      );
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        if (json['status'] == 'success' && json['data'] is List) {
          final products = (json['data'] as List)
              .map((item) => ProductModel.fromJson(item))
              .toList();
          state = products;
        }
      } else {
        debugPrint('API Error: ${response.statusCode}');
      }
    } catch (e, stack) {
      debugPrint('Error fetching products: $e');
      debugPrint(stack.toString());
    }
  }

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
    final cats = state.map((p) => p.category).whereType<String>().toSet().toList();
    cats.sort();
    return ['All', ...cats];
  }
}

// ==================== MAIN SCREEN ====================

class ResellingScreen extends ConsumerStatefulWidget {
  const ResellingScreen({super.key});

  @override
  ConsumerState<ResellingScreen> createState() => _ResellingScreenState();
}

// ==================== CATEGORY STYLE HELPER ====================

class CategoryStyle {
  final Color color;
  final IconData icon;

  const CategoryStyle({required this.color, required this.icon});
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
    Future.microtask(() {
      ref.read(productListProvider.notifier).fetchProducts();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  CategoryStyle getCategoryStyle(String category) {
    switch (category.toLowerCase()) {
      case 'electronics':
        return const CategoryStyle(color: Color(0xFF29B6F6), icon: CupertinoIcons.tv);
      case 'fashion':
        return const CategoryStyle(color: Color(0xFFFF4081), icon: CupertinoIcons.tag);
      case 'home':
        return const CategoryStyle(color: Color(0xFF66BB6A), icon: CupertinoIcons.house);
      case 'automotive':
        return const CategoryStyle(color: Color(0xFFFFA726), icon: CupertinoIcons.car);
      case 'sports':
        return const CategoryStyle(color: Color(0xFFAB47BC), icon: CupertinoIcons.sportscourt);
      case 'books':
        return const CategoryStyle(color: Color(0xFF8D6E63), icon: CupertinoIcons.book);
      case 'toys':
        return const CategoryStyle(color: Color(0xFFEF5350), icon: CupertinoIcons.gamecontroller);
      case 'beauty':
        return const CategoryStyle(color: Color(0xFFEC407A), icon: CupertinoIcons.heart);
      case 'food':
        return const CategoryStyle(color: Color(0xFF66BB6A), icon: CupertinoIcons.cart);
      case 'all':
        return const CategoryStyle(color: Color(0xFF29B6F6), icon: CupertinoIcons.circle_grid_3x3);
      default:
        return const CategoryStyle(color: Color(0xFF78909C), icon: CupertinoIcons.cube_box);
    }
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
        onProductAdded: (ProductModel newProduct) {
          ref.read(productListProvider.notifier).addProduct(newProduct);
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
                style: GoogleFonts.poppins(fontSize: 12.sp, fontWeight: FontWeight.w600, color: Colors.white),
              ),
            ).animate().scale(delay: 150.ms),
          ],
        ),
      ),
    );
  }

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
          boxShadow: [BoxShadow(color: shadowColor, blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: TextField(
          controller: _searchController,
          focusNode: _searchFocusNode,
          onChanged: (val) => setState(() => _searchQuery = val),
          style: GoogleFonts.poppins(fontSize: isSmall ? 12.sp : 13.sp, color: kTextDark),
          decoration: InputDecoration(
            hintText: 'Search Products...',
            hintStyle: GoogleFonts.poppins(fontSize: isSmall ? 12.sp : 13.sp, color: kTextMid),
            prefixIcon: Icon(CupertinoIcons.search, color: _isSearchFocused ? const Color(0xFF29B6F6) : kTextMid, size: isSmall ? 18.sp : 20.sp),
            suffixIcon: _searchQuery.isNotEmpty
                ? GestureDetector(
                    onTap: () {
                      _searchController.clear();
                      setState(() => _searchQuery = '');
                    },
                    child: Container(
                      margin: EdgeInsets.all(10.w),
                      decoration: BoxDecoration(color: borderColor, shape: BoxShape.circle),
                      child: Icon(CupertinoIcons.xmark, color: kTextMid, size: 12.sp),
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
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 3))],
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
                      child: Text('Banner Image', style: GoogleFonts.poppins(fontSize: 22.sp, fontWeight: FontWeight.bold, color: const Color(0xFF29B6F6))),
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
                  colors: [Colors.black.withOpacity(0.3), Colors.transparent, Colors.transparent],
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
                    decoration: BoxDecoration(color: const Color(0xFF29B6F6), borderRadius: BorderRadius.circular(8.r)),
                    child: Text('Special Offer', style: GoogleFonts.poppins(fontSize: 10.sp, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Big Sale!',
                    style: GoogleFonts.poppins(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [Shadow(color: Colors.black.withOpacity(0.3), blurRadius: 6, offset: const Offset(0, 2))],
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
                    boxShadow: [BoxShadow(color: shadowColor, blurRadius: 6, offset: const Offset(0, 2))],
                  ),
                  child: Center(child: Icon(action.icon, color: action.color, size: iconSize)),
                ),
                SizedBox(height: 6.h),
                Text(
                  action.label,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(fontSize: isSmall ? 9.sp : 10.sp, fontWeight: FontWeight.w500, color: kTextDark, height: 1.2),
                ),
              ],
            ),
          ).animate().fadeIn(delay: (actions.indexOf(action) * 80).ms).scale(begin: const Offset(0.85, 0.85), curve: Curves.easeOutBack);
        }).toList(),
      ),
    );
  }

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
              Text(title, style: GoogleFonts.poppins(fontSize: isSmall ? 14.sp : isDesktop ? 18.sp : 16.sp, fontWeight: FontWeight.bold, color: kTextDark)),
              Text(subtitle, style: GoogleFonts.poppins(fontSize: isSmall ? 10.sp : isDesktop ? 12.sp : 11.sp, color: kTextMid)),
            ],
          ),
          if (showViewAll)
            TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h), minimumSize: Size.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('See All', style: GoogleFonts.poppins(fontSize: isSmall ? 10.sp : 11.sp, color: const Color(0xFF29B6F6), fontWeight: FontWeight.w600)),
                  SizedBox(width: 2.w),
                  Icon(CupertinoIcons.chevron_right, size: isSmall ? 10.sp : 12.sp, color: const Color(0xFF29B6F6)),
                ],
              ),
            ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms);
  }

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
          final style = getCategoryStyle(cat);
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
                    border: Border.all(color: selected ? style.color.withOpacity(0.5) : borderColor, width: selected ? 2 : 0.5),
                    boxShadow: [BoxShadow(color: shadowColor, blurRadius: 6, offset: const Offset(0, 2))],
                  ),
                  child: Center(child: Icon(style.icon, color: selected ? style.color : kTextDark.withOpacity(0.6), size: iconSize)),
                ),
                SizedBox(height: 6.h),
                Text(
                  cat,
                  style: GoogleFonts.poppins(fontSize: isSmall ? 9.sp : 10.sp, fontWeight: selected ? FontWeight.w700 : FontWeight.w500, color: selected ? style.color : kTextDark),
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

  Widget _buildCustomTabBar(int allCount, int myCount, double hPadding, bool isSmall, Color cardBackground, Color borderColor, Color kTextDark, Color kTextMid) {
    return Container(
      margin: EdgeInsets.fromLTRB(hPadding, 16.h, hPadding, 4.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: cardBackground,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: borderColor),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
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
                  style: GoogleFonts.poppins(fontSize: isSmall ? 11.sp : 12.sp, fontWeight: FontWeight.w600, color: _tabController.index == 0 ? Colors.white : kTextMid),
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
                  style: GoogleFonts.poppins(fontSize: isSmall ? 11.sp : 12.sp, fontWeight: FontWeight.w600, color: _tabController.index == 1 ? Colors.white : kTextMid),
                ),
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 350.ms);
  }

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
        ref: ref,
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
            stock: product.stock,
          );
          ref.read(productListProvider.notifier).updateProduct(updated);
        },
      ),
    );
  }

  Widget _buildMyResellsTab(List<ProductModel> myResells, bool isSmall, Color cardBackground, Color shadowColor, Color borderColor, Color kTextDark, Color kTextMid) {
    if (myResells.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(24.w),
              decoration: BoxDecoration(color: const Color(0xFF29B6F6).withOpacity(0.08), shape: BoxShape.circle),
              child: Icon(CupertinoIcons.cube_box, size: 44.sp, color: const Color(0xFF29B6F6)),
            ).animate().scale(duration: 500.ms, curve: Curves.elasticOut),
            SizedBox(height: 16.h),
            Text('No active sales yet', style: GoogleFonts.poppins(fontSize: 16.sp, fontWeight: FontWeight.bold, color: kTextDark)),
            SizedBox(height: 6.h),
            Text('Pick a product and set your margin', style: GoogleFonts.poppins(fontSize: 13.sp, color: kTextMid)),
            SizedBox(height: 20.h),
            GestureDetector(
              onTap: () => _tabController.animateTo(0),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: const Color(0xFF29B6F6),
                  borderRadius: BorderRadius.circular(12.r),
                  boxShadow: [BoxShadow(color: const Color(0xFF29B6F6).withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4))],
                ),
                child: Text('Browse Products', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14.sp)),
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
            stock: myResells[i].stock,
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
          Text('No products found', style: GoogleFonts.poppins(fontSize: 15.sp, fontWeight: FontWeight.w500, color: kTextMid)),
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
  final WidgetRef ref;

  const _ResellProductCard({
    required this.product,
    required this.isSmall,
    required this.cardBackground,
    required this.shadowColor,
    required this.kTextDark,
    required this.kTextMid,
    required this.ref,
  });

  @override
  State<_ResellProductCard> createState() => _ResellProductCardState();
}

class _ResellProductCardState extends State<_ResellProductCard> {
  bool _pressed = false;

  // ✅ সঠিক জায়গায় — GoRouter + isDetailViewProvider
  void _goToDetails() {
    widget.ref.read(isDetailViewProvider.notifier).state = true;
    widget.ref.read(detailViewTitleProvider.notifier).state = widget.product.title;
    context.push('/product/${widget.product.id}');
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        _goToDetails();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: Container(
          decoration: BoxDecoration(
            color: widget.cardBackground,
            borderRadius: BorderRadius.circular(12.r),
            boxShadow: [BoxShadow(color: widget.shadowColor, blurRadius: 6, offset: const Offset(0, 2), spreadRadius: 0)],
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
                          child: Center(child: Icon(CupertinoIcons.photo, color: Colors.grey.shade400, size: 28.sp)),
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
                        decoration: BoxDecoration(color: const Color(0xFF34C759), borderRadius: BorderRadius.circular(6.r)),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(CupertinoIcons.checkmark_alt, color: Colors.white, size: 9.sp),
                            SizedBox(width: 2.w),
                            Text('Active', style: GoogleFonts.poppins(fontSize: 8.5.sp, color: Colors.white, fontWeight: FontWeight.w700)),
                          ],
                        ),
                      ),
                    ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
                      decoration: BoxDecoration(color: widget.cardBackground.withOpacity(0.92), borderRadius: BorderRadius.circular(8.r)),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(CupertinoIcons.star_fill, color: const Color(0xFFFFCC02), size: 10.sp),
                          SizedBox(width: 2.w),
                          Text(widget.product.rating.toString(), style: GoogleFonts.poppins(fontSize: 9.sp, fontWeight: FontWeight.w700, color: widget.kTextDark)),
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
                        style: GoogleFonts.poppins(fontSize: widget.isSmall ? 10.sp : 11.sp, fontWeight: FontWeight.w600, color: widget.kTextDark, height: 1.3),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (widget.product.subtitle != null) ...[
                        SizedBox(height: 2.h),
                        Text(
                          widget.product.subtitle!,
                          style: GoogleFonts.poppins(fontSize: 9.sp, fontWeight: FontWeight.w400, color: widget.kTextMid, height: 1.2),
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
                            style: GoogleFonts.poppins(fontSize: 14.sp, fontWeight: FontWeight.bold, color: const Color(0xFF29B6F6)),
                          ),
                          SizedBox(width: 5.w),
                          if (widget.product.originalPrice != null)
                            Text(
                              '\u09F3${widget.product.originalPrice!.toInt()}',
                              style: GoogleFonts.poppins(fontSize: 10.sp, fontWeight: FontWeight.w500, color: widget.kTextMid, decoration: TextDecoration.lineThrough),
                            ),
                        ],
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
        boxShadow: [BoxShadow(color: shadowColor, blurRadius: 6, offset: const Offset(0, 2), spreadRadius: 0)],
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
                Text(product.title, style: GoogleFonts.poppins(fontSize: 13.sp, fontWeight: FontWeight.w600, color: kTextDark), maxLines: 1, overflow: TextOverflow.ellipsis),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Text('Sell: ', style: GoogleFonts.poppins(fontSize: 11.sp, color: kTextMid)),
                    Text('\u09F3${product.myPrice.toInt()}', style: GoogleFonts.poppins(fontSize: 14.sp, fontWeight: FontWeight.bold, color: const Color(0xFF29B6F6))),
                  ],
                ),
                SizedBox(height: 4.h),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 2.h),
                  decoration: BoxDecoration(color: const Color(0xFF34C759).withOpacity(0.1), borderRadius: BorderRadius.circular(6.r)),
                  child: Text('Profit \u09F3${product.myMargin.toInt()}', style: GoogleFonts.poppins(fontSize: 9.5.sp, color: const Color(0xFF34C759), fontWeight: FontWeight.w700)),
                ),
                SizedBox(height: 8.h),
                Row(
                  children: [
                    _MiniButton(icon: CupertinoIcons.stop_circle, label: 'Stop', color: const Color(0xFFFF3B30), onTap: onStop),
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

  const _MiniButton({required this.icon, required this.label, required this.color, required this.onTap});

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
              Text(widget.label, style: GoogleFonts.poppins(fontSize: 10.sp, color: widget.color, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}
