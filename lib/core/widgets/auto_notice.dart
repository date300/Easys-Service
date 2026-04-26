import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum AutoNoticeType { success, error, warning, info }

class AutoNotice {
  static OverlayEntry? _currentEntry;

  static void show(
    BuildContext context, {
    required AutoNoticeType type,
    required String message,
    String? title,
  }) {
    _currentEntry?.remove();

    final overlay = Overlay.of(context);
    _currentEntry = OverlayEntry(
      builder: (context) => _AutoNoticeOverlay(
        type: type,
        title: title ?? _defaultTitle(type),
        message: message,
        onDismiss: _dismiss,
      ),
    );

    overlay.insert(_currentEntry!);
  }

  static void _dismiss() {
    _currentEntry?.remove();
    _currentEntry = null;
  }

  static String _defaultTitle(AutoNoticeType type) {
    switch (type) {
      case AutoNoticeType.success:
        return 'Success';
      case AutoNoticeType.error:
        return 'Error';
      case AutoNoticeType.warning:
        return 'Warning';
      case AutoNoticeType.info:
        return 'Info';
    }
  }

  static void success(BuildContext context, String message) => show(
        context,
        type: AutoNoticeType.success,
        message: message,
      );

  static void error(BuildContext context, String message) => show(
        context,
        type: AutoNoticeType.error,
        message: message,
      );

  static void warning(BuildContext context, String message) => show(
        context,
        type: AutoNoticeType.warning,
        message: message,
      );

  static void info(BuildContext context, String message) => show(
        context,
        type: AutoNoticeType.info,
        message: message,
      );
}

class _AutoNoticeOverlay extends StatefulWidget {
  final AutoNoticeType type;
  final String title;
  final String message;
  final VoidCallback onDismiss;

  const _AutoNoticeOverlay({
    required this.type,
    required this.title,
    required this.message,
    required this.onDismiss,
  });

  @override
  State<_AutoNoticeOverlay> createState() => _AutoNoticeOverlayState();
}

class _AutoNoticeOverlayState extends State<_AutoNoticeOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<Offset> _slideAnim;

  Color get _primaryColor {
    switch (widget.type) {
      case AutoNoticeType.success:
        return const Color(0xFF4CAF50);
      case AutoNoticeType.error:
        return const Color(0xFFE53935);
      case AutoNoticeType.warning:
        return const Color(0xFFFF9800);
      case AutoNoticeType.info:
        return const Color(0xFF2196F3);
    }
  }

  Color get _lightColor {
    switch (widget.type) {
      case AutoNoticeType.success:
        return const Color(0xFFE8F5E9);
      case AutoNoticeType.error:
        return const Color(0xFFFFEBEE);
      case AutoNoticeType.warning:
        return const Color(0xFFFFF3E0);
      case AutoNoticeType.info:
        return const Color(0xFFE3F2FD);
    }
  }

  IconData get _icon {
    switch (widget.type) {
      case AutoNoticeType.success:
        return Icons.check_circle_rounded;
      case AutoNoticeType.error:
        return Icons.error_rounded;
      case AutoNoticeType.warning:
        return Icons.warning_rounded;
      case AutoNoticeType.info:
        return Icons.info_rounded;
    }
  }

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, -1.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutBack),
    );

    _animController.forward();
  }

  Future<void> _remove() async {
    await _animController.reverse();
    if (mounted) widget.onDismiss();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Positioned(
      top: topPadding + 12,
      left: 16,
      right: 16,
      child: SlideTransition(
        position: _slideAnim,
        child: Material(
          color: Colors.transparent,
          child: GestureDetector(
            onTap: _remove,
            onHorizontalDragEnd: (_) => _remove(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: _primaryColor.withOpacity(0.25),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _lightColor,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _icon,
                      color: _primaryColor,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.title,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.message,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.black54,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _remove,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.05),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        size: 16,
                        color: Colors.black45,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
