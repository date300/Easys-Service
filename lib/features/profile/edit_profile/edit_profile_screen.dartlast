import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  static const Color skyBlue = Color(0xFF29B6F6);

  // ✅ Base URL — API base
  static const String baseUrl = "https://easy.ltcminematrix.com/api";

  // ✅ Static file base (server.js এ app.use(express.static("public")) আছে,
  //    কিন্তু uploads ফোল্ডার public এর বাইরে তাই সরাসরি /uploads দিয়ে serve করতে হবে)
  //    নিচে _getProfileImageUrl() দেখুন
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

  // ✅ GET /api/user/profile
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
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['status'] == 'success') {
        final user = data['user'];
        setState(() {
          _nameController.text = user['full_name'] ?? '';
          _mobileController.text = user['mobile'] ?? '';
          _emailController.text = user['email'] ?? '';
          _referralCodeController.text = user['referral_code'] ?? '';
          _referredByController.text = user['referred_by']?.toString() ?? '';
          _idVerified =
              user['id_verified'] == 1 || user['id_verified'] == true;
          _profilePicture = user['profile_picture'];

          // ✅ last_name_change parse করা
          if (user['last_name_change'] != null) {
            _lastNameChange = DateTime.parse(user['last_name_change']);
          } else {
            _lastNameChange = null;
          }
          _checkNameChangeEligibility();
        });
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

  // ✅ POST /api/user/upload-profile-pic (multipart, field name: profile_picture)
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
      final request = http.MultipartRequest(
        'POST',
        Uri.parse("$baseUrl/user/upload-profile-pic"),
      );

      request.headers['Authorization'] = 'Bearer $token';

      // ✅ field name অবশ্যই 'profile_picture' হতে হবে (multer এ এটাই সেট করা)
      request.files.add(await http.MultipartFile.fromPath(
        'profile_picture',
        pickedFile.path,
      ));

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      final data = jsonDecode(responseBody);

      if (response.statusCode == 200 && data['status'] == 'success') {
        _showSnack("Profile picture updated successfully", Colors.green);
        _fetchProfile(); // নতুন ছবি রিফ্রেশ করতে
      } else {
        _showSnack(data['message'] ?? "Failed to upload image", Colors.red);
      }
    } catch (e) {
      _showSnack("Failed to upload image", Colors.red);
    } finally {
      if (mounted) setState(() => _isUploadingImage = false);
    }
  }

  // ✅ DELETE /api/user/delete-profile-pic
  Future<void> _deleteProfilePicture() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Delete Profile Picture", style: GoogleFonts.poppins()),
        content: Text(
            "Are you sure you want to delete your profile picture?",
            style: GoogleFonts.poppins()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text("Cancel", style: GoogleFonts.poppins()),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child:
                Text("Delete", style: GoogleFonts.poppins(color: Colors.red)),
          ),
        ],
      ),
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
        setState(() => _profilePicture = null);
      } else {
        _showSnack(data['message'] ?? "Failed to delete image", Colors.red);
      }
    } catch (e) {
      _showSnack("Failed to delete image", Colors.red);
    } finally {
      if (mounted) setState(() => _isUploadingImage = false);
    }
  }

  // ✅ PUT /api/user/change-full-name — body: { "full_name": "..." }
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

    setState(() => _isSaving = true);
    try {
      final token = await _getToken();
      final response = await http.put(
        Uri.parse("$baseUrl/user/change-full-name"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "full_name": newName,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['status'] == 'success') {
        _showSnack("Full name updated successfully", Colors.green);
        _fetchProfile(); // last_name_change রিফ্রেশ করতে
      } else {
        _showSnack(data['message'] ?? "Update failed", Colors.red);
      }
    } catch (_) {
      _showSnack("Something went wrong!", Colors.red);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showSnack(String msg, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: color),
    );
  }

  // ✅ সঠিক URL: server.js এ uploads ফোল্ডার serve করতে হলে
  //    express.static("uploads") যোগ করতে হবে অথবা নিচের মতো route করতে হবে।
  //    যদি server.js এ app.use('/uploads', express.static('uploads')) থাকে
  //    তাহলে এই URL কাজ করবে।
  String _getProfileImageUrl() {
    if (_profilePicture == null || _profilePicture!.isEmpty) return "";
    return "$staticBase/uploads/profile_pics/$_profilePicture";
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = _isDesktop(context);
    final isTablet = _isTablet(context);
    final maxW =
        isDesktop ? 520.0 : isTablet ? 540.0 : double.infinity;

    return Container(
      color: Colors.white,
      child: _isLoading
          ? const Center(child: CircularProgressIndicator(color: skyBlue))
          : _errorMsg != null
              ? _buildError()
              : SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                      horizontal: isTablet ? 40 : isDesktop ? 32 : 24.w,
                      vertical: 28.h),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: maxW),
                      child: _buildForm(context),
                    ),
                  ),
                ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 50),
          const SizedBox(height: 12),
          Text(_errorMsg!, style: GoogleFonts.poppins(color: Colors.red)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _fetchProfile,
            style: ElevatedButton.styleFrom(backgroundColor: skyBlue),
            child:
                Text("Retry", style: GoogleFonts.poppins(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildForm(BuildContext ctx) {
    final isDesktop = _isDesktop(ctx);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Profile Picture Section ──
        Center(
          child: Column(
            children: [
              Stack(
                children: [
                  Container(
                    width: isDesktop ? 120 : 100.w,
                    height: isDesktop ? 120 : 100.w,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      shape: BoxShape.circle,
                      border: Border.all(color: skyBlue, width: 3),
                      image: _profilePicture != null
                          ? DecorationImage(
                              image: NetworkImage(_getProfileImageUrl()),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: _profilePicture == null
                        ? Icon(Icons.person,
                            size: isDesktop ? 60 : 50.w,
                            color: Colors.grey)
                        : null,
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
                        child: const Icon(Icons.camera_alt,
                            color: Colors.white, size: 20),
                      ),
                    ),
                  ),
                ],
              ),
              if (_profilePicture != null) ...[
                SizedBox(height: 8.h),
                TextButton.icon(
                  onPressed: _isUploadingImage ? null : _deleteProfilePicture,
                  icon: const Icon(Icons.delete_outline,
                      color: Colors.red, size: 18),
                  label: Text(
                    "Remove Photo",
                    style:
                        GoogleFonts.poppins(color: Colors.red, fontSize: 12),
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

        // ── Full Name ──
        _label(ctx, "Full Name"),
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
                const Icon(Icons.info_outline,
                    color: Colors.orange, size: 18),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    _nameChangeMessage!,
                    style: GoogleFonts.poppins(
                        color: Colors.orange, fontSize: 12),
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
        ),
        _gap(ctx),

        // ── Mobile (read-only) ──
        _label(ctx, "Mobile Number"),
        _field(ctx, _mobileController, "Enter your mobile number",
            keyboardType: TextInputType.phone, readOnly: true),
        _gap(ctx),

        // ── Email (read-only) ──
        _label(ctx, "Email Address"),
        _field(ctx, _emailController, "Email", readOnly: true),
        _gap(ctx),

        // ── Referral Code (read-only) ──
        _label(ctx, "Your Referral Code"),
        _field(ctx, _referralCodeController, "Referral code",
            readOnly: true),
        _gap(ctx),

        // ── Referred By (read-only, শুধু থাকলে দেখাবে) ──
        if (_referredByController.text.isNotEmpty) ...[
          _label(ctx, "Referred By"),
          _field(ctx, _referredByController, "Referred by", readOnly: true),
          _gap(ctx),
        ],

        // ── ID Verified Badge ──
        Container(
          padding:
              EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
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
                    fontSize: _fs(ctx, 13, 13, 14)),
              ),
            ],
          ),
        ),

        SizedBox(height: isDesktop ? 40 : 40.h),

        // ── Save Button ──
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
                    disabledBackgroundColor: Colors.grey[300],
                    shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(isDesktop ? 14 : 14.r)),
                    elevation: 0,
                  ),
                  child: Text("Save Changes",
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: _fs(ctx, 15, 16, 17))),
                ),
        ),
        SizedBox(height: 80.h),
      ],
    );
  }

  void _showImageOptions() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Container(
        padding: EdgeInsets.all(20.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Profile Picture",
              style: GoogleFonts.poppins(
                  fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20.h),
            ListTile(
              leading: const Icon(Icons.photo_library, color: skyBlue),
              title:
                  Text("Choose from Gallery", style: GoogleFonts.poppins()),
              onTap: () {
                Navigator.pop(ctx);
                _pickAndUploadImage();
              },
            ),
            if (_profilePicture != null)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: Text("Remove Photo",
                    style: GoogleFonts.poppins(color: Colors.red)),
                onTap: () {
                  Navigator.pop(ctx);
                  _deleteProfilePicture();
                },
              ),
            ListTile(
              leading: const Icon(Icons.cancel, color: Colors.grey),
              title: Text("Cancel", style: GoogleFonts.poppins()),
              onTap: () => Navigator.pop(ctx),
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(BuildContext ctx, String text) => Padding(
        padding: EdgeInsets.only(bottom: 6.h),
        child: Text(text,
            style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: _fs(ctx, 13, 13, 14),
                color: Colors.black87)),
      );

  Widget _gap(BuildContext ctx) =>
      SizedBox(height: _isDesktop(ctx) ? 14 : 14.h);

  Widget _field(
    BuildContext ctx,
    TextEditingController controller,
    String hint, {
    TextInputType keyboardType = TextInputType.text,
    bool readOnly = false,
  }) {
    final isDesktop = _isDesktop(ctx);
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      readOnly: readOnly,
      style: GoogleFonts.poppins(
          fontSize: _fs(ctx, 13, 13, 14),
          color: readOnly ? Colors.black45 : Colors.black87),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.poppins(
            color: Colors.black38, fontSize: _fs(ctx, 13, 13, 14)),
        filled: true,
        fillColor:
            readOnly ? const Color(0xFFEEEEEE) : const Color(0xFFF3F4F6),
        contentPadding: EdgeInsets.symmetric(
            horizontal: isDesktop ? 16 : 16.w,
            vertical: isDesktop ? 15 : 14.h),
        border: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(isDesktop ? 12 : 12.r),
          borderSide: BorderSide.none,
        ),
        suffixIcon: readOnly
            ? const Icon(Icons.lock_outline_rounded,
                color: Colors.black26, size: 18)
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
