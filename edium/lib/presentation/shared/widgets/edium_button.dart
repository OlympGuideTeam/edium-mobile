import 'package:edium/core/theme/app_colors.dart';
import 'package:edium/core/theme/app_dimens.dart';
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
  final double? height;

  const EdiumButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = EdiumButtonVariant.primary,
    this.isLoading = false,
    this.icon,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      height: height ?? AppDimens.buttonH,
      child: _buildButton(),
    );
  }

  Widget _buildButton() {
    final child = _buildChild();

    return switch (variant) {
      EdiumButtonVariant.primary => ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.mono900,
            foregroundColor: Colors.white,
            disabledBackgroundColor: AppColors.mono200,
            disabledForegroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimens.radiusLg),
            ),
            textStyle: AppTextStyles.primaryButton,
          ),
          child: child,
        ),
      EdiumButtonVariant.outline => OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.mono900,
            disabledForegroundColor: AppColors.mono200,
            elevation: 0,
            side: BorderSide(
              color: onPressed != null ? AppColors.mono900 : AppColors.mono200,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimens.radiusLg),
            ),
            textStyle: AppTextStyles.primaryButton,
          ),
          child: child,
        ),
      EdiumButtonVariant.ghost => TextButton(
          onPressed: isLoading ? null : onPressed,
          style: TextButton.styleFrom(
            foregroundColor: AppColors.mono900,
            disabledForegroundColor: AppColors.mono200,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimens.radiusLg),
            ),
            textStyle: AppTextStyles.primaryButton,
          ),
          child: child,
        ),
    };
  }

  Widget _buildChild() {
    if (isLoading) {
      return const SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: Colors.white,
        ),
      );
    }

    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 8),
          Text(label),
        ],
      );
    }

    return Text(label);
  }
}
