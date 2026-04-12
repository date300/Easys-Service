import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
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
        _profilePicture = user['profile_picture'];

        if (user['last_name_change'] != null) {
          _lastNameChange = DateTime.parse(user['last_name_change']);
          _checkNameChangeEligibility();
        }
      } else {
        _errorMsg = data['message'] ?? 'Failed to load profile';
      }
    } catch (e) {
      _errorMsg = "Something went wrong!";
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _checkNameChangeEligibility() {
    if (_lastNameChange == null) {
      _canChangeName = true;
      return;
    }

    final now = DateTime.now();
    final difference = now.difference(_lastNameChange!);
    final daysRemaining = 15 - difference.inDays;

    if (difference.inDays < 15) {
      _canChangeName = false;
      _nameChangeMessage = "You can change your name again in $daysRemaining days";
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
      final request = http.MultipartRequest(
        'POST',
        Uri.parse("$baseUrl/user/upload-profile-pic"),
      );

      request.headers['Authorization'] = 'Bearer $token';
      request.files.add(await http.MultipartFile.fromPath(
        'profile_picture',
        pickedFile.path,
      ));

      final response = await request.send();
      final responseData = await response.stream.bytesToString();
      final data = jsonDecode(responseData);

      if (data['status'] == 'success') {
        _showSnack("Profile picture updated successfully", Colors.green);
        _fetchProfile();
      } else {
        _showSnack(data['message'] ?? "Failed to upload image", Colors.red);
      }
    } catch (e) {
      _showSnack("Failed to upload image", Colors.red);
    } finally {
      setState(() => _isUploadingImage = false);
    }
  }

  Future<void> _deleteProfilePicture() async {
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

      if (data['status'] == 'success') {
        _showSnack("Profile picture deleted successfully", Colors.green);
        setState(() => _profilePicture = null);
      } else {
        _showSnack(data['message'] ?? "Failed to delete image", Colors.red);
      }
    } catch (e) {
      _showSnack("Failed to delete image", Colors.red);
    } finally {
      setState(() => _isUploadingImage = false);
    }
  }

  Future<void> _saveProfile() async {
    if (!_canChangeName) {
      _showSnack(_nameChangeMessage ?? "You cannot change name now", Colors.orange);
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
          "full_name": _nameController.text.trim(),
        }),
      );

      final data = jsonDecode(response.body);

      if (data['status'] == 'success') {
        _showSnack("Full name updated successfully", Colors.green);
        _fetchProfile();
      } else {
        _showSnack(data['message'] ?? "Update failed", Colors.red);
      }
    } catch (_) {
      _showSnack("Something went wrong!", Colors.red);
    } finally {
      setState(() => _isSaving = false);
    }
  }

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg), backgroundColor: color));
  }

  String _getProfileImageUrl() {
    if (_profilePicture == null) return "";
    return "$baseUrl/uploads/profile_pics/$_profilePicture";
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: _isLoading
          ? const Center(child: CircularProgressIndicator(color: skyBlue))
          : _errorMsg != null
              ? Center(child: Text(_errorMsg!, style: TextStyle(color: Colors.red)))
              : _buildForm(context),
    );
  }

  Widget _buildForm(BuildContext ctx) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          Center(
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 55,
                  backgroundColor: Colors.grey[300],
                  backgroundImage: _profilePicture != null
                      ? NetworkImage(_getProfileImageUrl())
                      : null,
                ),
                if (_isUploadingImage)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black45,
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      ),
                    ),
                  ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: _pickAndUploadImage,
                    child: CircleAvatar(
                      backgroundColor: skyBlue,
                      child: const Icon(Icons.camera_alt, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          TextField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: "Full Name"),
          ),

          const SizedBox(height: 20),

          ElevatedButton(
            onPressed: _saveProfile,
            child: const Text("Save Changes"),
          ),

          if (_profilePicture != null)
            TextButton(
              onPressed: _deleteProfilePicture,
              child: const Text("Remove Photo", style: TextStyle(color: Colors.red)),
            ),
        ],
      ),
    );
  }
}
