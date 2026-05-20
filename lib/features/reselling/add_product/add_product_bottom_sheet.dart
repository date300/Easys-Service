import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
  // ===================== CONSTANTS =====================
  static const String _baseUrl = 'https://api.easysarvice.com/api';

  // ===================== CONTROLLERS =====================
  final _titleController         = TextEditingController();
  final _descriptionController   = TextEditingController();
  final _priceController         = TextEditingController();
  final _discountPriceController = TextEditingController();
  final _stockController         = TextEditingController(text: '10');
  final _brandController         = TextEditingController(text: 'Easy Service');
  final _skuController           = TextEditingController();
  final _metaTitleController     = TextEditingController();
  final _metaDescController      = TextEditingController();

  // ===================== STATE =====================
  bool _isLoading = false;
  String _selectedCategory = 'Electronics';

  // ইমেজ বাইটস ও নাম (web/mobile উভয়ের জন্য)
  final List<Uint8List> _imageBytes = [];
  final List<String>    _imageNames = [];

  final Dio _dio = Dio();

  // API category_id ম্যাপিং
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

  // ===================== LIFECYCLE =====================
  @override
  void initState() {
    super.initState();
    // Auto-generate SKU
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
    _metaTitleController.dispose();
    _metaDescController.dispose();
    super.dispose();
  }

  // ===================== IMAGE PICKER =====================
  Future<void> _pickImages() async {
    // ইতিমধ্যে ৪টি ইমেজ থাকলে আর নেওয়া যাবে না
    if (_imageBytes.length >= 4) {
      _showSnackBar('Maximum 4 images allowed', isError: true);
      return;
    }

    final picker = ImagePicker();
    try {
      final remaining = 4 - _imageBytes.length;
      final pickedFiles = await picker.pickMultiImage(
        imageQuality: 85,
        limit: remaining,
      );

      if (pickedFiles.isNotEmpty) {
        for (var xfile in pickedFiles) {
          if (_imageBytes.length >= 4) break;
          final bytes = await xfile.readAsBytes();
          setState(() {
            _imageBytes.add(bytes);
            _imageNames.add(xfile.name);
          });
        }
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

  // ===================== VALIDATION =====================
  String? _validate() {
    final name = _titleController.text.trim();
    if (name.length < 2) return 'Product name required (min 2 characters)';

    final price = double.tryParse(_priceController.text.trim());
    if (price == null || price <= 0) return 'Enter a valid price';

    final discountText = _discountPriceController.text.trim();
    if (discountText.isNotEmpty) {
      final discountPrice = double.tryParse(discountText);
      if (discountPrice == null || discountPrice <= 0) return 'Enter a valid discount price';
      if (discountPrice >= price) return 'Discount price must be less than regular price';
    }

    final stockText = _stockController.text.trim();
    final stock = int.tryParse(stockText);
    if (stock == null || stock < 0) return 'Enter a valid stock quantity (0 or above)';

    return null; // সব ঠিক আছে
  }

  // ===================== SUBMIT =====================
  Future<void> _submitProduct() async {
    // Validation
    final validationError = _validate();
    if (validationError != null) {
      _showSnackBar(validationError, isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Token নেওয়া
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token');

      if (token == null || token.isEmpty) {
        _showSnackBar('Please login first.', isError: true);
        return;
      }

      final name          = _titleController.text.trim();
      final price         = double.parse(_priceController.text.trim());
      final discountText  = _discountPriceController.text.trim();
      final discountPrice = discountText.isNotEmpty ? double.tryParse(discountText) : null;
      final stock         = int.tryParse(_stockController.text.trim()) ?? 0;
      final brand         = _brandController.text.trim().isNotEmpty
                              ? _brandController.text.trim() : 'Easy Service';
      final categoryId    = (_categoryMap[_selectedCategory] ?? 1).toString();
      final description   = _descriptionController.text.trim();
      final sku           = _skuController.text.trim();

      // meta_title না দিলে product_name ব্যবহার করব
      final metaTitle = _metaTitleController.text.trim().isNotEmpty
          ? _metaTitleController.text.trim() : name;
      // meta_description না দিলে description ব্যবহার করব
      final metaDesc = _metaDescController.text.trim().isNotEmpty
          ? _metaDescController.text.trim() : description;

      // =====================
      // FormData তৈরি — API ফিল্ড নাম হুবহু মিলাতে হবে
      // =====================
      final Map<String, dynamic> formMap = {
        'product_name':     name,          // API: product_name
        'brand':            brand,         // API: brand
        'price':            price,         // API: price
        'category_id':      categoryId,    // API: category_id (string হিসেবে পাঠাও)
        'description':      description,   // API: description
        'stock':            stock.toString(),  // API: stock
        'sku':              sku,           // API: sku
        'meta_title':       metaTitle,     // API: meta_title
        'meta_description': metaDesc,      // API: meta_description
      };

      // discount_price শুধু থাকলেই পাঠাও (API: null হলে সমস্যা হয়)
      if (discountPrice != null) {
        formMap['discount_price'] = discountPrice;
      }

      // ইমেজ ফাইল যোগ করা — API: images[] (array, max 4)
      if (_imageBytes.isNotEmpty) {
        formMap['images'] = List.generate(
          _imageBytes.length,
          (i) => MultipartFile.fromBytes(
            _imageBytes[i],
            filename: _imageNames[i],
          ),
        );
      }

      final formData = FormData.fromMap(formMap);

      // =====================
      // API Call
      // =====================
      final response = await _dio.post(
        '$_baseUrl/vendor/product/create',
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            // Content-Type দিতে হবে না, Dio নিজে multipart/form-data দেবে
          },
          validateStatus: (status) => status != null && status < 600,
        ),
      );

      if (!mounted) return;

      final responseData = response.data as Map<String, dynamic>;

      // =====================
      // Response Handle — API 201 পাঠায় success এ
      // =====================
      if (response.statusCode == 201 &&
          responseData['status'] == 'success') {
        HapticFeedback.mediumImpact();

        // API থেকে আসা product_id ও slug ব্যবহার করব
        final productId = responseData['product_id']?.toString()
            ?? DateTime.now().millisecondsSinceEpoch.toString();

        final newProduct = ProductModel(
          id:             productId,
          title:          name,
          subtitle:       description,
          image:          _imageBytes.isNotEmpty ? '' : '',  // API image URL পরে fetch করতে হবে
          wholesalePrice: price,
          originalPrice:  discountPrice ?? (price + 200),
          maxResalePrice: price * 1.5,
          category:       _selectedCategory,
          rating:         0.0,
          isReselling:    false,
          myMargin:       0,
          stock:          stock,
        );

        _showSnackBar(
          responseData['message'] ?? 'Product submitted for approval!',
        );
        widget.onProductAdded(newProduct);
        Navigator.pop(context);

      } else {
        // Error message API থেকে নেওয়া
        final errMsg = responseData['message'] ?? 'Failed to add product.';
        _showSnackBar(errMsg, isError: true);
      }

    } on DioException catch (e) {
      // Network/Server error
      final serverMsg = e.response?.data?['message'];
      final msg = serverMsg ?? 'Connection error: ${e.message}';
      if (mounted) _showSnackBar(msg, isError: true);
    } catch (e) {
      if (mounted) _showSnackBar('Unexpected error: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ===================== SNACKBAR =====================
  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.poppins(fontSize: 13)),
        backgroundColor: isError ? Colors.redAccent : Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // ===================== IMAGE PICKER UI =====================
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
        SizedBox(
          height: 90.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            // ইমেজ + "Add" বাটন (সর্বোচ্চ ৪টি ইমেজ)
            itemCount: _imageBytes.length + (_imageBytes.length < 4 ? 1 : 0),
            separatorBuilder: (_, __) => SizedBox(width: 10.w),
            itemBuilder: (context, index) {
              // "Add more" বাটন
              if (index == _imageBytes.length) {
                return GestureDetector(
                  onTap: _pickImages,
                  child: Container(
                    width: 80.w, height: 80.h,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: const Color(0xFF29B6F6),
                        style: BorderStyle.solid,
                      ),
                      borderRadius: BorderRadius.circular(10.r),
                      color: const Color(0xFF29B6F6).withOpacity(0.08),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_a_photo_outlined,
                            color: const Color(0xFF29B6F6), size: 26.sp),
                        SizedBox(height: 4.h),
                        Text(
                          '${_imageBytes.length}/4',
                          style: GoogleFonts.poppins(
                            fontSize: 10.sp,
                            color: const Color(0xFF29B6F6),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              // ইমেজ প্রিভিউ
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
                  // Remove বাটন
                  Positioned(
                    top: 2.h, right: 2.w,
                    child: GestureDetector(
                      onTap: () => _removeImage(index),
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),
                        padding: EdgeInsets.all(3.sp),
                        child: Icon(Icons.close,
                            size: 14.sp, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        SizedBox(height: 6.h),
        Text(
          'Each image max 2MB. Formats: jpg, png, webp',
          style: GoogleFonts.poppins(
            fontSize: 11.sp,
            color: Colors.grey.shade500,
          ),
        ),
      ],
    );
  }

  // ===================== BUILD =====================
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
          bottom: MediaQuery.of(context).viewInsets.bottom + 24.h,
          left: 20.w, right: 20.w, top: 16.h,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 48.w, height: 4.h,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
            ),
            SizedBox(height: 20.h),

            // Title
            Text(
              'Add New Product',
              style: GoogleFonts.poppins(
                fontSize: 20.sp, fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            Text(
              'Will be submitted for admin approval',
              style: GoogleFonts.poppins(
                fontSize: 12.sp,
                color: Colors.orange.shade400,
              ),
            ),
            SizedBox(height: 20.h),

            // ===== REQUIRED FIELDS =====
            _buildTextField(_titleController,
                'Product Name *', Icons.title),
            SizedBox(height: 14.h),

            _buildTextField(_brandController,
                'Brand', Icons.branding_watermark),
            SizedBox(height: 14.h),

            _buildTextField(_descriptionController,
                'Description', Icons.description, maxLines: 3),
            SizedBox(height: 14.h),

            // Images
            _buildImagePickerSection(),
            SizedBox(height: 14.h),

            // Price row
            Row(
              children: [
                Expanded(
                  child: _buildTextField(_priceController,
                      'Price *', Icons.attach_money, isNumber: true),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: _buildTextField(_discountPriceController,
                      'Discount Price', Icons.local_offer, isNumber: true),
                ),
              ],
            ),
            SizedBox(height: 14.h),

            // Stock & SKU row
            Row(
              children: [
                Expanded(
                  child: _buildTextField(_stockController,
                      'Stock *', Icons.inventory, isNumber: true),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: _buildTextField(_skuController,
                      'SKU', Icons.qr_code),
                ),
              ],
            ),
            SizedBox(height: 14.h),

            // Category Dropdown
            Text(
              'Category',
              style: GoogleFonts.poppins(
                fontSize: 14.sp, fontWeight: FontWeight.w500,
                color: isDark ? Colors.white70 : Colors.grey.shade700,
              ),
            ),
            SizedBox(height: 8.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12.r),
                color: isDark
                    ? Colors.grey.shade800.withOpacity(0.3)
                    : Colors.grey.shade50,
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedCategory,
                  isExpanded: true,
                  dropdownColor:
                      isDark ? const Color(0xFF2C2C2C) : Colors.white,
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
                  onChanged: (val) =>
                      setState(() => _selectedCategory = val!),
                ),
              ),
            ),
            SizedBox(height: 14.h),

            // ===== OPTIONAL: SEO FIELDS (Expandable) =====
            _buildSeoSection(isDark),
            SizedBox(height: 24.h),

            // ===== SUBMIT BUTTON =====
            GestureDetector(
              onTap: _isLoading ? null : _submitProduct,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 15.h),
                decoration: BoxDecoration(
                  color: _isLoading
                      ? Colors.grey.shade400
                      : const Color(0xFF29B6F6),
                  borderRadius: BorderRadius.circular(14.r),
                  boxShadow: _isLoading
                      ? []
                      : [
                          BoxShadow(
                            color: const Color(0xFF29B6F6).withOpacity(0.35),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                ),
                child: _isLoading
                    ? const Center(
                        child: CupertinoActivityIndicator(color: Colors.white))
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
            SizedBox(height: 8.h),
          ],
        ),
      ),
    );
  }

  // ===================== SEO SECTION (Optional) =====================
  Widget _buildSeoSection(bool isDark) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        title: Text(
          'SEO Settings (Optional)',
          style: GoogleFonts.poppins(
            fontSize: 13.sp,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade500,
          ),
        ),
        children: [
          SizedBox(height: 8.h),
          _buildTextField(_metaTitleController,
              'Meta Title', Icons.title_outlined),
          SizedBox(height: 12.h),
          _buildTextField(_metaDescController,
              'Meta Description', Icons.description_outlined, maxLines: 2),
          SizedBox(height: 8.h),
        ],
      ),
    );
  }

  // ===================== TEXT FIELD BUILDER =====================
  Widget _buildTextField(
    TextEditingController controller,
    String hint,
    IconData icon, {
    int maxLines = 1,
    bool isNumber = false,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          hint,
          style: GoogleFonts.poppins(
            fontSize: 13.sp,
            fontWeight: FontWeight.w500,
            color: isDark ? Colors.white70 : Colors.grey.shade700,
          ),
        ),
        SizedBox(height: 6.h),
        TextField(
          controller: controller,
          keyboardType: isNumber
              ? const TextInputType.numberWithOptions(decimal: true)
              : TextInputType.text,
          maxLines: maxLines,
          style: GoogleFonts.poppins(
            fontSize: 14.sp,
            color: isDark ? Colors.white : Colors.black87,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.poppins(
              fontSize: 13.sp, color: Colors.grey.shade400,
            ),
            prefixIcon: Icon(icon,
                size: 20.sp, color: Colors.grey.shade500),
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
              borderSide: const BorderSide(
                  color: Color(0xFF29B6F6), width: 1.5),
            ),
            filled: true,
            fillColor: isDark
                ? Colors.grey.shade800.withOpacity(0.3)
                : Colors.grey.shade50,
            contentPadding: EdgeInsets.symmetric(
                vertical: 12.h, horizontal: 12.w),
          ),
        ),
      ],
    );
  }
}
