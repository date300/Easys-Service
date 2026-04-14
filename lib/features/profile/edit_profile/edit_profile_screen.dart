import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  static const Color skyBlue = Color(0xFF29B6F6);
  static const String baseUrl = "https://easy.ltcminematrix.com/api";
  static const String staticBase = "https://easy.ltcminematrix.com";

  final _nameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _emailController = TextEditingController();
  final _referralCodeController = TextEditingController();
  final _referredByController = TextEditingController();

  bool _isLoading = true;
  bool _isSaving = false;
  bool _isUploadingImage = false;
  bool _idVerified = false;
  String? _errorMsg;
  String? _profilePicture;
  DateTime? _lastNameChange;
  bool _canChangeName = true;
  String? _nameChangeMessage;
  String _originalName = '';
  
  // Cache busting এর জন্য ইউনিক কি
  int _imageKey = DateTime.now().millisecondsSinceEpoch;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  // প্রোফাইল ডাটা ফেচিং
  Future<void> _fetchProfile() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMsg = null;
    });

    try {
      final token = await _getToken();
      final response = await http.get(
        Uri.parse("$baseUrl/user/profile"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      ).timeout(const Duration(seconds: 15));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['status'] == 'success') {
        final user = data['user'];
        setState(() {
          _originalName = user['full_name'] ?? '';
          _nameController.text = _originalName;
          _mobileController.text = user['mobile'] ?? '';
          _emailController.text = user['email'] ?? '';
          
          // এপিআই থেকে null আসলে "N/A" দেখাবে
          _referralCodeController.text = user['referral_code']?.toString() ?? 'N/A';
          _referredByController.text = user['referred_by']?.toString() ?? 'None';
          
          _idVerified = user['id_verified'] == 1 || user['id_verified'] == true;
          _profilePicture = user['profile_picture']; // এপিআই থেকে ফুল ইউআরএল আসছে

          if (user['last_name_change'] != null) {
            _lastNameChange = DateTime.parse(user['last_name_change']);
            _checkNameChangeEligibility();
          }
        });
      } else {
        setState(() => _errorMsg = data['message'] ?? 'Failed to load profile');
      }
    } catch (e) {
      setState(() => _errorMsg = "Connection Error! Please try again.");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // প্রোফাইল পিকচার ইউআরএল জেনারেটর (Fixed)
  String _getProfileImageUrl() {
    if (_profilePicture == null || _profilePicture!.isEmpty) return "";
    
    String url = _profilePicture!;
    // যদি এপিআই থেকে শুধু ফাইলের নাম আসে তবে বেজ ইউআরএল যোগ হবে
    if (!url.startsWith('http')) {
      url = "$staticBase/public/uploads/profile_pics/$url";
    }
    
    // অনেক সময় ?v= প্যারামিটার সার্ভার সাপোর্ট করে না, তাই সরাসরি ইউআরএল পাঠানো হচ্ছে
    return url; 
  }

  void _checkNameChangeEligibility() {
    if (_lastNameChange == null) return;
    final now = DateTime.now();
    final difference = now.difference(_lastNameChange!);
    if (difference.inDays < 15) {
      _canChangeName = false;
      _nameChangeMessage = "You can change your name in ${15 - difference.inDays} days";
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
      appBar: AppBar(
        title: Text("Edit Profile", style: GoogleFonts.poppins(fontSize: 18)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: isDark ? Colors.white : Colors.black,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: skyBlue))
          : _errorMsg != null
              ? _buildError()
              : SingleChildScrollView(
                  padding: EdgeInsets.all(24.w),
                  child: Column(
                    children: [
                      _buildAvatarSection(isDark),
                      SizedBox(height: 30.h),
                      _buildFields(isDark),
                      SizedBox(height: 30.h),
                      _buildSaveButton(),
                    ],
                  ),
                ),
    );
  }

  Widget _buildAvatarSection(bool isDark) {
    return Center(
      child: Stack(
        children: [
          Container(
            width: 120.w,
            height: 120.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: skyBlue, width: 3),
              color: isDark ? Colors.grey[900] : Colors.grey[200],
            ),
            child: ClipOval(
              child: (_profilePicture != null && _profilePicture!.isNotEmpty)
                  ? Image.network(
                      _getProfileImageUrl(),
                      key: ValueKey(_imageKey), // রিফ্রেশ করার জন্য
                      fit: BoxFit.cover,
                      // অনেক সময় হেডার ছাড়া ইমেজ ব্লক করে সার্ভার
                      headers: const {
                        "User-Agent": "Mozilla/5.0",
                        "Accept": "image/*",
                      },
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return const Center(child: CircularProgressIndicator(strokeWidth: 2));
                      },
                      errorBuilder: (context, error, stackTrace) {
                        debugPrint("Image Load Error: $error");
                        return Icon(Icons.person, size: 60.w, color: Colors.grey);
                      },
                    )
                  : Icon(Icons.person, size: 60.w, color: Colors.grey),
            ),
          ),
          if (_isUploadingImage)
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(color: Colors.black45, shape: BoxShape.circle),
                child: const Center(child: CircularProgressIndicator(color: Colors.white)),
              ),
            ),
          Positioned(
            bottom: 5,
            right: 5,
            child: GestureDetector(
              onTap: _pickAndUploadImage,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(color: skyBlue, shape: BoxShape.circle),
                child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFields(bool isDark) {
    final textColor = isDark ? Colors.white : Colors.black87;
    final fieldBg = isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF3F4F6);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label("Full Name", textColor),
        _textField(_nameController, "Enter Name", readOnly: !_canChangeName, bg: fieldBg, isDark: isDark),
        if (!_canChangeName && _nameChangeMessage != null)
          Padding(
            padding: EdgeInsets.only(top: 5.h),
            child: Text(_nameChangeMessage!, style: const TextStyle(color: Colors.orange, fontSize: 11)),
          ),
        SizedBox(height: 16.h),
        _label("Mobile Number", textColor),
        _textField(_mobileController, "Mobile", readOnly: true, bg: fieldBg, isDark: isDark),
        SizedBox(height: 16.h),
        _label("Email Address", textColor),
        _textField(_emailController, "Email", readOnly: true, bg: fieldBg, isDark: isDark),
        SizedBox(height: 16.h),
        _label("Referral Code", textColor),
        _textField(_referralCodeController, "N/A", readOnly: true, bg: fieldBg, isDark: isDark),
        SizedBox(height: 16.h),
        _label("Referred By", textColor),
        _textField(_referredByController, "None", readOnly: true, bg: fieldBg, isDark: isDark),
      ],
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 50.h,
      child: ElevatedButton(
        onPressed: (_canChangeName && !_isSaving) ? _saveProfile : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: skyBlue,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
          elevation: 0,
        ),
        child: _isSaving
            ? const CircularProgressIndicator(color: Colors.white)
            : Text("Save Changes", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white)),
      ),
    );
  }

  // ইমেজ আপলোড ফাংশন
  Future<void> _pickAndUploadImage() async {
    try {
      final XFile? file = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
      if (file == null) return;

      setState(() => _isUploadingImage = true);
      final token = await _getToken();
      final request = http.MultipartRequest('POST', Uri.parse("$baseUrl/user/upload-profile-pic"));
      request.headers['Authorization'] = 'Bearer $token';
      
      request.files.add(await http.MultipartFile.fromPath('profile_picture', file.path));

      final response = await request.send();
      if (response.statusCode == 200) {
        _imageKey = DateTime.now().millisecondsSinceEpoch; // ইমেজ কি আপডেট
        await _fetchProfile();
        _showSnack("Profile picture updated!", Colors.green);
      } else {
        _showSnack("Failed to upload image", Colors.red);
      }
    } catch (e) {
      _showSnack("Error: $e", Colors.red);
    } finally {
      setState(() => _isUploadingImage = false);
    }
  }

  // নাম পরিবর্তন ফাংশন
  Future<void> _saveProfile() async {
    final name = _nameController.text.trim();
    if (name.isEmpty || name == _originalName) return;

    setState(() => _isSaving = true);
    try {
      final token = await _getToken();
      final response = await http.put(
        Uri.parse("$baseUrl/user/change-full-name"),
        headers: {"Content-Type": "application/json", "Authorization": "Bearer $token"},
        body: jsonEncode({"full_name": name}),
      );

      if (response.statusCode == 200) {
        _showSnack("Name updated successfully", Colors.green);
        await _fetchProfile();
      } else {
        _showSnack("Update failed", Colors.red);
      }
    } catch (e) {
      _showSnack("Something went wrong", Colors.red);
    } finally {
      setState(() => _isSaving = false);
    }
  }

  Widget _label(String text, Color color) => Padding(
    padding: EdgeInsets.only(bottom: 6.h),
    child: Text(text, style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13, color: color)),
  );

  Widget _textField(TextEditingController ctrl, String hint, {bool readOnly = false, required Color bg, required bool isDark}) {
    return TextFormField(
      controller: ctrl,
      readOnly: readOnly,
      style: GoogleFonts.poppins(fontSize: 14, color: isDark ? Colors.white : Colors.black87),
      decoration: InputDecoration(
        filled: true,
        fillColor: bg,
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r), borderSide: BorderSide.none),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        suffixIcon: readOnly ? const Icon(Icons.lock_outline, size: 16, color: Colors.grey) : null,
      ),
    );
  }

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: color));
  }

  Widget _buildError() => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(_errorMsg ?? "An error occurred"),
        TextButton(onPressed: _fetchProfile, child: const Text("Retry"))
      ],
    ),
  );
}
