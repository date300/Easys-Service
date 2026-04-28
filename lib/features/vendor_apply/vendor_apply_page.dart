import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

// ==================== State Providers ====================

final vendorApplyLoadingProvider = StateProvider<bool>((ref) => false);

// ==================== Page ====================

class VendorApplyPage extends ConsumerStatefulWidget {
  const VendorApplyPage({super.key});

  @override
  ConsumerState<VendorApplyPage> createState() => _VendorApplyPageState();
}

class _VendorApplyPageState extends ConsumerState<VendorApplyPage> {
  static const Color skyBlue = Color(0xFF29B6F6);
  static const String baseUrl = "https://easy.ltcminematrix.com/api";

  final _formKey = GlobalKey<FormState>();

  final _businessNameCtrl = TextEditingController();
  final _businessTypeCtrl = TextEditingController();
  final _phoneCtrl        = TextEditingController();
  final _addressCtrl      = TextEditingController();
  final _descriptionCtrl  = TextEditingController();
  final _countryCtrl      = TextEditingController();

  String? _selectedCategory;

  // API অনুযায়ী ১১টি ক্যাটাগরি
  final List<String> _categories = [
    "Fashion & Clothing",
    "Electronics",
    "Mobile & Accessories",
    "Home & Kitchen",
    "Beauty & Cosmetics",
    "Sports & Fitness",
    "Groceries",
    "Digital Products",
    "Books & Education",
    "Automotive",
    "Health & Pharmacy",
  ];

  @override
  void dispose() {
    _businessNameCtrl.dispose();
    _businessTypeCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    _descriptionCtrl.dispose();
    _countryCtrl.dispose();
    super.dispose();
  }

  // ==================== API: Create Business ====================
  Future<void> _submitApplication() async {
    if (!_formKey.currentState!.validate()) return;

    ref.read(vendorApplyLoadingProvider.notifier).state = true;

    try {
      // ← ProfileScreen এর মতো: 'jwt_token' নামে পড়ুন
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token');

      if (token == null || token.isEmpty) {
        _showResultDialog(success: false, message: 'Please login first. Token not found.');
        return;
      }

      final response = await http.post(
        Uri.parse("$baseUrl/business/create"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "business_name":      _businessNameCtrl.text.trim(),
          "business_type":      _businessTypeCtrl.text.trim(),
          "category":           _selectedCategory,
          "mobile_number":      _phoneCtrl.text.trim(),
          "business_address":   _addressCtrl.text.trim(),
          "business_description": _descriptionCtrl.text.trim(),
          "country":            _countryCtrl.text.trim(),
        }),
      ).timeout(const Duration(seconds: 15));

      if (!mounted) return;

      final data = jsonDecode(response.body);

      if (response.statusCode == 201 && data['status'] == 'success') {
        _showResultDialog(
          success: true, 
          message: "${data['message']}\n\nBusiness ID: ${data['data']['id']}\nVoucher Deducted: ৳${data['data']['voucher_deducted']}\nRemaining Balance: ৳${data['data']['remaining_balance']}",
        );
      } else {
        _showResultDialog(success: false, message: data['message'] ?? 'Something went wrong.');
      }
    } catch (e) {
      if (mounted) {
        _showResultDialog(success: false, message: 'Network error: $e');
      }
    } finally {
      ref.read(vendorApplyLoadingProvider.notifier).state = false;
    }
  }

  // ==================== Dialog ====================
  void _showResultDialog({required bool success, required String message}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 35,
              backgroundColor: (success ? Colors.green : Colors.red).withOpacity(0.1),
              child: Icon(
                success ? Icons.check_circle_rounded : Icons.error_rounded,
                color: success ? Colors.green : Colors.red,
                size: 45,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              success ? 'Application Submitted!' : 'Submission Failed',
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              if (success) Navigator.pop(context);
            },
            child: Text(
              success ? 'Done' : 'Try Again',
              style: GoogleFonts.poppins(color: skyBlue, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== Build ====================
  @override
  Widget build(BuildContext context) {
    final isDark      = Theme.of(context).brightness == Brightness.dark;
    final isLoading   = ref.watch(vendorApplyLoadingProvider);
    final bgColor     = isDark ? const Color(0xFF121212) : const Color(0xFFF5F7FA);
    final cardColor   = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor   = isDark ? Colors.white : Colors.black87;
    final hintColor   = isDark ? Colors.grey.shade500 : Colors.grey.shade400;
    final borderColor = isDark ? const Color(0xFF333333) : const Color(0xFFE0E0E0);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        title: Text(
          'Apply for Vendor',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: textColor),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
          physics: const BouncingScrollPhysics(),
          children: [

            // Info Banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [skyBlue.withOpacity(0.15), skyBlue.withOpacity(0.05)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: skyBlue.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded, color: skyBlue, size: 22),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Application fee: ৳999 voucher balance. Fill in your business details carefully.',
                      style: GoogleFonts.poppins(fontSize: 12, color: isDark ? Colors.white70 : Colors.black54, height: 1.5),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Section: Business Info
            _sectionLabel('Business Information', isDark),
            const SizedBox(height: 12),

            _buildCard(
              cardColor: cardColor,
              borderColor: borderColor,
              children: [
                _inputField(
                  controller: _businessNameCtrl,
                  label: 'Business Name *',
                  hint: 'e.g. ABC Electronics',
                  icon: Icons.store_rounded,
                  textColor: textColor,
                  hintColor: hintColor,
                  isDark: isDark,
                  validator: (v) => v == null || v.isEmpty ? 'Business name is required' : null,
                ),
                _divider(borderColor),
                _inputField(
                  controller: _businessTypeCtrl,
                  label: 'Business Type *',
                  hint: 'e.g. Retail, Wholesale',
                  icon: Icons.business_center_rounded,
                  textColor: textColor,
                  hintColor: hintColor,
                  isDark: isDark,
                  validator: (v) => v == null || v.isEmpty ? 'Business type is required' : null,
                ),
                _divider(borderColor),
                _dropdownField(
                  label: 'Category *',
                  icon: Icons.category_rounded,
                  textColor: textColor,
                  hintColor: hintColor,
                  isDark: isDark,
                  cardColor: cardColor,
                  borderColor: borderColor,
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Section: Contact & Location
            _sectionLabel('Contact & Location', isDark),
            const SizedBox(height: 12),

            _buildCard(
              cardColor: cardColor,
              borderColor: borderColor,
              children: [
                _inputField(
                  controller: _phoneCtrl,
                  label: 'Mobile Number',
                  hint: 'e.g. 01712345678 or +8801712345678',
                  icon: Icons.phone_rounded,
                  keyboardType: TextInputType.phone,
                  textColor: textColor,
                  hintColor: hintColor,
                  isDark: isDark,
                ),
                _divider(borderColor),
                _inputField(
                  controller: _addressCtrl,
                  label: 'Business Address *',
                  hint: 'Full address: Street, City, Country',
                  icon: Icons.location_on_rounded,
                  maxLines: 2,
                  textColor: textColor,
                  hintColor: hintColor,
                  isDark: isDark,
                  validator: (v) => v == null || v.isEmpty ? 'Address is required' : null,
                ),
                _divider(borderColor),
                _inputField(
                  controller: _countryCtrl,
                  label: 'Country',
                  hint: 'e.g. Bangladesh',
                  icon: Icons.public_rounded,
                  textColor: textColor,
                  hintColor: hintColor,
                  isDark: isDark,
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Section: About Business
            _sectionLabel('About Your Business', isDark),
            const SizedBox(height: 12),

            _buildCard(
              cardColor: cardColor,
              borderColor: borderColor,
              children: [
                _inputField(
                  controller: _descriptionCtrl,
                  label: 'Business Description',
                  hint: 'Tell us what your business does... (optional)',
                  icon: Icons.description_rounded,
                  maxLines: 4,
                  textColor: textColor,
                  hintColor: hintColor,
                  isDark: isDark,
                ),
              ],
            ),

            const SizedBox(height: 30),

            // Submit Button
            SizedBox(
              height: 54,
              child: ElevatedButton(
                onPressed: isLoading ? null : _submitApplication,
                style: ElevatedButton.styleFrom(
                  backgroundColor: skyBlue,
                  disabledBackgroundColor: skyBlue.withOpacity(0.5),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.send_rounded, size: 20),
                          const SizedBox(width: 10),
                          Text(
                            'Submit (৳999)',
                            style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== Helper Widgets ====================

  Widget _sectionLabel(String label, bool isDark) {
    return Row(
      children: [
        Container(width: 4, height: 18, decoration: BoxDecoration(color: skyBlue, borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 8),
        Text(label, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: isDark ? Colors.white70 : Colors.black54)),
      ],
    );
  }

  Widget _buildCard({required Color cardColor, required Color borderColor, required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(children: children),
    );
  }

  Widget _divider(Color borderColor) => Divider(height: 1, thickness: 1, color: borderColor, indent: 54);

  Widget _inputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required Color textColor,
    required Color hintColor,
    required bool isDark,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        style: GoogleFonts.poppins(fontSize: 13, color: textColor),
        validator: validator,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: skyBlue, size: 20),
          labelText: label,
          hintText: hint,
          labelStyle: GoogleFonts.poppins(fontSize: 12, color: hintColor),
          hintStyle: GoogleFonts.poppins(fontSize: 12, color: hintColor),
          border: InputBorder.none,
          errorStyle: GoogleFonts.poppins(fontSize: 11),
        ),
      ),
    );
  }

  Widget _dropdownField({
    required String label,
    required IconData icon,
    required Color textColor,
    required Color hintColor,
    required bool isDark,
    required Color cardColor,
    required Color borderColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: DropdownButtonFormField<String>(
        value: _selectedCategory,
        dropdownColor: cardColor,
        style: GoogleFonts.poppins(fontSize: 13, color: textColor),
        icon: Icon(Icons.keyboard_arrow_down_rounded, color: hintColor),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: skyBlue, size: 20),
          labelText: label,
          labelStyle: GoogleFonts.poppins(fontSize: 12, color: hintColor),
          border: InputBorder.none,
          errorStyle: GoogleFonts.poppins(fontSize: 11),
        ),
        items: _categories
            .map((c) => DropdownMenuItem(value: c, child: Text(c, style: GoogleFonts.poppins(fontSize: 13))))
            .toList(),
        onChanged: (val) => setState(() => _selectedCategory = val),
        validator: (v) => v == null ? 'Please select a category' : null,
      ),
    );
  }
}
