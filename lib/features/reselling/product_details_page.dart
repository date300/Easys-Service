import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'product_model.dart';
import 'resell_bottom_sheet.dart';

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
    final shadowColor = isDark ? Colors.black.withOpacity(0.3) : Colors.black.withOpacity(0.04);

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
      appBar: _buildAppBar(isDark, kTextDark, shadowColor),
      body: Stack(
        children: [
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildImageSlider(isDark, cardBg, shadowColor, borderColor),
                _buildPriceSection(isDark, kTextDark, kTextMid, cardBg, borderColor, shadowColor, discount),
                SizedBox(height: 12.h),
                _buildProfitBanner(maxProfit, shadowColor),
                SizedBox(height: 12.h),
                _buildDeliveryInfo(isDark, cardBg, kTextDark, kTextMid, borderColor, shadowColor),
                SizedBox(height: 12.h),
                _buildHighlights(isDark, cardBg, kTextDark, kTextMid, borderColor, shadowColor),
                SizedBox(height: 12.h),
                _buildDescription(isDark, cardBg, kTextDark, kTextMid, borderColor, shadowColor),
                SizedBox(height: 12.h),
                _buildSellerInfo(isDark, cardBg, kTextDark, kTextMid, borderColor, shadowColor),
                SizedBox(height: 12.h),
                _buildRatings(isDark, cardBg, kTextDark, kTextMid, borderColor, shadowColor),
                SizedBox(height: 100.h),
              ],
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildBottomBar(isDark, cardBg, kTextDark, kTextMid, borderColor, shadowColor),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(bool isDark, Color kTextDark, Color shadowColor) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          margin: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E1E).withOpacity(0.95) : Colors.white.withOpacity(0.95),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: shadowColor,
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
              color: isDark ? const Color(0xFF1E1E1E).withOpacity(0.95) : Colors.white.withOpacity(0.95),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: shadowColor,
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
                color: _isWishlisted ? const Color(0xFFFF3B30) : kTextDark.withOpacity(0.6),
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
              color: isDark ? const Color(0xFF1E1E1E).withOpacity(0.95) : Colors.white.withOpacity(0.95),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: shadowColor,
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              CupertinoIcons.share,
              color: kTextDark.withOpacity(0.6),
              size: 18.sp,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImageSlider(bool isDark, Color cardBg, Color shadowColor, Color borderColor) {
    return Container(
      height: 320.h,
      margin: EdgeInsets.fromLTRB(16.w, 0, 16.w, 0),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.r),
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
                          color: const Color(0xFF29B6F6),
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
              left: 12.w,
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
                      margin: EdgeInsets.symmetric(vertical: 4.h),
                      width: selected ? 46.w : 42.w,
                      height: selected ? 46.w : 42.w,
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
                        borderRadius: BorderRadius.circular(10.r),
                        border: Border.all(
                          color: selected ? const Color(0xFF29B6F6) : borderColor,
                          width: selected ? 2.5 : 1,
                        ),
                        boxShadow: selected
                            ? [
                                BoxShadow(
                                  color: const Color(0xFF29B6F6).withOpacity(0.25),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : [
                                BoxShadow(
                                  color: shadowColor,
                                  blurRadius: 4,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8.r),
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
                          ? const Color(0xFF29B6F6)
                          : Colors.grey.withOpacity(0.35),
                      borderRadius: BorderRadius.circular(3.r),
                    ),
                  );
                }),
              ),
            ),
            if (widget.product.originalPrice != null)
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
                      BoxShadow(
                        color: const Color(0xFF29B6F6).withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    '-${(((widget.product.originalPrice! - widget.product.wholesalePrice) / widget.product.originalPrice!) * 100).toStringAsFixed(0)}%',
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
      ),
    ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.05);
  }

  Widget _buildPriceSection(bool isDark, Color kTextDark, Color kTextMid, Color cardBg, Color borderColor, Color shadowColor, String? discount) {
    return Container(
      margin: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 0),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: borderColor, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                    fontSize: 14.sp,
                    color: kTextMid,
                    decoration: TextDecoration.lineThrough,
                  ),
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
                    style: GoogleFonts.poppins(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF34C759),
                    ),
                  ),
                ),
              ],
            ],
          ).animate().fadeIn(delay: 150.ms).slideX(begin: -0.05),
          SizedBox(height: 12.h),
          Text(
            widget.product.title,
            style: GoogleFonts.poppins(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: kTextDark,
              height: 1.35,
            ),
          ).animate().fadeIn(delay: 200.ms),
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
              Container(
                width: 4.w,
                height: 4.w,
                decoration: BoxDecoration(
                  color: kTextMid.withOpacity(0.4),
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 8.w),
              Text(
                '1.2k sold',
                style: GoogleFonts.poppins(
                  fontSize: 11.sp,
                  color: kTextMid,
                ),
              ),
            ],
          ).animate().fadeIn(delay: 250.ms),
          SizedBox(height: 12.h),
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
    ).animate().fadeIn(delay: 200.ms);
  }

  Widget _buildProfitBanner(double maxProfit, Color shadowColor) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF29B6F6), Color(0xFF0284C7)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(16.r),
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
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(CupertinoIcons.money_dollar_circle, color: Colors.white, size: 24.sp),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Resell \u09F3${maxProfit.toInt()} profit!',
                  style: GoogleFonts.poppins(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Add your margin upto \u09F3${maxProfit.toInt()} and start selling today',
                  style: GoogleFonts.poppins(
                    fontSize: 12.sp,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
          Icon(CupertinoIcons.chevron_right, color: Colors.white.withOpacity(0.8), size: 18.sp),
        ],
      ),
    ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.05);
  }

  Widget _buildDeliveryInfo(bool isDark, Color cardBg, Color kTextDark, Color kTextMid, Color borderColor, Color shadowColor) {
    final items = [
      _InfoRow(icon: CupertinoIcons.location, color: const Color(0xFF34C759), title: 'Delivery', value: 'Free delivery on orders over \u09F3999'),
      _InfoRow(icon: CupertinoIcons.return_icon, color: const Color(0xFF29B6F6), title: 'Returns', value: '7 days easy return policy'),
      _InfoRow(icon: CupertinoIcons.shield_fill, color: const Color(0xFF6366F1), title: 'Warranty', value: '1 year brand warranty'),
      _InfoRow(icon: CupertinoIcons.checkmark_seal, color: const Color(0xFFFF9500), title: 'Authentic', value: '100% genuine guaranteed'),
    ];

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
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
                child: Icon(CupertinoIcons.cube_box, color: const Color(0xFF29B6F6), size: 18.sp),
              ),
              SizedBox(width: 10.w),
              Text(
                'Delivery & Services',
                style: GoogleFonts.poppins(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: kTextDark,
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          ...items.asMap().entries.map((entry) => _buildInfoRow(
                entry.value,
                kTextDark,
                kTextMid,
                borderColor,
                isLast: entry.key == items.length - 1,
              )),
        ],
      ),
    ).animate().fadeIn(delay: 350.ms);
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
                  borderRadius: BorderRadius.circular(10.r),
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

  Widget _buildHighlights(bool isDark, Color cardBg, Color kTextDark, Color kTextMid, Color borderColor, Color shadowColor) {
    final highlights = [
      'Premium quality with long lasting durability',
      'Latest v2.0 chip for better performance',
      'Fast charging support included',
      'Water resistant design',
      'Compatible with all devices',
    ];

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
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
                  color: const Color(0xFFFF9500).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(CupertinoIcons.star_circle_fill, color: const Color(0xFFFF9500), size: 18.sp),
              ),
              SizedBox(width: 10.w),
              Text(
                'Key Highlights',
                style: GoogleFonts.poppins(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: kTextDark,
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          ...highlights.map((h) => Padding(
                padding: EdgeInsets.only(bottom: 10.h),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: EdgeInsets.only(top: 4.h),
                      width: 6.w,
                      height: 6.w,
                      decoration: const BoxDecoration(
                        color: Color(0xFF29B6F6),
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Text(
                        h,
                        style: GoogleFonts.poppins(
                          fontSize: 12.sp,
                          color: kTextMid,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    ).animate().fadeIn(delay: 400.ms);
  }

  Widget _buildDescription(bool isDark, Color cardBg, Color kTextDark, Color kTextMid, Color borderColor, Color shadowColor) {
    const fullDesc =
        'This premium quality product comes with amazing features that make your daily life easier. Built with top-grade materials, it ensures durability and long-lasting performance. '
        'Designed for modern users who want both style and functionality. Perfect for personal use or as a gift for your loved ones. '
        'Order now and enjoy fast delivery with cash on delivery option available across Bangladesh.';

    final shortDesc = fullDesc.substring(0, 120) + '...';

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
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
                child: Icon(CupertinoIcons.doc_text, color: const Color(0xFF29B6F6), size: 18.sp),
              ),
              SizedBox(width: 10.w),
              Text(
                'Product Description',
                style: GoogleFonts.poppins(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: kTextDark,
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
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
          SizedBox(height: 12.h),
          GestureDetector(
            onTap: () => setState(() => _showFullDescription = !_showFullDescription),
            child: Row(
              children: [
                Text(
                  _showFullDescription ? 'Show Less' : 'Read More',
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
    ).animate().fadeIn(delay: 450.ms);
  }

  Widget _buildSellerInfo(bool isDark, Color cardBg, Color kTextDark, Color kTextMid, Color borderColor, Color shadowColor) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
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
                child: Icon(CupertinoIcons.person_2, color: const Color(0xFF6366F1), size: 18.sp),
              ),
              SizedBox(width: 10.w),
              Text(
                'Seller Info',
                style: GoogleFonts.poppins(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: kTextDark,
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          Row(
            children: [
              Container(
                width: 48.w,
                height: 48.w,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF29B6F6), Color(0xFF0284C7)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF29B6F6).withOpacity(0.25),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    'BD',
                    style: GoogleFonts.poppins(
                      fontSize: 15.sp,
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
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                            color: kTextDark,
                          ),
                        ),
                        SizedBox(width: 6.w),
                        Icon(CupertinoIcons.checkmark_seal_fill,
                            color: const Color(0xFF29B6F6), size: 15.sp),
                      ],
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      '\u2605 4.9 | 2.3k+ followers | 98% positive',
                      style: GoogleFonts.poppins(fontSize: 11.sp, color: kTextMid),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 7.h),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF29B6F6), Color(0xFF0284C7)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(10.r),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF29B6F6).withOpacity(0.25),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  'Follow',
                  style: GoogleFonts.poppins(
                    fontSize: 11.sp,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: 500.ms);
  }

  Widget _buildRatings(bool isDark, Color cardBg, Color kTextDark, Color kTextMid, Color borderColor, Color shadowColor) {
    final reviews = [
      _Review(name: 'Rahim Uddin', rating: 5, text: 'Amazing product! Fast delivery, great quality', time: '2 days ago'),
      _Review(name: 'Karim Ali', rating: 4, text: 'Value for money. Packaging could be better', time: '1 week ago'),
      _Review(name: 'Salma Begum', rating: 5, text: 'Best seller in this platform, recommended', time: '2 weeks ago'),
    ];

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
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
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFCC02).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Icon(CupertinoIcons.star_fill, color: const Color(0xFFFFCC02), size: 18.sp),
                  ),
                  SizedBox(width: 10.w),
                  Text(
                    'Ratings & Reviews',
                    style: GoogleFonts.poppins(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: kTextDark,
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'See All',
                      style: GoogleFonts.poppins(
                        fontSize: 12.sp,
                        color: const Color(0xFF29B6F6),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
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
                    '234 reviews',
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
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF29B6F6), Color(0xFF0284C7)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            r.name[0],
                            style: GoogleFonts.poppins(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
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
                  SizedBox(height: 10.h),
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
            ).animate().fadeIn(delay: (entry.key * 80 + 550).ms);
          }),
        ],
      ),
    ).animate().fadeIn(delay: 550.ms);
  }

  Widget _buildBottomBar(bool isDark, Color cardBg, Color kTextDark, Color kTextMid, Color borderColor, Color shadowColor) {
    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 24.h),
      decoration: BoxDecoration(
        color: cardBg,
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
                'Wholesale Price',
                style: GoogleFonts.poppins(fontSize: 10.sp, color: kTextMid),
              ),
              Text(
                '\u09F3${widget.product.wholesalePrice.toInt()}',
                style: GoogleFonts.poppins(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF29B6F6),
                ),
              ),
            ],
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: GestureDetector(
              onTap: _showResellSheet,
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 16.h),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF29B6F6), Color(0xFF0284C7)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(14.r),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF29B6F6).withOpacity(0.35),
                      blurRadius: 14,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(CupertinoIcons.cart_badge_plus, color: Colors.white, size: 18.sp),
                    SizedBox(width: 8.w),
                    Text(
                      'Resell & Earn',
                      style: GoogleFonts.poppins(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
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

class _InfoRow {
  final IconData icon;
  final Color color;
  final String title;
  final String value;

  _InfoRow({
    required this.icon,
    required this.color,
    required this.title,
    required this.value,
  });
}

class _Review {
  final String name;
  final int rating;
  final String text;
  final String time;

  _Review({
    required this.name,
    required this.rating,
    required this.text,
    required this.time,
  });
}
