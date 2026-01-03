import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

/// Accessibility utilities
class AccessibilityUtils {
  /// Set semantic label for better screen reader support
  static void setSemanticLabel(Widget widget, String label) {
    Semantics(
      label: label,
      child: widget,
    );
  }

  /// Create accessible button
  static Widget accessibleButton({
    required VoidCallback onPressed,
    required Widget child,
    String? semanticLabel,
    String? tooltip,
  }) {
    return Semantics(
      label: semanticLabel,
      hint: tooltip,
      button: true,
      enabled: true,
      child: Tooltip(
        message: tooltip ?? semanticLabel ?? '',
        child: child,
      ),
    );
  }

  /// Create accessible text field
  static Widget accessibleTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    String? helperText,
  }) {
    return Semantics(
      label: label,
      hint: hint,
      textField: true,
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          helperText: helperText,
        ),
      ),
    );
  }
}
