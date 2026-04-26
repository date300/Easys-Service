import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../widgets/auto_notice.dart';

class VerificationGuard {
  /// পুরোনো check মেথড — home_screen.dart থেকে যেভাবে কল করে সেভাবেই কাজ করবে
  static Future<void> check(
    BuildContext context, {
    required VoidCallback onVerified,
    double amount = 300.00,
    String purpose = 'Account Verification Fee',
    bool useDialog = false,
  }) async {
    final verified = await AuthService.isVerified();
    if (!context.mounted) return;

    if (verified) {
      onVerified();
    } else {
      AutoNotice.warning(
        context,
        'Please complete $purpose by paying ৳$amount to unlock this feature.',
      );
    }
  }

  /// পেজ লোডে অটো চেক — বাটন ক্লিক ছাড়াই নোটিস আসবে
  static Future<void> autoCheck(
    BuildContext context, {
    VoidCallback? onVerified,
  }) async {
    final verified = await AuthService.isVerified();
    if (!context.mounted) return;

    if (!verified) {
      AutoNotice.warning(
        context,
        'Your account is not verified. Please complete verification to unlock all features.',
      );
    } else {
      onVerified?.call();
    }
  }

  /// initState এ কল করতে হবে
  static void checkOnLoad(
    BuildContext context, {
    VoidCallback? onVerified,
  }) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      autoCheck(context, onVerified: onVerified);
    });
  }

  /// পুরোনো wrap মেথড
  static Widget wrap({
    required BuildContext context,
    required Widget child,
    required VoidCallback onVerified,
    double amount = 300.00,
    String purpose = 'Account Verification Fee',
  }) {
    return GestureDetector(
      onTap: () => check(
        context,
        onVerified: onVerified,
        amount: amount,
        purpose: purpose,
      ),
      child: child,
    );
  }
}

class VerificationGuardWidget {
  static Future<void> autoCheck(
    BuildContext context, {
    VoidCallback? onVerified,
  }) async {
    final verified = await AuthService.isVerified();
    if (!context.mounted) return;

    if (!verified) {
      AutoNotice.warning(
        context,
        'Your account is not verified. Please complete verification to unlock all features.',
      );
    } else {
      onVerified?.call();
    }
  }
}
