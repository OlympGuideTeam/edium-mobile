import 'package:edium/core/theme/app_colors.dart';
import 'package:edium/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';

enum EdiumButtonVariant { primary, outline, ghost }

class EdiumButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final EdiumButtonVariant variant;
  final bool isLoading;
  final IconData? icon;
  final double? width;

  const EdiumButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = EdiumButtonVariant.primary,
    this.isLoading = false,
    this.icon,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final child = isLoading
        ? const SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.white,
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18),
                const SizedBox(width: 8),
              ],
              Text(label),
            ],
          );

    Widget button;
    switch (variant) {
      case EdiumButtonVariant.primary:
        button = ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          child: child,
        );
        break;
      case EdiumButtonVariant.outline:
        button = OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          child: DefaultTextStyle.merge(
            style: AppTextStyles.button.copyWith(color: AppColors.primary),
            child: child,
          ),
        );
        break;
      case EdiumButtonVariant.ghost:
        button = TextButton(
          onPressed: isLoading ? null : onPressed,
          child: child,
        );
        break;
    }

    if (width != null) {
      return SizedBox(width: width, child: button);
    }
    return button;
  }
}
