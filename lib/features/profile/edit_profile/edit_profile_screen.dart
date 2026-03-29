import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  static const Color skyBlue = Color(0xFF29B6F6);

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController(text: "Easy Service User");
  final _emailController = TextEditingController(text: "user@easyservice.com");
  final _mobileController = TextEditingController(text: "");
  final _addressController = TextEditingController(text: "");

  bool _isLoading = false;

  bool _isDesktop(BuildContext ctx) => MediaQuery.of(ctx).size.width >= 1100;
  bool _isTablet(BuildContext ctx) =>
      MediaQuery.of(ctx).size.width >= 600 &&
      MediaQuery.of(ctx).size.width < 1100;

  double _fs(BuildContext ctx, double m, double t, double d) {
    if (_isDesktop(ctx)) return d;
    if (_isTablet(ctx)) return t;
    return m;
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1)); // API call এখানে
    if (!mounted) return;
    setState(() => _isLoading = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text("Profile updated successfully"),
          backgroundColor: Colors.green),
    );
    Navigator.pop(context);
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
                    padding:
                        EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
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
                                size: isDesktop ? 55 : isTablet ? 52 : 50.sp),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              padding: const EdgeInsets.all(4),
                              child: Icon(Icons.camera_alt_rounded,
                                  color: skyBlue, size: 18),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Decorative dots
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
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                      horizontal: isTablet ? 40 : isDesktop ? 32 : 24.w,
                      vertical: 28.h),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: maxW),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _label(context, "Full Name"),
                            _field(context, _nameController, "Enter your full name",
                                keyboardType: TextInputType.name),
                            _gap(context),

                            _label(context, "Email Address"),
                            _field(context, _emailController, "Enter your email",
                                keyboardType: TextInputType.emailAddress),
                            _gap(context),

                            _label(context, "Mobile Number"),
                            _field(context, _mobileController, "Enter your mobile number",
                                keyboardType: TextInputType.phone,
                                optional: true),
                            _gap(context),

                            _label(context, "Address (Optional)"),
                            _field(context, _addressController, "Enter your address",
                                optional: true),

                            SizedBox(height: isDesktop ? 30 : 30.h),

                            SizedBox(
                              width: double.infinity,
                              height: isDesktop ? 52 : 52.h,
                              child: _isLoading
                                  ? const Center(
                                      child: CircularProgressIndicator(
                                          color: skyBlue))
                                  : ElevatedButton(
                                      onPressed: _saveProfile,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: skyBlue,
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(
                                                    isDesktop ? 14 : 14.r)),
                                        elevation: 0,
                                      ),
                                      child: Text("Save Changes",
                                          style: GoogleFonts.poppins(
                                              fontWeight: FontWeight.bold,
                                              fontSize:
                                                  _fs(context, 15, 16, 17))),
                                    ),
                            ),
                            SizedBox(height: isDesktop ? 10 : 10.h),
                          ],
                        ),
                      ),
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
    bool optional = false,
  }) {
    final isDesktop = _isDesktop(ctx);
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: GoogleFonts.poppins(fontSize: _fs(ctx, 13, 13, 14)),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.poppins(
            color: Colors.black38, fontSize: _fs(ctx, 13, 13, 14)),
        filled: true,
        fillColor: const Color(0xFFF3F4F6),
        contentPadding: EdgeInsets.symmetric(
            horizontal: isDesktop ? 16 : 16.w,
            vertical: isDesktop ? 15 : 14.h),
        border: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(isDesktop ? 12 : 12.r),
          borderSide: BorderSide.none,
        ),
      ),
      validator: (value) {
        if (!optional && (value == null || value.isEmpty)) {
          return "$hint is required";
        }
        return null;
      },
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
    _emailController.dispose();
    _mobileController.dispose();
    _addressController.dispose();
    super.dispose();
  }
}
