import 'package:flutter/material.dart';
import 'colors.dart';

class AppTextStyles {
  AppTextStyles._();

  static const TextStyle label = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w900,
    letterSpacing: 2.8,
    color: AppColors.textTertiary,
  );

  static const TextStyle labelTeal = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w900,
    letterSpacing: 3.2,
    color: AppColors.tealDark,
  );

  static const TextStyle heading1 = TextStyle(
    fontSize: 56,
    fontWeight: FontWeight.w900,
    letterSpacing: -3.5,
    color: AppColors.textPrimary,
    height: 0.95,
  );

  static const TextStyle heading2 = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w900,
    letterSpacing: -1.2,
    color: AppColors.textPrimary,
  );

  static const TextStyle heading3 = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w900,
    letterSpacing: -0.8,
    color: AppColors.textPrimary,
  );

  static const TextStyle heading4 = TextStyle(
    fontSize: 36,
    fontWeight: FontWeight.w900,
    letterSpacing: -2.0,
    color: AppColors.textPrimary,
  );

  static const TextStyle body = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 1.6,
    color: AppColors.textSecondary,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textSecondary,
  );

  static const TextStyle buttonPrimary = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w900,
    color: Colors.white,
  );

  static const TextStyle buttonSecondary = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w900,
    color: AppColors.textPrimary,
  );

  static const TextStyle taskTitle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w900,
    color: AppColors.textPrimary,
  );

  static const TextStyle taskTitleDone = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w900,
    color: AppColors.textTertiary,
    decoration: TextDecoration.lineThrough,
  );

  static const TextStyle bigNumber = TextStyle(
    fontSize: 48,
    fontWeight: FontWeight.w900,
    letterSpacing: -2.5,
    color: Colors.white,
  );
}
