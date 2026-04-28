import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'product_model.dart';

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
    'Electronics', 'Smart Watch', 'Neckband', 'Airpods',
    'Power Bank', 'Earphone', 'Fashion', 'Home',
    'Sports', 'Beauty', 'Books', 'Toys',
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
    if (_titleController.text.isEmpty || _priceController.text.isEmpty || _maxPriceController.text.isEmpty) {
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBackground = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final kTextDark = isDark ? Colors.white : const Color(0xFF0F172A);
    final kTextMid = isDark ? Colors.grey.shade400 : const Color(0xFF475569);
    final borderColor = isDark ? const Color(0xFF333333) : Colors.grey.withOpacity(0.1);

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24.h,
      ),
      decoration: BoxDecoration(
        color: cardBackground,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
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
                  color: borderColor,
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
                      color: const Color(0xFF29B6F6).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                    child: Icon(
                      CupertinoIcons.add_circled,
                      color: const Color(0xFF29B6F6),
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
                          style: GoogleFonts.poppins(
                            fontSize: 17.sp,
                            fontWeight: FontWeight.bold,
                            color: kTextDark,
                          ),
                        ),
                        Text(
                          'Fill the details to list your product',
                          style: GoogleFonts.poppins(
                            fontSize: 12.sp,
                            color: kTextMid,
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
              icon: CupertinoIcons.tag,
              kTextDark: kTextDark,
              kTextMid: kTextMid,
              borderColor: borderColor,
              isDark: isDark,
            ),
            SizedBox(height: 14.h),
            _buildTextField(
              label: 'Subtitle (with emoji)',
              hint: 'e.g. Premium Quality',
              controller: _subtitleController,
              icon: CupertinoIcons.textformat,
              kTextDark: kTextDark,
              kTextMid: kTextMid,
              borderColor: borderColor,
              isDark: isDark,
            ),
            SizedBox(height: 14.h),
            _buildTextField(
              label: 'Image URL',
              hint: 'Paste product image link (optional)',
              controller: _imageController,
              icon: CupertinoIcons.photo,
              kTextDark: kTextDark,
              kTextMid: kTextMid,
              borderColor: borderColor,
              isDark: isDark,
            ),
            SizedBox(height: 14.h),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    label: 'Wholesale Price',
                    hint: 'Buying price',
                    controller: _priceController,
                    icon: CupertinoIcons.money_dollar_circle,
                    keyboardType: TextInputType.number,
                    kTextDark: kTextDark,
                    kTextMid: kTextMid,
                    borderColor: borderColor,
                    isDark: isDark,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: _buildTextField(
                    label: 'Original Price',
                    hint: 'MRP (optional)',
                    controller: _originalPriceController,
                    icon: CupertinoIcons.tag_circle,
                    keyboardType: TextInputType.number,
                    kTextDark: kTextDark,
                    kTextMid: kTextMid,
                    borderColor: borderColor,
                    isDark: isDark,
                  ),
                ),
              ],
            ),
            SizedBox(height: 14.h),
            _buildTextField(
              label: 'Max Resale Price',
              hint: 'Maximum you can sell for',
              controller: _maxPriceController,
              icon: CupertinoIcons.arrow_up_circle,
              keyboardType: TextInputType.number,
              kTextDark: kTextDark,
              kTextMid: kTextMid,
              borderColor: borderColor,
              isDark: isDark,
            ),
            SizedBox(height: 18.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Text(
                'Select Category',
                style: GoogleFonts.poppins(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.bold,
                  color: kTextDark,
                ),
              ),
            ),
            SizedBox(height: 10.h),
            SizedBox(
              height: 44.h,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                itemCount: _availableCategories.length,
                separatorBuilder: (_, __) => SizedBox(width: 8.w),
                itemBuilder: (_, i) {
                  final cat = _availableCategories[i];
                  final selected = _selectedCategory == cat;
                  final style = getCategoryStyle(cat);
                  return GestureDetector(
                    onTap: () => setState(() => _selectedCategory = cat),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 9.h),
                      decoration: BoxDecoration(
                        color: selected ? style.color.withOpacity(0.15) : (isDark ? const Color(0xFF2C2C2C) : const Color(0xFFF1F5F9)),
                        borderRadius: BorderRadius.circular(10.r),
                        border: Border.all(
                          color: selected ? style.color.withOpacity(0.5) : borderColor,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            style.icon,
                            size: 15.sp,
                            color: selected ? style.color : kTextMid,
                          ),
                          SizedBox(width: 6.w),
                          Text(
                            cat,
                            style: GoogleFonts.poppins(
                              fontSize: 12.sp,
                              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                              color: selected ? style.color : kTextMid,
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
                    color: const Color(0xFF29B6F6),
                    borderRadius: BorderRadius.circular(14.r),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF29B6F6).withOpacity(0.3),
                        blurRadius: 14,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Text(
                    'Add Product',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.bold,
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
    required Color kTextDark,
    required Color kTextMid,
    required Color borderColor,
    required bool isDark,
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: kTextDark,
            ),
          ),
          SizedBox(height: 6.h),
          Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF2C2C2C) : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: borderColor),
            ),
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              style: GoogleFonts.poppins(
                fontSize: 14.sp,
                color: kTextDark,
              ),
              decoration: InputDecoration(
                prefixIcon: Icon(icon, color: kTextMid, size: 18.sp),
                hintText: hint,
                hintStyle: GoogleFonts.poppins(
                  fontSize: 13.sp,
                  color: kTextMid,
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
