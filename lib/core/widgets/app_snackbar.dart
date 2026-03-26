import 'package:flutter/material.dart';

enum SnackBarType { success, error, info }

class AppSnackBar {
  static void show(
    BuildContext context, {
    required String message,
    SnackBarType type = SnackBarType.info,
  }) {
    final style = _getStyle(type);

    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF2E2E2E), // Premium Charcoal Dark
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Row(
          children: [
            Icon(style.icon, color: style.color, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Style helper for icons and their subtle colors
  static _SnackBarStyle _getStyle(SnackBarType type) {
    switch (type) {
      case SnackBarType.success:
        return _SnackBarStyle(
          color: Colors.greenAccent,
          icon: Icons.check_circle_rounded,
        );

      case SnackBarType.error:
        return _SnackBarStyle(
          color: Colors.redAccent,
          icon: Icons.error_rounded,
        );

      case SnackBarType.info:
        return _SnackBarStyle(
          color: Colors.lightBlueAccent,
          icon: Icons.info_rounded,
        );
    }
  }
}

/// Internal style model
class _SnackBarStyle {
  _SnackBarStyle({required this.color, required this.icon});
  final Color color;
  final IconData icon;
}
