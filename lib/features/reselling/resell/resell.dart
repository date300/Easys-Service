import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/product_model.dart';

class ProductDetailPage extends StatefulWidget {
  final ProductModel product;
  final Function(double margin)? onConfirmResell;

  const ProductDetailPage({
    super.key,
    required this.product,
    this.onConfirmResell,
  });

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage>
    with SingleTickerProviderStateMixin {
  late final PageController _imagePageController;
  int _currentImageIndex = 0;
  double _margin = 0;
  bool _isWishlisted = false;
  bool _showAllDetails = false;

  // Demo multiple images (in real app, use product.images list)
  List<String> get _productImages => [
        widget.product.image,
        widget.product.image.replaceAll('w=400', 'w=600'),
        widget.product.image.replaceAll('w=400', 'w=800'),
      ];

  @override
  void initState() {
    super.initState();
    _imagePageController = PageController();
  }

  @override
  void dispose() {
    _imagePageController.dispose();
    super.dispose();
  }

  double get _sellPrice => widget.product.wholesalePrice + _margin;
  double get _profitPercent => widget.product.wholesalePrice > 0
      ? (_margin / widget.product.wholesalePrice) * 100
      : 0;
  double get _discountPercent => (widget.product.originalPrice != null &&
          widget.product.originalPrice! > 0)
      ? ((widget.product.originalPrice! - widget.product.wholesalePrice) /
              widget.product.originalPrice!) *
          100
      : 0;

  void _onResellPressed() {
    HapticFeedback.mediumImpact();
    if (widget.onConfirmResell != null) {
      widget.onConfirmResell!(_margin);
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Product added to your resell list!',
          style: GoogleFonts.poppins(fontSize: 13.sp),
        ),
        backgroundColor: const Color(0xFF34C759),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
        margin: EdgeInsets.all(16.w),
      ),
    );
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF121212) : const Color(0xFFF8FAFC);
    final cardBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textDark = isDark ? Colors.white : const Color(0xFF0F172A);
    final textMid = isDark ? Colors.grey.shade400 : const Color(0xFF475569);
    final borderColor = isDark ? const Color(0xFF333333) : Colors.grey.shade200;

    final maxMargin = widget.product.maxResalePrice - widget.product.wholesalePrice;

    return Scaffold(
      backgroundColor: bg,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ==================== SLIVER APP BAR WITH IMAGE CAROUSEL ====================
          SliverAppBar(
            expandedHeight: 380.h,
            pinned: true,
            floating: false,
            backgroundColor: cardBg,
            elevation: 0,
            leading: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                margin: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.4),
                  shape: BoxShape.circle,
                ),
                child: Icon(CupertinoIcons.back, color: Colors.white, size: 20.sp),
              ),
            ),
            actions: [
              _CircleActionButton(
                icon: CupertinoIcons.share,
                onTap: () {},
              ),
              _CircleActionButton(
                icon: _isWishlisted ? CupertinoIcons.heart_fill : CupertinoIcons.heart,
                color: _isWishlisted ? const Color(0xFFFF3B30) : Colors.white,
                onTap: () => setState(() => _isWishlisted = !_isWishlisted),
              ),
              SizedBox(width: 8.w),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                children: [
                  // Image Carousel
                  PageView.builder(
                    controller: _imagePageController,
                    onPageChanged: (i) => setState(() => _currentImageIndex = i),
                    itemCount: _productImages.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          // TODO: Open full screen image viewer
                        },
                        child: Hero(
                          tag: 'product_image_${widget.product.id}',
                          child: Image.network(
                            _productImages[index],
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: 380.h,
                            loadingBuilder: (context, child, progress) {
                              if (progress == null) return child;
                              return Container(
                                color: isDark ? const Color(0xFF1E1E1E) : Colors.grey.shade100,
                                child: Center(
                                  child: CupertinoActivityIndicator(radius: 14.r),
                                ),
                              );
                            },
                            errorBuilder: (_, __, ___) => Container(
                              color: Colors.grey.shade100,
                              child: Center(
                                child: Icon(CupertinoIcons.photo,
                                    size: 60.sp, color: Colors.grey.shade400),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  // Gradient overlay at bottom
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 80.h,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.3),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Image indicator dots
                  Positioned(
                    bottom: 16.h,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(_productImages.length, (index) {
                        final isActive = index == _currentImageIndex;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: EdgeInsets.symmetric(horizontal: 4.w),
                          width: isActive ? 24.w : 8.w,
                          height: 8.h,
                          decoration: BoxDecoration(
                            color: isActive ? const Color(0xFF29B6F6) : Colors.white.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                        );
                      }),
                    ),
                  ),
                  // Category badge
                  Positioned(
                    top: 60.h,
                    left: 16.w,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFF29B6F6),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Text(
                        widget.product.category,
                        style: GoogleFonts.poppins(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ==================== CONTENT ====================
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Price & Title Card
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.vertical(bottom: Radius.circular(16.r)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Price Row
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '\u09F3${widget.product.wholesalePrice.toInt()}',
                            style: GoogleFonts.poppins(
                              fontSize: 26.sp,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF29B6F6),
                            ),
                          ),
                          SizedBox(width: 10.w),
                          if (widget.product.originalPrice != null) ...[
                            Text(
                              '\u09F3${widget.product.originalPrice!.toInt()}',
                              style: GoogleFonts.poppins(
                                fontSize: 15.sp,
                                color: textMid,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFF3B30).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4.r),
                              ),
                              child: Text(
                                '-${_discountPercent.toInt()}%',
                                style: GoogleFonts.poppins(
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFFFF3B30),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      SizedBox(height: 10.h),
                      // Title
                      Text(
                        widget.product.title,
                        style: GoogleFonts.poppins(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: textDark,
                          height: 1.3,
                        ),
                      ),
                      if (widget.product.subtitle != null) ...[
                        SizedBox(height: 4.h),
                        Text(
                          widget.product.subtitle!,
                          style: GoogleFonts.poppins(
                            fontSize: 13.sp,
                            color: textMid,
                            height: 1.4,
                          ),
                        ),
                      ],
                      SizedBox(height: 12.h),
                      // Rating Row
                      Row(
                        children: [
                          Row(
                            children: List.generate(5, (index) {
                              final fill = index < widget.product.rating.floor();
                              final half = index == widget.product.rating.floor() &&
                                  widget.product.rating % 1 >= 0.5;
                              return Icon(
                                half
                                    ? CupertinoIcons.star_lefthalf_fill
                                    : fill
                                        ? CupertinoIcons.star_fill
                                        : CupertinoIcons.star,
                                color: const Color(0xFFFFCC02),
                                size: 16.sp,
                              );
                            }),
                          ),
                          SizedBox(width: 6.w),
                          Text(
                            '${widget.product.rating}',
                            style: GoogleFonts.poppins(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                              color: textDark,
                            ),
                          ),
                          SizedBox(width: 6.w),
                          Text(
                            '(128 Reviews)',
                            style: GoogleFonts.poppins(
                              fontSize: 12.sp,
                              color: textMid,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                            decoration: BoxDecoration(
                              color: const Color(0xFF34C759).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6.r),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(CupertinoIcons.checkmark_seal_fill,
                                    size: 12.sp, color: const Color(0xFF34C759)),
                                SizedBox(width: 4.w),
                                Text(
                                  'Verified',
                                  style: GoogleFonts.poppins(
                                    fontSize: 10.sp,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF34C759),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 10.h),

                // ==================== RESELL CALCULATOR SECTION ====================
                Container(
                  width: double.infinity,
                  margin: EdgeInsets.symmetric(horizontal: 16.w),
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(color: borderColor),
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
                            child: Icon(
                              CupertinoIcons.arrow_up_arrow_down_circle_fill,
                              color: const Color(0xFF29B6F6),
                              size: 20.sp,
                            ),
                          ),
                          SizedBox(width: 10.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Resell Calculator',
                                  style: GoogleFonts.poppins(
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.bold,
                                    color: textDark,
                                  ),
                                ),
                                Text(
                                  'Set your margin and start earning',
                                  style: GoogleFonts.poppins(
                                    fontSize: 11.sp,
                                    color: textMid,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16.h),
                      // Slider
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Margin: \u09F3${_margin.toInt()}',
                            style: GoogleFonts.poppins(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                              color: textDark,
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                            decoration: BoxDecoration(
                              color: const Color(0xFF34C759).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6.r),
                            ),
                            child: Text(
                              '+${_profitPercent.toInt()}% Profit',
                              style: GoogleFonts.poppins(
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF34C759),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8.h),
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          trackHeight: 6.h,
                          thumbShape: RoundSliderThumbShape(enabledThumbRadius: 12.r),
                          overlayShape: RoundSliderOverlayShape(overlayRadius: 20.r),
                        ),
                        child: Slider(
                          value: _margin.clamp(0, maxMargin),
                          min: 0,
                          max: maxMargin,
                          divisions: maxMargin > 0 ? maxMargin.toInt() : 1,
                          activeColor: const Color(0xFF29B6F6),
                          inactiveColor: isDark ? const Color(0xFF333333) : Colors.grey.shade200,
                          thumbColor: const Color(0xFF29B6F6),
                          onChanged: (val) => setState(() => _margin = val),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '\u09F30',
                            style: GoogleFonts.poppins(fontSize: 11.sp, color: textMid),
                          ),
                          Text(
                            'Max: \u09F3${maxMargin.toInt()}',
                            style: GoogleFonts.poppins(fontSize: 11.sp, color: textMid),
                          ),
                        ],
                      ),
                      SizedBox(height: 16.h),
                      // Price Cards
                      Row(
                        children: [
                          Expanded(
                            child: _PriceInfoCard(
                              label: 'Your Cost',
                              amount: '\u09F3${widget.product.wholesalePrice.toInt()}',
                              color: textMid,
                              cardBg: isDark ? const Color(0xFF2C2C2C) : const Color(0xFFF1F5F9),
                              borderColor: borderColor,
                            ),
                          ),
                          SizedBox(width: 10.w),
                          Expanded(
                            child: _PriceInfoCard(
                              label: 'Sell Price',
                              amount: '\u09F3${_sellPrice.toInt()}',
                              color: const Color(0xFF29B6F6),
                              cardBg: const Color(0xFF29B6F6).withOpacity(0.06),
                              borderColor: const Color(0xFF29B6F6).withOpacity(0.2),
                              isHighlight: true,
                            ),
                          ),
                          SizedBox(width: 10.w),
                          Expanded(
                            child: _PriceInfoCard(
                              label: 'Profit',
                              amount: '\u09F3${_margin.toInt()}',
                              color: const Color(0xFF34C759),
                              cardBg: const Color(0xFF34C759).withOpacity(0.06),
                              borderColor: const Color(0xFF34C759).withOpacity(0.2),
                              isHighlight: true,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.05),

                SizedBox(height: 10.h),

                // ==================== PRODUCT DETAILS ====================
                Container(
                  width: double.infinity,
                  margin: EdgeInsets.symmetric(horizontal: 16.w),
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(color: borderColor),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Product Details',
                        style: GoogleFonts.poppins(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.bold,
                          color: textDark,
                        ),
                      ),
                      SizedBox(height: 12.h),
                      _DetailRow(label: 'Category', value: widget.product.category),
                      _DetailRow(
                          label: 'Wholesale Price',
                          value: '\u09F3${widget.product.wholesalePrice.toInt()}'),
                      _DetailRow(
                          label: 'Original MRP',
                          value: widget.product.originalPrice != null
                              ? '\u09F3${widget.product.originalPrice!.toInt()}'
                              : 'N/A'),
                      _DetailRow(
                          label: 'Max Resale',
                          value: '\u09F3${widget.product.maxResalePrice.toInt()}'),
                      _DetailRow(label: 'Product ID', value: '#${widget.product.id}'),
                      if (_showAllDetails) ...[
                        _DetailRow(label: 'Brand', value: 'Premium'),
                        _DetailRow(label: 'Warranty', value: '6 Months'),
                        _DetailRow(label: 'Return Policy', value: '7 Days Easy Return'),
                        _DetailRow(label: 'Stock', value: 'In Stock'),
                      ],
                      SizedBox(height: 8.h),
                      GestureDetector(
                        onTap: () => setState(() => _showAllDetails = !_showAllDetails),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _showAllDetails ? 'Show Less' : 'Show More',
                              style: GoogleFonts.poppins(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF29B6F6),
                              ),
                            ),
                            Icon(
                              _showAllDetails
                                  ? CupertinoIcons.chevron_up
                                  : CupertinoIcons.chevron_down,
                              size: 14.sp,
                              color: const Color(0xFF29B6F6),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 300.ms),

                SizedBox(height: 10.h),

                // ==================== DELIVERY INFO ====================
                Container(
                  width: double.infinity,
                  margin: EdgeInsets.symmetric(horizontal: 16.w),
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(color: borderColor),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Delivery & Services',
                        style: GoogleFonts.poppins(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.bold,
                          color: textDark,
                        ),
                      ),
                      SizedBox(height: 12.h),
                      _ServiceRow(
                        icon: CupertinoIcons.bus,
                        title: 'Free Delivery',
                        subtitle: 'Within 3-5 business days',
                        color: const Color(0xFF6366F1),
                      ),
                      SizedBox(height: 10.h),
                      _ServiceRow(
                        icon: CupertinoIcons.shield_lefthalf_fill,
                        title: 'Secure Payment',
                        subtitle: '100% secure checkout',
                        color: const Color(0xFF10B981),
                      ),
                      SizedBox(height: 10.h),
                      _ServiceRow(
                        icon: CupertinoIcons.return_icon,
                        title: 'Easy Return',
                        subtitle: '7 days return policy',
                        color: const Color(0xFFF59E0B),
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 400.ms),

                SizedBox(height: 10.h),

                // ==================== REVIEWS PREVIEW ====================
                Container(
                  width: double.infinity,
                  margin: EdgeInsets.symmetric(horizontal: 16.w),
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(color: borderColor),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Reviews (128)',
                            style: GoogleFonts.poppins(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.bold,
                              color: textDark,
                            ),
                          ),
                          TextButton(
                            onPressed: () {},
                            child: Text(
                              'View All',
                              style: GoogleFonts.poppins(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF29B6F6),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10.h),
                      _ReviewCard(
                        name: 'Rahim H.',
                        rating: 5,
                        date: '2 days ago',
                        comment: 'Excellent product quality! Fast delivery and packaging was great.',
                        textDark: textDark,
                        textMid: textMid,
                        borderColor: borderColor,
                      ),
                      Divider(height: 20.h, color: borderColor),
                      _ReviewCard(
                        name: 'Sadia A.',
                        rating: 4,
                        date: '1 week ago',
                        comment: 'Good value for money. Recommended for reselling.',
                        textDark: textDark,
                        textMid: textMid,
                        borderColor: borderColor,
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 500.ms),

                SizedBox(height: 100.h), // Space for bottom bar
              ],
            ),
          ),
        ],
      ),

      // ==================== BOTTOM STICKY ACTION BAR ====================
      bottomNavigationBar: Container(
        padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 24.h),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              // Chat Button
              GestureDetector(
                onTap: () {},
                child: Container(
                  width: 48.w,
                  height: 48.w,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF2C2C2C) : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: borderColor),
                  ),
                  child: Icon(
                    CupertinoIcons.chat_bubble_text,
                    color: const Color(0xFF6366F1),
                    size: 20.sp,
                  ),
                ),
              ),
              SizedBox(width: 10.w),
              // Add to Cart / Resell Button
              Expanded(
                child: GestureDetector(
                  onTap: _onResellPressed,
                  child: Container(
                    height: 48.h,
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
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(CupertinoIcons.cart_badge_plus, color: Colors.white, size: 18.sp),
                        SizedBox(width: 8.w),
                        Text(
                          'Start Reselling',
                          style: GoogleFonts.poppins(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
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

// ==================== HELPER WIDGETS ====================

class _CircleActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color? color;

  const _CircleActionButton({
    required this.icon,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(right: 8.w),
        width: 36.w,
        height: 36.w,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.4),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color ?? Colors.white, size: 18.sp),
      ),
    );
  }
}

class _PriceInfoCard extends StatelessWidget {
  final String label;
  final String amount;
  final Color color;
  final Color cardBg;
  final Color borderColor;
  final bool isHighlight;

  const _PriceInfoCard({
    required this.label,
    required this.amount,
    required this.color,
    required this.cardBg,
    required this.borderColor,
    this.isHighlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: isHighlight ? borderColor : Colors.transparent,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 10.sp,
              color: color.withOpacity(0.8),
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            amount,
            style: GoogleFonts.poppins(
              fontSize: 15.sp,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textDark = isDark ? Colors.white : const Color(0xFF0F172A);
    final textMid = isDark ? Colors.grey.shade400 : const Color(0xFF475569);

    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110.w,
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12.sp,
                color: textMid,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: textDark,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ServiceRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;

  const _ServiceRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textDark = isDark ? Colors.white : const Color(0xFF0F172A);
    final textMid = isDark ? Colors.grey.shade400 : const Color(0xFF475569);

    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Icon(icon, color: color, size: 18.sp),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: textDark,
                ),
              ),
              Text(
                subtitle,
                style: GoogleFonts.poppins(
                  fontSize: 11.sp,
                  color: textMid,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final String name;
  final int rating;
  final String date;
  final String comment;
  final Color textDark;
  final Color textMid;
  final Color borderColor;

  const _ReviewCard({
    required this.name,
    required this.rating,
    required this.date,
    required this.comment,
    required this.textDark,
    required this.textMid,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 32.w,
              height: 32.w,
              decoration: BoxDecoration(
                color: const Color(0xFF29B6F6).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  name[0],
                  style: GoogleFonts.poppins(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF29B6F6),
                  ),
                ),
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: GoogleFonts.poppins(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: textDark,
                    ),
                  ),
                  Row(
                    children: [
                      ...List.generate(
                        5,
                        (i) => Icon(
                          i < rating ? CupertinoIcons.star_fill : CupertinoIcons.star,
                          size: 11.sp,
                          color: const Color(0xFFFFCC02),
                        ),
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        date,
                        style: GoogleFonts.poppins(
                          fontSize: 10.sp,
                          color: textMid,
                        ),
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
          comment,
          style: GoogleFonts.poppins(
            fontSize: 12.sp,
            color: textMid,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}
