import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // রিভারপড ইমপোর্ট
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:go_router/go_router.dart'; // GoRouter ইমপোর্ট

// আপনার প্রোজেক্টের পাথ অনুযায়ী main.dart ইমপোর্ট করুন (যেখানে প্রোভাইডার আছে)
import '../../main.dart'; 

class VerificationModal {
  /// Bottom Sheet দেখানোর মেথড
  static Future<void> show(
    BuildContext context, {
    VoidCallback? onVerified,
    double amount = 199.00,
    String purpose = 'Account Verification Fee',
  }) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.6),
      builder: (_) => _VerificationBottomSheet(
        amount: amount,
        purpose: purpose,
        onVerified: onVerified,
      ),
    );
  }

  /// Dialog দেখানোর মেথড
  static Future<void> showDialog(
    BuildContext context, {
    VoidCallback? onVerified,
    double amount = 199.00,
    String purpose = 'Account Verification Fee',
  }) async {
    await showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.black.withOpacity(0.6),
      transitionDuration: const Duration(milliseconds: 350),
      transitionBuilder: (_, anim, __, child) {
        return ScaleTransition(
          scale: CurvedAnimation(parent: anim, curve: Curves.easeOutBack),
          child: FadeTransition(opacity: anim, child: child),
        );
      },
      pageBuilder: (_, __, ___) => _VerificationDialog(
        amount: amount,
        purpose: purpose,
        onVerified: onVerified,
      ),
    );
  }
}

// ============================================
//  Bottom Sheet UI (ConsumerWidget ব্যবহার করা হয়েছে)
// ============================================
class _VerificationBottomSheet extends ConsumerWidget {
  final double amount;
  final String purpose;
  final VoidCallback? onVerified;

  const _VerificationBottomSheet({
    required this.amount,
    required this.purpose,
    this.onVerified,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.black12,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Lottie.network(
                'https://assets9.lottiefiles.com/packages/lf20_touohxv0.json',
                width: 120,
                height: 120,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 16),
              Text(
                'Account Verification Required',
                style: GoogleFonts.poppins(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'To access all features, please complete account verification by paying a fee of \$$amount.',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: Colors.black54,
                  fontSize: 13,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 24),
              _BenefitRow(text: 'Full access to all features'),
              const SizedBox(height: 10),
              _BenefitRow(text: 'Priority customer support'),
              const SizedBox(height: 10),
              _BenefitRow(text: 'Secure and trusted platform'),
              const SizedBox(height: 28),

              // Verify Button
              SizedBox(
                width: double.infinity,
                height: 54,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6C63FF), Color(0xFF9B59B6)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () {
                        // ১. স্টেট আপডেট (ডিটেইল ভিউ অন করা)
                        ref.read(isDetailViewProvider.notifier).state = true;
                        ref.read(detailViewTitleProvider.notifier).state = 'Payment';

                        // ২. মোডাল বন্ধ করা
                        Navigator.pop(context);

                        // ৩. GoRouter ব্যবহার করে নেভিগেট করা
                        context.push('/payment'); 
                      },
                      child: Center(
                        child: Text(
                          'Verify Now ? \$$amount',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Cancel',
                  style: GoogleFonts.poppins(
                    color: Colors.black38,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================
//  Dialog UI (ConsumerWidget ব্যবহার করা হয়েছে)
// ============================================
class _VerificationDialog extends ConsumerWidget {
  final double amount;
  final String purpose;
  final VoidCallback? onVerified;

  const _VerificationDialog({
    required this.amount,
    required this.purpose,
    this.onVerified,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Lottie.network(
                  'https://assets9.lottiefiles.com/packages/lf20_touohxv0.json',
                  width: 100,
                  height: 100,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 16),
                Text(
                  'Account Verification Required',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Please complete account verification to unlock all features.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    color: Colors.black54,
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6C63FF),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () {
                      // ১. স্টেট আপডেট
                      ref.read(isDetailViewProvider.notifier).state = true;
                      ref.read(detailViewTitleProvider.notifier).state = 'Payment';

                      // ২. ডায়ালগ বন্ধ করা
                      Navigator.pop(context);

                      // ৩. নেভিগেট করা
                      context.push('/payment');
                    },
                    child: Text(
                      'Verify Now ? \$$amount',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Cancel',
                    style: GoogleFonts.poppins(
                      color: Colors.black38,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BenefitRow extends StatelessWidget {
  final String text;
  const _BenefitRow({required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Lottie.network(
          'https://assets2.lottiefiles.com/packages/lf20_jfe6xnkr.json',
          width: 28,
          height: 28,
          fit: BoxFit.contain,
        ),
        const SizedBox(width: 10),
        Text(
          text,
          style: GoogleFonts.poppins(
            color: Colors.black87,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}
