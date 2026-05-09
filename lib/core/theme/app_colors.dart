import 'package:flutter/material.dart';

class AppColors {
  const AppColors._();

  // Primary Brand
  static const Color primary = Color(0xFFFF6F00);
  static const Color primaryDark = Color(0xFFE65100);
  static const Color primaryLight = Color(0xFFFFF3E0);

  // Text
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textHint = Color(0xFFBDBDBD);

  // Surfaces
  static const Color surface = Color(0xFFFFFFFF);
  static const Color cardSurface = surface;
  static const Color background = Color(0xFFF5F5F5);
  static const Color divider = Color(0xFFEEEEEE);
  static const Color bannerTint = primaryLight;
  static const Color transparent = Colors.transparent;

  // Semantic
  static const Color success = Color(0xFF2E7D32);
  static const Color error = Color(0xFFB71C1C);
  static const Color warning = Color(0xFFF57F17);

  // Order slip status
  static const Color statusDraft = Color(0xFFF9A825);
  static const Color statusShared = Color(0xFF1565C0);
  static const Color statusDelivered = Color(0xFF2E7D32);
  static const Color statusCancelled = Color(0xFFB71C1C);

  // Khata-specific
  static const Color khataCredit = Color(0xFF1B5E20);
  static const Color khataDebit = Color(0xFFB71C1C);
}
