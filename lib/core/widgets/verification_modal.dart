import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:go_router/go_router.dart';

// ============================================
//  নোটিস টাইপ এনাম
// ============================================
enum NoticeType {
  success,
  error,
  warning,
  info,
}

// ============================================
//  নোটিস কনফিগ মডেল
// ============================================
class NoticeConfig {
  final NoticeType type;
  final String title;
  final String message;
  final String? primaryButtonText;
  final String? secondaryButtonText;
  final VoidCallback? onPrimaryPressed;
  final VoidCallback? onSecondaryPressed;
  final String? lottieUrl;
  final IconData? icon;
  final bool dismissible;

  const NoticeConfig({
    required this.type,
    required this.title,
    required this.message,
    this.primaryButtonText,
    this.secondaryButtonText,
    this.onPrimaryPressed,
    this.onSecondaryPressed,
    this.lottieUrl,
    this.icon,
    this.dismissible = true,
  });
}

// ============================================
//  মেইন নোটিস মোডাল ক্লাস
// ============================================
class NoticeModal {
  /// Bottom Sheet আকারে দেখান
  static Future<void> showBottomSheet(
    BuildContext context, {
    required NoticeConfig config,
  }) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.5),
      isDismissible: config.dismissible,
      builder: (_) => _NoticeBottomSheet(config: config),
    );
  }

  /// Dialog আকারে দেখান
  static Future<void> showDialog(
    BuildContext context, {
    required NoticeConfig config,
  }) async {
    await showGeneralDialog(
      context: context,
      barrierDismissible: config.dismissible,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: const Duration(milliseconds: 300),
      transitionBuilder: (_, anim, __, child) {
        return ScaleTransition(
          scale: CurvedAnimation(parent: anim, curve: Curves.easeOutBack),
          child: FadeTransition(opacity: anim, child: child),
        );
      },
      pageBuilder: (_, __, ___) => _NoticeDialog(config: config),
    );
  }

  /// সহজে Success নোটিস দেখান
  static Future<void> success(
    BuildContext context, {
    required String title,
    required String message,
    String buttonText = 'ঠিক আছে',
    VoidCallback? onPressed,
  }) async {
    await showDialog(
      context,
      config: NoticeConfig(
        type: NoticeType.success,
        title: title,
        message: message,
        primaryButtonText: buttonText,
        onPrimaryPressed: onPressed,
        lottieUrl: 'https://assets2.lottiefiles.com/packages/lf20_s2lryxtd.json',
      ),
    );
  }

  /// সহজে Error নোটিস দেখান
  static Future<void> error(
    BuildContext context, {
    required String title,
    required String message,
    String buttonText = 'ঠিক আছে',
    VoidCallback? onPressed,
  }) async {
    await showDialog(
      context,
      config: NoticeConfig(
        type: NoticeType.error,
        title: title,
        message: message,
        primaryButtonText: buttonText,
        onPrimaryPressed: onPressed,
        lottieUrl: 'https://assets10.lottiefiles.com/packages/lf20_qpwbv5gm.json',
      ),
    );
  }

  /// সহজে Warning নোটিস দেখান
  static Future<void> warning(
    BuildContext context, {
    required String title,
    required String message,
    String primaryText = 'ঠিক আছে',
    String? secondaryText,
    VoidCallback? onPrimaryPressed,
    VoidCallback? onSecondaryPressed,
  }) async {
    await showDialog(
      context,
      config: NoticeConfig(
        type: NoticeType.warning,
        title: title,
        message: message,
        primaryButtonText: primaryText,
        secondaryButtonText: secondaryText,
        onPrimaryPressed: onPrimaryPressed,
        onSecondaryPressed: onSecondaryPressed,
        lottieUrl: 'https://assets10.lottiefiles.com/packages/lf20_Tkwjw8.json',
      ),
    );
  }

  /// সহজে Info নোটিস দেখান
  static Future<void> info(
    BuildContext context, {
    required String title,
    required String message,
    String buttonText = 'বুঝেছি',
    VoidCallback? onPressed,
  }) async {
    await showDialog(
      context,
      config: NoticeConfig(
        type: NoticeType.info,
        title: title,
        message: message,
        primaryButtonText: buttonText,
        onPrimaryPressed: onPressed,
        lottieUrl: 'https://assets9.lottiefiles.com/packages/lf20_b88nh30c.json',
      ),
    );
  }
}

// ============================================
//  কালার এবং আইকন হেল্পার
// ============================================
class _NoticeTheme {
  final Color primaryColor;
  final Color lightColor;
  final IconData defaultIcon;

  const _NoticeTheme({
    required this.primaryColor,
    required this.lightColor,
    required this.defaultIcon,
  });

  static _NoticeTheme getTheme(NoticeType type) {
    switch (type) {
      case NoticeType.success:
        return const _NoticeTheme(
          primaryColor: Color(0xFF4CAF50),
          lightColor: Color(0xFFE8F5E9),
          defaultIcon: Icons.check_circle_rounded,
        );
      case NoticeType.error:
        return const _NoticeTheme(
          primaryColor: Color(0xFFE53935),
          lightColor: Color(0xFFFFEBEE),
          defaultIcon: Icons.error_rounded,
        );
      case NoticeType.warning:
        return const _NoticeTheme(
          primaryColor: Color(0xFFFF9800),
          lightColor: Color(0xFFFFF3E0),
          defaultIcon: Icons.warning_rounded,
        );
      case NoticeType.info:
        return const _NoticeTheme(
          primaryColor: Color(0xFF2196F3),
          lightColor: Color(0xFFE3F2FD),
          defaultIcon: Icons.info_rounded,
        );
    }
  }
}

// ============================================
//  Bottom Sheet UI
// ============================================
class _NoticeBottomSheet extends ConsumerWidget {
  final NoticeConfig config;

  const _NoticeBottomSheet({required this.config});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = _NoticeTheme.getTheme(config.type);

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
              // Drag Handle
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.black12,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),

              // Animation or Icon
              _buildIcon(theme),
              const SizedBox(height: 20),

              // Title
              Text(
                config.title,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),

              // Message
              Text(
                config.message,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: Colors.black54,
                  fontSize: 14,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 28),

              // Primary Button
              if (config.primaryButtonText != null) ...[
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.primaryColor,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      config.onPrimaryPressed?.call();
                    },
                    child: Text(
                      config.primaryButtonText!,
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],

              // Secondary Button
              if (config.secondaryButtonText != null) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: TextButton(
                    style: TextButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      config.onSecondaryPressed?.call();
                    },
                    child: Text(
                      config.secondaryButtonText!,
                      style: GoogleFonts.poppins(
                        color: Colors.black54,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],

              // Default Close if no buttons
              if (config.primaryButtonText == null &&
                  config.secondaryButtonText == null) ...[
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'বন্ধ করুন',
                    style: GoogleFonts.poppins(
                      color: Colors.black38,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIcon(_NoticeTheme theme) {
    if (config.lottieUrl != null) {
      return Lottie.network(
        config.lottieUrl!,
        width: 120,
        height: 120,
        fit: BoxFit.contain,
      );
    }
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: theme.lightColor,
        shape: BoxShape.circle,
      ),
      child: Icon(
        config.icon ?? theme.defaultIcon,
        size: 40,
        color: theme.primaryColor,
      ),
    );
  }
}

// ============================================
//  Dialog UI
// ============================================
class _NoticeDialog extends ConsumerWidget {
  final NoticeConfig config;

  const _NoticeDialog({required this.config});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = _NoticeTheme.getTheme(config.type);

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
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
                _buildIcon(theme),
                const SizedBox(height: 20),

                Text(
                  config.title,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),

                Text(
                  config.message,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    color: Colors.black54,
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),

                if (config.primaryButtonText != null) ...[
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.primaryColor,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        config.onPrimaryPressed?.call();
                      },
                      child: Text(
                        config.primaryButtonText!,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ],

                if (config.secondaryButtonText != null) ...[
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      config.onSecondaryPressed?.call();
                    },
                    child: Text(
                      config.secondaryButtonText!,
                      style: GoogleFonts.poppins(
                        color: Colors.black54,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],

                if (config.primaryButtonText == null &&
                    config.secondaryButtonText == null) ...[
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'বন্ধ করুন',
                      style: GoogleFonts.poppins(
                        color: Colors.black38,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIcon(_NoticeTheme theme) {
    if (config.lottieUrl != null) {
      return Lottie.network(
        config.lottieUrl!,
        width: 100,
        height: 100,
        fit: BoxFit.contain,
      );
    }
    return Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        color: theme.lightColor,
        shape: BoxShape.circle,
      ),
      child: Icon(
        config.icon ?? theme.defaultIcon,
        size: 35,
        color: theme.primaryColor,
      ),
    );
  }
}
