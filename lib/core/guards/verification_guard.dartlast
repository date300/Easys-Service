import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../widgets/verification_modal.dart';

class VerificationGuard {
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

  static Widget wrap({
    required BuildContext context,
    required Widget child,
    required VoidCallback onVerified,
    double amount = 300.00,
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

class VerificationGuardWidget {
  static Future<void> autoCheck(
    BuildContext context, {
    VoidCallback? onVerified,
    double amount = 300.00,
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
