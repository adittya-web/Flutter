import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Colors.blue;
  static const Color secondary = Colors.lightBlueAccent;
  static const Color background = Color(0xFFF9FAFB);
  static const Color card = Colors.white;
  static const Color textDark = Colors.black87;
  static const Color textLight = Colors.grey;
}

class AppTextStyles {
  static const TextStyle heading = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: AppColors.textDark,
  );

  static const TextStyle subheading = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.textDark,
  );

  static const TextStyle body = TextStyle(
    fontSize: 14,
    color: AppColors.textLight,
  );

  static const TextStyle label = TextStyle(
    fontSize: 13,
    color: AppColors.textLight,
  );
}
