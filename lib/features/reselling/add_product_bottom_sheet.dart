import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'product_model.dart';   // ⬅️ ইম্পোর্ট করুন

class AddProductBottomSheet extends StatefulWidget {
  final Function(ProductModel) onProductAdded;  // ✅ এখন ProductModel প্যারামিটার নেবে

  const AddProductBottomSheet({super.key, required this.onProductAdded});

  @override
  State<AddProductBottomSheet> createState() => _AddProductBottomSheetState();
}

class _AddProductBottomSheetState extends State<AddProductBottomSheet> {
  // ... আপনার সব TextEditingController আগের মতো থাকবে
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _imageController = TextEditingController();
  final _priceController = TextEditingController();
  final _discountPriceController = TextEditingController();
  final _stockController = TextEditingController(text: "10");

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
      final String? token = prefs.getString('jwt_token');
      if (token == null) {
        _showSnackBar("Session expired. Please login again.", isError: true);
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
        
        // ✅ API থেকে পাওয়া ডাটা দিয়ে ProductModel বানান
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
              : double.parse(_priceController.text) + 200, // fallback
          maxResalePrice: double.parse(_priceController.text) * 1.5,
          category: _selectedCategory,
          rating: 0.0,
          isReselling: false,
          myMargin: 0,
        );
        
        _showSnackBar("Product submitted for approval!");
        widget.onProductAdded(newProduct); // ✅ নতুন প্রোডাক্ট পাঠান
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
    // 👇 আপনার বাকি UI ঠিক আগের মতো রাখুন, শুধু বাটনের onPressed-এ _submitProduct দিন
    return Container(
      // ... সব UI
      child: SingleChildScrollView(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Column(
          children: [
            // ... সব টেক্সট ফিল্ড
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
              child: InkWell(
                onTap: _isLoading ? null : _submitProduct,
                child: Container(
                  // ... ডেকোরেশন
                  child: _isLoading 
                    ? const Center(child: CupertinoActivityIndicator(color: Colors.white))
                    : Text('Add Product', ...),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
