// ══════════════════════════════════════════════════════════════
//  registration_screen.dart — Sound Integration Example
//  শুধু sound-related changes দেখানো হয়েছে (3 জায়গায়)
// ══════════════════════════════════════════════════════════════

// Step 1: Import যোগ করো (file এর top এ)
import '../../core/services/app_sound_service.dart';

// ─────────────────────────────────────────────────────────────
// Step 2: _register() method এ sound যোগ করো
// ─────────────────────────────────────────────────────────────

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final response = await http.post(
        Uri.parse("https://easy.ltcminematrix.com/api/auth/register"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "full_name": _nameController.text.trim(),
          "mobile": _mobileController.text.trim(),
          "email": _emailController.text.trim(),
          "password": _passController.text,
          "confirm_password": _confirmPassController.text,
          "referral_code": _refController.text.trim().isEmpty
              ? null
              : _refController.text.trim(),
        }),
      );
      final data = jsonDecode(response.body);
      if (data['status'] == "success") {
        await AppSoundService.instance.playOtp(); // 📨 OTP পাঠানো হলো
        if (!mounted) return;
        _showSnack(data['message'], Colors.green);
        setState(() => _isOtpSent = true);
      } else {
        await AppSoundService.instance.playError(); // ❌ Registration fail
        _showSnack(data['message'], Colors.red);
      }
    } catch (_) {
      await AppSoundService.instance.playError(); // ❌ Network error
      _showSnack("Connection error!", Colors.red);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

// ─────────────────────────────────────────────────────────────
// Step 3: _verifyOtp() method এ sound যোগ করো
// ─────────────────────────────────────────────────────────────

  Future<void> _verifyOtp() async {
    final otp = _otpController.text.trim();
    if (otp.length < 6) {
      await AppSoundService.instance.playError(); // ❌ OTP too short
      _showSnack("Please enter 6-digit OTP", Colors.red);
      return;
    }
    setState(() => _isLoading = true);
    try {
      final response = await http.post(
        Uri.parse("https://easy.ltcminematrix.com/api/auth/verify-otp"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": _emailController.text.trim(),
          "otp": otp,
        }),
      );
      final data = jsonDecode(response.body);
      if (data['status'] == "success") {
        await AppSoundService.instance.playLogin(); // 🔐 Login success!
        await ref.read(authProvider.notifier).loginWithToken(data['token']);
        if (!mounted) return;
        _showSnack(data['message'], Colors.green);
        context.go('/home');
      } else {
        await AppSoundService.instance.playError(); // ❌ OTP wrong
        _showSnack(data['message'], Colors.red);
      }
    } catch (_) {
      await AppSoundService.instance.playError(); // ❌ Network error
      _showSnack("Connection error!", Colors.red);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

// ─────────────────────────────────────────────────────────────
// Step 4: Register button এ tap sound (optional)
// ─────────────────────────────────────────────────────────────

  // ElevatedButton এর onPressed:
  onPressed: () {
    AppSoundService.instance.playTap(); // 👆 tap feedback
    _register();
  },
