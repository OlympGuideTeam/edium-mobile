import 'package:edium/core/theme/app_colors.dart';
import 'package:edium/core/theme/app_dimens.dart';
import 'package:flutter/material.dart';

class EdiumConfirmDialog extends StatelessWidget {
  final String title;
  final String body;
  final String confirmLabel;
  final String cancelLabel;
  final bool isDestructive;

  const EdiumConfirmDialog({
    super.key,
    required this.title,
    required this.body,
    required this.confirmLabel,
    required this.cancelLabel,
    this.isDestructive = false,
  });

  static Future<bool?> show(
    BuildContext context, {
    required String title,
    required String body,
    required String confirmLabel,
    required String cancelLabel,
    bool isDestructive = false,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (_) => EdiumConfirmDialog(
        title: title,
        body: body,
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
        isDestructive: isDestructive,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.mono900,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              body,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.mono600,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: AppDimens.buttonHSm,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      isDestructive ? AppColors.error : AppColors.mono900,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppDimens.radiusLg),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  confirmLabel,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: AppDimens.buttonHSm,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context, false),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.mono150),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppDimens.radiusLg),
                  ),
                ),
                child: Text(
                  cancelLabel,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.mono700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
