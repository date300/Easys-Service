import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  static const Color skyBlue = Color(0xFF29B6F6);
  static const String baseUrl = "https://easy.ltcminematrix.com/api";

  final _nameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _emailController = TextEditingController();
  final _referralCodeController = TextEditingController();
  final _referredByController = TextEditingController();

  bool _isLoading = true;
  bool _isSaving = false;
  bool _idVerified = false;
  String? _errorMsg;

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

      if (data['status'] == 'success') {
        final user = data['user'];
        _nameController.text = user['full_name'] ?? '';
        _mobileController.text = user['mobile'] ?? '';
        _emailController.text = user['email'] ?? '';
        _referralCodeController.text = user['referral_code'] ?? '';
        _referredByController.text = user['referred_by']?.toString() ?? '';
        _idVerified = user['id_verified'] == 1 || user['id_verified'] == true;
      } else {
        _errorMsg = data['message'] ?? 'Failed to load profile';
      }
    } catch (e) {
      _errorMsg = "সার্ভার সংযোগ ব্যর্থ হয়েছে!";
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnack(String msg, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg), backgroundColor: color));
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = _isDesktop(context);
    final isTablet = _isTablet(context);
    final maxW = isDesktop ? 520.0 : isTablet ? 540.0 : double.infinity;

    return Scaffold(
      backgroundColor: skyBlue,
      body: Column(
        children: [
          // ── Top Blue Header ─────────────────────────────────────
          SafeArea(
            bottom: false,
            child: SizedBox(
              height: isDesktop ? 180 : isTablet ? 190 : 180.h,
              child: Stack(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: 8.w, vertical: 8.h),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_rounded,
                              color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                        Text(
                          'Edit Profile',
                          style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: _fs(context, 20, 22, 24)),
                        ),
                        const Spacer(),
                        if (_idVerified)
                          Padding(
                            padding: EdgeInsets.only(right: 16.w),
                            child: Row(
                              children: [
                                const Icon(Icons.verified_rounded,
                                    color: Colors.white, size: 18),
                                SizedBox(width: 4.w),
                                Text("Verified",
                                    style: GoogleFonts.poppins(
                                        color: Colors.white,
                                        fontSize: 12)),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                  Center(
                    child: Padding(
                      padding: EdgeInsets.only(top: 30.h),
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: isDesktop ? 50 : isTablet ? 48 : 45.r,
                            backgroundColor: Colors.white,
                            child: Icon(Icons.person_rounded,
                                color: skyBlue,
                                size: isDesktop
                                    ? 55
                                    : isTablet
                                        ? 52
                                        : 50.sp),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle),
                              padding: const EdgeInsets.all(4),
                              child: Icon(Icons.camera_alt_rounded,
                                  color: skyBlue, size: 18),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                      top: 30.h,
                      left: 30.w,
                      child: _dot(10, Colors.white.withOpacity(0.3))),
                  Positioned(
                      top: 60.h,
                      right: 40.w,
                      child: _dot(8, Colors.white.withOpacity(0.2))),
                ],
              ),
            ),
          ),

          // ── White Card ──────────────────────────────────────────
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(32.r),
                  topRight: Radius.circular(32.r),
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(32.r),
                  topRight: Radius.circular(32.r),
                ),
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(color: skyBlue))
                    : _errorMsg != null
                        ? _buildError()
                        : SingleChildScrollView(
                            padding: EdgeInsets.symmetric(
                                horizontal: isTablet
                                    ? 40
                                    : isDesktop
                                        ? 32
                                        : 24.w,
                                vertical: 28.h),
                            child: Center(
                              child: ConstrainedBox(
                                constraints:
                                    BoxConstraints(maxWidth: maxW),
                                child: _buildForm(context),
                              ),
                            ),
                          ),
              ),
            ),
          ),
        ],
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
          Text(_errorMsg!,
              style: GoogleFonts.poppins(color: Colors.red)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _fetchProfile,
            style: ElevatedButton.styleFrom(backgroundColor: skyBlue),
            child: Text("Retry",
                style:
                    GoogleFonts.poppins(color: Colors.white)),
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
        _label(ctx, "Full Name"),
        _field(ctx, _nameController, "Enter your full name",
            keyboardType: TextInputType.name),
        _gap(ctx),

        _label(ctx, "Mobile Number"),
        _field(ctx, _mobileController, "Enter your mobile number",
            keyboardType: TextInputType.phone),
        _gap(ctx),

        // Email — read only
        _label(ctx, "Email Address"),
        _field(ctx, _emailController, "Email",
            readOnly: true),
        _gap(ctx),

        // Referral Code — read only
        _label(ctx, "Your Referral Code"),
        _field(ctx, _referralCodeController, "Referral code",
            readOnly: true),
        _gap(ctx),

        // Referred By — read only
        if (_referredByController.text.isNotEmpty) ...[
          _label(ctx, "Referred By"),
          _field(ctx, _referredByController, "Referred by",
              readOnly: true),
          _gap(ctx),
        ],

        // ID Verified badge
        Container(
          padding: EdgeInsets.symmetric(
              horizontal: 16.w, vertical: 12.h),
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
                _idVerified
                    ? "ID Verified"
                    : "ID Not Verified",
                style: GoogleFonts.poppins(
                    color: _idVerified ? Colors.green : Colors.orange,
                    fontWeight: FontWeight.w600,
                    fontSize: _fs(ctx, 13, 13, 14)),
              ),
            ],
          ),
        ),

        SizedBox(height: isDesktop ? 30 : 30.h),

        SizedBox(
          width: double.infinity,
          height: isDesktop ? 52 : 52.h,
          child: _isSaving
              ? const Center(
                  child: CircularProgressIndicator(color: skyBlue))
              : ElevatedButton(
                  onPressed: _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: skyBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                            isDesktop ? 14 : 14.r)),
                    elevation: 0,
                  ),
                  child: Text("Save Changes",
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: _fs(ctx, 15, 16, 17))),
                ),
        ),
        SizedBox(height: isDesktop ? 10 : 10.h),
      ],
    );
  }

  Future<void> _saveProfile() async {
    setState(() => _isSaving = true);
    try {
      final token = await _getToken();
      final response = await http.put(
        Uri.parse("$baseUrl/user/profile"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "full_name": _nameController.text.trim(),
          "mobile": _mobileController.text.trim(),
        }),
      );

      final data = jsonDecode(response.body);
      if (data['status'] == 'success') {
        _showSnack("Profile updated successfully", Colors.green);
        if (mounted) Navigator.pop(context);
      } else {
        _showSnack(data['message'] ?? "Update failed", Colors.red);
      }
    } catch (_) {
      _showSnack("সার্ভার সংযোগ ব্যর্থ হয়েছে!", Colors.red);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
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
        fillColor: readOnly
            ? const Color(0xFFEEEEEE)
            : const Color(0xFFF3F4F6),
        contentPadding: EdgeInsets.symmetric(
            horizontal: isDesktop ? 16 : 16.w,
            vertical: isDesktop ? 15 : 14.h),
        border: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(isDesktop ? 12 : 12.r),
          borderSide: BorderSide.none,
        ),
        suffixIcon: readOnly
            ? Icon(Icons.lock_outline_rounded,
                color: Colors.black26, size: 18)
            : null,
      ),
    );
  }

  Widget _dot(double size, Color color) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      );

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
