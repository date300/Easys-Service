import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  // Theme Colors
  static const Color skyBlue = Color(0xFF29B6F6);
  static const Color accentColor = Color(0xFF00BCD4);
  static const Color successColor = Color(0xFF4CAF50);
  static const Color warningColor = Color(0xFFFF9800);
  static const Color errorColor = Color(0xFFE53935);

  // API Config
  static const String baseUrl = "https://easy.ltcminematrix.com/api";
  static const String staticBase = "https://easy.ltcminematrix.com";

  // Controllers
  final _nameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _emailController = TextEditingController();
  final _referralCodeController = TextEditingController();
  final _referredByController = TextEditingController();

  // State Variables
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
  int _imageKey = 0;
  bool _hasChanges = false;

  // User Stats
  int _userId = 0;
  String _joinDate = '';

  final ImagePicker _picker = ImagePicker();

  // Responsive Helpers
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
    _nameController.addListener(_checkChanges);
    _fetchProfile();
  }

  @override
  void dispose() {
    _nameController.removeListener(_checkChanges);
    _nameController.dispose();
    _mobileController.dispose();
    _emailController.dispose();
    _referralCodeController.dispose();
    _referredByController.dispose();
    super.dispose();
  }

  void _checkChanges() {
    setState(() {
      _hasChanges = _nameController.text.trim() != _originalName;
    });
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
      if (token == null) {
        setState(() {
          _errorMsg = 'Please login again';
          _isLoading = false;
        });
        return;
      }

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
          _userId = user['id'] ?? 0;
          _originalName = user['full_name'] ?? '';
          _nameController.text = _originalName;
          _mobileController.text = user['mobile'] ?? '';
          _emailController.text = user['email'] ?? '';
          _referralCodeController.text = user['referral_code'] ?? '';
          _referredByController.text = user['referred_by']?.toString() ?? '';
          _idVerified = user['id_verified'] == 1 || user['id_verified'] == true;
          _profilePicture = user['profile_picture'];

          // Cache busting key
          _imageKey = DateTime.now().millisecondsSinceEpoch;

          // Parse last name change
          if (user['last_name_change'] != null) {
            _lastNameChange = DateTime.parse(user['last_name_change']);
          } else {
            _lastNameChange = null;
          }

          // Parse join date
          if (user['created_at'] != null) {
            final date = DateTime.parse(user['created_at']);
            _joinDate = DateFormat('MMM dd, yyyy').format(date);
          }

          _checkNameChangeEligibility();
          _hasChanges = false;
        });

        debugPrint("✅ Profile loaded: ${_getProfileImageUrl()}");
      } else {
        setState(() {
          _errorMsg = data['message'] ?? 'Failed to load profile';
        });
      }
    } catch (e) {
      debugPrint("❌ Fetch Error: $e");
      setState(() {
        _errorMsg = "Network error. Please check your connection.";
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
      _nameChangeMessage = "Name change available in $daysRemaining days";
    } else {
      _canChangeName = true;
      _nameChangeMessage = null;
    }
  }

  Future<void> _pickAndUploadImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 90,
      );

      if (pickedFile == null) return;

      setState(() => _isUploadingImage = true);

      final token = await _getToken();
      if (token == null) {
        _showSnack("Session expired. Please login again.", errorColor);
        return;
      }

      // Validate file size
      final bytes = await pickedFile.readAsBytes();
      final fileSizeMB = bytes.length / (1024 * 1024);
      if (fileSizeMB > 5) {
        _showSnack("Image too large. Max 5MB allowed.", warningColor);
        return;
      }

      final uri = Uri.parse("$baseUrl/user/upload-profile-pic");
      final request = http.MultipartRequest('POST', uri);
      request.headers['Authorization'] = 'Bearer $token';

      final fileName = pickedFile.name;
      final ext = fileName.split('.').last.toLowerCase();

      // Validate extension
      final allowedExts = ['jpg', 'jpeg', 'png', 'gif', 'webp'];
      if (!allowedExts.contains(ext)) {
        _showSnack("Invalid format. Use: JPG, PNG, GIF, WEBP", warningColor);
        return;
      }

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
        onTimeout: () => throw Exception("Upload timed out"),
      );

      final responseBody = await streamedResponse.stream.bytesToString();
      final data = jsonDecode(responseBody);

      if (streamedResponse.statusCode == 200 && data['status'] == 'success') {
        _showSnack("✅ Profile picture updated!", successColor);
        await _fetchProfile();
      } else {
        _showSnack(data['message'] ?? "Upload failed", errorColor);
      }
    } catch (e) {
      debugPrint("❌ Upload Error: $e");
      _showSnack("Failed to upload image", errorColor);
    } finally {
      if (mounted) setState(() => _isUploadingImage = false);
    }
  }

  Future<void> _deleteProfilePicture() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => _buildConfirmDialog(
        ctx: ctx,
        title: "Remove Photo?",
        message: "Your profile picture will be deleted permanently.",
        confirmText: "Remove",
        confirmColor: errorColor,
        icon: Icons.delete_outline,
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
      ).timeout(const Duration(seconds: 15));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['status'] == 'success') {
        _showSnack("✅ Photo removed", successColor);
        setState(() {
          _profilePicture = null;
          _imageKey = DateTime.now().millisecondsSinceEpoch;
        });
      } else {
        _showSnack(data['message'] ?? "Failed to remove", errorColor);
      }
    } catch (e) {
      _showSnack("Network error", errorColor);
    } finally {
      if (mounted) setState(() => _isUploadingImage = false);
    }
  }

  Future<void> _saveProfile() async {
    if (!_canChangeName) {
      _showSnack(_nameChangeMessage ?? "Name change locked", warningColor);
      return;
    }

    final newName = _nameController.text.trim();

    if (newName.isEmpty) {
      _showSnack("Name cannot be empty", errorColor);
      return;
    }

    if (newName.length < 3) <response clipped><NOTE>Result is longer than **10000 characters**, will be **truncated**.</NOTE>
