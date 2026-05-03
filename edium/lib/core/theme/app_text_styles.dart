import 'package:flutter/material.dart';
import 'package:edium/core/theme/app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  static const TextStyle heading1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: -0.5,
    height: 1.2,
  );

  static const TextStyle heading2 = TextStyle(
    fontSize: 26,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: -0.3,
    height: 1.2,
  );

  static const TextStyle heading3 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.3,
  );

  static const TextStyle subtitle = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.4,
  );

  static const TextStyle body = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    height: 1.5,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    height: 1.5,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.4,
  );

  static const TextStyle button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.2,
  );

  static const TextStyle label = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
    letterSpacing: 0.1,
  );

  // ── Монохромный UI (auth-экраны и новые экраны) ──────────────────────────

  static const TextStyle screenTitle = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: AppColors.mono900,
  );

  static const TextStyle screenSubtitle = TextStyle(
    fontSize: 14,
    color: AppColors.mono400,
    height: 1.4,
  );

  static const TextStyle fieldLabel = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: AppColors.mono400,
  );

  static const TextStyle fieldText = TextStyle(
    fontSize: 15,
    color: AppColors.mono700,
  );

  static const TextStyle fieldHint = TextStyle(
    fontSize: 15,
    color: AppColors.mono250,
  );

  static const TextStyle helperText = TextStyle(
    fontSize: 12,
    color: AppColors.mono300,
    height: 1.5,
  );

  static const TextStyle badgeText = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w700,
    color: Colors.white,
    letterSpacing: 1.0,
  );

  static const TextStyle primaryButton = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle secondaryButton = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle otpDigit = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: AppColors.mono700,
  );

  // Shorthand aliases
  static const TextStyle h1 = heading1;
  static const TextStyle h2 = heading2;
  static const TextStyle h3 = heading3;

  static const TextStyle sectionTag = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w700,
    color: AppColors.mono350,
    letterSpacing: 0.5,
  );
}
