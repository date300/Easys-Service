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

  // FIX: Cache busting এর জন্য timestamp রাখা হচ্ছে
  int _imageKey = 0;

  final ImagePicker _picker = ImagePicker();

  bool _isDesktop(BuildContext ctx) => MediaQuery.of(ctx).size.width >= 1100;
  bool _isTablet(BuildContext ctx) =>
      MediaQuery.of(ctx).size.width >= 600 &&
      MediaQuery.of(ctx).size.width < 1100;

  double _fs(BuildContext ctx, double m, double t, double d) {
    if (_isDesktop(ctx)) return d;
    if (_isTablet(ctx)) return t;
    return m;
  }

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  Future<void> _fetchProfile() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMsg = null;
    });

    try {
      final token = await _getToken();
      final response = await http
          .get(
            Uri.parse("$baseUrl/user/profile"),
            headers: {
              "Content-Type": "application/json",
              "Authorization": "Bearer $token",
            },
          )
          .timeout(const Duration(seconds: 15));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['status'] == 'success') {
        final user = data['user'];
        setState(() {
          _originalName = user['full_name'] ?? '';
          _nameController.text = _originalName;
          _mobileController.text = user['mobile'] ?? '';
          _emailController.text = user['email'] ?? '';
          _referralCodeController.text = user['referral_code'] ?? '';
          _referredByController.text = user['referred_by']?.toString() ?? '';
          _idVerified = user['id_verified'] == 1 || user['id_verified'] == true;
          _profilePicture = user['profile_picture'];

          // FIX: নতুন প্রোফাইল লোড হলে imageKey update করো যাতে cache bust হয়
          _imageKey = DateTime.now().millisecondsSinceEpoch;

          if (user['last_name_change'] != null) {
            _lastNameChange = DateTime.parse(user['last_name_change']);
          } else {
            _lastNameChange = null;
          }
          _checkNameChangeEligibility();
        });

        // Debug: URL লগ করো
        debugPrint("Profile picture URL: ${_getProfileImageUrl()}");
      } else {
        setState(() {
          _errorMsg = data['message'] ?? 'Failed to load profile';
        });
      }
    } catch (e) {
      setState(() {
        _errorMsg = "Something went wrong!";
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _checkNameChangeEligibility() {
    if (_lastNameChange == null) {
      _canChangeName = true;
      _nameChangeMessage = null;
      return;
    }
    final now = DateTime.now();
    final difference = now.difference(_lastNameChange!);
    final daysRemaining = 15 - difference.inDays;

    if (difference.inDays < 15) {
      _canChangeName = false;
      _nameChangeMessage =
          "You can change your name again in $daysRemaining days";
    } else {
      _canChangeName = true;
      _nameChangeMessage = null;
    }
  }

  Future<void> _pickAndUploadImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (pickedFile == null) return;

      setState(() => _isUploadingImage = true);

      final token = await _getToken();

      if (token == null) {
        _showSnack("Authentication error. Please login again.", Colors.red);
        return;
      }

      final uri = Uri.parse("$baseUrl/user/upload-profile-pic");
      final request = http.MultipartRequest('POST', uri);

      request.headers['Authorization'] = 'Bearer $token';

      final bytes = await pickedFile.readAsBytes();
      final fileName = pickedFile.name;
      final ext = fileName.split('.').last.toLowerCase();

      String mimeSubtype = 'jpeg';
      if (ext == 'png') mimeSubtype = 'png';
      if (ext == 'gif') mimeSubtype = 'gif';
      if (ext == 'webp') mimeSubtype = 'webp';

      final multipartFile = http.MultipartFile.fromBytes(
        'profile_picture',
        bytes,
        filename: fileName,
        contentType: MediaType('image', mimeSubtype),
      );
      request.files.add(multipartFile);

      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception("Request timed out");
        },
      );

      final responseBody = await streamedResponse.stream.bytesToString();

      debugPrint("Upload Status: ${streamedResponse.statusCode}");
      debugPrint("Upload Body: $responseBody");

      final data = jsonDecode(responseBody);

      if (streamedResponse.statusCode == 200 && data['status'] == 'success') {
        _showSnack("Profile picture updated successfully", Colors.green);
        // FIX: আপলোড সফল হলে profile আবার fetch করো, imageKey update হবে
        await _fetchProfile();
      } else {
        _showSnack(data['message'] ?? "Failed to upload image", Colors.red);
      }
    } catch (e) {
      debugPrint("Upload Exception: $e");
      _showSnack("Failed to upload: ${e.toString()}", Colors.red);
    } finally {
      if (mounted) setState(() => _isUploadingImage = false);
    }
  }

  Future<void> _deleteProfilePicture() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        final dialogBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
        final textColor = isDark ? Colors.white : Colors.black;

        return AlertDialog(
          backgroundColor: dialogBg,
          title: Text(
            "Delete Profile Picture",
            style: GoogleFonts.poppins(color: textColor),
          ),
          content: Text(
            "Are you sure you want to delete your profile picture?",
            style: GoogleFonts.poppins(
                color: isDark ? Colors.white70 : Colors.black87),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(
                "Cancel",
                style: GoogleFonts.poppins(
                    color: isDark ? Colors.grey : Colors.grey.shade600),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(
                "Delete",
                style: GoogleFonts.poppins(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    setState(() => _isUploadingImage = true);

    try {
      final token = await _getToken();
      final response = await http.delete(
        Uri.parse("$baseUrl/user/delete-profile-pic"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['status'] == 'success') {
        _showSnack("Profile picture deleted successfully", Colors.green);
        // FIX: delete হলে _profilePicture null করো এবং imageKey reset করো
        setState(() {
          _profilePicture = null;
          _imageKey = 0;
        });
      } else {
        _showSnack(data['message'] ?? "Failed to delete image", Colors.red);
      }
    } catch (e) {
      debugPrint("Delete Exception: $e");
      _showSnack("Failed to delete image", Colors.red);
    } finally {
      if (mounted) setState(() => _isUploadingImage = false);
    }
  }

  Future<void> _saveProfile() async {
    if (!_canChangeName) {
      _showSnack(
          _nameChangeMessage ?? "You cannot change name now", Colors.orange);
      return;
    }

    final newName = _nameController.text.trim();
    if (newName.isEmpty) {
      _showSnack("Name cannot be empty", Colors.red);
      return;
    }

    if (newName == _originalName) {
      _showSnack("No changes made", Colors.orange);
      return;
    }

    setState(() => _isSaving = true);
    try {
      final token = await _getToken();
      final response = await http
          .put(
            Uri.parse("$baseUrl/user/change-full-name"),
            headers: {
              "Content-Type": "application/json",
              "Authorization": "Bearer $token",
            },
            body: jsonEncode({"full_name": newName}),
          )
          .timeout(const Duration(seconds: 15));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['status'] == 'success') {
        _showSnack("Full name updated successfully", Colors.green);
        await _fetchProfile();
      } else {
        _showSnack(data['message'] ?? "Update failed", Colors.red);
      }
    } catch (e) {
      debugPrint("Save Exception: $e");
      _showSnack("Something went wrong!", Colors.red);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showSnack(String msg, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          msg,
          style: GoogleFonts.poppins(color: Colors.white),
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.r),
        ),
      ),
    );
  }

String _getProfileImageUrl() {
  if (_profilePicture == null || _profilePicture!.isEmpty) return "";
  if (_profilePicture!.startsWith('http')) return _profilePicture!;
  return "$staticBase/uploads/profile_pics/$_profilePicture?v=$_imageKey";
}
  @override
  Widget build(BuildContext context) {
    final isDesktop = _isDesktop(context);
    final isTablet = _isTablet(context);
    final maxW = isDesktop ? 520.0 : isTablet ? 540.0 : double.infinity;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? const Color(0xFF121212) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subTextColor = isDark ? Colors.grey.shade400 : Colors.black45;
    final hintColor = isDark ? Colors.grey.shade500 : Colors.black38;
    final fieldBgReadOnly =
        isDark ? const Color(0xFF2C2C2C) : const Color(0xFFEEEEEE);
    final fieldBgEditable =
        isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF3F4F6);
    final avatarBg = isDark ? const Color(0xFF2C2C2C) : Colors.grey[200];
    final avatarIconColor = isDark ? Colors.grey.shade400 : Colors.grey;

    return Container(
      color: backgroundColor,
      child: _isLoading
          ? const Center(child: CircularProgressIndicator(color: skyBlue))
          : _errorMsg != null
              ? _buildError(isDark)
              : SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: isTablet ? 40 : isDesktop ? 32 : 24.w,
                    vertical: 28.h,
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: maxW),
                      child: _buildForm(
                          context,
                          isDark,
                          textColor,
                          subTextColor,
                          hintColor,
                          fieldBgReadOnly,
                          fieldBgEditable,
                          avatarBg,
                          avatarIconColor),
                    ),
                  ),
                ),
    );
  }

  Widget _buildError(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 50),
          const SizedBox(height: 12),
          Text(
            _errorMsg!,
            style: GoogleFonts.poppins(
              color: isDark ? Colors.white : Colors.red,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _fetchProfile,
            style: ElevatedButton.styleFrom(backgroundColor: skyBlue),
            child: Text(
              "Retry",
              style: GoogleFonts.poppins(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForm(
    BuildContext ctx,
    bool isDark,
    Color textColor,
    Color subTextColor,
    Color hintColor,
    Color fieldBgReadOnly,
    Color fieldBgEditable,
    Color? avatarBg,
    Color avatarIconColor,
  ) {
    final isDesktop = _isDesktop(ctx);
    final double avatarSize = isDesktop ? 120 : 100.w;
    final double iconSize = isDesktop ? 60 : 50.w;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Profile Picture Section
        Center(
          child: Column(
            children: [
              Stack(
                children: [
                  Container(
                    width: avatarSize,
                    height: avatarSize,
                    decoration: BoxDecoration(
                      color: avatarBg,
                      shape: BoxShape.circle,
                      border: Border.all(color: skyBlue, width: 3),
                    ),
                    child: ClipOval(
                      child: _profilePicture != null
                          ? Image.network(
                              // FIX: _imageKey দিয়ে ValueKey ব্যবহার করো
                              // এতে প্রতিবার নতুন ছবি আপলোডের পর cache bust হয়
                              // এবং Flutter নতুন করে ছবি load করে
                              _getProfileImageUrl(),
                              key: ValueKey(_imageKey),
                              width: avatarSize,
                              height: avatarSize,
                              fit: BoxFit.cover,
                              // FIX: headers দিয়ে cache disable করো
                              headers: const {
                                'Cache-Control': 'no-cache',
                                'Pragma': 'no-cache',
                              },
                              errorBuilder: (context, error, stackTrace) {
                                debugPrint("Image load error: $error");
                                return Icon(
                                  Icons.person,
                                  size: iconSize,
                                  color: avatarIconColor,
                                );
                              },
                              loadingBuilder: (_, child, progress) {
                                if (progress == null) return child;
                                return Center(
                                  child: CircularProgressIndicator(
                                    color: skyBlue,
                                    value: progress.expectedTotalBytes != null
                                        ? progress.cumulativeBytesLoaded /
                                            progress.expectedTotalBytes!
                                        : null,
                                  ),
                                );
                              },
                            )
                          : Icon(
                              Icons.person,
                              size: iconSize,
                              color: avatarIconColor,
                            ),
                    ),
                  ),
                  if (_isUploadingImage)
                    Positioned.fill(
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child:
                              CircularProgressIndicator(color: Colors.white),
                        ),
                      ),
                    ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: _isUploadingImage ? null : _showImageOptions,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: skyBlue,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              if (_profilePicture != null) ...[
                SizedBox(height: 8.h),
                TextButton.icon(
                  onPressed: _isUploadingImage ? null : _deleteProfilePicture,
                  icon: const Icon(
                    Icons.delete_outline,
                    color: Colors.red,
                    size: 18,
                  ),
                  label: Text(
                    "Remove Photo",
                    style: GoogleFonts.poppins(
                      color: Colors.red,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),

        SizedBox(height: 24.h),

        Text(
          "Edit Profile",
          style: GoogleFonts.poppins(
            fontSize: _fs(ctx, 22, 24, 26),
            fontWeight: FontWeight.bold,
            color: skyBlue,
          ),
        ),
        SizedBox(height: 20.h),

        // Full Name
        _label(ctx, "Full Name", textColor),
        if (!_canChangeName && _nameChangeMessage != null) ...[
          Container(
            padding: EdgeInsets.all(12.w),
            margin: EdgeInsets.only(bottom: 8.h),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: Colors.orange.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: Colors.orange, size: 18),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    _nameChangeMessage!,
                    style: GoogleFonts.poppins(
                      color: Colors.orange,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
        _field(
          ctx,
          _nameController,
          "Enter your full name",
          keyboardType: TextInputType.name,
          readOnly: !_canChangeName,
          textColor: textColor,
          subTextColor: subTextColor,
          hintColor: hintColor,
          fieldBgReadOnly: fieldBgReadOnly,
          fieldBgEditable: fieldBgEditable,
        ),
        _gap(ctx),

        // Mobile
        _label(ctx, "Mobile Number", textColor),
        _field(
          ctx,
          _mobileController,
          "Enter your mobile number",
          keyboardType: TextInputType.phone,
          readOnly: true,
          textColor: textColor,
          subTextColor: subTextColor,
          hintColor: hintColor,
          fieldBgReadOnly: fieldBgReadOnly,
          fieldBgEditable: fieldBgEditable,
        ),
        _gap(ctx),

        // Email
        _label(ctx, "Email Address", textColor),
        _field(
          ctx,
          _emailController,
          "Email",
          readOnly: true,
          textColor: textColor,
          subTextColor: subTextColor,
          hintColor: hintColor,
          fieldBgReadOnly: fieldBgReadOnly,
          fieldBgEditable: fieldBgEditable,
        ),
        _gap(ctx),

        // Referral Code
        _label(ctx, "Your Referral Code", textColor),
        _field(
          ctx,
          _referralCodeController,
          "Referral code",
          readOnly: true,
          textColor: textColor,
          subTextColor: subTextColor,
          hintColor: hintColor,
          fieldBgReadOnly: fieldBgReadOnly,
          fieldBgEditable: fieldBgEditable,
        ),
        _gap(ctx),

        // Referred By
        if (_referredByController.text.isNotEmpty) ...[
          _label(ctx, "Referred By", textColor),
          _field(
            ctx,
            _referredByController,
            "Referred by",
            readOnly: true,
            textColor: textColor,
            subTextColor: subTextColor,
            hintColor: hintColor,
            fieldBgReadOnly: fieldBgReadOnly,
            fieldBgEditable: fieldBgEditable,
          ),
          _gap(ctx),
        ],

        // ID Verified Badge
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: _idVerified
                ? Colors.green.withOpacity(0.1)
                : Colors.orange.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Row(
            children: [
              Icon(
                _idVerified
                    ? Icons.verified_user_rounded
                    : Icons.warning_amber_rounded,
                color: _idVerified ? Colors.green : Colors.orange,
                size: 22,
              ),
              SizedBox(width: 10.w),
              Text(
                _idVerified ? "ID Verified" : "ID Not Verified",
                style: GoogleFonts.poppins(
                  color: _idVerified ? Colors.green : Colors.orange,
                  fontWeight: FontWeight.w600,
                  fontSize: _fs(ctx, 13, 13, 14),
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: isDesktop ? 40 : 40.h),

        // Save Button
        SizedBox(
          width: double.infinity,
          height: isDesktop ? 52 : 52.h,
          child: _isSaving
              ? const Center(
                  child: CircularProgressIndicator(color: skyBlue))
              : ElevatedButton(
                  onPressed: _canChangeName ? _saveProfile : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: skyBlue,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: isDark
                        ? const Color(0xFF333333)
                        : Colors.grey[300],
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(isDesktop ? 14 : 14.r),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    "Save Changes",
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: _fs(ctx, 15, 16, 17),
                    ),
                  ),
                ),
        ),
        SizedBox(height: 80.h),
      ],
    );
  }

  void _showImageOptions() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sheetBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black;

    showModalBottomSheet(
      context: context,
      backgroundColor: sheetBg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      builder: (ctx) => Container(
        padding: EdgeInsets.all(20.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Profile Picture",
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            SizedBox(height: 20.h),
            ListTile(
              leading: const Icon(Icons.photo_library, color: skyBlue),
              title: Text(
                "Choose from Gallery",
                style: GoogleFonts.poppins(color: textColor),
              ),
              onTap: () {
                Navigator.pop(ctx);
                _pickAndUploadImage();
              },
            ),
            if (_profilePicture != null)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: Text(
                  "Remove Photo",
                  style: GoogleFonts.poppins(color: Colors.red),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  _deleteProfilePicture();
                },
              ),
            ListTile(
              leading: Icon(
                Icons.cancel,
                color: isDark ? Colors.grey : Colors.grey.shade600,
              ),
              title: Text(
                "Cancel",
                style: GoogleFonts.poppins(
                    color: isDark ? Colors.grey : Colors.grey.shade600),
              ),
              onTap: () => Navigator.pop(ctx),
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(BuildContext ctx, String text, Color textColor) => Padding(
        padding: EdgeInsets.only(bottom: 6.h),
        child: Text(
          text,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: _fs(ctx, 13, 13, 14),
            color: textColor,
          ),
        ),
      );

  Widget _gap(BuildContext ctx) =>
      SizedBox(height: _isDesktop(ctx) ? 14 : 14.h);

  Widget _field(
    BuildContext ctx,
    TextEditingController controller,
    String hint, {
    TextInputType keyboardType = TextInputType.text,
    bool readOnly = false,
    required Color textColor,
    required Color subTextColor,
    required Color hintColor,
    required Color fieldBgReadOnly,
    required Color fieldBgEditable,
  }) {
    final isDesktop = _isDesktop(ctx);
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      readOnly: readOnly,
      style: GoogleFonts.poppins(
        fontSize: _fs(ctx, 13, 13, 14),
        color: readOnly ? subTextColor : textColor,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.poppins(
          color: hintColor,
          fontSize: _fs(ctx, 13, 13, 14),
        ),
        filled: true,
        fillColor: readOnly ? fieldBgReadOnly : fieldBgEditable,
        contentPadding: EdgeInsets.symmetric(
          horizontal: isDesktop ? 16 : 16.w,
          vertical: isDesktop ? 15 : 14.h,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(isDesktop ? 12 : 12.r),
          borderSide: BorderSide.none,
        ),
        suffixIcon: readOnly
            ? Icon(
                Icons.lock_outline_rounded,
                color: subTextColor,
                size: 18,
              )
            : null,
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _mobileController.dispose();
    _emailController.dispose();
    _referralCodeController.dispose();
    _referredByController.dispose();
    super.dispose();
  }
}
