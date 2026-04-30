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

const Color kTextMid = Color(0xFF64748B);

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

      debugPrint('Wishlist status: ${response.statusCode}');
      debugPrint('Wishlist body: ${response.body}');

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

  List<String> get _availableColors {
    if (_product == null) return [];
    return _product!.variants
        .where((v) => v.color != null && v.color!.isNotEmpty)
        .map((v) => v.color!)
        .toSet()
        .toList();
  }

  List<String> get _availableSizes {
    if (_product == null) return [];
    return _product!.variants
        .where((v) => v.size != null && v.size!.isNotEmpty)
        .map((v) => v.size!)
        .toSet()
        .toList();
  }

  double get _currentPrice {
    if (_selectedVariant != null) return _selectedVariant!.price;
    return _product?.wholesalePrice ?? 0;
  }

  int get _currentStock {
    if (_selectedVariant != null) return _selectedVariant!.stock;
    return _product?.stock ?? 0;
  }

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
    final kBackground = isDark ? const Color(0xFF121212) : const Color(0xFFF8FAFC);
    final kTextDark = isDark ? Colors.white : const Color(0xFF0F172A);
    final kTextMidColor = isDark ? Colors.grey.shade400 : const Color(0xFF475569);
    final cardBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final borderColor = isDark ? const Color(0xFF333333) : Colors.grey.withOpacity(0.1);
    final shadowColor = isDark ? Colors.black.withOpacity(0.3) : Colors.black.withOpacity(0.04);
    final lockBgColor = isDark ? const Color(0xFF2C2C2C) : const Color(0xFFF1F5F9);

    if (_isLoading) {
      return Scaffold(
        backgroundColor: kBackground,
        appBar: _buildAppBar(isDark, shadowColor, borderColor),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CupertinoActivityIndicator(radius: 14.r, color: const Color(0xFF29B6F6)),
              SizedBox(height: 16.h),
              Text(
                'Loading product...',
                style: GoogleFonts.poppins(fontSize: 14.sp, color: kTextMidColor),
              ),
            ],
          ),
        ),
      );
    }

    if (_error != null || _product == null) {
      return Scaffold(
        backgroundColor: kBackground,
        appBar: _buildAppBar(isDark, shadowColor, borderColor),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(CupertinoIcons.exclamationmark_triangle, size: 52.sp, color: const Color(0xFFFF9500)),
              SizedBox(height: 16.h),
              Text(
                _error ?? 'Product not found',
                style: GoogleFonts.poppins(fontSize: 16.sp, fontWeight: FontWeight.w600, color: kTextDark),
              ),
              SizedBox(height: 24.h),
              GestureDetector(
                onTap: _loadProduct,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF29B6F6), Color(0xFF0284C7)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12.r),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF29B6F6).withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Text(
                    'Retry',
                    style: GoogleFonts.poppins(fontSize: 14.sp, fontWeight: FontWeight.w600, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final product = _product!;
    final discount = product.originalPrice > 0
        ? (((product.originalPrice - product.wholesalePrice) / product.originalPrice) * 100)
            .toStringAsFixed(0)
        : null;

    return Scaffold(
      backgroundColor: kBackground,
      appBar: _buildAppBar(isDark, shadowColor, borderColor),
      body: Stack(
        children: [
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 8.h),
                _buildImageSlider(isDark, cardBg, shadowColor, borderColor, lockBgColor),
                SizedBox(height: 16.h),
                _buildPriceSection(isDark, kTextDark, kTextMidColor, cardBg, borderColor, shadowColor, discount),
                SizedBox(height: 16.h),
                if (product.variants.isNotEmpty) ...[
                  _buildVariantSelector(isDark, cardBg, kTextDark, kTextMidColor, borderColor, shadowColor),
                  SizedBox(height: 16.h),
                ],
                _buildStockBadge(isDark, cardBg, kTextDark, kTextMidColor, borderColor, shadowColor),
                SizedBox(height: 16.h),
                _buildDescription(isDark, cardBg, kTextDark, kTextMidColor, borderColor, shadowColor),
                SizedBox(height: 16.h),
                _buildRatings(isDark, cardBg, kTextDark, kTextMidColor, borderColor, shadowColor),
                SizedBox(height: 120.h),
              ],
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildBottomBar(isDark, cardBg, kTextDark, kTextMidColor, borderColor, shadowColor),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(bool isDark, Color shadowColor, Color borderColor) {
    return AppBar(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF8FAFC),
      elevation: 0,
      centerTitle: true,
      leadingWidth: 56.w,
      leading: Padding(
        padding: EdgeInsets.only(left: 12.w),
        child: GestureDetector(
          onTap: () => context.pop(),
          child: Container(
            margin: EdgeInsets.symmetric(vertical: 8.h),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: borderColor, width: 0.5),
              boxShadow: [BoxShadow(color: shadowColor, blurRadius: 6, offset: const Offset(0, 2))],
            ),
            child: Icon(
              CupertinoIcons.back,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
              size: 18.sp,
            ),
          ),
        ),
      ),
      title: Text(
        'Product Details',
        style: GoogleFonts.poppins(
          fontSize: 16.sp,
          fontWeight: FontWeight.w600,
          color: isDark ? Colors.white : const Color(0xFF0F172A),
        ),
      ),
    );
  }

  Widget _buildImageSlider(bool isDark, Color cardBg, Color shadowColor, Color borderColor, Color lockBgColor) {
    final images = _productImages;

    if (images.isEmpty) {
      return Container(
        height: 320.h,
        margin: EdgeInsets.symmetric(horizontal: 16.w),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [BoxShadow(color: shadowColor, blurRadius: 10, offset: const Offset(0, 4))],
          border: Border.all(color: borderColor, width: 0.5),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(CupertinoIcons.photo, color: Colors.grey.shade300, size: 60.sp),
              SizedBox(height: 12.h),
              Text('No images available', style: GoogleFonts.poppins(fontSize: 13.sp, color: kTextMid)),
            ],
          ),
        ),
      ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.04);
    }

    return Container(
      height: 320.h,
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [BoxShadow(color: shadowColor, blurRadius: 10, offset: const Offset(0, 4))],
        border: Border.all(color: borderColor, width: 0.5),
      ),
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
                  padding: EdgeInsets.all(24.w),
                  child: Image.network(
                    images[index],
                    fit: BoxFit.contain,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CupertinoActivityIndicator(radius: 14.r, color: const Color(0xFF29B6F6)),
                      );
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
                left: 12.w,
                top: 60.h,
                child: Column(
                  children: List.generate(images.length, (i) {
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
                        margin: EdgeInsets.symmetric(vertical: 4.h),
                        width: selected ? 48.w : 44.w,
                        height: selected ? 48.w : 44.w,
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(
                            color: selected ? const Color(0xFF29B6F6) : borderColor,
                            width: selected ? 2.5 : 1,
                          ),
                          boxShadow: selected
                              ? [BoxShadow(color: const Color(0xFF29B6F6).withOpacity(0.25), blurRadius: 8, offset: const Offset(0, 2))]
                              : [BoxShadow(color: shadowColor, blurRadius: 4, offset: const Offset(0, 1))],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10.r),
                          child: Image.network(
                            images[i],
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Icon(CupertinoIcons.photo, color: Colors.grey.shade300, size: 18.sp),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            if (images.length > 1)
              Positioned(
                bottom: 12.h,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(images.length, (i) {
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: EdgeInsets.symmetric(horizontal: 3.w),
                      width: _currentImageIndex == i ? 20.w : 6.w,
                      height: 6.h,
                      decoration: BoxDecoration(
                        color: _currentImageIndex == i ? const Color(0xFF29B6F6) : Colors.grey.withOpacity(0.35),
                        borderRadius: BorderRadius.circular(3.r),
                      ),
                    );
                  }),
                ),
              ),
            if (_product?.originalPrice != null && _product!.originalPrice > 0)
              Positioned(
                top: 16.h,
                right: 16.w,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF29B6F6), Color(0xFF0284C7)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(8.r),
                    boxShadow: [
                      BoxShadow(color: const Color(0xFF29B6F6).withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 2)),
                    ],
                  ),
                  child: Text(
                    '-${((_product!.originalPrice - _product!.wholesalePrice) / _product!.originalPrice * 100).toStringAsFixed(0)}%',
                    style: GoogleFonts.poppins(fontSize: 11.sp, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ).animate().scale(delay: 300.ms, curve: Curves.elasticOut),
              ),
            Positioned(
              top: 12.h,
              left: 12.w,
              child: Row(
                children: [
                  GestureDetector(
                    onTap: _toggleWishlist,
                    child: Container(
                      padding: EdgeInsets.all(9.w),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E1E1E).withOpacity(0.95) : Colors.white.withOpacity(0.95),
                        shape: BoxShape.circle,
                        boxShadow: [BoxShadow(color: shadowColor, blurRadius: 8, offset: const Offset(0, 2))],
                      ),
                      child: ScaleTransition(
                        scale: Tween(begin: 1.0, end: 1.25).animate(
                          CurvedAnimation(parent: _heartAnimController, curve: Curves.easeOut),
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
                  ),
                  SizedBox(width: 8.w),
                  GestureDetector(
                    onTap: () {},
                    child: Container(
                      padding: EdgeInsets.all(9.w),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E1E1E).withOpacity(0.95) : Colors.white.withOpacity(0.95),
                        shape: BoxShape.circle,
                        boxShadow: [BoxShadow(color: shadowColor, blurRadius: 8, offset: const Offset(0, 2))],
                      ),
                      child: Icon(CupertinoIcons.share, color: Colors.grey, size: 18.sp),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.04);
  }

  Widget _buildPriceSection(bool isDark, Color kTextDark, Color kTextMidColor, Color cardBg, Color borderColor, Color shadowColor, String? discount) {
    final product = _product!;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [BoxShadow(color: shadowColor, blurRadius: 10, offset: const Offset(0, 4))],
        border: Border.all(color: borderColor, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: const Color(0xFF29B6F6).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(CupertinoIcons.tag_fill, color: const Color(0xFF29B6F6), size: 18.sp),
              ),
              SizedBox(width: 10.w),
              Text('Price & Details', style: GoogleFonts.poppins(fontSize: 14.sp, fontWeight: FontWeight.bold, color: kTextDark)),
            ],
          ),
          SizedBox(height: 14.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '\u09F3${_currentPrice.toInt()}',
                style: GoogleFonts.poppins(fontSize: 26.sp, fontWeight: FontWeight.bold, color: const Color(0xFF29B6F6)),
              ),
              SizedBox(width: 10.w),
              if (product.originalPrice > 0) ...[
                Text(
                  '\u09F3${product.originalPrice.toInt()}',
                  style: GoogleFonts.poppins(fontSize: 14.sp, color: kTextMidColor, decoration: TextDecoration.lineThrough),
                ),
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
                    style: GoogleFonts.poppins(fontSize: 11.sp, fontWeight: FontWeight.w700, color: const Color(0xFF34C759)),
                  ),
                ),
              ],
            ],
          ).animate().fadeIn(delay: 150.ms).slideX(begin: -0.05),
          SizedBox(height: 12.h),
          Text(
            product.title,
            style: GoogleFonts.poppins(fontSize: 16.sp, fontWeight: FontWeight.w600, color: kTextDark, height: 1.35),
          ).animate().fadeIn(delay: 200.ms),
          if (product.subtitle != null && product.subtitle!.isNotEmpty) ...[
            SizedBox(height: 4.h),
            Text(product.subtitle!, style: GoogleFonts.poppins(fontSize: 12.sp, color: kTextMidColor)),
          ],
          SizedBox(height: 14.h),
          Divider(color: borderColor, height: 1),
          SizedBox(height: 14.h),
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
                    Icon(CupertinoIcons.star_fill, color: const Color(0xFFFFCC02), size: 13.sp),
                    SizedBox(width: 4.w),
                    Text(
                      product.rating.toStringAsFixed(1),
                      style: GoogleFonts.poppins(fontSize: 12.sp, fontWeight: FontWeight.w700, color: const Color(0xFF34C759)),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 10.w),
              Text('(${product.reviewCount} reviews)', style: GoogleFonts.poppins(fontSize: 11.sp, color: kTextMidColor)),
              SizedBox(width: 8.w),
              Container(width: 4.w, height: 4.w, decoration: BoxDecoration(color: kTextMidColor.withOpacity(0.4), shape: BoxShape.circle)),
              SizedBox(width: 8.w),
              Text('${product.viewCount} views', style: GoogleFonts.poppins(fontSize: 11.sp, color: kTextMidColor)),
            ],
          ).animate().fadeIn(delay: 250.ms),
          SizedBox(height: 12.h),
          if (product.brand != null && product.brand!.isNotEmpty)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 5.h),
              decoration: BoxDecoration(
                color: const Color(0xFF29B6F6).withOpacity(0.08),
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(color: const Color(0xFF29B6F6).withOpacity(0.2)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(CupertinoIcons.tag, size: 12.sp, color: const Color(0xFF29B6F6)),
                  SizedBox(width: 4.w),
                  Text(product.brand!, style: GoogleFonts.poppins(fontSize: 11.sp, color: const Color(0xFF29B6F6), fontWeight: FontWeight.w600)),
                ],
              ),
            ),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.03);
  }

  Widget _buildVariantSelector(bool isDark, Color cardBg, Color kTextDark, Color kTextMidColor, Color borderColor, Color shadowColor) {
    final colors = _availableColors;
    final sizes = _availableSizes;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [BoxShadow(color: shadowColor, blurRadius: 10, offset: const Offset(0, 4))],
        border: Border.all(color: borderColor, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(CupertinoIcons.layers, color: const Color(0xFF6366F1), size: 18.sp),
              ),
              SizedBox(width: 10.w),
              Text('Select Variant', style: GoogleFonts.poppins(fontSize: 14.sp, fontWeight: FontWeight.bold, color: kTextDark)),
            ],
          ),
          SizedBox(height: 14.h),
          if (colors.isNotEmpty) ...[
            Text('Color', style: GoogleFonts.poppins(fontSize: 12.sp, fontWeight: FontWeight.w600, color: kTextDark)),
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
                      color: isSelected ? const Color(0xFF29B6F6) : (isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF1F5F9)),
                      borderRadius: BorderRadius.circular(10.r),
                      border: Border.all(color: isSelected ? const Color(0xFF29B6F6) : borderColor, width: isSelected ? 2 : 1),
                    ),
                    child: Text(
                      color,
                      style: GoogleFonts.poppins(fontSize: 12.sp, fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500, color: isSelected ? Colors.white : kTextDark),
                    ),
                  ),
                );
              }).toList(),
            ),
            SizedBox(height: 14.h),
          ],
          if (sizes.isNotEmpty) ...[
            Text('Size', style: GoogleFonts.poppins(fontSize: 12.sp, fontWeight: FontWeight.w600, color: kTextDark)),
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
                      color: isSelected ? const Color(0xFF29B6F6) : (isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF1F5F9)),
                      borderRadius: BorderRadius.circular(10.r),
                      border: Border.all(color: isSelected ? const Color(0xFF29B6F6) : borderColor, width: isSelected ? 2 : 1),
                    ),
                    child: Text(
                      size,
                      style: GoogleFonts.poppins(fontSize: 12.sp, fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500, color: isSelected ? Colors.white : kTextDark),
                    ),
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
                Text('Selected Price:', style: GoogleFonts.poppins(fontSize: 12.sp, color: kTextMidColor)),
                Text('\u09F3${_selectedVariant!.price.toInt()}', style: GoogleFonts.poppins(fontSize: 14.sp, fontWeight: FontWeight.bold, color: const Color(0xFF29B6F6))),
              ],
            ),
            SizedBox(height: 4.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Stock:', style: GoogleFonts.poppins(fontSize: 12.sp, color: kTextMidColor)),
                Text(
                  '${_selectedVariant!.stock} available',
                  style: GoogleFonts.poppins(fontSize: 12.sp, fontWeight: FontWeight.w600, color: _selectedVariant!.stock > 0 ? const Color(0xFF34C759) : const Color(0xFFFF3B30)),
                ),
              ],
            ),
          ],
        ],
      ),
    ).animate().fadeIn(delay: 250.ms).slideY(begin: 0.03);
  }

  Widget _buildStockBadge(bool isDark, Color cardBg, Color kTextDark, Color kTextMidColor, Color borderColor, Color shadowColor) {
    final stock = _currentStock;
    final bool inStock = stock > 0;
    final bool lowStock = stock > 0 && stock <= 10;
    final Color statusColor = inStock
        ? (lowStock ? const Color(0xFFFF9500) : const Color(0xFF34C759))
        : const Color(0xFFFF3B30);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [BoxShadow(color: shadowColor, blurRadius: 10, offset: const Offset(0, 4))],
        border: Border.all(color: borderColor, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(
                  inStock ? (lowStock ? CupertinoIcons.cube_box : CupertinoIcons.cube_box_fill) : CupertinoIcons.xmark_circle,
                  color: statusColor,
                  size: 18.sp,
                ),
              ),
              SizedBox(width: 10.w),
              Text('Stock Status', style: GoogleFonts.poppins(fontSize: 14.sp, fontWeight: FontWeight.bold, color: kTextDark)),
            ],
          ),
          SizedBox(height: 14.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: statusColor.withOpacity(0.25)),
            ),
            child: Row(
              children: [
                Icon(
                  inStock ? (lowStock ? CupertinoIcons.exclamationmark_triangle : CupertinoIcons.checkmark_circle) : CupertinoIcons.xmark_circle,
                  color: statusColor,
                  size: 22.sp,
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        inStock ? (lowStock ? 'Low Stock - Only $stock left!' : 'In Stock ($stock available)') : 'Out of Stock',
                        style: GoogleFonts.poppins(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: statusColor,
                        ),
                      ),
                      if (lowStock)
                        Text('Hurry up! Limited quantity available', style: GoogleFonts.poppins(fontSize: 11.sp, color: kTextMidColor)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.03);
  }

  Widget _buildDescription(bool isDark, Color cardBg, Color kTextDark, Color kTextMidColor, Color borderColor, Color shadowColor) {
    final description = _product?.description;
    if (description == null || description.isEmpty) return const SizedBox.shrink();

    final shortDesc = description.length > 120 ? '${description.substring(0, 120)}...' : description;
    final hasMore = description.length > 120;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [BoxShadow(color: shadowColor, blurRadius: 10, offset: const Offset(0, 4))],
        border: Border.all(color: borderColor, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(color: const Color(0xFF29B6F6).withOpacity(0.1), borderRadius: BorderRadius.circular(10.r)),
                child: Icon(CupertinoIcons.doc_text, color: const Color(0xFF29B6F6), size: 18.sp),
              ),
              SizedBox(width: 10.w),
              Text('Product Description', style: GoogleFonts.poppins(fontSize: 14.sp, fontWeight: FontWeight.bold, color: kTextDark)),
            ],
          ),
          SizedBox(height: 14.h),
          if (hasMore)
            AnimatedCrossFade(
              firstChild: Text(shortDesc, style: GoogleFonts.poppins(fontSize: 12.5.sp, color: kTextDark.withOpacity(0.8), height: 1.7)),
              secondChild: Text(description, style: GoogleFonts.poppins(fontSize: 12.5.sp, color: kTextDark.withOpacity(0.8), height: 1.7)),
              crossFadeState: _showFullDescription ? CrossFadeState.showSecond : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 300),
            )
          else
            Text(description, style: GoogleFonts.poppins(fontSize: 12.5.sp, color: kTextDark.withOpacity(0.8), height: 1.7)),
          if (hasMore) ...[
            SizedBox(height: 12.h),
            GestureDetector(
              onTap: () => setState(() => _showFullDescription = !_showFullDescription),
              child: Row(
                children: [
                  Text(
                    _showFullDescription ? 'Show Less' : 'Read More',
                    style: GoogleFonts.poppins(fontSize: 12.sp, color: const Color(0xFF29B6F6), fontWeight: FontWeight.w600),
                  ),
                  SizedBox(width: 4.w),
                  AnimatedRotation(
                    turns: _showFullDescription ? 0.5 : 0,
                    duration: const Duration(milliseconds: 300),
                    child: Icon(CupertinoIcons.chevron_down, size: 14.sp, color: const Color(0xFF29B6F6)),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    ).animate().fadeIn(delay: 350.ms).slideY(begin: 0.03);
  }

  Widget _buildRatings(bool isDark, Color cardBg, Color kTextDark, Color kTextMidColor, Color borderColor, Color shadowColor) {
    final product = _product!;
    final reviews = _reviews;
    final isLoading = _isLoadingReviews;
    final List<double> ratingWidths = [0.75, 0.15, 0.05, 0.03, 0.02];

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [BoxShadow(color: shadowColor, blurRadius: 10, offset: const Offset(0, 4))],
        border: Border.all(color: borderColor, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(color: const Color(0xFFFFCC02).withOpacity(0.1), borderRadius: BorderRadius.circular(10.r)),
                    child: Icon(CupertinoIcons.star_fill, color: const Color(0xFFFFCC02), size: 18.sp),
                  ),
                  SizedBox(width: 10.w),
                  Text('Ratings & Reviews', style: GoogleFonts.poppins(fontSize: 14.sp, fontWeight: FontWeight.bold, color: kTextDark)),
                ],
              ),
              if (reviews.isNotEmpty)
                TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('See All', style: GoogleFonts.poppins(fontSize: 12.sp, color: const Color(0xFF29B6F6), fontWeight: FontWeight.w600)),
                      SizedBox(width: 2.w),
                      Icon(CupertinoIcons.chevron_right, size: 12.sp, color: const Color(0xFF29B6F6)),
                    ],
                  ),
                ),
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Column(
                children: [
                  Text(product.rating.toStringAsFixed(1), style: GoogleFonts.poppins(fontSize: 40.sp, fontWeight: FontWeight.bold, color: kTextDark)),
                  Row(children: List.generate(5, (i) => Icon(i < product.rating.floor() ? CupertinoIcons.star_fill : CupertinoIcons.star, color: const Color(0xFFFFCC02), size: 14.sp))),
                  SizedBox(height: 4.h),
                  Text('${product.reviewCount} reviews', style: GoogleFonts.poppins(fontSize: 11.sp, color: kTextMidColor)),
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
                          Text('$star', style: GoogleFonts.poppins(fontSize: 11.sp, color: kTextMidColor)),
                          SizedBox(width: 4.w),
                          Icon(CupertinoIcons.star_fill, color: const Color(0xFFFFCC02), size: 10.sp),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4.r),
                              child: LinearProgressIndicator(
                                value: ratingWidths[5 - star],
                                backgroundColor: Colors.grey.withOpacity(0.15),
                                valueColor: AlwaysStoppedAnimation(
                                  star >= 4 ? const Color(0xFF34C759) : star == 3 ? const Color(0xFFFFCC02) : const Color(0xFFFF3B30),
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
          if (isLoading)
            Center(child: CupertinoActivityIndicator(radius: 14.r, color: const Color(0xFF29B6F6)))
          else if (reviews.isEmpty)
            Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 20.h),
                child: Text('No reviews yet', style: GoogleFonts.poppins(fontSize: 13.sp, color: kTextMidColor)),
              ),
            )
          else
            ...reviews.asMap().entries.map((entry) {
              final r = entry.value;
              final reviewerName = r['reviewer_name']?.toString() ?? 'Anonymous';
              final rating = int.tryParse(r['rating']?.toString() ?? '') ?? 5;
              final comment = r['comment']?.toString() ?? '';
              final createdAt = r['created_at']?.toString() ?? '';

              return Container(
                margin: EdgeInsets.only(bottom: 12.h),
                padding: EdgeInsets.all(14.w),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: borderColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 36.w,
                          height: 36.w,
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(colors: [Color(0xFF29B6F6), Color(0xFF0284C7)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              reviewerName.isNotEmpty ? reviewerName[0].toUpperCase() : '?',
                              style: GoogleFonts.poppins(fontSize: 14.sp, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(reviewerName, style: GoogleFonts.poppins(fontSize: 12.sp, fontWeight: FontWeight.w600, color: kTextDark)),
                              Row(
                                children: [
                                  ...List.generate(5, (i) => Icon(i < rating ? CupertinoIcons.star_fill : CupertinoIcons.star, color: const Color(0xFFFFCC02), size: 11.sp)),
                                  SizedBox(width: 6.w),
                                  Text(createdAt, style: GoogleFonts.poppins(fontSize: 10.sp, color: kTextMidColor)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10.h),
                    if (comment.isNotEmpty)
                      Text(comment, style: GoogleFonts.poppins(fontSize: 12.sp, color: kTextMidColor, height: 1.5)),
                  ],
                ),
              ).animate().fadeIn(delay: (entry.key * 80 + 550).ms);
            }),
        ],
      ),
    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.03);
  }

  Widget _buildBottomBar(bool isDark, Color cardBg, Color kTextDark, Color kTextMidColor, Color borderColor, Color shadowColor) {
    final inStock = _currentStock > 0;

    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 14.h),
      decoration: BoxDecoration(
        color: cardBg,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, -3))],
        border: Border(top: BorderSide(color: borderColor, width: 0.8)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Wholesale',
                  style: GoogleFonts.poppins(fontSize: 9.sp, color: kTextMidColor, letterSpacing: 0.3),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '\u09F3${_currentPrice.toInt()}',
                      style: GoogleFonts.poppins(fontSize: 18.sp, fontWeight: FontWeight.bold, color: const Color(0xFF29B6F6), height: 1.1),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(width: 12.w),
            Container(height: 36.h, width: 1, color: borderColor),
            SizedBox(width: 12.w),
            Expanded(
              child: GestureDetector(
                onTap: inStock ? _showResellSheet : null,
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  decoration: BoxDecoration(
                    gradient: inStock
                        ? const LinearGradient(
                            colors: [Color(0xFF29B6F6), Color(0xFF0284C7)],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          )
                        : LinearGradient(
                            colors: [Colors.grey.shade400, Colors.grey.shade500],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                    borderRadius: BorderRadius.circular(12.r),
                    boxShadow: [
                      BoxShadow(
                        color: inStock ? const Color(0xFF29B6F6).withOpacity(0.28) : Colors.transparent,
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        inStock ? CupertinoIcons.bag_fill : CupertinoIcons.xmark_circle,
                        color: Colors.white,
                        size: 15.sp,
                      ),
                      SizedBox(width: 7.w),
                      Text(
                        inStock ? 'Order Now' : 'Out of Stock',
                        style: GoogleFonts.poppins(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ).animate().scale(delay: 500.ms, curve: Curves.elasticOut),
            ),
          ],
        ),
      ),
    );
  }
}
