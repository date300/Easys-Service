import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'product_model.dart';

class AddProductBottomSheet extends StatefulWidget {
  final Function(ProductModel) onProductAdded;

  const AddProductBottomSheet({super.key, required this.onProductAdded});

  @override
  State<AddProductBottomSheet> createState() => _AddProductBottomSheetState();
}

class _AddProductBottomSheetState extends State<AddProductBottomSheet> {
  static const String _baseUrl = 'https://easy.ltcminematrix.com/api';

  final _titleController         = TextEditingController();
  final _descriptionController   = TextEditingController();
  final _imageController         = TextEditingController();
  final _priceController         = TextEditingController();
  final _discountPriceController = TextEditingController();
  final _stockController         = TextEditingController(text: '10');
  final _brandController         = TextEditingController(text: 'Generic');
  final _skuController           = TextEditingController();

  bool    _isLoading    = false;
  bool    _isLoadingBiz = true;
  int?    _businessId;
  String? _bizError;

  String _selectedCategory = 'Electronics';

  // ✅ Backend category_id এর সাথে match
  final Map<String, int> _categoryMap = {
    'Electronics': 1,
    'Smart Watch': 2,
    'Neckband':    3,
    'Airpods':     4,
    'Power Bank':  5,
    'Earphone':    6,
    'Fashion':     7,
    'Home':        8,
  };

  @override
  void initState() {
    super.initState();
    _skuController.text = 'SKU-${DateTime.now().millisecondsSinceEpoch}';
    _loadBusinessId();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _imageController.dispose();
    _priceController.dispose();
    _discountPriceController.dispose();
    _stockController.dispose();
    _brandController.dispose();
    _skuController.dispose();
    super.dispose();
  }

  // ✅ SharedPreferences থেকে business_id লোড, না থাকলে API থেকে fetch
  Future<void> _loadBusinessId() async {
    setState(() { _isLoadingBiz = true; _bizError = null; });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token');

      if (token == null || token.isEmpty) {
        setState(() {
          _bizError    = 'Please login first. Token not found.';
          _isLoadingBiz = false;
        });
        return;
      }

      // আগে SharedPreferences এ saved আছে কিনা দেখো
      final saved = prefs.getInt('business_id');
      if (saved != null) {
        setState(() { _businessId = saved; _isLoadingBiz = false; });
        return;
      }

      // না থাকলে API থেকে vendor products নিয়ে business_id বের করো
      final response = await http.get(
        Uri.parse('$_baseUrl/vendor/products?limit=1'),
        headers: {
          'Content-Type':  'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      if (!mounted) return;

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final list = data['data'] as List?;
        if (list != null && list.isNotEmpty) {
          final bizId = list[0]['business_id'];
          if (bizId != null) {
            await prefs.setInt('business_id', bizId as int);
            setState(() { _businessId = bizId; _isLoadingBiz = false; });
            return;
          }
        }
      }

      setState(() {
        _bizError    = 'No approved business found.\nPlease apply as a vendor first.';
        _isLoadingBiz = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _bizError    = 'Failed to load business info.\nCheck your connection.';
          _isLoadingBiz = false;
        });
      }
    }
  }

  // ✅ VendorApplyPage এর মতো token pattern
  Future<void> _submitProduct() async {
    final name = _titleController.text.trim();
    if (name.length < 2) {
      _showSnackBar('Product name required (min 2 characters)', isError: true);
      return;
    }

    final price = double.tryParse(_priceController.text.trim());
    if (price == null || price <= 0) {
      _showSnackBar('Enter a valid price', isError: true);
      return;
    }

    // ✅ discount_price < price — backend validate করে, client-এও check করা হচ্ছে
    double? discountPrice;
    if (_discountPriceController.text.trim().isNotEmpty) {
      discountPrice = double.tryParse(_discountPriceController.text.trim());
      if (discountPrice == null || discountPrice <= 0) {
        _showSnackBar('Enter a valid discount price', isError: true);
        return;
      }
      if (discountPrice >= price) {
        _showSnackBar('Discount price must be less than regular price', isError: true);
        return;
      }
    }

    if (_businessId == null) {
      _showSnackBar('Business not found. Apply as vendor first.', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token'); // ✅ VendorApplyPage এর মতো

      if (token == null || token.isEmpty) { // ✅ VendorApplyPage এর মতো
        _showSnackBar('Please login first. Token not found.', isError: true);
        return;
      }

      final imageUrl = _imageController.text.trim().isNotEmpty
          ? _imageController.text.trim()
          : 'https://images.unsplash.com/photo-1523275335684-37898b6baf30';

      final Map<String, dynamic> requestBody = {
        'business_id':      _businessId,                         // ✅ dynamic, hardcoded না
        'product_name':     name,
        'brand':            _brandController.text.trim().isNotEmpty
                              ? _brandController.text.trim()
                              : 'Generic',
        'price':            price,
        'discount_price':   discountPrice,                       // null হলে backend skip করে
        'category_id':      _categoryMap[_selectedCategory] ?? 1,
        'description':      _descriptionController.text.trim(),
        'stock':            int.tryParse(_stockController.text.trim()) ?? 0,
        'sku':              _skuController.text.trim(),
        'images':           [imageUrl],                          // ✅ array — backend এ array expect করে
        'meta_title':       name,
        'meta_description': _descriptionController.text.trim(),
      };

      final response = await http.post(
        Uri.parse('$_baseUrl/vendor/product/create'),
        headers: {
          'Content-Type':  'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(requestBody),
      ).timeout(const Duration(seconds: 15));

      if (!mounted) return;

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 201) {
        HapticFeedback.mediumImpact();

        final newProduct = ProductModel(
          id: responseData['product_id']?.toString()  // ✅ backend 'product_id' return করে
              ?? DateTime.now().millisecondsSinceEpoch.toString(),
          title:          name,
          subtitle:       _descriptionController.text.trim(),
          image:          imageUrl,
          wholesalePrice: price,
          originalPrice:  discountPrice ?? price + 200,
          maxResalePrice: price * 1.5,
          category:       _selectedCategory,
          rating:         0.0,
          isReselling:    false,
          myMargin:       0,
        );

        _showSnackBar('Product submitted for approval!');
        widget.onProductAdded(newProduct);
        Navigator.pop(context);

      } else if (response.statusCode == 403) {
        // Business not approved অথবা not found
        _showSnackBar(
          responseData['message'] ?? 'Business not approved. Contact support.',
          isError: true,
        );
      } else if (response.statusCode == 400) {
        // Validation error
        _showSnackBar(
          responseData['message'] ?? 'Invalid input. Check all fields.',
          isError: true,
        );
      } else {
        _showSnackBar(
          responseData['message'] ?? 'Failed to add product. Try again.',
          isError: true,
        );
      }
    } catch (e) {
      if (mounted) _showSnackBar('Connection error: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.poppins(fontSize: 13)),
        backgroundColor: isError ? Colors.redAccent : Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          left:  20.w,
          right: 20.w,
          top:   20.h,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 60.w, height: 4.h,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
            ),
            SizedBox(height: 20.h),

            Text(
              'Add New Product',
              style: GoogleFonts.poppins(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            SizedBox(height: 12.h),

            // ✅ Business status banner
            if (_isLoadingBiz)
              _infoBanner(
                icon: CupertinoIcons.clock,
                message: 'Loading your business info...',
                color: Colors.orange,
              )
            else if (_bizError != null)
              _infoBanner(
                icon: CupertinoIcons.exclamationmark_circle,
                message: _bizError!,
                color: Colors.red,
                onRetry: _loadBusinessId,
              )
            else
              _infoBanner(
                icon: CupertinoIcons.checkmark_shield,
                message: 'Business verified (ID: $_businessId). Product will be reviewed by admin.',
                color: Colors.green,
              ),

            SizedBox(height: 20.h),

            _buildTextField(_titleController, 'Product Name *', Icons.title),
            SizedBox(height: 16.h),
            _buildTextField(_brandController, 'Brand', Icons.branding_watermark),
            SizedBox(height: 16.h),
            _buildTextField(_descriptionController, 'Description', Icons.description, maxLines: 3),
            SizedBox(height: 16.h),
            _buildTextField(_imageController, 'Image URL (optional)', Icons.image),
            SizedBox(height: 16.h),
            _buildTextField(_priceController, 'Price * (৳)', Icons.attach_money, isNumber: true),
            SizedBox(height: 16.h),
            _buildTextField(
              _discountPriceController,
              'Discount Price (must be less than price)',
              Icons.local_offer,
              isNumber: true,
            ),
            SizedBox(height: 16.h),
            _buildTextField(_stockController, 'Stock Quantity', Icons.inventory, isNumber: true),
            SizedBox(height: 16.h),
            _buildTextField(_skuController, 'SKU', Icons.qr_code),
            SizedBox(height: 16.h),

            // Category Dropdown
            Text(
              'Category',
              style: GoogleFonts.poppins(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.white70 : Colors.grey.shade700,
              ),
            ),
            SizedBox(height: 8.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedCategory,
                  isExpanded: true,
                  dropdownColor: isDark ? const Color(0xFF2C2C2C) : Colors.white,
                  icon: Icon(CupertinoIcons.chevron_down, size: 16.sp),
                  items: _categoryMap.keys.map((cat) {
                    return DropdownMenuItem(
                      value: cat,
                      child: Text(
                        cat,
                        style: GoogleFonts.poppins(
                          fontSize: 13.sp,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (val) => setState(() => _selectedCategory = val!),
                ),
              ),
            ),
            SizedBox(height: 24.h),

            // Submit Button
            GestureDetector(
              onTap: (_isLoading || _isLoadingBiz || _bizError != null)
                  ? null
                  : _submitProduct,
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 14.h),
                decoration: BoxDecoration(
                  color: (_isLoading || _isLoadingBiz || _bizError != null)
                      ? Colors.grey
                      : const Color(0xFF29B6F6),
                  borderRadius: BorderRadius.circular(14.r),
                  boxShadow: (_isLoading || _bizError != null) ? [] : [
                    BoxShadow(
                      color: const Color(0xFF29B6F6).withOpacity(0.3),
                      blurRadius: 14,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: _isLoading
                    ? const Center(child: CupertinoActivityIndicator(color: Colors.white))
                    : Text(
                        'Submit for Approval',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoBanner({
    required IconData icon,
    required String message,
    required Color color,
    VoidCallback? onRetry,
  }) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18.sp),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              message,
              style: GoogleFonts.poppins(fontSize: 12.sp, color: color, height: 1.4),
            ),
          ),
          if (onRetry != null) ...[
            SizedBox(width: 8.w),
            GestureDetector(
              onTap: onRetry,
              child: Icon(CupertinoIcons.refresh, color: color, size: 18.sp),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hint,
    IconData icon, {
    int maxLines  = 1,
    bool isNumber = false,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          hint,
          style: GoogleFonts.poppins(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: isDark ? Colors.white70 : Colors.grey.shade700,
          ),
        ),
        SizedBox(height: 8.h),
        TextField(
          controller: controller,
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          maxLines: maxLines,
          style: GoogleFonts.poppins(
            fontSize: 14.sp,
            color: isDark ? Colors.white : Colors.black87,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.poppins(fontSize: 13.sp, color: Colors.grey.shade400),
            prefixIcon: Icon(icon, size: 20.sp, color: Colors.grey.shade500),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: const BorderSide(color: Color(0xFF29B6F6), width: 1.5),
            ),
            filled: true,
            fillColor: isDark
                ? Colors.grey.shade800.withOpacity(0.3)
                : Colors.grey.shade50,
          ),
        ),
      ],
    );
  }
}
