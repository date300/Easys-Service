import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../features/payment/payment_gateway_screen.dart';

// ─────────────────────────────────────────────
//  VerificationModal — Reusable popup
//  যেকোনো জায়গায় call করো:
//  VerificationModal.show(context);
// ─────────────────────────────────────────────
class VerificationModal {
  /// Modal দেখানোর main method
  /// onVerified: payment সফল হলে কী করবে
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

  /// Dialog হিসেবে দেখাতে চাইলে এটা use করো
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

// ─────────────────────────────────────────────
//  Bottom Sheet UI
// ─────────────────────────────────────────────
class _VerificationBottomSheet extends StatelessWidget {
  final double amount;
  final String purpose;
  final VoidCallback? onVerified;

  const _VerificationBottomSheet({
    required this.amount,
    required this.purpose,
    this.onVerified,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF0F0F14),
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
              // Handle bar
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 28),

              // Warning Icon
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B).withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.verified_user_rounded,
                  color: Color(0xFFF59E0B),
                  size: 36,
                ),
              ),
              const SizedBox(height: 20),

              Text(
                'অ্যাকাউন্ট ভেরিফাই করুন',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'এই ফিচারটি ব্যবহার করতে আপনার অ্যাকাউন্ট ভেরিফাই করা প্রয়োজন। মাত্র ৳$amount পেমেন্ট করে আপনার অ্যাকাউন্ট সক্রিয় করুন।',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: Colors.white.withOpacity(0.55),
                  fontSize: 13,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 28),

              // Benefits list
              _BenefitRow(
                  icon: Icons.check_circle_rounded,
                  text: 'সকল প্রিমিয়াম ফিচার আনলক'),
              const SizedBox(height: 10),
              _BenefitRow(
                  icon: Icons.check_circle_rounded,
                  text: 'উপার্জন শুরু করুন তাৎক্ষণিকভাবে'),
              const SizedBox(height: 10),
              _BenefitRow(
                  icon: Icons.check_circle_rounded,
                  text: 'একবারের পেমেন্ট, আজীবন সুবিধা'),

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
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF6C63FF).withOpacity(0.35),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PaymentGatewayScreen(
                              amount: amount,
                              purpose: purpose,
                              onPaymentSuccess: onVerified,
                            ),
                          ),
                        );
                      },
                      child: Center(
                        child: Text(
                          '✓  এখনই ভেরিফাই করুন — ৳$amount',
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

              // Cancel
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'এখন নয়',
                  style: GoogleFonts.poppins(
                    color: Colors.white38,
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

// ─────────────────────────────────────────────
//  Dialog UI (alternative to bottom sheet)
// ─────────────────────────────────────────────
class _VerificationDialog extends StatelessWidget {
  final double amount;
  final String purpose;
  final VoidCallback? onVerified;

  const _VerificationDialog({
    required this.amount,
    required this.purpose,
    this.onVerified,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A26),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                  color: Colors.white.withOpacity(0.08), width: 1),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF59E0B).withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.verified_user_rounded,
                      color: Color(0xFFF59E0B), size: 32),
                ),
                const SizedBox(height: 18),
                Text(
                  'অ্যাকাউন্ট ভেরিফাই করুন',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'এই ফিচার ব্যবহার করতে অ্যাকাউন্ট ভেরিফাই করা প্রয়োজন।',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    color: Colors.white.withOpacity(0.5),
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
                          borderRadius: BorderRadius.circular(14)),
                      elevation: 0,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PaymentGatewayScreen(
                            amount: amount,
                            purpose: purpose,
                            onPaymentSuccess: onVerified,
                          ),
                        ),
                      );
                    },
                    child: Text(
                      'ভেরিফাই করুন — ৳$amount',
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
                  child: Text('পরে করব',
                      style: GoogleFonts.poppins(
                          color: Colors.white38, fontSize: 13)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Benefit Row Widget
// ─────────────────────────────────────────────
class _BenefitRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _BenefitRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF22C55E), size: 18),
        const SizedBox(width: 10),
        Text(
          text,
          style: GoogleFonts.poppins(
            color: Colors.white.withOpacity(0.7),
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}
