import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'product_model.dart';
import 'resell_bottom_sheet.dart';

// ==================== CONSTANTS ====================
const Color kPrimary = Color(0xFF29B6F6);
const Color kTextMid = Color(0xFF64748B);

// ==================== API SERVICE (unchanged) ====================
class ApiService {
  static const String baseUrl = 'https://easy.ltcminematrix.com/api';
  static String? authToken;

  static Future<void> loadAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    authToken = prefs.getString('jwt_token');
    debugPrint('ApiService: token loaded = $authToken');
  }

  static Map<String, String> get headers => {
        'Content-Type': 'application/json',
        if (authToken != null) 'Authorization': 'Bearer $authToken',
      };

  static Future<ProductModel?> fetchProductDetail(String productId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/product/$productId'),
        headers: headers,
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          final productData = {
            ...Map<String, dynamic>.from(data['product']),
            'images': data['images'] ?? [],
            'variants': data['variants'] ?? [],
            'is_wishlisted': data['is_wishlisted'] ?? false,
          };
          return ProductModel.fromJson(productData);
        }
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching product: $e');
      return null;
    }
  }

  static Future<List<Map<String, dynamic>>> fetchProductReviews(
    String productId, {
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/product/$productId/reviews?page=$page&limit=$limit'),
        headers: headers,
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          return List<Map<String, dynamic>>.from(data['data'] ?? []);
        }
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching reviews: $e');
      return [];
    }
  }

  static Future<bool> toggleWishlist(String productId) async {
    if (authToken == null) {
      debugPrint('Wishlist failed: No auth token');
      return false;
    }
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/product/$productId/wishlist'),
        headers: headers,
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['is_wishlisted'] == true;
      }
      return false;
    } catch (e) {
      debugPrint('Error toggling wishlist: $e');
      return false;
    }
  }
}

// ==================== PRODUCT DETAILS PAGE ====================
class ProductDetailsPage extends StatefulWidget {
  final String productId;
  final Function(double margin)? onStartResell;

  const ProductDetailsPage({
    super.key,
    required this.productId,
    this.onStartResell,
  });

  @override
  State<ProductDetailsPage> createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage>
    with SingleTickerProviderStateMixin {
  final PageController _imagePageController = PageController();
  int _currentImageIndex = 0;
  bool _showFullDescription = false;
  bool _isLoading = true;
  bool _isWishlisted = false;
  String? _error;

  ProductModel? _product;
  List<Map<String, dynamic>> _reviews = [];
  bool _isLoadingReviews = false;

  ProductVariant? _selectedVariant;
  String? _selectedColor;
  String? _selectedSize;

  late AnimationController _heartAnimController;

  @override
  void initState() {
    super.initState();
    _heartAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _loadProduct();
  }

  Future<void> _loadProduct() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    await ApiService.loadAuthToken();
    final product = await ApiService.fetchProductDetail(widget.productId);
    if (mounted) {
      if (product != null) {
        setState(() {
          _product = product;
          _isWishlisted = product.isWishlisted;
          _isLoading = false;
        });
        _loadReviews();
      } else {
        setState(() {
          _error = 'Failed to load product';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadReviews() async {
    if (_product == null) return;
    setState(() => _isLoadingReviews = true);
    final reviews = await ApiService.fetchProductReviews(_product!.id);
    if (mounted) {
      setState(() {
        _reviews = reviews;
        _isLoadingReviews = false;
      });
    }
  }

  Future<void> _toggleWishlist() async {
    if (_product == null) return;
    if (ApiService.authToken == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please login to add to wishlist',
            style: GoogleFonts.poppins(fontSize: 13.sp),
          ),
          backgroundColor: const Color(0xFFFF3B30),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
        ),
      );
      return;
    }
    HapticFeedback.lightImpact();
    _heartAnimController.forward(from: 0);
    setState(() => _isWishlisted = !_isWishlisted);
    final result = await ApiService.toggleWishlist(_product!.id);
    if (mounted) {
      setState(() => _isWishlisted = result);
    }
  }

  List<String> get _productImages {
    if (_product == null) return [];
    if (_product!.images.isNotEmpty) {
      return _product!.images.map((img) => img.imageUrl).toList();
    }
    if (_product!.image.isNotEmpty) return [_product!.image];
    return [];
  }

  List<String> get _availableColors =>
      _product?.variants.where((v) => v.color != null && v.color!.isNotEmpty).map((v) => v.color!).toSet().toList() ?? [];

  List<String> get _availableSizes =>
      _product?.variants.where((v) => v.size != null && v.size!.isNotEmpty).map((v) => v.size!).toSet().toList() ?? [];

  double get _currentPrice => _selectedVariant?.price ?? _product?.wholesalePrice ?? 0;

  int get _currentStock => _selectedVariant?.stock ?? _product?.stock ?? 0;

  void _updateSelectedVariant() {
    if (_selectedColor == null && _selectedSize == null) {
      _selectedVariant = null;
      return;
    }
    final matches = _product!.variants.where((v) {
      final colorMatch = _selectedColor == null || v.color == _selectedColor;
      final sizeMatch = _selectedSize == null || v.size == _selectedSize;
      return colorMatch && sizeMatch;
    }).toList();
    _selectedVariant = matches.isNotEmpty ? matches.first : null;
  }

  void _showResellSheet() {
    if (_product == null) return;
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ResellBottomSheet(
        product: _product!,
        selectedVariant: _selectedVariant,
        onConfirm: (margin) {
          widget.onStartResell?.call(margin);
          Navigator.pop(context);
          context.pop();
        },
      ),
    );
  }

  @override
  void dispose() {
    _imagePageController.dispose();
    _heartAnimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 1024;
    final isTablet = screenWidth >= 600 && screenWidth < 1024;
    final isSmall = screenWidth < 360;

    final kBackground = isDark ? const Color(0xFF121212) : const Color(0xFFF8FAFC);
    final kTextDark = isDark ? Colors.white : const Color(0xFF0F172A);
    final kTextMid = isDark ? Colors.grey.shade400 : const Color(0xFF475569);
    final cardBackground = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final shadowColor = isDark ? Colors.black.withOpacity(0.3) : Colors.black.withOpacity(0.04);
    final borderColor = isDark ? const Color(0xFF333333) : Colors.grey.withOpacity(0.1);

    final hPadding = isDesktop ? 32.w : isTablet ? 20.w : isSmall ? 12.w : 16.w;
    final vPadding = isDesktop ? 24.h : isTablet ? 20.h : 16.h;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: kBackground,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CupertinoActivityIndicator(radius: 14.r, color: kPrimary),
              SizedBox(height: 16.h),
              Text('Loading product...', style: GoogleFonts.poppins(fontSize: 14.sp, color: kTextMid)),
            ],
          ),
        ),
      );
    }

    if (_error != null || _product == null) {
      return Scaffold(
        backgroundColor: kBackground,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(CupertinoIcons.exclamationmark_triangle, size: 48.sp, color: Colors.orange),
              SizedBox(height: 16.h),
              Text(_error ?? 'Product not found', style: GoogleFonts.poppins(fontSize: 16.sp, color: kTextDark)),
              SizedBox(height: 24.h),
              CupertinoButton(
                onPressed: _loadProduct,
                color: kPrimary,
                child: Text('Retry', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ),
      );
    }

    final product = _product!;
    final discount = product.originalPrice > 0
        ? (((product.originalPrice - product.wholesalePrice) / product.originalPrice) * 100).toStringAsFixed(0)
        : null;

    return Scaffold(
      backgroundColor: kBackground,
      body: Stack(
        children: [
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ইমেজ স্লাইডার – ফুল প্রস্থে, কোনো প্যাডিং ছাড়া
                _buildImageSlider(isDark, shadowColor, borderColor, isDesktop, isTablet, isSmall),
                // বাকি সব কন্টেন্ট প্যাডিং সহ
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: hPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: vPadding),
                      _buildSectionHeader('Price', 'Wholesale & discount', kTextDark, kTextMid, isDesktop: isDesktop, isSmall: isSmall),
                      _buildPriceSection(isDark, kTextDark, kTextMid, borderColor, discount, isDesktop, isTablet, isSmall),
                      SizedBox(height: isDesktop ? 20.h : 12.h),
                      if (product.variants.isNotEmpty) ...[
                        _buildSectionHeader('Select Variant', 'Choose your preference', kTextDark, kTextMid, isDesktop: isDesktop, isSmall: isSmall),
                        _buildVariantSelector(isDark, kTextDark, kTextMid, borderColor, isDesktop, isTablet, isSmall),
                        SizedBox(height: isDesktop ? 20.h : 12.h),
                      ],
                      _buildSectionHeader('Stock', 'Availability', kTextDark, kTextMid, isDesktop: isDesktop, isSmall: isSmall),
                      _buildStockBadge(isDark, kTextDark, borderColor, isDesktop, isTablet, isSmall),
                      SizedBox(height: isDesktop ? 20.h : 12.h),
                      _buildSectionHeader('Product Description', 'Details & Specifications', kTextDark, kTextMid, isDesktop: isDesktop, isSmall: isSmall),
                      _buildDescription(isDark, kTextDark, kTextMid, borderColor, isDesktop, isTablet, isSmall),
                      SizedBox(height: isDesktop ? 20.h : 12.h),
                      _buildSectionHeader('Ratings & Reviews', 'See what others say', kTextDark, kTextMid, isDesktop: isDesktop, isSmall: isSmall),
                      _buildRatings(isDark, kTextDark, kTextMid, borderColor, isDesktop, isTablet, isSmall),
                      SizedBox(height: 100.h + vPadding),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildBottomBar(isDark, cardBackground, kTextDark, kTextMid, borderColor, shadowColor, isDesktop, isTablet, isSmall),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, String subtitle, Color kTextDark, Color kTextMid, {bool isDesktop = false, bool isSmall = false, bool showViewAll = false, VoidCallback? onViewAll}) {
    return Row(
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
            onPressed: onViewAll ?? () {},
            style: TextButton.styleFrom(padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h), minimumSize: Size.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('See All', style: GoogleFonts.poppins(fontSize: isSmall ? 10.sp : 11.sp, color: kPrimary, fontWeight: FontWeight.w600)),
                SizedBox(width: 2.w),
                Icon(CupertinoIcons.chevron_right, size: isSmall ? 10.sp : 12.sp, color: kPrimary),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildImageSlider(bool isDark, Color shadowColor, Color borderColor, bool isDesktop, bool isTablet, bool isSmall) {
    final images = _productImages;
    final bannerHeight = isDesktop ? 360.h : isTablet ? 300.h : isSmall ? 220.h : 320.h;

    if (images.isEmpty) {
      return SizedBox(
        height: bannerHeight,
        child: Center(
          child: Icon(CupertinoIcons.photo, color: Colors.grey.shade300, size: 60.sp),
        ),
      );
    }

    return SizedBox(
      height: bannerHeight,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.r),
        child: Stack(
          children: [
            PageView.builder(
              controller: _imagePageController,
              itemCount: images.length,
              onPageChanged: (i) => setState(() => _currentImageIndex = i),
              itemBuilder: (context, index) {
                return Padding(
                  padding: EdgeInsets.all(isSmall ? 16.w : 24.w),
                  child: Image.network(
                    images[index],
                    fit: BoxFit.contain,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(child: CupertinoActivityIndicator(radius: 14.r, color: kPrimary));
                    },
                    errorBuilder: (_, __, ___) => Center(
                      child: Icon(CupertinoIcons.photo, color: Colors.grey.shade300, size: 60.sp),
                    ),
                  ),
                );
              },
            ),
            if (images.length > 1)
              Positioned(
                left: isSmall ? 8.w : 12.w,
                top: isSmall ? 40.h : 60.h,
                child: Column(
                  children: List.generate(images.length, (i) {
                    final selected = _currentImageIndex == i;
                    return GestureDetector(
                      onTap: () => _imagePageController.animateToPage(i, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: EdgeInsets.symmetric(vertical: 4.h),
                        width: selected ? (isSmall ? 38.w : 46.w) : (isSmall ? 34.w : 42.w),
                        height: selected ? (isSmall ? 38.w : 46.w) : (isSmall ? 34.w : 42.w),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
                          borderRadius: BorderRadius.circular(10.r),
                          border: Border.all(color: selected ? kPrimary : borderColor, width: selected ? 2.5 : 1),
                          boxShadow: selected
                              ? [BoxShadow(color: kPrimary.withOpacity(0.25), blurRadius: 8, offset: const Offset(0, 2))]
                              : [BoxShadow(color: shadowColor, blurRadius: 4, offset: const Offset(0, 1))],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8.r),
                          child: Image.network(images[i], fit: BoxFit.cover, errorBuilder: (_, __, ___) => Icon(CupertinoIcons.photo, color: Colors.grey.shade300, size: 18.sp)),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            if (images.length > 1)
              Positioned(
                bottom: isSmall ? 8.h : 12.h,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(images.length, (i) {
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: EdgeInsets.symmetric(horizontal: 3.w),
                      width: _currentImageIndex == i ? 20.w : 6.w,
                      height: isSmall ? 5.h : 6.h,
                      decoration: BoxDecoration(
                        color: _currentImageIndex == i ? kPrimary : Colors.grey.withOpacity(0.35),
                        borderRadius: BorderRadius.circular(3.r),
                      ),
                    );
                  }),
                ),
              ),
            if (_product?.originalPrice != null && _product!.originalPrice > 0)
              Positioned(
                top: isSmall ? 12.h : 16.h,
                right: isSmall ? 12.w : 16.w,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [kPrimary, Color(0xFF0284C7)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                    borderRadius: BorderRadius.circular(8.r),
                    boxShadow: [BoxShadow(color: kPrimary.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 2))],
                  ),
                  child: Text(
                    '-${((_product!.originalPrice - _product!.wholesalePrice) / _product!.originalPrice * 100).toStringAsFixed(0)}%',
                    style: GoogleFonts.poppins(fontSize: isSmall ? 10.sp : 11.sp, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ).animate().scale(delay: 300.ms, curve: Curves.elasticOut),
              ),
            Positioned(
              top: isSmall ? 8.h : 12.h,
              left: isSmall ? 8.w : 12.w,
              child: Row(
                children: [
                  GestureDetector(
                    onTap: _toggleWishlist,
                    child: Container(
                      padding: EdgeInsets.all(isSmall ? 6.w : 8.w),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E1E1E).withOpacity(0.95) : Colors.white.withOpacity(0.95),
                        shape: BoxShape.circle,
                        boxShadow: [BoxShadow(color: shadowColor, blurRadius: 8, offset: const Offset(0, 2))],
                      ),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: Icon(
                          _isWishlisted ? CupertinoIcons.heart_fill : CupertinoIcons.heart,
                          key: ValueKey(_isWishlisted),
                          color: _isWishlisted ? const Color(0xFFFF3B30) : Colors.grey,
                          size: isSmall ? 16.sp : 18.sp,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  GestureDetector(
                    onTap: () {},
                    child: Container(
                      padding: EdgeInsets.all(isSmall ? 6.w : 8.w),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E1E1E).withOpacity(0.95) : Colors.white.withOpacity(0.95),
                        shape: BoxShape.circle,
                        boxShadow: [BoxShadow(color: shadowColor, blurRadius: 8, offset: const Offset(0, 2))],
                      ),
                      child: Icon(CupertinoIcons.share, color: Colors.grey, size: isSmall ? 16.sp : 18.sp),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 500.ms);
  }

  Widget _buildPriceSection(bool isDark, Color kTextDark, Color kTextMid, Color borderColor, String? discount, bool isDesktop, bool isTablet, bool isSmall) {
    final product = _product!;
    return Padding(
      padding: EdgeInsets.only(top: isSmall ? 8.h : 12.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '\u09F3${_currentPrice.toInt()}',
                style: GoogleFonts.poppins(fontSize: isSmall ? 22.sp : isDesktop ? 28.sp : 26.sp, fontWeight: FontWeight.bold, color: kPrimary),
              ),
              SizedBox(width: 10.w),
              if (product.originalPrice > 0) ...[
                Text('\u09F3${product.originalPrice.toInt()}', style: GoogleFonts.poppins(fontSize: isSmall ? 12.sp : 14.sp, color: kTextMid, decoration: TextDecoration.lineThrough)),
                SizedBox(width: 8.w),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFF34C759).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6.r),
                    border: Border.all(color: const Color(0xFF34C759).withOpacity(0.3)),
                  ),
                  child: Text(
                    '-$discount%',
                    style: GoogleFonts.poppins(fontSize: isSmall ? 10.sp : 11.sp, fontWeight: FontWeight.w700, color: const Color(0xFF34C759)),
                  ),
                ),
              ],
            ],
          ).animate().fadeIn(delay: 150.ms).slideX(begin: -0.05),
          SizedBox(height: isSmall ? 8.h : 12.h),
          Text(
            product.title,
            style: GoogleFonts.poppins(fontSize: isSmall ? 14.sp : isDesktop ? 18.sp : 16.sp, fontWeight: FontWeight.w600, color: kTextDark, height: 1.35),
          ).animate().fadeIn(delay: 200.ms),
          if (product.subtitle != null && product.subtitle!.isNotEmpty) ...[
            SizedBox(height: 4.h),
            Text(product.subtitle!, style: GoogleFonts.poppins(fontSize: isSmall ? 11.sp : 12.sp, color: kTextMid)),
          ],
          SizedBox(height: isSmall ? 10.h : 14.h),
          Divider(color: borderColor, height: 1),
          SizedBox(height: isSmall ? 10.h : 14.h),
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: const Color(0xFF34C759).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(color: const Color(0xFF34C759).withOpacity(0.2)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(CupertinoIcons.star_fill, color: const Color(0xFFFFCC02), size: isSmall ? 11.sp : 13.sp),
                    SizedBox(width: 4.w),
                    Text(product.rating.toStringAsFixed(1), style: GoogleFonts.poppins(fontSize: isSmall ? 11.sp : 12.sp, fontWeight: FontWeight.w700, color: const Color(0xFF34C759))),
                  ],
                ),
              ),
              SizedBox(width: 10.w),
              Text('(${product.reviewCount} reviews)', style: GoogleFonts.poppins(fontSize: isSmall ? 10.sp : 11.sp, color: kTextMid)),
              SizedBox(width: 8.w),
              Container(width: 4.w, height: 4.w, decoration: BoxDecoration(color: kTextMid.withOpacity(0.4), shape: BoxShape.circle)),
              SizedBox(width: 8.w),
              Text('${product.viewCount} views', style: GoogleFonts.poppins(fontSize: isSmall ? 10.sp : 11.sp, color: kTextMid)),
            ],
          ).animate().fadeIn(delay: 250.ms),
          SizedBox(height: isSmall ? 8.h : 12.h),
          if (product.brand != null && product.brand!.isNotEmpty)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 5.h),
              decoration: BoxDecoration(
                color: kPrimary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(color: kPrimary.withOpacity(0.2)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(CupertinoIcons.tag, size: isSmall ? 10.sp : 12.sp, color: kPrimary),
                  SizedBox(width: 4.w),
                  Text(product.brand!, style: GoogleFonts.poppins(fontSize: isSmall ? 10.sp : 11.sp, color: kPrimary, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms);
  }

  Widget _buildVariantSelector(bool isDark, Color kTextDark, Color kTextMid, Color borderColor, bool isDesktop, bool isTablet, bool isSmall) {
    final colors = _availableColors;
    final sizes = _availableSizes;
    return Padding(
      padding: EdgeInsets.only(top: isSmall ? 8.h : 12.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (colors.isNotEmpty) ...[
            Text('Color', style: GoogleFonts.poppins(fontSize: isSmall ? 11.sp : 12.sp, fontWeight: FontWeight.w600, color: kTextDark)),
            SizedBox(height: 8.h),
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: colors.map((color) {
                final isSelected = _selectedColor == color;
                return GestureDetector(
                  onTap: () => setState(() {
                    _selectedColor = isSelected ? null : color;
                    _updateSelectedVariant();
                  }),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                    decoration: BoxDecoration(
                      color: isSelected ? kPrimary : (isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF1F5F9)),
                      borderRadius: BorderRadius.circular(10.r),
                      border: Border.all(color: isSelected ? kPrimary : borderColor, width: isSelected ? 2 : 1),
                    ),
                    child: Text(color, style: GoogleFonts.poppins(fontSize: isSmall ? 11.sp : 12.sp, fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500, color: isSelected ? Colors.white : kTextDark)),
                  ),
                );
              }).toList(),
            ),
            SizedBox(height: 14.h),
          ],
          if (sizes.isNotEmpty) ...[
            Text('Size', style: GoogleFonts.poppins(fontSize: isSmall ? 11.sp : 12.sp, fontWeight: FontWeight.w600, color: kTextDark)),
            SizedBox(height: 8.h),
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: sizes.map((size) {
                final isSelected = _selectedSize == size;
                return GestureDetector(
                  onTap: () => setState(() {
                    _selectedSize = isSelected ? null : size;
                    _updateSelectedVariant();
                  }),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                    decoration: BoxDecoration(
                      color: isSelected ? kPrimary : (isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF1F5F9)),
                      borderRadius: BorderRadius.circular(10.r),
                      border: Border.all(color: isSelected ? kPrimary : borderColor, width: isSelected ? 2 : 1),
                    ),
                    child: Text(size, style: GoogleFonts.poppins(fontSize: isSmall ? 11.sp : 12.sp, fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500, color: isSelected ? Colors.white : kTextDark)),
                  ),
                );
              }).toList(),
            ),
          ],
          if (_selectedVariant != null) ...[
            SizedBox(height: 12.h),
            Divider(color: borderColor),
            SizedBox(height: 8.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Selected Price:', style: GoogleFonts.poppins(fontSize: isSmall ? 11.sp : 12.sp, color: kTextMid)),
                Text('\u09F3${_selectedVariant!.price.toInt()}', style: GoogleFonts.poppins(fontSize: isSmall ? 13.sp : 14.sp, fontWeight: FontWeight.bold, color: kPrimary)),
              ],
            ),
            SizedBox(height: 4.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Stock:', style: GoogleFonts.poppins(fontSize: isSmall ? 11.sp : 12.sp, color: kTextMid)),
                Text('${_selectedVariant!.stock} available', style: GoogleFonts.poppins(fontSize: isSmall ? 11.sp : 12.sp, fontWeight: FontWeight.w600, color: _selectedVariant!.stock > 0 ? const Color(0xFF34C759) : const Color(0xFFFF3B30))),
              ],
            ),
          ],
        ],
      ),
    ).animate().fadeIn(delay: 250.ms);
  }

  Widget _buildStockBadge(bool isDark, Color kTextDark, Color borderColor, bool isDesktop, bool isTablet, bool isSmall) {
    final stock = _currentStock;
    final bool inStock = stock > 0;
    final bool lowStock = stock > 0 && stock <= 10;
    return Padding(
      padding: EdgeInsets.only(top: isSmall ? 8.h : 12.h),
      child: Row(
        children: [
          Icon(
            inStock ? (lowStock ? CupertinoIcons.exclamationmark_triangle : CupertinoIcons.checkmark_circle) : CupertinoIcons.xmark_circle,
            color: inStock ? (lowStock ? const Color(0xFFFF9500) : const Color(0xFF34C759)) : const Color(0xFFFF3B30),
            size: isSmall ? 16.sp : 20.sp,
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  inStock ? (lowStock ? 'Low Stock - Only $stock left!' : 'In Stock ($stock available)') : 'Out of Stock',
                  style: GoogleFonts.poppins(fontSize: isSmall ? 12.sp : 13.sp, fontWeight: FontWeight.w600, color: inStock ? (lowStock ? const Color(0xFFFF9500) : const Color(0xFF34C759)) : const Color(0xFFFF3B30)),
                ),
                if (lowStock) Text('Hurry up! Limited quantity available', style: GoogleFonts.poppins(fontSize: isSmall ? 10.sp : 11.sp, color: kTextDark.withOpacity(0.6))),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 275.ms);
  }

  Widget _buildDescription(bool isDark, Color kTextDark, Color kTextMid, Color borderColor, bool isDesktop, bool isTablet, bool isSmall) {
    final description = _product?.description;
    if (description == null || description.isEmpty) return const SizedBox.shrink();
    final hasMore = description.length > 120;
    final shortDesc = hasMore ? '${description.substring(0, 120)}...' : description;
    return Padding(
      padding: EdgeInsets.only(top: isSmall ? 8.h : 12.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (hasMore)
            AnimatedCrossFade(
              firstChild: Text(shortDesc, style: GoogleFonts.poppins(fontSize: isSmall ? 11.sp : 12.5.sp, color: kTextDark.withOpacity(0.8), height: 1.7)),
              secondChild: Text(description, style: GoogleFonts.poppins(fontSize: isSmall ? 11.sp : 12.5.sp, color: kTextDark.withOpacity(0.8), height: 1.7)),
              crossFadeState: _showFullDescription ? CrossFadeState.showSecond : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 300),
            )
          else
            Text(description, style: GoogleFonts.poppins(fontSize: isSmall ? 11.sp : 12.5.sp, color: kTextDark.withOpacity(0.8), height: 1.7)),
          if (hasMore) ...[
            SizedBox(height: 12.h),
            GestureDetector(
              onTap: () => setState(() => _showFullDescription = !_showFullDescription),
              child: Row(
                children: [
                  Text(_showFullDescription ? 'Show Less' : 'Read More', style: GoogleFonts.poppins(fontSize: isSmall ? 11.sp : 12.sp, color: kPrimary, fontWeight: FontWeight.w600)),
                  SizedBox(width: 4.w),
                  AnimatedRotation(
                    turns: _showFullDescription ? 0.5 : 0,
                    duration: const Duration(milliseconds: 300),
                    child: Icon(CupertinoIcons.chevron_down, size: isSmall ? 12.sp : 14.sp, color: kPrimary),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    ).animate().fadeIn(delay: 400.ms);
  }

  Widget _buildRatings(bool isDark, Color kTextDark, Color kTextMid, Color borderColor, bool isDesktop, bool isTablet, bool isSmall) {
    final product = _product!;
    final reviews = _reviews;
    final isLoading = _isLoadingReviews;
    final List<double> ratingWidths = [0.75, 0.15, 0.05, 0.03, 0.02];

    return Padding(
      padding: EdgeInsets.only(top: isSmall ? 8.h : 12.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 8.h),
          Row(
            children: [
              Column(
                children: [
                  Text(product.rating.toStringAsFixed(1), style: GoogleFonts.poppins(fontSize: isSmall ? 34.sp : 40.sp, fontWeight: FontWeight.bold, color: kTextDark)),
                  Row(children: List.generate(5, (i) => Icon(i < product.rating.floor() ? CupertinoIcons.star_fill : CupertinoIcons.star, color: const Color(0xFFFFCC02), size: isSmall ? 12.sp : 14.sp))),
                  SizedBox(height: 4.h),
                  Text('${product.reviewCount} reviews', style: GoogleFonts.poppins(fontSize: isSmall ? 10.sp : 11.sp, color: kTextMid)),
                ],
              ),
              SizedBox(width: 20.w),
              Expanded(
                child: Column(
                  children: [5, 4, 3, 2, 1].map((star) {
                    return Padding(
                      padding: EdgeInsets.symmetric(vertical: 2.h),
                      child: Row(
                        children: [
                          Text('$star', style: GoogleFonts.poppins(fontSize: isSmall ? 10.sp : 11.sp, color: kTextMid)),
                          SizedBox(width: 4.w),
                          Icon(CupertinoIcons.star_fill, color: const Color(0xFFFFCC02), size: isSmall ? 9.sp : 10.sp),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4.r),
                              child: LinearProgressIndicator(
                                value: ratingWidths[5 - star],
                                backgroundColor: Colors.grey.withOpacity(0.15),
                                valueColor: AlwaysStoppedAnimation(star >= 4 ? const Color(0xFF34C759) : star == 3 ? const Color(0xFFFFCC02) : const Color(0xFFFF3B30)),
                                minHeight: isSmall ? 4.h : 6.h,
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
          if (isLoading)
            Center(child: CupertinoActivityIndicator(radius: 12.r, color: kPrimary))
          else if (reviews.isEmpty)
            Center(child: Padding(padding: EdgeInsets.symmetric(vertical: 20.h), child: Text('No reviews yet', style: GoogleFonts.poppins(fontSize: isSmall ? 12.sp : 13.sp, color: kTextMid))))
          else
            ...reviews.asMap().entries.map((entry) {
              final r = entry.value;
              final reviewerName = r['reviewer_name']?.toString() ?? 'Anonymous';
              final rating = int.tryParse(r['rating']?.toString() ?? '') ?? 5;
              final comment = r['comment']?.toString() ?? '';
              final createdAt = r['created_at']?.toString() ?? '';
              return Padding(
                padding: EdgeInsets.only(bottom: 12.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: isSmall ? 30.w : 36.w,
                          height: isSmall ? 30.w : 36.w,
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(colors: [kPrimary, Color(0xFF0284C7)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(reviewerName.isNotEmpty ? reviewerName[0].toUpperCase() : '?', style: GoogleFonts.poppins(fontSize: isSmall ? 12.sp : 14.sp, fontWeight: FontWeight.bold, color: Colors.white)),
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(reviewerName, style: GoogleFonts.poppins(fontSize: isSmall ? 11.sp : 12.sp, fontWeight: FontWeight.w600, color: kTextDark)),
                              Row(
                                children: [
                                  ...List.generate(5, (i) => Icon(i < rating ? CupertinoIcons.star_fill : CupertinoIcons.star, color: const Color(0xFFFFCC02), size: isSmall ? 10.sp : 11.sp)),
                                  SizedBox(width: 6.w),
                                  Text(createdAt, style: GoogleFonts.poppins(fontSize: isSmall ? 9.sp : 10.sp, color: kTextMid)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10.h),
                    if (comment.isNotEmpty)
                      Text(comment, style: GoogleFonts.poppins(fontSize: isSmall ? 11.sp : 12.sp, color: kTextMid, height: 1.5)),
                  ],
                ),
              ).animate().fadeIn(delay: (entry.key * 80 + 550).ms);
            }),
        ],
      ),
    ).animate().fadeIn(delay: 550.ms);
  }

  Widget _buildBottomBar(bool isDark, Color cardBg, Color kTextDark, Color kTextMid, Color borderColor, Color shadowColor, bool isDesktop, bool isTablet, bool isSmall) {
    final inStock = _currentStock > 0;
    return Container(
      padding: EdgeInsets.fromLTRB(isSmall ? 12.w : 16.w, isSmall ? 8.h : 10.h, isSmall ? 12.w : 16.w, isSmall ? 12.h : 14.h),
      decoration: BoxDecoration(
        color: cardBg,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, -3))],
        border: Border(top: BorderSide(color: borderColor, width: 0.8)),
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Wholesale', style: GoogleFonts.poppins(fontSize: isSmall ? 8.sp : 9.sp, color: kTextMid, letterSpacing: 0.3)),
              Text('\u09F3${_currentPrice.toInt()}', style: GoogleFonts.poppins(fontSize: isSmall ? 16.sp : 18.sp, fontWeight: FontWeight.bold, color: kPrimary, height: 1.1)),
            ],
          ),
          SizedBox(width: 12.w),
          Container(height: isSmall ? 32.h : 36.h, width: 1, color: borderColor),
          SizedBox(width: 12.w),
          Expanded(
            child: GestureDetector(
              onTap: inStock ? _showResellSheet : null,
              child: Container(
                padding: EdgeInsets.symmetric(vertical: isSmall ? 10.h : 12.h),
                decoration: BoxDecoration(
                  gradient: inStock
                      ? const LinearGradient(colors: [kPrimary, Color(0xFF0284C7)], begin: Alignment.centerLeft, end: Alignment.centerRight)
                      : LinearGradient(colors: [Colors.grey.shade400, Colors.grey.shade500], begin: Alignment.centerLeft, end: Alignment.centerRight),
                  borderRadius: BorderRadius.circular(12.r),
                  boxShadow: [
                    BoxShadow(
                      color: inStock ? kPrimary.withOpacity(0.28) : Colors.transparent,
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(inStock ? CupertinoIcons.bag_fill : CupertinoIcons.xmark_circle, color: Colors.white, size: isSmall ? 13.sp : 15.sp),
                    SizedBox(width: 7.w),
                    Text(inStock ? 'Order Now' : 'Out of Stock', style: GoogleFonts.poppins(fontSize: isSmall ? 12.sp : 13.sp, fontWeight: FontWeight.w600, color: Colors.white, letterSpacing: 0.4)),
                  ],
                ),
              ),
            ).animate().scale(delay: 600.ms, curve: Curves.elasticOut),
          ),
        ],
      ),
    );
  }
}
