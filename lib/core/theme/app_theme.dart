import 'package:driver_app_saferide/core/theme/app_color.dart';
import 'package:driver_app_saferide/core/theme/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTheme{
  static ThemeData get dark => _buildTheme(
    brightness:Brightness.dark,
    bg:AppColors.bgDark,
    surface: AppColors.surfaceDark,
    surfaceVariant: AppColors.surfaceVariantDark,
    
    border: AppColors.borderDark,
    textPrimary:AppColors.textPrimaryDark,
    textSecondary:AppColors.textSecondaryDark,
    accent:AppColors.accentDark,
    success:AppColors.successDark,
    danger:AppColors.dangerDark,
  );
    static ThemeData get light => _buildTheme(
    brightness: Brightness.light,
    bg: AppColors.bgLight,
    surface: AppColors.surfaceLight,
    surfaceVariant: AppColors.surfaceVariantLight,
    border: AppColors.borderLight,
    textPrimary: AppColors.textPrimaryLight,
    textSecondary: AppColors.textSecondaryLight,
    accent: AppColors.accentLight,
    success: AppColors.successLight,
    danger: AppColors.dangerLight,
  );
  static ThemeData _buildTheme({
required Brightness brightness,
required Color bg,
required Color surface,
required Color surfaceVariant,
 required Color border,
    required Color textPrimary,
    required Color textSecondary,
    required Color accent,
    required Color success,
    required Color danger,
  }){
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: bg,
      fontFamily: AppTypography.bodyFont,
      colorScheme: ColorScheme(brightness: brightness, primary: accent,
        onPrimary: brightness == Brightness.dark ? Colors.black : Colors.white,
        secondary: success,
        onSecondary: Colors.white,
        error: danger,
        onError: Colors.white,
        surface: surface,
        onSurface: textPrimary,
      ),
      
        appBarTheme: AppBarTheme(
        backgroundColor: bg,
        foregroundColor: textPrimary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: AppTypography.heading(color: textPrimary),
        systemOverlayStyle: brightness == Brightness.dark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
      ),
         elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: brightness == Brightness.dark
              ? Colors.black
              : Colors.white,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: AppTypography.heading(
            color: brightness == Brightness.dark ? Colors.black : Colors.white,
            size: 15,
          ),
          elevation: 0,
        ),
      ),
       inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: accent, width: 1.5),
        ),
        hintStyle: AppTypography.body(color: textSecondary),
        labelStyle: AppTypography.caption(color: textSecondary),
      ),
      // cardTheme: CardTheme(
      //   color: surface,
      //   elevation: 0,
      //   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      //   margin: EdgeInsets.zero,
      // ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: bg,
        selectedItemColor: accent,
        unselectedItemColor: textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      dividerColor: border,
      dividerTheme: DividerThemeData(color: border, thickness: 1, space: 0),
    
    );
  }
}