import 'package:flutter/material.dart';
import '../services/accessibility_service.dart';
import '../theme/app_theme.dart';

class AccessibleButton extends StatelessWidget {
  final String label;
  final String? hint;
  final VoidCallback onPressed;
  final IconData? icon;
  final bool isPrimary;
  final bool isFullWidth;
  final EdgeInsetsGeometry padding;

  const AccessibleButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.hint,
    this.icon,
    this.isPrimary = true,
    this.isFullWidth = false,
    this.padding = const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
  });

  @override
  Widget build(BuildContext context) {
    final effectiveChild = Row(
      mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 22, color: isPrimary ? Colors.black : AppTheme.goldAccent),
          const SizedBox(width: 10),
        ],
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isPrimary ? Colors.black : AppTheme.goldAccent,
          ),
        ),
      ],
    );

    return Semantics(
      button: true,
      enabled: true,
      label: label,
      hint: hint ?? 'Double tap to activate',
      child: Material(
        color: isPrimary ? AppTheme.goldAccent : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            AccessibilityService.hapticMedium();
            onPressed();
          },
          child: Container(
            constraints: const BoxConstraints(minHeight: 48, minWidth: 48),
            padding: padding,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: isPrimary ? null : Border.all(color: AppTheme.goldAccent, width: 2),
            ),
            child: effectiveChild,
          ),
        ),
      ),
    );
  }
}
