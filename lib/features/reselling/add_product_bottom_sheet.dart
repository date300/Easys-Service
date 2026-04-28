, import 'dart:convert';
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
  final _titleController        = TextEditingController();
  final _descriptionController  = TextEditingController();
  final _imageController        = TextEditingController();
  final _priceController        = TextEditingController();
  final _discountPriceController = TextEditingController();
  final _stockController        = TextEditingController(text: "10");

  bool _isLoading = false;
  String _selectedCategory = 'Electronics';

  final Map<String, int> _categoryMap = {
    'Electronics': 1, 'Smart Watch': 2, 'Neckband': 3, 'Airpods': 4,
    'Power Bank': 5, 'Earphone': 6, 'Fashion': 7, 'Home': 8,
  };

  final List<String> _availableCategories = [
    'Electronics', 'Smart Watch', 'Neckband', 'Airpods',
    'Power Bank', 'Earphone', 'Fashion', 'Home'
  ];

  Future<void> _submitProduct() async {
    if (_titleController.text.isEmpty || _priceController.text.isEmpty) {
      _showSnackBar("Product name and price are required!", isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token'); // ✅ VendorApplyPage এর মতো

      if (token == null || token.isEmpty) { // ✅ VendorApplyPage এর মতো
        _showSnackBar("Please login first. Token not found.", isError: true);
        return;
      }

      final String apiUrl = 'https://easy.ltcminematrix.com/api/vendor/product/create';
      final Map<String, dynamic> requestBody = {
        "business_id": 1,
        "product_name": _titleController.text.trim(),
        "brand": "Generic",
        "price": double.parse(_priceController.text),
        "discount_price": _discountPriceController.text.isNotEmpty
            ? double.parse(_discountPriceController.text) : null,
        "category_id": _categoryMap[_selectedCategory] ?? 1,
        "description": _descriptionController.text.trim(),
        "stock": int.tryParse(_stockController.text) ?? 0,
        "sku": "SKU-${DateTime.now().millisecondsSinceEpoch}",
        "images": [
          _imageController.text.trim().isNotEmpty
              ? _imageController.text.trim()
              : "https://images.unsplash.com/photo-1523275335684-37898b6baf30"
        ],
        "meta_title": _titleController.text.trim(),
        "meta_description": _descriptionController.text.trim(),
      };

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(requestBody),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 201 || response.statusCode == 200) {
        HapticFeedback.mediumImpact();

        final newProduct = ProductModel(
          id: responseData['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
          title: _titleController.text.trim(),
          subtitle: _descriptionController.text.trim(),
          image: _imageController.text.trim().isNotEmpty
              ? _imageController.text.trim()
              : "https://images.unsplash.com/photo-1523275335684-37898b6baf30",
          wholesalePrice: double.parse(_priceController.text),
          originalPrice: _discountPriceController.text.isNotEmpty
              ? double.parse(_discountPriceController.text)
              : double.parse(_priceController.text) + 200,
          maxResalePrice: double.parse(_priceController.text) * 1.5,
          category: _selectedCategory,
          rating: 0.0,
          isReselling: false,
          myMargin: 0,
        );

        _showSnackBar("Product submitted for approval!");
        widget.onProductAdded(newProduct);
        Navigator.pop(context);
      } else {
        _showSnackBar(responseData['message'] ?? "Failed to add product", isError: true);
      }
    } catch (e) {
      _showSnackBar("Connection error: $e", isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.redAccent : Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF1E1E1E)
            : Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 20.w,
          right: 20.w,
          top: 20.h,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 60.w,
                height: 4.h,
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
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : Colors.black87,
              ),
            ),
            SizedBox(height: 20.h),
            _buildTextField(_titleController, 'Product Title', Icons.title),
            SizedBox(height: 16.h),
            _buildTextField(_descriptionController, 'Description', Icons.description, maxLines: 3),
            SizedBox(height: 16.h),
            _buildTextField(_imageController, 'Image URL (optional)', Icons.image),
            SizedBox(height: 16.h),
            _buildTextField(_priceController, 'Price (?)', Icons.attach_money, isNumber: true),
            SizedBox(height: 16.h),
            _buildTextField(_discountPriceController, 'Discount Price (optional)', Icons.local_offer, isNumber: true),
            SizedBox(height: 16.h),
            _buildTextField(_stockController, 'Stock Quantity', Icons.inventory, isNumber: true),
            SizedBox(height: 16.h),
            Text(
              'Category',
              style: GoogleFonts.poppins(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white70
                    : Colors.grey.shade700,
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
                  icon: Icon(CupertinoIcons.chevron_down, size: 16.sp),
                  items: _availableCategories.map((cat) {
                    return DropdownMenuItem(value: cat, child: Text(cat));
                  }).toList(),
                  onChanged: (val) => setState(() => _selectedCategory = val!),
                ),
              ),
            ),
            SizedBox(height: 24.h),
            InkWell(
              onTap: _isLoading ? null : _submitProduct,
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 14.h),
                decoration: BoxDecoration(
                  color: _isLoading ? Colors.grey : const Color(0xFF29B6F6),
                  borderRadius: BorderRadius.circular(14.r),
                  boxShadow: _isLoading ? [] : [
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
            SizedBox(height: 30.h),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, IconData icon,
      {int maxLines = 1, bool isNumber = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          hint,
          style: GoogleFonts.poppins(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white70
                : Colors.grey.shade700,
          ),
        ),
        SizedBox(height: 8.h),
        TextField(
          controller: controller,
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          maxLines: maxLines,
          style: GoogleFonts.poppins(fontSize: 14.sp),
          decoration: InputDecoration(
            hintText: hint,
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
            fillColor: Theme.of(context).brightness == Brightness.dark
                ? Colors.grey.shade800.withOpacity(0.3)
                : Colors.grey.shade50,
          ),
        ),
      ],
    );
  }
}

