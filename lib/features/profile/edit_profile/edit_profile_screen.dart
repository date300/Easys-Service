
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  // কনস্ট্যান্টস
  static const Color skyBlue = Color(0xFF29B6F6);
  static const String apiUrl = "https://easy.ltcminematrix.com/api/user/profile";

  // কন্ট্রোলার
  final _nameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _emailController = TextEditingController();
  final _referralCodeController = TextEditingController();
  final _referredByController = TextEditingController();

  bool _isLoading = true;
  String? _profilePicture;
  int _imageKey = DateTime.now().millisecondsSinceEpoch; // ক্যাশ সমস্যা সমাধানের জন্য

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  // ডাটা ফেচ করা
  Future<void> _fetchProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token');

      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          final user = data['user'];
          setState(() {
            _nameController.text = user['full_name'] ?? '';
            _mobileController.text = user['mobile'] ?? '';
            _emailController.text = user['email'] ?? '';
            
            // referred_by এবং referral_code যদি null থাকে তবে 'N/A' দেখাবে
            _referralCodeController.text = user['referral_code']?.toString() ?? 'N/A';
            _referredByController.text = user['referred_by']?.toString() ?? 'None';
            
            _profilePicture = user['profile_picture'];
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      debugPrint("Fetch Error: $e");
      setState(() => _isLoading = false);
    }
  }

  // প্রোফাইল পিকচার URL জেনারেটর
  String _getProfileImageUrl() {
    if (_profilePicture == null || _profilePicture!.isEmpty) return "";
    
    // এপিআই থেকে যদি ফুল লিঙ্ক আসে তবে সেটি ব্যবহার হবে
    // ক্যাশ রিফ্রেশ করতে শেষে টাইমস্ট্যাম্প যোগ করা হয়েছে
    return "$_profilePicture?v=$_imageKey";
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;
    final fieldBg = isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF3F4F6);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
      appBar: AppBar(
        title: Text("Profile Settings", style: GoogleFonts.poppins(fontSize: 18.sp)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        foregroundColor: textColor,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: skyBlue))
          : SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
              child: Column(
                children: [
                  // প্রোফাইল পিকচার সেকশন
                  Center(
                    child: Stack(
                      children: [
                        Container(
                          width: 110.w,
                          height: 110.w,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: skyBlue, width: 2.5),
                          ),
                          child: ClipOval(
                            child: (_profilePicture != null && _profilePicture!.isNotEmpty)
                                ? Image.network(
                                    _getProfileImageUrl(),
                                    key: ValueKey(_imageKey),
                                    fit: BoxFit.cover,
                                    loadingBuilder: (context, child, loading) {
                                      if (loading == null) return child;
                                      return const Center(child: CircularProgressIndicator(strokeWidth: 2));
                                    },
                                    errorBuilder: (context, error, stack) {
                                      return Icon(Icons.person, size: 50.w, color: Colors.grey);
                                    },
                                  )
                                : Icon(Icons.person, size: 50.w, color: Colors.grey),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: CircleAvatar(
                            backgroundColor: skyBlue,
                            radius: 18.r,
                            child: Icon(Icons.camera_alt, color: Colors.white, size: 16.sp),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 30.h),

                  // ইনপুট ফিল্ডস
                  _buildLabel("Full Name", textColor),
                  _buildTextField(_nameController, "Name", fieldBg, isDark, readOnly: false),
                  
                  SizedBox(height: 15.h),
                  _buildLabel("Mobile Number", textColor),
                  _buildTextField(_mobileController, "Mobile", fieldBg, isDark),

                  SizedBox(height: 15.h),
                  _buildLabel("Email Address", textColor),
                  _buildTextField(_emailController, "Email", fieldBg, isDark),

                  SizedBox(height: 15.h),
                  _buildLabel("Referral Code", textColor),
                  _buildTextField(_referralCodeController, "N/A", fieldBg, isDark),

                  SizedBox(height: 15.h),
                  _buildLabel("Referred By", textColor),
                  _buildTextField(_referredByController, "None", fieldBg, isDark),
                  
                  SizedBox(height: 30.h),
                  // আপডেট বাটন
                  SizedBox(
                    width: double.infinity,
                    height: 50.h,
                    child: ElevatedButton(
                      onPressed: () {}, // আপনার আপডেট ফাংশন এখানে দিন
                      style: ElevatedButton.styleFrom(
                        backgroundColor: skyBlue,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                      ),
                      child: Text("Save Profile", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildLabel(String text, Color color) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: EdgeInsets.only(bottom: 6.h, left: 4.w),
        child: Text(text, style: GoogleFonts.poppins(fontSize: 13.sp, fontWeight: FontWeight.w600, color: color)),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, Color bg, bool isDark, {bool readOnly = true}) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      style: GoogleFonts.poppins(fontSize: 14.sp, color: isDark ? Colors.white : Colors.black87),
      decoration: InputDecoration(
        filled: true,
        fillColor: bg,
        hintText: hint,
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: BorderSide.none),
        suffixIcon: readOnly ? Icon(Icons.lock_outline, size: 16.sp, color: Colors.grey) : null,
      ),
    );
  }
}
