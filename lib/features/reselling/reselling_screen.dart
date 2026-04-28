import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

// ==================== State Providers ====================

// লোডিং স্টেট ম্যানেজ করার জন্য
final resellingLoadingProvider = StateProvider<bool>((ref) => false);

// ==================== Page ====================

class ResellingPage extends ConsumerStatefulWidget {
  const ResellingPage({super.key});

  @override
  ConsumerState<ResellingPage> createState() => _ResellingPageState();
}

class _ResellingPageState extends ConsumerState<ResellingPage> {
  @override
  Widget build(BuildContext context) {
    // লোডিং স্টেট ওয়াচ করা হচ্ছে
    final isLoading = ref.watch(resellingLoadingProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // হালকা ব্যাকগ্রাউন্ড
      appBar: AppBar(
        title: Text(
          'Reselling Application',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: isLoading 
        ? const Center(child: CircularProgressIndicator()) 
        : SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                // এখানে আপনার ফর্মের ডিজাইন শুরু করতে পারেন
                const SizedBox(height: 20),
                _buildModernTextField(
                  label: "Shop Name",
                  icon: Icons.store_mall_directory_outlined,
                ),
                const SizedBox(height: 15),
                _buildModernTextField(
                  label: "Phone Number",
                  icon: Icons.phone_android_outlined,
                ),
                const SizedBox(height: 30),
                
                // সাবমিট বাটন
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: () {
                      // এখানে সাবমিট লজিক হবে
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: Text(
                      'Apply for Reselling',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
    );
  }

  // টেক্সট ফিল্ডের জন্য একটি ছোট মেথড
  Widget _buildModernTextField({required String label, required IconData icon}) {
    return TextField(
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }
}
