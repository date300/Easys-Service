import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Riverpod ইমপোর্ট
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

// main.dart ফাইলটি ইমপোর্ট করুন যেখানে authProvider লেখা আছে
// (আপনার ফোল্ডার অনুযায়ী পাথ ঠিক করে নেবেন)
import '../../main.dart';

class RegistrationScreen extends ConsumerStatefulWidget {
  const RegistrationScreen({super.key});

  @override
  ConsumerState<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends ConsumerState<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  
  final _nameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _emailController = TextEditingController();
  final _passController = TextEditingController();
  final _confirmPassController = TextEditingController();
  final _refController = TextEditingController();
  final _otpController = TextEditingController();

  bool _isLoading = false;
  bool _isOtpSent = false;

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    const String apiUrl = "https://easy.ltcminematrix.com/api/register";

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json" // এই হেডারটি যোগ করা হয়েছে
        },
        body: jsonEncode({
          "full_name": _nameController.text.trim(),
          "mobile": _mobileController.text.trim(),
          "email": _emailController.text.trim(),
          "password": _passController.text,
          "confirm_password": _confirmPassController.text,
          "referral_code": _refController.text.trim().isEmpty ? null : _refController.text.trim(),
        }),
      );

      final data = jsonDecode(response.body);

      if (data['status'] == "success") {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message']), backgroundColor: Colors.green),
        );
        setState(() {
          _isOtpSent = true;
        });
      } else {
        _showError(data['message']);
      }
    } catch (e) {
      print("Register Error: $e");
      _showError("সার্ভারের সাথে কানেকশন করা যাচ্ছে না!");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _verifyOtp() async {
    final otp = _otpController.text.trim();
    if (otp.length < 6) {
      _showError("সঠিক ৬ ডিজিটের OTP দিন");
      return;
    }

    setState(() => _isLoading = true);
    const String apiUrl = "https://easy.ltcminematrix.com/api/verify-otp";

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json"
        },
        body: jsonEncode({
          "email": _emailController.text.trim(),
          "otp": otp,
        }),
      );

      final data = jsonDecode(response.body);

      if (data['status'] == "success") {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwt_token', data['token']);
        
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message']), backgroundColor: Colors.green),
        );

        // ✅ ম্যাজিক: রিভারপড স্টেট আপডেট, ফলে অটোমেটিক হোম পেজে চলে যাবে লেআউটের ভেতরেই!
        ref.read(authProvider.notifier).state = true;
        
      } else {
        _showError(data['message']);
      }
    } catch (e) {
      print("OTP Verify Error: $e");
      _showError("সার্ভারের সাথে কানেকশন করা যাচ্ছে না!");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
  }

  @override
  Widget build(BuildContext context) {
    // Scaffold বাদ দিয়েছি, কারণ এটি MainWrapper-এর বডির ভেতরে বসবে
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: _isOtpSent ? _buildOtpForm() : _buildRegistrationForm(),
    );
  }

  Widget _buildRegistrationForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          const SizedBox(height: 10),
          _buildTextField(_nameController, "Full Name", Icons.person),
          _buildTextField(_mobileController, "Mobile Number", Icons.phone, keyboardType: TextInputType.phone),
          _buildTextField(_emailController, "Email Address", Icons.email, keyboardType: TextInputType.emailAddress),
          _buildTextField(_passController, "Password", Icons.lock, isPassword: true),
          _buildTextField(_confirmPassController, "Confirm Password", Icons.lock_clock, isPassword: true),
          _buildTextField(_refController, "Referral Code (Optional)", Icons.card_giftcard),
          
          const SizedBox(height: 25),
          
          _isLoading 
            ? const CircularProgressIndicator()
            : SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF29B6F6),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: _register,
                  child: const Text("Register", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
        ],
      ),
    );
  }

  Widget _buildOtpForm() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 40),
        const Icon(Icons.mark_email_read, size: 80, color: Color(0xFF29B6F6)),
        const SizedBox(height: 20),
        Text(
          "We have sent an OTP to\n${_emailController.text}",
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 30),
        
        TextField(
          controller: _otpController,
          keyboardType: TextInputType.number,
          maxLength: 6,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 24, letterSpacing: 10),
          decoration: const InputDecoration(
            hintText: "000000",
            counterText: "",
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 30),

        _isLoading
            ? const CircularProgressIndicator()
            : SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF29B6F6),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: _verifyOtp,
                  child: const Text("Verify & Login", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
              
        const SizedBox(height: 20),
        TextButton(
          onPressed: () {
            setState(() {
              _isOtpSent = false;
            });
          },
          child: const Text("Change Email Address", style: TextStyle(color: Color(0xFF29B6F6))),
        )
      ],
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool isPassword = false, TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.grey),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFF29B6F6), width: 2),
          ),
        ),
        validator: (value) {
          if (!label.contains("Optional") && (value == null || value.isEmpty)) {
            return "$label প্রয়োজন";
          }
          if (label == "Confirm Password" && value != _passController.text) {
            return "পাসওয়ার্ড মিলছে না";
          }
          return null;
        },
      ),
    );
  }
}
