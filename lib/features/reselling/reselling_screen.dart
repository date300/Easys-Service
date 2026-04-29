import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'product_model.dart';
import 'resell_bottom_sheet.dart';
import 'product_details_page.dart';
import 'add_product_bottom_sheet.dart';

// ==================== API CLIENT ====================

class ProductApiService {
  static const String baseUrl = 'https://easy.ltcminematrix.com/api';

  Future<List<ProductModel>> fetchProducts({int page = 1, int limit = 50}) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/products?page=$page&limit=$limit'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        if (json['status'] == 'success' && json['data'] is List) {
          return (json['data'] as List)
              .map((p) => ProductModel.fromJson(p))
              .toList();
        }
        throw Exception('Invalid response format');
      } else {
        throw Exception('Failed to fetch products: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }
}

// ==================== RIVERPOD PROVIDERS ====================

final productApiProvider = Provider<ProductApiService>((ref) => ProductApiService());

final productListProvider = FutureProvider<List<ProductModel>>((ref) async {
  final api = ref.watch(productApiProvider);
  return api.fetchProducts();
});

final productNotifierProvider = StateNotifierProvider<ProductListNotifier, List<ProductModel>>((ref) {
  return ProductListNotifier([]);
});

class ProductListNotifier extends StateNotifier<List<ProductModel>> {
  ProductListNotifier(super.state);

  void addProduct(ProductModel product) {
    state = [...state, product];
  }

  void updateProduct(ProductModel updated) {
    state = state.map((p) => p.id == updated.id ? updated : p).toList();
  }

  void removeProduct(int id) {
    state = state.where((p) => p.id != id).toList();
  }

  void setProducts(List<ProductModel> products) {
    state = products;
  }

  List<String> get categories {
    final cats = state.map((p) => p.category).toSet().toList();
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
      final matchSearch = p.productName.toLowerCase().contains(_searchQuery.toLowerCase());
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
          ref.read(productNotifierProvider.notifier).addProduct(newProduct);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final productAsyncValue = ref.watch(productListProvider);
    final localProducts = ref.watch(productNotifierProvider);

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
          child: productAsyncValue.when(
            loading: () => _buildLoadingState(kBackground),
            error: (err, stack) => _buildErrorState(kBackground, kTextDark, kTextMid),
            data: (apiProducts) {
              final allProducts = [...apiProducts, ...localProducts];
              final filtered = _filterProducts(allProducts);
              final myResells = allProducts.where((p) => p.isReselling).toList();

              return NestedScrollView(
                physics: const BouncingScrollPhysics(),
                headerSliverBuilder: (_, __) => [
                  SliverToBoxAdapter(
                    child: _buildSearchBar(hPadding, isSmall, kTextDark, kTextMid, cardBackground, shadowColor, borderColor),
                  ),
                  SliverToBoxAdapter(
                    child: _buildBannerSlider(isSmall, isTablet, isDesktop),
                  ),
                  SliverToBoxAdapter(
                    child: _buildQuickActions(hPadding, isSmall, isDesktop, cardBackground, shadowColor, borderColor, kTextDark),
                  ),
                  SliverToBoxAdapter(
                    child: _buildSectionHeader(hPadding, isSmall, isDesktop, kTextDark, kTextMid, title: 'Products', subtitle: 'Browse all', showViewAll: false),
                  ),
                  SliverToBoxAdapter(
                    child: _buildCategoryFilter(allProducts, isSmall, isDesktop, cardBackground, shadowColor, borderColor, kTextDark),
                  ),
                  SliverToBoxAdapter(
                    child: _buildSectionHeader(hPadding, isSmall, isDesktop, kTextDark, kTextMid, title: 'Popular', subtitle: 'Trending now', showViewAll: false),
                  ),
                  SliverToBoxAdapter(
                    child: _buildCustomTabBar(filtered.length, myResells.length, hPadding, isSmall, cardBackground, borderColor, kTextDark, kTextMid),
                  ),
                ],
                body: TabBarView(
                  controller: _tabController,
                  physics: const BouncingScrollPhysics(),
                  children: [
                    _buildProductsTab(filtered, isSmall, isDesktop, isTablet, cardBackground, shadowColor, kTextDark, kTextMid),
                    _buildMyResellsTab(myResells, isSmall, cardBackground, shadowColor, borderColor, kTextDark, kTextMid),
                  ],
                ),
              );
            },
          ),
        ),
        floatingActionButton: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FloatingActionButton.small(
              heroTag: 'sales',
              onPressed: () => _tabController.animateTo(1),
              backgroundColor: cardBackground,
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
              child: Icon(CupertinoIcons.chart_bar, color: const Color(0xFF29B6F6), size: 18.sp),
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

  Widget _buildLoadingState(Color kBackground) {
    return Scaffold(
      backgroundColor: kBackground,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CupertinoActivityIndicator(radius: 16.r),
            SizedBox(height: 16.h),
            Text('Loading products...', style: GoogleFonts.poppins(fontSize: 14.sp)),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(Color kBackground, Color kTextDark, Color kTextMid) {
    return Scaffold(
      backgroundColor: kBackground,
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(CupertinoIcons.exclamationmark_circle, size: 48.sp, color: Colors.red),
              SizedBox(height: 16.h),
              Text('Failed to load products', style: GoogleFonts.poppins(fontSize: 16.sp, fontWeight: FontWeight.w600, color: kTextDark)),
              SizedBox(height: 8.h),
              Text('Please check your internet connection', textAlign: TextAlign.center, style: GoogleFonts.poppins(fontSize: 13.sp, color: kTextMid)),
              SizedBox(height: 24.h),
              CupertinoButton(
                color: const Color(0xFF29B6F6),
                onPressed: () => ref.refresh(productListProvider),
                child: Text('Retry', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
              ),
            ],
          ),
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
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12.r), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 3))]),
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
                    return Container(color: const Color(0xFF29B6F6).withOpacity(0.1), child: Center(child: CupertinoActivityIndicator(radius: 12.r)));
                  },
                  errorBuilder: (_, __, ___) => Container(
                    color: const Color(0xFF29B6F6).withOpacity(0.1),
                    child: Center(child: Text('Banner Image', style: GoogleFonts.poppins(fontSize: 22.sp, fontWeight: FontWeight.bold, color: const Color(0xFF29B6F6)))),
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
                  Text('Big Sale!', style: GoogleFonts.poppins(fontSize: 20.sp, fontWeight: FontWeight.bold, color: Colors.white, shadows: [Shadow(color: Colors.black.withOpacity(0.3), blurRadius: 6, offset: const Offset(0, 2))])),
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
                  decoration: BoxDecoration(color: cardBackground, shape: BoxShape.circle, border: Border.all(color: borderColor, width: 0.5), boxShadow: [BoxShadow(color: shadowColor, blurRadius: 6, offset: const Offset(0, 2))]),
                  child: Center(child: Icon(action.icon, color: action.color, size: iconSize)),
                ),
                SizedBox(height: 6.h),
                Text(action.label, textAlign: TextAlign.center, style: GoogleFonts.poppins(fontSize: isSmall ? 9.sp : 10.sp, fontWeight: FontWeight.w500, color: kTextDark, height: 1.2)),
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
                  Text('View All', style: GoogleFonts.poppins(fontSize: isSmall ? 10.sp : 11.sp, fontWeight: FontWeight.w600, color: const Color(0xFF29B6F6))),
                  SizedBox(width: 4.w),
                  Icon(CupertinoIcons.forward, size: 12.sp, color: const Color(0xFF29B6F6)),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter(List<ProductModel> allProducts, bool isSmall, bool isDesktop, Color cardBackground, Color shadowColor, Color borderColor, Color kTextDark) {
    final categories = ['All', ...allProducts.map((p) => p.category).toSet().toList()..sort()];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Row(
        children: categories.map((cat) {
          final isSelected = _selectedCategory == cat;
          return Padding(
            padding: EdgeInsets.only(right: 8.w),
            child: GestureDetector(
              onTap: () => setState(() => _selectedCategory = cat),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: EdgeInsets.symmetric(horizontal: isSmall ? 12.w : 16.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF29B6F6) : cardBackground,
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(color: isSelected ? const Color(0xFF29B6F6) : borderColor, width: 1),
                  boxShadow: isSelected ? [BoxShadow(color: const Color(0xFF29B6F6).withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 2))] : [BoxShadow(color: shadowColor, blurRadius: 4, offset: const Offset(0, 1))],
                ),
                child: Text(cat, style: GoogleFonts.poppins(fontSize: isSmall ? 11.sp : 12.sp, fontWeight: FontWeight.w600, color: isSelected ? Colors.white : kTextDark)),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCustomTabBar(int productCount, int resellCount, double hPadding, bool isSmall, Color cardBackground, Color borderColor, Color kTextDark, Color kTextMid) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: hPadding, vertical: 12.h),
      child: Container(
        decoration: BoxDecoration(color: cardBackground, borderRadius: BorderRadius.circular(12.r), border: Border.all(color: borderColor, width: 1)),
        child: TabBar(
          controller: _tabController,
          indicator: BoxDecoration(color: const Color(0xFF29B6F6).withOpacity(0.1), borderRadius: BorderRadius.circular(10.r)),
          labelColor: const Color(0xFF29B6F6),
          unselectedLabelColor: kTextMid,
          labelStyle: GoogleFonts.poppins(fontSize: 12.sp, fontWeight: FontWeight.w600),
          unselectedLabelStyle: GoogleFonts.poppins(fontSize: 12.sp, fontWeight: FontWeight.w500),
          tabs: [
            Tab(child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(CupertinoIcons.square_grid_2x2, size: 16.sp), SizedBox(width: 6.w), Text('All ($productCount)')])),
            Tab(child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(CupertinoIcons.bag, size: 16.sp), SizedBox(width: 6.w), Text('Resells ($resellCount)')])),
          ],
        ),
      ),
    );
  }

  Widget _buildProductsTab(List<ProductModel> products, bool isSmall, bool isDesktop, bool isTablet, Color cardBackground, Color shadowColor, Color kTextDark, Color kTextMid) {
    if (products.isEmpty) {
      return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(CupertinoIcons.cube_box, size: 48.sp, color: kTextMid), SizedBox(height: 16.h), Text('No products found', style: GoogleFonts.poppins(fontSize: 14.sp, color: kTextDark))]));
    }

    int crossAxisCount = isDesktop ? 4 : isTablet ? 3 : 2;
    double childAspectRatio = isDesktop ? 0.75 : isTablet ? 0.7 : 0.65;

    return GridView.builder(
      padding: EdgeInsets.all(16.w),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: childAspectRatio,
        crossAxisSpacing: 12.w,
        mainAxisSpacing: 16.h,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return _buildProductCard(product, cardBackground, shadowColor, kTextDark, kTextMid, isSmall);
      },
    );
  }

  Widget _buildProductCard(ProductModel product, Color cardBackground, Color shadowColor, Color kTextDark, Color kTextMid, bool isSmall) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        CupertinoPageRoute(
          builder: (_) => ProductDetailsPage(
            product: product,
            onStartResell: (sellingPrice) {
              product.isReselling = true;
              ref.read(productNotifierProvider.notifier).updateProduct(product);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Added to resells at ৳${sellingPrice.toInt()}'),
                  duration: const Duration(seconds: 2),
                  backgroundColor: const Color(0xFF29B6F6),
                ),
              );
            },
          ),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(color: cardBackground, borderRadius: BorderRadius.circular(12.r), boxShadow: [BoxShadow(color: shadowColor, blurRadius: 8, offset: const Offset(0, 2))]),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(borderRadius: BorderRadius.vertical(top: Radius.circular(12.r)), color: const Color(0xFF29B6F6).withOpacity(0.05)),
                child: ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(12.r)),
                  child: Image.network(
                    product.imageUrl,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(child: CupertinoActivityIndicator(radius: 8.r));
                    },
                    errorBuilder: (_, __, ___) => Center(child: Icon(CupertinoIcons.photo, size: 24.sp, color: kTextMid)),
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(10.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.productName, maxLines: 2, overflow: TextOverflow.ellipsis, style: GoogleFonts.poppins(fontSize: isSmall ? 10.sp : 11.sp, fontWeight: FontWeight.w600, color: kTextDark)),
                  SizedBox(height: 4.h),
                  Text(product.brand, maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.poppins(fontSize: 9.sp, color: kTextMid)),
                  SizedBox(height: 6.h),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('৳${product.price.toStringAsFixed(0)}', style: GoogleFonts.poppins(fontSize: isSmall ? 10.sp : 11.sp, fontWeight: FontWeight.bold, color: const Color(0xFF29B6F6))),
                            if (product.discountPrice != null) Text('৳${product.discountPrice?.toStringAsFixed(0)}', style: GoogleFonts.poppins(fontSize: 8.sp, decoration: TextDecoration.lineThrough, color: kTextMid)),
                          ],
                        ),
                      ),
                      if (product.avgRating > 0)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [Icon(CupertinoIcons.star_fill, size: 12.sp, color: Colors.amber), SizedBox(width: 2.w), Text(product.avgRating.toStringAsFixed(1), style: GoogleFonts.poppins(fontSize: 8.sp, fontWeight: FontWeight.w600))],
                        ),
                    ],
                  ),
                  if (!product.isInStock) Padding(padding: EdgeInsets.only(top: 6.h), child: Text('Out of Stock', style: GoogleFonts.poppins(fontSize: 8.sp, color: Colors.red, fontWeight: FontWeight.w600))),
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 100.ms).scale(begin: const Offset(0.95, 0.95));
  }

  Widget _buildMyResellsTab(List<ProductModel> products, bool isSmall, Color cardBackground, Color shadowColor, Color borderColor, Color kTextDark, Color kTextMid) {
    if (products.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(CupertinoIcons.cube_box, size: 48.sp, color: kTextMid),
            SizedBox(height: 16.h),
            Text('No resells yet', style: GoogleFonts.poppins(fontSize: 14.sp, color: kTextDark)),
            SizedBox(height: 8.h),
            Text('Start adding products to resell', style: GoogleFonts.poppins(fontSize: 12.sp, color: kTextMid)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16.w),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return Padding(
          padding: EdgeInsets.only(bottom: 12.h),
          child: GestureDetector(
            onTap: () => showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (_) => ResellBottomSheet(
                product: product,
                onConfirm: (sellingPrice) {
                  product.isReselling = true;
                  ref.read(productNotifierProvider.notifier).updateProduct(product);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Resell confirmed at ৳${sellingPrice.toInt()}'),
                      duration: const Duration(seconds: 2),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
              ),
            ),
            child: Container(
              decoration: BoxDecoration(color: cardBackground, borderRadius: BorderRadius.circular(12.r), border: Border.all(color: borderColor, width: 1), boxShadow: [BoxShadow(color: shadowColor, blurRadius: 6, offset: const Offset(0, 2))]),
              child: Padding(
                padding: EdgeInsets.all(12.w),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8.r),
                      child: Image.network(
                        product.imageUrl,
                        width: 80.w,
                        height: 80.w,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(width: 80.w, height: 80.w, color: const Color(0xFF29B6F6).withOpacity(0.1), child: Icon(CupertinoIcons.photo, color: kTextMid)),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(product.productName, maxLines: 2, overflow: TextOverflow.ellipsis, style: GoogleFonts.poppins(fontSize: 12.sp, fontWeight: FontWeight.w600, color: kTextDark)),
                          SizedBox(height: 4.h),
                          Text('৳${product.price.toStringAsFixed(0)}', style: GoogleFonts.poppins(fontSize: 13.sp, fontWeight: FontWeight.bold, color: const Color(0xFF29B6F6))),
                          SizedBox(height: 4.h),
                          Row(
                            children: [Expanded(child: Text('Stock: ${product.stock}', style: GoogleFonts.poppins(fontSize: 10.sp, color: kTextMid))), Icon(CupertinoIcons.arrow_up_right, size: 16.sp, color: const Color(0xFF29B6F6))],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ).animate().fadeIn(delay: (index * 50).ms);
      },
    );
  }
}

class _QuickActionData {
  final IconData icon;
  final String label;
  final Color color;
  _QuickActionData({required this.icon, required this.label, required this.color});
}
