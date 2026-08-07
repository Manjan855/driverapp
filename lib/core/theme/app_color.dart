import 'package:flutter/material.dart';

/// Color tokens for both light and dark mode. Every color used anywhere
/// in the app should come from here — never a hardcoded hex in a widget.
class AppColors {
  // ---- Brand accent (amber) — darkened for light mode, bright for dark ----
  static const Color accentDark = Color(0xFFFFB020);   // dark mode amber
  static const Color accentLight = Color(0xFFC97A0E);  // light mode amber

  // ---- Status colors — also mode-aware ----
  static const Color successDark = Color(0xFF3DDC84);
  static const Color successLight = Color(0xFF1A8F52);

  static const Color dangerDark = Color(0xFFFF5C5C);
  static const Color dangerLight = Color(0xFFC23B3B);

  static const Color warningDark = Color(0xFFFFB020);
  static const Color warningLight = Color(0xFFC97A0E);

  // ---- Surfaces — dark mode ----
  static const Color bgDark = Color(0xFF0B0E14);       // page background
  static const Color surfaceDark = Color(0xFF141925);  // card surface
  static const Color surfaceVariantDark = Color(0xFF1A2030); // avatar bg, dividers
  static const Color borderDark = Color(0xFF2A3142);

  // ---- Surfaces — light mode ----
  static const Color scheme =Color(0xFF191911);
  static const Color bgLight = Color(0xFFEDEFF3);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceVariantLight = Color(0xFFEDEFF3);
  static const Color borderLight = Color(0xFFD7DAE0);

  // ---- Text — dark mode ----
  static const Color textPrimaryDark = Color(0xFFFFFFFF);
  static const Color textSecondaryDark = Color(0xFF8B93A7);
  static const Color textMutedDark = Color(0xFF4A5268);

  // ---- Text — light mode ----
  static const Color textPrimaryLight = Color(0xFF10131A);
  static const Color textSecondaryLight = Color(0xFF6B7280);
  static const Color textMutedLight = Color(0xFF9CA3AF);
}