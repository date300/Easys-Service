import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
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
  final _priceController         = TextEditingController();
  final _discountPriceController = TextEditingController();
  final _stockController         = TextEditingController(text: '10');
  final _brandController         = TextEditingController(text: 'Easy Service');
  final _skuController           = TextEditingController();

  bool _isLoading = false;
  String _selectedCategory = 'Electronics';

  // ক্রস-প্ল্যাটফর্ম ইমেজ সংরক্ষণ
  List<Uint8List> _imageBytes = [];
  List<String> _imageNames = [];

  final Dio _dio = Dio();

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
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _discountPriceController.dispose();
    _stockController.dispose();
    _brandController.dispose();
    _skuController.dispose();
    super.dispose();
  }

  // ============= ইমেজ পিকার (ওয়েব ও মোবাইল – দুই-ই সাপোর্ট) =============
  Future<void> _pickImages() async {
    final picker = ImagePicker();
    try {
      final pickedFiles = await picker.pickMultiImage(
        imageQuality: 85,
        limit: 4,
      );
      if (pickedFiles.isNotEmpty) {
        // সবগুলো ফাইল থেকে বাইট ও নাম রেখে দিচ্ছি
        List<Uint8List> bytesList = [];
        List<String> namesList = [];
        for (var xfile in pickedFiles) {
          final bytes = await xfile.readAsBytes();
          bytesList.add(bytes);
          namesList.add(xfile.name);
        }
        setState(() {
          _imageBytes = bytesList;
          _imageNames = namesList;
        });
      }
    } catch (e) {
      _showSnackBar('Could not pick images: $e', isError: true);
    }
  }

  void _removeImage(int index) {
    setState(() {
      _imageBytes.removeAt(index);
      _imageNames.removeAt(index);
    });
  }

  // ============= সাবমিট (Dio মাল্টিপার্ট) =============
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

    if (_imageBytes.length > 4) {
      _showSnackBar('Maximum 4 images allowed', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token');

      if (token == null || token.isEmpty) {
        _showSnackBar('Please login first.', isError: true);
        return;
      }

      // মাল্টিপার্ট ফর্ম তৈরি (সকল প্ল্যাটফর্মের জন্য)
      final formData = FormData.fromMap({
        'product_name':     name,
        'brand':            _brandController.text.trim().isNotEmpty
                              ? _brandController.text.trim() : 'Easy Service',
        'price':            price,
        'category_id':      (_categoryMap[_selectedCategory] ?? 1).toString(),
        'description':      _descriptionController.text.trim(),
        'stock':            _stockController.text.trim(),
        'sku':              _skuController.text.trim(),
        'meta_title':       name,
        'meta_description': _descriptionController.text.trim(),
        if (discountPrice != null) 'discount_price': discountPrice,
        // ইমেজগুলো বাইট থেকে যোগ
        'images': List.generate(
          _imageBytes.length,
          (i) => MultipartFile.fromBytes(
            _imageBytes[i],
            filename: _imageNames[i],
          ),
        ),
      });

      final response = await _dio.post(
        '$_baseUrl/vendor/product/create',
        data: formData,
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      if (!mounted) return;

      final responseData = response.data;

      if (response.statusCode == 201) {
        HapticFeedback.mediumImpact();

        final newProduct = ProductModel(
          id: responseData['product_id']?.toString()
              ?? DateTime.now().millisecondsSinceEpoch.toString(),
          title: name,
          subtitle: _descriptionController.text.trim(),
          image: '',   // পরে সঠিক URL আসবে API থেকে
          wholesalePrice: price,
          originalPrice: discountPrice ?? price + 200,
          maxResalePrice: price * 1.5,
          category: _selectedCategory,
          rating: 0.0,
          isReselling: false,
          myMargin: 0,
          stock: int.tryParse(_stockController.text.trim()) ?? 10,
        );

        _showSnackBar('Product submitted for approval!');
        widget.onProductAdded(newProduct);
        Navigator.pop(context);
      } else {
        _showSnackBar(
          responseData['message'] ?? 'Failed to add product.',
          isError: true,
        );
      }
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? 'Connection error: ${e.message}';
      if (mounted) _showSnackBar(msg, isError: true);
    } catch (e) {
      if (mounted) _showSnackBar('Unexpected error: $e', isError: true);
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

  // ============= ইমেজ সিলেক্টর UI (Image.memory দিয়ে প্রিভিউ) =============
  Widget _buildImagePickerSection() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Product Images (max 4)',
          style: GoogleFonts.poppins(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: isDark ? Colors.white70 : Colors.grey.shade700,
          ),
        ),
        SizedBox(height: 10.h),
        if (_imageBytes.isNotEmpty)
          SizedBox(
            height: 90.h,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _imageBytes.length + (_imageBytes.length < 4 ? 1 : 0),
              separatorBuilder: (_, __) => SizedBox(width: 10.w),
              itemBuilder: (context, index) {
                // শেষে অ্যাড বাটন
                if (index == _imageBytes.length) {
                  return GestureDetector(
                    onTap: _pickImages,
                    child: Container(
                      width: 80.w, height: 80.h,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade400),
                        borderRadius: BorderRadius.circular(10.r),
                        color: Colors.grey.shade200.withOpacity(0.5),
                      ),
                      child: Icon(Icons.add_a_photo, color: Colors.grey.shade600, size: 28.sp),
                    ),
                  );
                }
                // ইমেজ প্রিভিউ (Image.memory)
                return Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10.r),
                      child: Image.memory(
                        _imageBytes[index],
                        width: 80.w, height: 80.h,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      top: 2.h, right: 2.w,
                      child: GestureDetector(
                        onTap: () => _removeImage(index),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black54, shape: BoxShape.circle,
                          ),
                          padding: EdgeInsets.all(2.sp),
                          child: Icon(Icons.close, size: 16.sp, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          )
        else
          GestureDetector(
            onTap: _pickImages,
            child: Container(
              width: 80.w, height: 80.h,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(10.r),
                color: Colors.grey.shade200.withOpacity(0.5),
              ),
              child: Icon(Icons.add_a_photo, color: Colors.grey.shade600, size: 32.sp),
            ),
          ),
      ],
    );
  }

  // ============= বাকি UI (আগের মতোই) =============
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
          left: 20.w, right: 20.w, top: 20.h,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
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
                fontSize: 20.sp, fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            SizedBox(height: 20.h),

            _buildTextField(_titleController, 'Product Name *', Icons.title),
            SizedBox(height: 16.h),
            _buildTextField(_brandController, 'Brand', Icons.branding_watermark),
            SizedBox(height: 16.h),
            _buildTextField(_descriptionController, 'Description', Icons.description, maxLines: 3),
            SizedBox(height: 16.h),
            _buildImagePickerSection(),
            SizedBox(height: 16.h),
            _buildTextField(_priceController, 'Price *', Icons.attach_money, isNumber: true),
            SizedBox(height: 16.h),
            _buildTextField(_discountPriceController, 'Discount Price', Icons.local_offer, isNumber: true),
            SizedBox(height: 16.h),
            _buildTextField(_stockController, 'Stock Quantity', Icons.inventory, isNumber: true),
            SizedBox(height: 16.h),
            _buildTextField(_skuController, 'SKU', Icons.qr_code),
            SizedBox(height: 16.h),

            Text('Category', style: GoogleFonts.poppins(fontSize: 14.sp, fontWeight: FontWeight.w500, color: isDark ? Colors.white70 : Colors.grey.shade700)),
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
                      child: Text(cat, style: GoogleFonts.poppins(fontSize: 13.sp, color: isDark ? Colors.white : Colors.black87)),
                    );
                  }).toList(),
                  onChanged: (val) => setState(() => _selectedCategory = val!),
                ),
              ),
            ),
            SizedBox(height: 24.h),

            GestureDetector(
              onTap: _isLoading ? null : _submitProduct,
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 14.h),
                decoration: BoxDecoration(
                  color: _isLoading ? Colors.grey : const Color(0xFF29B6F6),
                  borderRadius: BorderRadius.circular(14.r),
                  boxShadow: _isLoading ? [] : [
                    BoxShadow(color: const Color(0xFF29B6F6).withOpacity(0.3), blurRadius: 14, offset: Offset(0, 5)),
                  ],
                ),
                child: _isLoading
                    ? const Center(child: CupertinoActivityIndicator(color: Colors.white))
                    : Text('Submit for Approval', textAlign: TextAlign.center, style: GoogleFonts.poppins(fontSize: 15.sp, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
            SizedBox(height: 10.h),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, IconData icon, {int maxLines = 1, bool isNumber = false}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(hint, style: GoogleFonts.poppins(fontSize: 14.sp, fontWeight: FontWeight.w500, color: isDark ? Colors.white70 : Colors.grey.shade700)),
        SizedBox(height: 8.h),
        TextField(
          controller: controller,
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          maxLines: maxLines,
          style: GoogleFonts.poppins(fontSize: 14.sp, color: isDark ? Colors.white : Colors.black87),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.poppins(fontSize: 13.sp, color: Colors.grey.shade400),
            prefixIcon: Icon(icon, size: 20.sp, color: Colors.grey.shade500),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: BorderSide(color: Colors.grey.shade300)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: BorderSide(color: Colors.grey.shade300)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: const BorderSide(color: Color(0xFF29B6F6), width: 1.5)),
            filled: true,
            fillColor: isDark ? Colors.grey.shade800.withOpacity(0.3) : Colors.grey.shade50,
          ),
        ),
      ],
    );
  }
}
