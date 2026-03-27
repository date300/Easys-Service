import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../home/home_screen.dart'; // আপনার হোম স্ক্রিনের ইম্পোর্ট পাথ ঠিক করে নিবেন

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // রেজিস্ট্রেশন কন্ট্রোলার
  final _nameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _emailController = TextEditingController();
  final _passController = TextEditingController();
  final _confirmPassController = TextEditingController();
  final _refController = TextEditingController();

  // OTP কন্ট্রোলার
  final _otpController = TextEditingController();

  bool _isLoading = false;
  bool _isOtpSent = false; // এই স্টেট দিয়ে আমরা পেজের ডিজাইন চেঞ্জ করবো

  // ১. রেজিস্ট্রেশন API কল
  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    const String apiUrl = "https://easy.ltcminematrix.com/api/register";

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
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
        
        // সফল হলে OTP ফর্ম দেখানোর জন্য স্টেট পরিবর্তন করছি
        setState(() {
          _isOtpSent = true;
        });
      } else {
        _showError(data['message']);
      }
    } catch (e) {
      _showError("সার্ভারের সাথে কানেক্ট করা যাচ্ছে না!");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ২. OTP ভেরিফিকেশন API কল
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
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": _emailController.text.trim(), // রেজিস্ট্রেশনের সময় দেওয়া ইমেইল
          "otp": otp,
        }),
      );

      final data = jsonDecode(response.body);

      if (data['status'] == "success") {
        // টোকেন সেভ করা হচ্ছে
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwt_token', data['token']);
        
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message']), backgroundColor: Colors.green),
        );

        // সফল হলে হোম স্ক্রিনে পাঠিয়ে দেওয়া
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()), 
          (route) => false,
        );
      } else {
        _showError(data['message']);
      }
    } catch (e) {
      _showError("সার্ভারের সাথে কানেক্ট করা যাচ্ছে না!");
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
    return Scaffold(
      // OTP পাঠানো হলে টাইটেল পরিবর্তন হয়ে যাবে
      appBar: AppBar(title: Text(_isOtpSent ? "OTP Verification" : "Create Account")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        // _isOtpSent সত্য হলে OTP ফর্ম দেখাবে, না হলে রেজিস্ট্রেশন ফর্ম দেখাবে
        child: _isOtpSent ? _buildOtpForm() : _buildRegistrationForm(),
      ),
    );
  }

  // ================= রেজিস্ট্রেশন ফর্ম UI =================
  Widget _buildRegistrationForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
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
                  onPressed: _register,
                  child: const Text("Register", style: TextStyle(fontSize: 18)),
                ),
              ),
        ],
      ),
    );
  }

  // ================= OTP ফর্ম UI =================
  Widget _buildOtpForm() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 40),
        const Icon(Icons.mark_email_read, size: 80, color: Colors.blue),
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
                  onPressed: _verifyOtp,
                  child: const Text("Verify & Login", style: TextStyle(fontSize: 18)),
                ),
              ),
              
        const SizedBox(height: 20),
        TextButton(
          onPressed: () {
            // ভুল ইমেইল দিলে আবার পেছনে যাওয়ার অপশন
            setState(() {
              _isOtpSent = false;
            });
          },
          child: const Text("Change Email Address"),
        )
      ],
    );
  }

  // ================= সাধারণ টেক্সট ফিল্ড উইজেট =================
  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool isPassword = false, TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: const OutlineInputBorder(),
        ),
        validator: (value) {
          if (!label.contains("Optional") && (value == null || value.isEmpty)) {
            return "$label প্রয়োজন";
          }
          if (label == "Confirm Password" && value != _passController.text) {
            return "পাসওয়ার্ড ম্যাচ করছে না";
          }
          return null;
        },
      ),
    );
  }
}

