import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AddProductBottomSheet extends StatefulWidget {
  final Function() onProductAdded;

  const AddProductBottomSheet({super.key, required this.onProductAdded});

  @override
  State<AddProductBottomSheet> createState() => _AddProductBottomSheetState();
}

class _AddProductBottomSheetState extends State<AddProductBottomSheet> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _imageController = TextEditingController();
  final _priceController = TextEditingController();
  final _discountPriceController = TextEditingController();
  final _stockController = TextEditingController(text: "10"); // Default stock

  bool _isLoading = false;
  String _selectedCategory = 'Electronics';

  // ক্যাটাগরি নাম থেকে আইডি ম্যাপ (তোমার DB অনুযায়ী আইডি সেট করো)
  final Map<String, int> _categoryMap = {
    'Electronics': 1, 'Smart Watch': 2, 'Neckband': 3, 'Airpods': 4,
    'Power Bank': 5, 'Earphone': 6, 'Fashion': 7, 'Home': 8,
  };

  final List<String> _availableCategories = [
    'Electronics', 'Smart Watch', 'Neckband', 'Airpods',
    'Power Bank', 'Earphone', 'Fashion', 'Home'
  ];

  // API কল করার মেইন ফাংশন
  Future<void> _submitProduct() async {
    // ১. বেসিক ভ্যালিডেশন
    if (_titleController.text.isEmpty || _priceController.text.isEmpty) {
      _showSnackBar("Product name and price are required!", isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      // ২. SharedPreferences থেকে টোকেন নেওয়া
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('jwt_token');

      if (token == null) {
        _showSnackBar("Session expired. Please login again.", isError: true);
        return;
      }

      // ৩. ডাটা প্রিপারেশন (Backend-এর রিকোয়েস্ট বডি অনুযায়ী)
      final String apiUrl = 'https://easy.ltcminematrix.com/api/vendor/product/create';
      
      final Map<String, dynamic> requestBody = {
        "business_id": 1, // এটি তোমার ডাইনামিকলি নেওয়া উচিত (যেমন লগইন করার সময় পাওয়া আইডি)
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

      // ৪. HTTP POST রিকোয়েস্ট পাঠানো
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
        // সাকসেস
        HapticFeedback.mediumImpact();
        _showSnackBar("Product submitted for approval!");
        widget.onProductAdded(); // লিস্ট রিফ্রেশ করার কলব্যাক
        Navigator.pop(context);
      } else {
        // এরর মেসেজ হ্যান্ডলিং
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
    // ... আগের UI কোড ঠিক থাকবে, শুধু 'Add Product' বাটনের onPressed-এ _submitProduct দাও
    // নিচে বাটনের অংশটি আপডেট করে দিচ্ছি:

    return Container(
      // ... (তোমার বাকি কন্টেইনার ডেকোরেশন)
      child: SingleChildScrollView(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Column(
          children: [
            // ... (সব টেক্সট ফিল্ড)

            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
              child: InkWell(
                onTap: _isLoading ? null : _submitProduct,
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 16.h),
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
            ),
          ],
        ),
      ),
    );
  }
}
