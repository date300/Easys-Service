import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../widgets/verification_modal.dart';
// ─────────────────────────────────────────────
//  VerificationGuard
//  যেকোনো button বা action এ ব্যবহার করো।
//
//  Example:
//  onTap: () => VerificationGuard.check(
//    context,
//    onVerified: () { /* verified হলে এখানে */ },
//  ),
// ─────────────────────────────────────────────
class VerificationGuard {
  /// Check করে verified কিনা।
  /// Verified হলে onVerified() call করে।
  /// না হলে VerificationModal দেখায়।
  static Future<void> check(
    BuildContext context, {
    required VoidCallback onVerified,
    double amount = 199.00,
    String purpose = 'Account Verification Fee',
    bool useDialog = false, // true হলে bottom sheet এর বদলে dialog দেখাবে
  }) async {
    final verified = await AuthService.isVerified();

    if (!context.mounted) return;

    if (verified) {
      onVerified();
    } else {
      if (useDialog) {
        await VerificationModal.showDialog(
          context,
          amount: amount,
          purpose: purpose,
          onVerified: onVerified,
        );
      } else {
        await VerificationModal.show(
          context,
          amount: amount,
          purpose: purpose,
          onVerified: onVerified,
        );
      }
    }
  }

  /// Widget wrap করার জন্য।
  /// Verified না হলে child এর উপর tap করলে modal দেখাবে।
  static Widget wrap({
    required BuildContext context,
    required Widget child,
    required VoidCallback onVerified,
    double amount = 199.00,
    String purpose = 'Account Verification Fee',
  }) {
    return GestureDetector(
      onTap: () => VerificationGuard.check(
        context,
        onVerified: onVerified,
        amount: amount,
        purpose: purpose,
      ),
      child: child,
    );
  }
}

// ─────────────────────────────────────────────
//  VerificationGuardWidget — auto check on build
//  Screen load হলেই verify check করে।
//
//  Example:
//  @override
//  void initState() {
//    super.initState();
//    WidgetsBinding.instance.addPostFrameCallback((_) {
//      VerificationGuardWidget.autoCheck(context);
//    });
//  }
// ─────────────────────────────────────────────
class VerificationGuardWidget {
  /// Screen open হলেই check করে, verified না হলে modal দেখায়
  static Future<void> autoCheck(
    BuildContext context, {
    VoidCallback? onVerified,
    double amount = 199.00,
    String purpose = 'Account Verification Fee',
  }) async {
    final verified = await AuthService.isVerified();
    if (!context.mounted) return;
    if (!verified) {
      await VerificationModal.show(
        context,
        amount: amount,
        purpose: purpose,
        onVerified: onVerified,
      );
    }
  }
}
