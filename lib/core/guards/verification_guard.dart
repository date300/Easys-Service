import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../widgets/auto_notice.dart';

class VerificationGuard {
  /// অটো চেক — বাটন ক্লিক ছাড়াই উপরে নোটিস আসবে, ম্যানুয়ালি ক্লোজ করতে হবে
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

  /// পেজ লোড হলেই অটো চেক
  static void checkOnLoad(
    BuildContext context, {
    VoidCallback? onVerified,
  }) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      autoCheck(context, onVerified: onVerified);
    });
  }

  static Widget wrap({
    required BuildContext context,
    required Widget child,
    required VoidCallback onVerified,
  }) {
    return GestureDetector(
      onTap: () => autoCheck(context, onVerified: onVerified),
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
