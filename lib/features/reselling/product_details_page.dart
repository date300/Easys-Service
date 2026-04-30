import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'product_model.dart'; // আপনার মডেল ফাইলের পাথ দিন

class ProductDetailScreen extends StatelessWidget {
  final ProductModel product;
  const ProductDetailScreen({super.key, required this.product});

  static const Color kPrimary = Color(0xFF29B6F6);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final kBackground = isDark ? const Color(0xFF121212) : const Color(0xFFF8FAFC);
    final kTextDark = isDark ? Colors.white : const Color(0xFF0F172A);
    final kTextMid = isDark ? Colors.grey.shade400 : const Color(0xFF475569);
    final cardBackground = isDark ? const Color(0xFF1E1E1E) : Colors.white;

    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: kTextDark, size: 20.sp),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(
              product.isWishlisted ? Icons.favorite : Icons.favorite_border,
              color: product.isWishlisted ? Colors.red : kTextDark,
              size: 24.sp,
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Image Carousel
            _buildImageCarousel(cardBackground),

            Padding(
              padding: EdgeInsets.all(20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 2. Title & Brand
                  Text(
                    product.title,
                    style: GoogleFonts.poppins(
                      fontSize: 22.sp,
                      fontWeight: FontWeight.bold,
                      color: kTextDark,
                    ),
                  ).animate().fadeIn().slideX(),
                  
                  SizedBox(height: 4.h),
                  
                  Text(
                    product.brand ?? "Premium Brand",
                    style: GoogleFonts.poppins(
                      fontSize: 14.sp,
                      color: kTextMid,
                      fontWeight: FontWeight.w500,
                    ),
                  ).animate().fadeIn(delay: 100.ms),

                  SizedBox(height: 12.h),

                  // 3. Rating & Reviews
                  Row(
                    children: [
                      Icon(Icons.star, color: Colors.amber, size: 18.sp),
                      SizedBox(width: 4.w),
                      Text(
                        "${product.rating} (${product.reviewCount} Reviews)",
                        style: GoogleFonts.poppins(
                          fontSize: 13.sp,
                          color: kTextMid,
                        ),
                      ),
                    ],
                  ).animate().fadeIn(delay: 200.ms),

                  SizedBox(height: 20.h),

                  // 4. Pricing Section
                  _buildPriceSection(kTextDark, kTextMid),

                  SizedBox(height: 24.h),

                  // 5. Variants Section
                  _buildSectionTitle(context, "Select Variant", kTextDark),
                  SizedBox(height: 12.h),
                  _buildVariantChips(product.variants, kTextDark, cardBackground),

                  SizedBox(height: 24.h),

                  // 6. Description
                  _buildSectionTitle(context, "Description", kTextDark),
                  SizedBox(height: 12.h),
                  Text(
                    product.description ?? "No description available for this product.",
                    style: GoogleFonts.poppins(
                      fontSize: 14.sp,
                      color: kTextMid,
                      height: 1.6,
                    ),
                  ).animate().fadeIn(delay: 300.ms),
                  
                  SizedBox(height: 100.h), // Bottom space for buttons
                ],
              ),
            ),
          ],
        ),
      ),
      bottomSheet: _buildBottomActionBar(context, cardBackground, kTextDark),
    );
  }

  Widget _buildImageCarousel(Color bgColor) {
    return Container(
      height: 350.h,
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20.r),
        child: PageView.builder(
          itemCount: product.images.isEmpty ? 1 : product.images.length,
          itemBuilder: (context, index) {
            String imgUrl = product.images.isEmpty 
                ? product.image 
                : product.images[index].imageUrl;
            return Image.network(
              imgUrl,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, progress) => progress == null 
                ? child 
                : Center(child: CupertinoActivityIndicator()),
            );
          },
        ),
      ),
    ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack);
  }

  Widget _buildPriceSection(Color kTextDark, Color kTextMid) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          "৳${product.wholesalePrice.toStringAsFixed(0)}",
          style: GoogleFonts.poppins(
            fontSize: 28.sp,
            fontWeight: FontWeight.bold,
            color: kPrimary,
          ),
        ),
        SizedBox(width: 12.w),
        Text(
          "৳${product.originalPrice.toStringAsFixed(0)}",
          style: GoogleFonts.poppins(
            fontSize: 16.sp,
            color: kTextMid,
            decoration: TextDecoration.lineThrough,
          ),
        ),
        SizedBox(width: 12.w),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: Colors.redAccent.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6.r),
          ),
          child: Text(
            "${product.discountPercentage.toStringAsFixed(0)}% OFF",
            style: GoogleFonts.poppins(
              fontSize: 12.sp,
              fontWeight: FontWeight.bold,
              color: Colors.redAccent,
            ),
          ),
        ),
      ],
    ).animate().fadeIn(delay: 250.ms);
  }

  Widget _buildSectionTitle(BuildContext context, String title, Color color) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 16.sp,
        fontWeight: FontWeight.w600,
        color: color,
      ),
    );
  }

  Widget _buildVariantChips(List<ProductVariant> variants, Color kTextDark, Color bgColor) {
    if (variants.isEmpty) return Text("No variants available", style: GoogleFonts.poppins(fontSize: 13.sp, color: Colors.grey));

    return Wrap(
      spacing: 10.w,
      runSpacing: 10.h,
      children: variants.map((v) {
        return ChoiceChip(
          label: Text(v.color ?? v.size ?? "Default"),
          selected: false,
          onSelected: (val) {},
          backgroundColor: bgColor,
          selectedColor: kPrimary.withOpacity(0.2),
          labelStyle: GoogleFonts.poppins(fontSize: 13.sp, color: kTextDark),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r), side: BorderSide(color: Colors.grey.withOpacity(0.2))),
        );
      }).toList(),
    );
  }

  Widget _buildBottomActionBar(BuildContext context, Color bgColor, Color kTextDark) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.r)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 15.h),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                side: BorderSide(color: kPrimary),
              ),
              child: Text("Add to Cart", style: GoogleFonts.poppins(color: kPrimary, fontWeight: FontWeight.w600, fontSize: 14.sp)),
            ),
          ),
          SizedBox(width: 15.w),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimary,
                padding: EdgeInsets.symmetric(vertical: 15.h),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                elevation: 0,
              ),
              child: Text("Buy Now", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14.sp)),
            ),
          ),
        ],
      ),
    );
  }
}
