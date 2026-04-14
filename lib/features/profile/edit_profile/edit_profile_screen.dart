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

  // API থেকে প্রোফাইল ডাটা ফেচ করা
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
          
          // রেসপন্স নাল হলে 'N/A' বা খালি দেখানো
          _referralCodeController.text = user['referral_code'] ?? 'Not Assigned';
          _referredByController.text = user['referred_by']?.toString() ?? 'None';
          
          _idVerified = user['id_verified'] == 1 || user['id_verified'] == true;
          _profilePicture = user['profile_picture'];

          if (user['last_name_change'] != null) {
            _lastNameChange = DateTime.parse(user['last_name_change']);
          }
          _checkNameChangeEligibility();
        });
      } else {
        setState(() => _errorMsg = data['message'] ?? 'Failed to load profile');
      }
    } catch (e) {
      setState(() => _errorMsg = "Something went wrong! Check connection.");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // প্রোফাইল পিকচার এর URL জেনারেট করা (FIXED)
  String _getProfileImageUrl() {
    if (_profilePicture == null || _profilePicture!.isEmpty) return "";
    
    String finalUrl = _profilePicture!;
    // যদি এপিআই থেকে ফুল ইউআরএল না আসে তবে বেজ ইউআরএল যোগ হবে
    if (!finalUrl.startsWith('http')) {
      finalUrl = "$staticBase/public/uploads/profile_pics/$finalUrl";
    }
    
    // ক্যাশ সমস্যা এড়াতে টাইমস্ট্যাম্প যোগ করা হয়েছে
    return "$finalUrl?v=$_imageKey";
  }

  void _checkNameChangeEligibility() {
    if (_lastNameChange == null) {
      _canChangeName = true;
      return;
    }
    final now = DateTime.now();
    final difference = now.difference(_lastNameChange!);
    if (difference.inDays < 15) {
      _canChangeName = false;
      _nameChangeMessage = "You can change your name again in ${15 - difference.inDays} days";
    } else {
      _canChangeName = true;
    }
  }

  Future<void> _pickAndUploadImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 500,
        maxHeight: 500,
        imageQuality: 80,
      );

      if (pickedFile == null) return;

      setState(() => _isUploadingImage = true);
      final token = await _getToken();
      final uri = Uri.parse("$baseUrl/user/upload-profile-pic");
      final request = http.MultipartRequest('POST', uri);
      request.headers['Authorization'] = 'Bearer $token';

      final bytes = await pickedFile.readAsBytes();
      request.files.add(http.MultipartFile.fromBytes(
        'profile_picture',
        bytes,
        filename: pickedFile.name,
        contentType: MediaType('image', 'jpeg'),
      ));

      final streamedResponse = await request.send();
      if (streamedResponse.statusCode == 200) {
        _imageKey = DateTime.now().millisecondsSinceEpoch; // ইমেজ কি আপডেট
        await _fetchProfile();
        _showSnack("Profile picture updated", Colors.green);
      } else {
        _showSnack("Upload failed", Colors.red);
      }
    } catch (e) {
      _showSnack("Error: $e", Colors.red);
    } finally {
      setState(() => _isUploadingImage = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? const Color(0xFF121212) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: skyBlue))
          : _errorMsg != null
              ? _buildError(isDark)
              : SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
                  child: Column(
                    children: [
                      _buildAvatarSection(isDark),
                      SizedBox(height: 30.h),
                      _buildFormFields(textColor, isDark),
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
            width: 110.w,
            height: 110.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: skyBlue, width: 3),
              color: isDark ? Colors.grey[900] : Colors.grey[200],
            ),
            child: ClipOval(
              child: _profilePicture != null && _profilePicture!.isNotEmpty
                  ? Image.network(
                      _getProfileImageUrl(),
                      key: ValueKey(_imageKey),
                      fit: BoxFit.cover,
                      errorBuilder: (c, e, s) => Icon(Icons.person, size: 50.w, color: Colors.grey),
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return const Center(child: CircularProgressIndicator(strokeWidth: 2));
                      },
                    )
                  : Icon(Icons.person, size: 50.w, color: Colors.grey),
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
            bottom: 0,
            right: 0,
            child: GestureDetector(
              onTap: _pickAndUploadImage,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(color: skyBlue, shape: BoxShape.circle),
                child: const Icon(Icons.camera_alt, color: Colors.white, size: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormFields(Color textColor, bool isDark) {
    final fieldBg = isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF3F4F6);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label("Full Name", textColor),
        _field(_nameController, "Name", readOnly: !_canChangeName, bg: fieldBg, isDark: isDark),
        if (!_canChangeName) 
          Padding(
            padding: EdgeInsets.only(top: 5.h),
            child: Text(_nameChangeMessage ?? "", style: const TextStyle(color: Colors.orange, fontSize: 11)),
          ),
        SizedBox(height: 15.h),
        _label("Mobile", textColor),
        _field(_mobileController, "Mobile", readOnly: true, bg: fieldBg, isDark: isDark),
        SizedBox(height: 15.h),
        _label("Email", textColor),
        _field(_emailController, "Email", readOnly: true, bg: fieldBg, isDark: isDark),
        SizedBox(height: 15.h),
        _label("Referral Code", textColor),
        _field(_referralCodeController, "N/A", readOnly: true, bg: fieldBg, isDark: isDark),
        SizedBox(height: 15.h),
        _label("Referred By", textColor),
        _field(_referredByController, "None", readOnly: true, bg: fieldBg, isDark: isDark),
        SizedBox(height: 30.h),
        SizedBox(
          width: double.infinity,
          height: 50.h,
          child: ElevatedButton(
            onPressed: _canChangeName && !_isSaving ? _saveProfile : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: skyBlue,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
            ),
            child: _isSaving 
              ? const CircularProgressIndicator(color: Colors.white) 
              : Text("Save Changes", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white)),
          ),
        ),
      ],
    );
  }

  // প্রোফাইল নাম আপডেট করা
  Future<void> _saveProfile() async {
    final newName = _nameController.text.trim();
    if (newName.isEmpty || newName == _originalName) return;

    setState(() => _isSaving = true);
    try {
      final token = await _getToken();
      final response = await http.put(
        Uri.parse("$baseUrl/user/change-full-name"),
        headers: {"Content-Type": "application/json", "Authorization": "Bearer $token"},
        body: jsonEncode({"full_name": newName}),
      );

      if (response.statusCode == 200) {
        _showSnack("Name updated successfully", Colors.green);
        await _fetchProfile();
      } else {
        _showSnack("Failed to update", Colors.red);
      }
    } catch (e) {
      _showSnack("Error occurred", Colors.red);
    } finally {
      setState(() => _isSaving = false);
    }
  }

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: color));
  }

  Widget _label(String text, Color color) => Padding(
    padding: EdgeInsets.only(bottom: 5.h),
    child: Text(text, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 13, color: color)),
  );

  Widget _field(TextEditingController controller, String hint, {bool readOnly = false, required Color bg, required bool isDark}) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      style: GoogleFonts.poppins(fontSize: 14, color: isDark ? Colors.white : Colors.black),
      decoration: InputDecoration(
        filled: true,
        fillColor: bg,
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r), borderSide: BorderSide.none),
        contentPadding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 14.h),
        suffixIcon: readOnly ? const Icon(Icons.lock_outline, size: 16, color: Colors.grey) : null,
      ),
    );
  }

  Widget _buildError(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(_errorMsg ?? "Error", style: TextStyle(color: isDark ? Colors.white : Colors.black)),
          TextButton(onPressed: _fetchProfile, child: const Text("Retry")),
        ],
      ),
    );
  }
}
