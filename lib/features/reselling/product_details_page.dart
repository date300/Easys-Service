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
const Color kTextMid  = Color(0xFF64748B);

// ==================== API SERVICE ====================
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

  // =====================================================
  // Product Detail — API: GET /product/:id
  // Response: { status, product, images, variants, is_wishlisted }
  // =====================================================
  static Future<ProductModel?> fetchProductDetail(String productId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/product/$productId'),
        headers: headers,
      );
      debugPrint('ProductDetail status: ${response.statusCode}');
      debugPrint('ProductDetail body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        if (data['status'] == 'success') {
          // API থেকে images ও variants আলাদা আসে, product object এ merge করি
          final productMap = Map<String, dynamic>.from(data['product'] as Map);

          // images: [ { id, product_id, image_url, sort_order } ]
          productMap['images']       = data['images']       ?? [];
          // variants: [ { id, product_id, color, size, price, stock, sku } ]
          productMap['variants']     = data['variants']     ?? [];
          // is_wishlisted: bool
          productMap['is_wishlisted']= data['is_wishlisted'] ?? false;

          return ProductModel.fromJson(productMap);
        }
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching product: $e');
      return null;
    }
  }

  // =====================================================
  // Product Reviews — API: GET /product/:id/reviews
  // Response: { status, page, limit, total, data: [ reviews ] }
  // Review fields: id, product_id, user_id, rating, comment,
  //                created_at, user_name, user_avatar
  // =====================================================
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
        final data = jsonDecode(response.body) as Map<String, dynamic>;
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

  // =====================================================
  // Toggle Wishlist — API: POST /product/:id/wishlist
  // Response: { status, message, is_wishlisted }
  // =====================================================
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
        final data = jsonDecode(response.body) as Map<String, dynamic>;
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
  int  _currentImageIndex  = 0;
  bool _showFullDescription = false;
  bool _isLoading           = true;
  bool _isWishlisted        = false;
  String? _error;

  ProductModel? _product;
  List<Map<String, dynamic>> _reviews        = [];
  bool                       _isLoadingReviews = false;

  ProductVariant? _selectedVariant;
  String?         _selectedColor;
  String?         _selectedSize;

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

  @override
  void dispose() {
    _imagePageController.dispose();
    _heartAnimController.dispose();
    super.dispose();
  }

  // ===================== LOAD =====================
  Future<void> _loadProduct() async {
    setState(() { _isLoading = true; _error = null; });
    await ApiService.loadAuthToken();
    final product = await ApiService.fetchProductDetail(widget.productId);
    if (!mounted) return;

    if (product != null) {
      setState(() {
        _product    = product;
        _isWishlisted = product.isWishlisted;
        _isLoading  = false;
      });
      _loadReviews();
    } else {
      setState(() { _error = 'Failed to load product'; _isLoading = false; });
    }
  }

  Future<void> _loadReviews() async {
    if (_product == null) return;
    setState(() => _isLoadingReviews = true);
    final reviews = await ApiService.fetchProductReviews(_product!.id);
    if (!mounted) return;
    setState(() { _reviews = reviews; _isLoadingReviews = false; });
  }

  // ===================== WISHLIST =====================
  Future<void> _toggleWishlist() async {
    if (_product == null) return;
    if (ApiService.authToken == null) {
      _showSnack('Please login to add to wishlist', isError: true);
      return;
    }
    HapticFeedback.lightImpact();
    _heartAnimController.forward(from: 0);
    setState(() => _isWishlisted = !_isWishlisted); // Optimistic update
    final result = await ApiService.toggleWishlist(_product!.id);
    if (mounted) setState(() => _isWishlisted = result);
  }

  void _showSnack(String msg, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: GoogleFonts.poppins(fontSize: 13.sp)),
      backgroundColor: isError ? const Color(0xFFFF3B30) : const Color(0xFF34C759),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
    ));
  }

  // ===================== COMPUTED =====================

  /// API: images = [ { image_url: "https://..." }, ... ]
  /// FIX: সরাসরি image_url নিচ্ছি, ProductImage model থেকে
  List<String> get _productImages {
    if (_product == null) return [];

    // ✅ FIX 1: ProductModel.images list থেকে image_url নাও
    if (_product!.images.isNotEmpty) {
      final urls = _product!.images
          .map((img) => img.imageUrl.trim())
          .where((url) => url.isNotEmpty)
          .toList();
      if (urls.isNotEmpty) return urls;
    }

    // ✅ FIX 2: Fallback — product.thumbnail বা product.image
    if (_product!.thumbnail != null && _product!.thumbnail!.isNotEmpty) {
      return [_product!.thumbnail!];
    }
    if (_product!.image.isNotEmpty) return [_product!.image];

    return [];
  }

  List<String> get _availableColors => _product?.variants
      .where((v) => v.color != null && v.color!.isNotEmpty)
      .map((v) => v.color!)
      .toSet()
      .toList() ?? [];

  List<String> get _availableSizes => _product?.variants
      .where((v) => v.size != null && v.size!.isNotEmpty)
      .map((v) => v.size!)
      .toSet()
      .toList() ?? [];

  double get _currentPrice  => _selectedVariant?.price ?? _product?.wholesalePrice ?? 0;
  int    get _currentStock  => _selectedVariant?.stock ?? _product?.stock ?? 0;

  void _updateSelectedVariant() {
    if (_selectedColor == null && _selectedSize == null) {
      setState(() => _selectedVariant = null);
      return;
    }
    final matches = _product!.variants.where((v) {
      final colorMatch = _selectedColor == null || v.color == _selectedColor;
      final sizeMatch  = _selectedSize  == null || v.size  == _selectedSize;
      return colorMatch && sizeMatch;
    }).toList();
    setState(() => _selectedVariant = matches.isNotEmpty ? matches.first : null);
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

  // ==================== BUILD ====================
  @override
  Widget build(BuildContext context) {
    final isDark      = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop   = screenWidth >= 1024;
    final isTablet    = screenWidth >= 600 && screenWidth < 1024;
    final isSmall     = screenWidth < 360;

    final kBackground  = isDark ? const Color(0xFF121212) : const Color(0xFFF8FAFC);
    final kTextDark    = isDark ? Colors.white : const Color(0xFF0F172A);
    final kTextMidDyn  = isDark ? Colors.grey.shade400 : const Color(0xFF475569);
    final cardBg       = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final shadowColor  = isDark ? Colors.black.withOpacity(0.3) : Colors.black.withOpacity(0.04);
    final borderColor  = isDark ? const Color(0xFF333333) : Colors.grey.withOpacity(0.1);
    final hPadding     = isDesktop ? 32.w : isTablet ? 20.w : isSmall ? 12.w : 16.w;
    final vPadding     = isDesktop ? 24.h : isTablet ? 20.h : 16.h;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: kBackground,
        body: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          CupertinoActivityIndicator(radius: 14.r, color: kPrimary),
          SizedBox(height: 16.h),
          Text('Loading product...', style: GoogleFonts.poppins(fontSize: 14.sp, color: kTextMidDyn)),
        ])),
      );
    }

    if (_error != null || _product == null) {
      return Scaffold(
        backgroundColor: kBackground,
        body: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(CupertinoIcons.exclamationmark_triangle, size: 48.sp, color: Colors.orange),
          SizedBox(height: 16.h),
          Text(_error ?? 'Product not found', style: GoogleFonts.poppins(fontSize: 16.sp, color: kTextDark)),
          SizedBox(height: 24.h),
          CupertinoButton(onPressed: _loadProduct, color: kPrimary,
            child: Text('Retry', style: GoogleFonts.poppins(fontWeight: FontWeight.w600))),
        ])),
      );
    }

    final product  = _product!;
    final discount = product.originalPrice > 0
        ? (((product.originalPrice - product.wholesalePrice) / product.originalPrice) * 100)
            .toStringAsFixed(0)
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
                _buildImageSlider(isDark, shadowColor, borderColor, isDesktop, isTablet, isSmall),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: hPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: vPadding),
                      _buildSectionHeader('Price', 'Wholesale & discount', kTextDark, kTextMidDyn, isDesktop: isDesktop, isSmall: isSmall),
                      _buildPriceSection(isDark, kTextDark, kTextMidDyn, borderColor, discount, isDesktop, isTablet, isSmall),
                      SizedBox(height: isDesktop ? 20.h : 12.h),
                      if (product.variants.isNotEmpty) ...[
                        _buildSectionHeader('Select Variant', 'Choose your preference', kTextDark, kTextMidDyn, isDesktop: isDesktop, isSmall: isSmall),
                        _buildVariantSelector(isDark, kTextDark, kTextMidDyn, borderColor, isDesktop, isTablet, isSmall),
                        SizedBox(height: isDesktop ? 20.h : 12.h),
                      ],
                      _buildSectionHeader('Stock', 'Availability', kTextDark, kTextMidDyn, isDesktop: isDesktop, isSmall: isSmall),
                      _buildStockBadge(isDark, kTextDark, borderColor, isDesktop, isTablet, isSmall),
                      SizedBox(height: isDesktop ? 20.h : 12.h),
                      _buildSectionHeader('Description', 'Details & Specifications', kTextDark, kTextMidDyn, isDesktop: isDesktop, isSmall: isSmall),
                      _buildDescription(isDark, kTextDark, kTextMidDyn, borderColor, isDesktop, isTablet, isSmall),
                      SizedBox(height: isDesktop ? 20.h : 12.h),
                      _buildSectionHeader('Ratings & Reviews', 'See what others say', kTextDark, kTextMidDyn, isDesktop: isDesktop, isSmall: isSmall),
                      _buildRatings(isDark, kTextDark, kTextMidDyn, borderColor, isDesktop, isTablet, isSmall),
                      SizedBox(height: 100.h + vPadding),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: _buildBottomBar(isDark, cardBg, kTextDark, kTextMidDyn, borderColor, shadowColor, isDesktop, isTablet, isSmall),
          ),
        ],
      ),
    );
  }

  // ==================== SECTION HEADER ====================
  Widget _buildSectionHeader(String title, String subtitle, Color kTextDark, Color kTextMid,
      {bool isDesktop = false, bool isSmall = false, bool showViewAll = false, VoidCallback? onViewAll}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: GoogleFonts.poppins(fontSize: isSmall ? 14.sp : isDesktop ? 18.sp : 16.sp, fontWeight: FontWeight.bold, color: kTextDark)),
          Text(subtitle, style: GoogleFonts.poppins(fontSize: isSmall ? 10.sp : 11.sp, color: kTextMid)),
        ]),
        if (showViewAll)
          TextButton(
            onPressed: onViewAll ?? () {},
            style: TextButton.styleFrom(padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h), minimumSize: Size.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Text('See All', style: GoogleFonts.poppins(fontSize: isSmall ? 10.sp : 11.sp, color: kPrimary, fontWeight: FontWeight.w600)),
              SizedBox(width: 2.w),
              Icon(CupertinoIcons.chevron_right, size: isSmall ? 10.sp : 12.sp, color: kPrimary),
            ]),
          ),
      ],
    );
  }

  // ==================== IMAGE SLIDER ====================
  Widget _buildImageSlider(bool isDark, Color shadowColor, Color borderColor, bool isDesktop, bool isTablet, bool isSmall) {
    final images      = _productImages; // ✅ Fixed getter
    final bannerHeight = isDesktop ? 360.h : isTablet ? 300.h : isSmall ? 220.h : 320.h;

    // ইমেজ না থাকলে placeholder দেখাও
    if (images.isEmpty) {
      return Container(
        height: bannerHeight,
        color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF1F5F9),
        child: Center(child: Icon(CupertinoIcons.photo, color: Colors.grey.shade400, size: 60.sp)),
      );
    }

    return SizedBox(
      height: bannerHeight,
      child: Stack(
        children: [
          // ===== PageView =====
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
                  // ✅ FIX: loadingBuilder দিয়ে loading দেখাও
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CupertinoActivityIndicator(radius: 14.r, color: kPrimary),
                    );
                  },
                  // ✅ FIX: errorBuilder দিয়ে broken image handle করো
                  errorBuilder: (context, error, stackTrace) {
                    debugPrint('Image load error [$index]: $error\nURL: ${images[index]}');
                    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Icon(CupertinoIcons.photo, color: Colors.grey.shade300, size: 50.sp),
                      SizedBox(height: 8.h),
                      Text('Image not available', style: GoogleFonts.poppins(fontSize: 12.sp, color: Colors.grey.shade400)),
                    ]);
                  },
                ),
              );
            },
          ),

          // ===== Thumbnail strip (left side) =====
          if (images.length > 1)
            Positioned(
              left: isSmall ? 8.w : 12.w,
              top: isSmall ? 40.h : 60.h,
              child: Column(
                children: List.generate(images.length, (i) {
                  final selected = _currentImageIndex == i;
                  return GestureDetector(
                    onTap: () => _imagePageController.animateToPage(
                      i, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: EdgeInsets.symmetric(vertical: 4.h),
                      width:  selected ? (isSmall ? 38.w : 46.w) : (isSmall ? 34.w : 42.w),
                      height: selected ? (isSmall ? 38.w : 46.w) : (isSmall ? 34.w : 42.w),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
                        borderRadius: BorderRadius.circular(10.r),
                        border: Border.all(color: selected ? kPrimary : borderColor, width: selected ? 2.5 : 1),
                        boxShadow: selected
                            ? [BoxShadow(color: kPrimary.withOpacity(0.25), blurRadius: 8, offset: const Offset(0, 2))]
                            : [BoxShadow(color: shadowColor, blurRadius: 4)],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8.r),
                        child: Image.network(
                          images[i], fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Icon(CupertinoIcons.photo, color: Colors.grey.shade300, size: 18.sp),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),

          // ===== Dot indicators (bottom) =====
          if (images.length > 1)
            Positioned(
              bottom: isSmall ? 8.h : 12.h, left: 0, right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(images.length, (i) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: EdgeInsets.symmetric(horizontal: 3.w),
                    width:  _currentImageIndex == i ? 20.w : 6.w,
                    height: isSmall ? 5.h : 6.h,
                    decoration: BoxDecoration(
                      color: _currentImageIndex == i ? kPrimary : Colors.grey.withOpacity(0.35),
                      borderRadius: BorderRadius.circular(3.r),
                    ),
                  );
                }),
              ),
            ),

          // ===== Discount badge =====
          if (_product?.originalPrice != null && _product!.originalPrice > _product!.wholesalePrice)
            Positioned(
              top: isSmall ? 12.h : 16.h, right: isSmall ? 12.w : 16.w,
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

          // ===== Wishlist & Share buttons =====
          Positioned(
            top: isSmall ? 8.h : 12.h, left: isSmall ? 8.w : 12.w,
            child: Row(children: [
              _iconButton(
                onTap: _toggleWishlist,
                isDark: isDark,
                shadowColor: shadowColor,
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
              SizedBox(width: 8.w),
              _iconButton(
                onTap: () {},
                isDark: isDark,
                shadowColor: shadowColor,
                child: Icon(CupertinoIcons.share, color: Colors.grey, size: isSmall ? 16.sp : 18.sp),
              ),
            ]),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms);
  }

  Widget _iconButton({required VoidCallback onTap, required bool isDark, required Color shadowColor, required Widget child}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E).withOpacity(0.95) : Colors.white.withOpacity(0.95),
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: shadowColor, blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: child,
      ),
    );
  }

  // ==================== PRICE SECTION ====================
  Widget _buildPriceSection(bool isDark, Color kTextDark, Color kTextMid, Color borderColor, String? discount, bool isDesktop, bool isTablet, bool isSmall) {
    final product = _product!;
    return Padding(
      padding: EdgeInsets.only(top: isSmall ? 8.h : 12.h),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text('৳${_currentPrice.toInt()}',
              style: GoogleFonts.poppins(fontSize: isSmall ? 22.sp : isDesktop ? 28.sp : 26.sp, fontWeight: FontWeight.bold, color: kPrimary)),
          SizedBox(width: 10.w),
          if (product.originalPrice > product.wholesalePrice) ...[
            Text('৳${product.originalPrice.toInt()}',
                style: GoogleFonts.poppins(fontSize: isSmall ? 12.sp : 14.sp, color: kTextMid, decoration: TextDecoration.lineThrough)),
            SizedBox(width: 8.w),
            if (discount != null)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: const Color(0xFF34C759).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6.r),
                  border: Border.all(color: const Color(0xFF34C759).withOpacity(0.3)),
                ),
                child: Text('-$discount%',
                    style: GoogleFonts.poppins(fontSize: isSmall ? 10.sp : 11.sp, fontWeight: FontWeight.w700, color: const Color(0xFF34C759))),
              ),
          ],
        ]).animate().fadeIn(delay: 150.ms).slideX(begin: -0.05),

        SizedBox(height: isSmall ? 8.h : 12.h),
        Text(product.title,
            style: GoogleFonts.poppins(fontSize: isSmall ? 14.sp : isDesktop ? 18.sp : 16.sp, fontWeight: FontWeight.w600, color: kTextDark, height: 1.35))
            .animate().fadeIn(delay: 200.ms),

        if (product.subtitle != null && product.subtitle!.isNotEmpty) ...[
          SizedBox(height: 4.h),
          Text(product.subtitle!, style: GoogleFonts.poppins(fontSize: isSmall ? 11.sp : 12.sp, color: kTextMid)),
        ],

        SizedBox(height: isSmall ? 10.h : 14.h),
        Divider(color: borderColor, height: 1),
        SizedBox(height: isSmall ? 10.h : 14.h),

        // Rating & views row
        Row(children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: const Color(0xFF34C759).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: const Color(0xFF34C759).withOpacity(0.2)),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(CupertinoIcons.star_fill, color: const Color(0xFFFFCC02), size: isSmall ? 11.sp : 13.sp),
              SizedBox(width: 4.w),
              Text(product.rating.toStringAsFixed(1),
                  style: GoogleFonts.poppins(fontSize: isSmall ? 11.sp : 12.sp, fontWeight: FontWeight.w700, color: const Color(0xFF34C759))),
            ]),
          ),
          SizedBox(width: 10.w),
          Text('(${product.reviewCount} reviews)', style: GoogleFonts.poppins(fontSize: isSmall ? 10.sp : 11.sp, color: kTextMid)),
          SizedBox(width: 8.w),
          Container(width: 4.w, height: 4.w, decoration: BoxDecoration(color: kTextMid.withOpacity(0.4), shape: BoxShape.circle)),
          SizedBox(width: 8.w),
          Text('${product.viewCount} views', style: GoogleFonts.poppins(fontSize: isSmall ? 10.sp : 11.sp, color: kTextMid)),
        ]).animate().fadeIn(delay: 250.ms),

        if (product.brand != null && product.brand!.isNotEmpty) ...[
          SizedBox(height: isSmall ? 8.h : 12.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 5.h),
            decoration: BoxDecoration(
              color: kPrimary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(color: kPrimary.withOpacity(0.2)),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(CupertinoIcons.tag, size: isSmall ? 10.sp : 12.sp, color: kPrimary),
              SizedBox(width: 4.w),
              Text(product.brand!, style: GoogleFonts.poppins(fontSize: isSmall ? 10.sp : 11.sp, color: kPrimary, fontWeight: FontWeight.w600)),
            ]),
          ),
        ],
      ]),
    ).animate().fadeIn(delay: 200.ms);
  }

  // ==================== VARIANT SELECTOR ====================
  Widget _buildVariantSelector(bool isDark, Color kTextDark, Color kTextMid, Color borderColor, bool isDesktop, bool isTablet, bool isSmall) {
    final colors = _availableColors;
    final sizes  = _availableSizes;

    return Padding(
      padding: EdgeInsets.only(top: isSmall ? 8.h : 12.h),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (colors.isNotEmpty) ...[
          Text('Color', style: GoogleFonts.poppins(fontSize: isSmall ? 11.sp : 12.sp, fontWeight: FontWeight.w600, color: kTextDark)),
          SizedBox(height: 8.h),
          Wrap(
            spacing: 8.w, runSpacing: 8.h,
            children: colors.map((color) {
              final isSelected = _selectedColor == color;
              return GestureDetector(
                onTap: () { setState(() { _selectedColor = isSelected ? null : color; }); _updateSelectedVariant(); },
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
            spacing: 8.w, runSpacing: 8.h,
            children: sizes.map((size) {
              final isSelected = _selectedSize == size;
              return GestureDetector(
                onTap: () { setState(() { _selectedSize = isSelected ? null : size; }); _updateSelectedVariant(); },
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
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('Selected Price:', style: GoogleFonts.poppins(fontSize: isSmall ? 11.sp : 12.sp, color: kTextMid)),
            Text('৳${_selectedVariant!.price.toInt()}', style: GoogleFonts.poppins(fontSize: isSmall ? 13.sp : 14.sp, fontWeight: FontWeight.bold, color: kPrimary)),
          ]),
          SizedBox(height: 4.h),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('Stock:', style: GoogleFonts.poppins(fontSize: isSmall ? 11.sp : 12.sp, color: kTextMid)),
            Text('${_selectedVariant!.stock} available',
                style: GoogleFonts.poppins(fontSize: isSmall ? 11.sp : 12.sp, fontWeight: FontWeight.w600,
                    color: _selectedVariant!.stock > 0 ? const Color(0xFF34C759) : const Color(0xFFFF3B30))),
          ]),
        ],
      ]),
    ).animate().fadeIn(delay: 250.ms);
  }

  // ==================== STOCK ====================
  Widget _buildStockBadge(bool isDark, Color kTextDark, Color borderColor, bool isDesktop, bool isTablet, bool isSmall) {
    final stock    = _currentStock;
    final inStock  = stock > 0;
    final lowStock = stock > 0 && stock <= 10;

    return Padding(
      padding: EdgeInsets.only(top: isSmall ? 8.h : 12.h),
      child: Row(children: [
        Icon(
          inStock ? (lowStock ? CupertinoIcons.exclamationmark_triangle : CupertinoIcons.checkmark_circle) : CupertinoIcons.xmark_circle,
          color: inStock ? (lowStock ? const Color(0xFFFF9500) : const Color(0xFF34C759)) : const Color(0xFFFF3B30),
          size: isSmall ? 16.sp : 20.sp,
        ),
        SizedBox(width: 10.w),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(
            inStock ? (lowStock ? 'Low Stock — Only $stock left!' : 'In Stock ($stock available)') : 'Out of Stock',
            style: GoogleFonts.poppins(fontSize: isSmall ? 12.sp : 13.sp, fontWeight: FontWeight.w600,
                color: inStock ? (lowStock ? const Color(0xFFFF9500) : const Color(0xFF34C759)) : const Color(0xFFFF3B30)),
          ),
          if (lowStock)
            Text('Hurry up! Limited quantity available',
                style: GoogleFonts.poppins(fontSize: isSmall ? 10.sp : 11.sp, color: kTextDark.withOpacity(0.6))),
        ])),
      ]),
    ).animate().fadeIn(delay: 275.ms);
  }

  // ==================== DESCRIPTION ====================
  Widget _buildDescription(bool isDark, Color kTextDark, Color kTextMid, Color borderColor, bool isDesktop, bool isTablet, bool isSmall) {
    final description = _product?.description;
    if (description == null || description.isEmpty) return const SizedBox.shrink();

    final hasMore  = description.length > 120;
    final shortDesc = hasMore ? '${description.substring(0, 120)}...' : description;

    return Padding(
      padding: EdgeInsets.only(top: isSmall ? 8.h : 12.h),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (hasMore)
          AnimatedCrossFade(
            firstChild:  Text(shortDesc, style: GoogleFonts.poppins(fontSize: isSmall ? 11.sp : 12.5.sp, color: kTextDark.withOpacity(0.8), height: 1.7)),
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
            child: Row(children: [
              Text(_showFullDescription ? 'Show Less' : 'Read More',
                  style: GoogleFonts.poppins(fontSize: isSmall ? 11.sp : 12.sp, color: kPrimary, fontWeight: FontWeight.w600)),
              SizedBox(width: 4.w),
              AnimatedRotation(
                turns: _showFullDescription ? 0.5 : 0,
                duration: const Duration(milliseconds: 300),
                child: Icon(CupertinoIcons.chevron_down, size: isSmall ? 12.sp : 14.sp, color: kPrimary),
              ),
            ]),
          ),
        ],
      ]),
    ).animate().fadeIn(delay: 400.ms);
  }

  // ==================== RATINGS ====================
  Widget _buildRatings(bool isDark, Color kTextDark, Color kTextMid, Color borderColor, bool isDesktop, bool isTablet, bool isSmall) {
    final product  = _product!;
    final reviews  = _reviews;
    final isLoading = _isLoadingReviews;

    return Padding(
      padding: EdgeInsets.only(top: isSmall ? 8.h : 12.h),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Column(children: [
            Text(product.rating.toStringAsFixed(1),
                style: GoogleFonts.poppins(fontSize: isSmall ? 34.sp : 40.sp, fontWeight: FontWeight.bold, color: kTextDark)),
            Row(children: List.generate(5, (i) => Icon(
              i < product.rating.floor() ? CupertinoIcons.star_fill : CupertinoIcons.star,
              color: const Color(0xFFFFCC02), size: isSmall ? 12.sp : 14.sp))),
            SizedBox(height: 4.h),
            Text('${product.reviewCount} reviews', style: GoogleFonts.poppins(fontSize: isSmall ? 10.sp : 11.sp, color: kTextMid)),
          ]),
          SizedBox(width: 20.w),
          Expanded(child: Column(
            children: [5, 4, 3, 2, 1].asMap().entries.map((e) {
              const bars = [0.75, 0.15, 0.05, 0.03, 0.02];
              final star = e.value;
              return Padding(
                padding: EdgeInsets.symmetric(vertical: 2.h),
                child: Row(children: [
                  Text('$star', style: GoogleFonts.poppins(fontSize: isSmall ? 10.sp : 11.sp, color: kTextMid)),
                  SizedBox(width: 4.w),
                  Icon(CupertinoIcons.star_fill, color: const Color(0xFFFFCC02), size: isSmall ? 9.sp : 10.sp),
                  SizedBox(width: 8.w),
                  Expanded(child: ClipRRect(
                    borderRadius: BorderRadius.circular(4.r),
                    child: LinearProgressIndicator(
                      value: bars[e.key],
                      backgroundColor: Colors.grey.withOpacity(0.15),
                      valueColor: AlwaysStoppedAnimation(
                          star >= 4 ? const Color(0xFF34C759) : star == 3 ? const Color(0xFFFFCC02) : const Color(0xFFFF3B30)),
                      minHeight: isSmall ? 4.h : 6.h,
                    ),
                  )),
                ]),
              );
            }).toList(),
          )),
        ]),

        SizedBox(height: 16.h),
        Divider(color: borderColor, height: 1),
        SizedBox(height: 12.h),

        if (isLoading)
          Center(child: CupertinoActivityIndicator(radius: 12.r, color: kPrimary))
        else if (reviews.isEmpty)
          Center(child: Padding(
            padding: EdgeInsets.symmetric(vertical: 20.h),
            child: Text('No reviews yet', style: GoogleFonts.poppins(fontSize: isSmall ? 12.sp : 13.sp, color: kTextMid)),
          ))
        else
          ...reviews.asMap().entries.map((entry) {
            final r = entry.value;

            // ✅ FIX: API field নাম হলো 'user_name' (reviewer_name নয়)
            final reviewerName = r['user_name']?.toString() ?? 'Anonymous';
            final userAvatar   = r['user_avatar']?.toString();
            final rating       = int.tryParse(r['rating']?.toString() ?? '') ?? 5;
            final comment      = r['comment']?.toString() ?? '';
            final createdAt    = r['created_at']?.toString() ?? '';

            return Padding(
              padding: EdgeInsets.only(bottom: 12.h),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  // Avatar — URL থাকলে দেখাও, না হলে initial
                  CircleAvatar(
                    radius: isSmall ? 15.r : 18.r,
                    backgroundImage: (userAvatar != null && userAvatar.isNotEmpty)
                        ? NetworkImage(userAvatar) : null,
                    backgroundColor: kPrimary,
                    child: (userAvatar == null || userAvatar.isEmpty)
                        ? Text(reviewerName.isNotEmpty ? reviewerName[0].toUpperCase() : '?',
                            style: GoogleFonts.poppins(fontSize: isSmall ? 12.sp : 14.sp, fontWeight: FontWeight.bold, color: Colors.white))
                        : null,
                  ),
                  SizedBox(width: 10.w),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(reviewerName, style: GoogleFonts.poppins(fontSize: isSmall ? 11.sp : 12.sp, fontWeight: FontWeight.w600, color: kTextDark)),
                    Row(children: [
                      ...List.generate(5, (i) => Icon(
                        i < rating ? CupertinoIcons.star_fill : CupertinoIcons.star,
                        color: const Color(0xFFFFCC02), size: isSmall ? 10.sp : 11.sp)),
                      SizedBox(width: 6.w),
                      Text(createdAt, style: GoogleFonts.poppins(fontSize: isSmall ? 9.sp : 10.sp, color: kTextMid)),
                    ]),
                  ])),
                ]),
                if (comment.isNotEmpty) ...[
                  SizedBox(height: 8.h),
                  Text(comment, style: GoogleFonts.poppins(fontSize: isSmall ? 11.sp : 12.sp, color: kTextMid, height: 1.5)),
                ],
                SizedBox(height: 8.h),
                Divider(color: borderColor, height: 1),
              ]),
            ).animate().fadeIn(delay: (entry.key * 80 + 550).ms);
          }),
      ]),
    ).animate().fadeIn(delay: 550.ms);
  }

  // ==================== BOTTOM BAR ====================
  Widget _buildBottomBar(bool isDark, Color cardBg, Color kTextDark, Color kTextMid, Color borderColor, Color shadowColor, bool isDesktop, bool isTablet, bool isSmall) {
    final inStock = _currentStock > 0;
    return Container(
      padding: EdgeInsets.fromLTRB(isSmall ? 12.w : 16.w, isSmall ? 8.h : 10.h, isSmall ? 12.w : 16.w, isSmall ? 12.h : 14.h),
      decoration: BoxDecoration(
        color: cardBg,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, -3))],
        border: Border(top: BorderSide(color: borderColor, width: 0.8)),
      ),
      child: Row(children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
          Text('Wholesale', style: GoogleFonts.poppins(fontSize: isSmall ? 8.sp : 9.sp, color: kTextMid, letterSpacing: 0.3)),
          Text('৳${_currentPrice.toInt()}',
              style: GoogleFonts.poppins(fontSize: isSmall ? 16.sp : 18.sp, fontWeight: FontWeight.bold, color: kPrimary, height: 1.1)),
        ]),
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
                    : LinearGradient(colors: [Colors.grey.shade400, Colors.grey.shade500]),
                borderRadius: BorderRadius.circular(12.r),
                boxShadow: [BoxShadow(color: inStock ? kPrimary.withOpacity(0.28) : Colors.transparent, blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(inStock ? CupertinoIcons.bag_fill : CupertinoIcons.xmark_circle, color: Colors.white, size: isSmall ? 13.sp : 15.sp),
                SizedBox(width: 7.w),
                Text(inStock ? 'Order Now' : 'Out of Stock',
                    style: GoogleFonts.poppins(fontSize: isSmall ? 12.sp : 13.sp, fontWeight: FontWeight.w600, color: Colors.white, letterSpacing: 0.4)),
              ]),
            ),
          ).animate().scale(delay: 600.ms, curve: Curves.elasticOut),
        ),
      ]),
    );
  }
}
