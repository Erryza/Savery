import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const primary = Color(0xFF2563EB);
  static const success = Color(0xFF10B981);
  static const danger = Color(0xFFEF4444);
  static const warning = Color(0xFFF59E0B);
  static const accent = Color(0xFF8B5CF6);
  static const darkText = Color(0xFF111827);
  static const grayText = Color(0xFF6B7280);
  static const cardBg = Color(0xFFFFFFFF);
  static const scaffoldBg = Color(0xFFF0F4FF);
  static const divider = Color(0xFFF3F4F6);

  static const primaryLight = Color(0xFFDBEAFE);
  static const successLight = Color(0xFFD1FAE5);
  static const dangerLight = Color(0xFFFEE2E2);
  static const warningLight = Color(0xFFFEF3C7);
  static const accentLight = Color(0xFFEDE9FE);
}

extension ThemeX on BuildContext {
  Color get appBg => AppColors.scaffoldBg;
  Color get appSurface => Colors.white;
  Color get appSurfaceAlt => AppColors.scaffoldBg;
  Color get appBarColor => Colors.white;
  Color get appText => AppColors.darkText;
  Color get appSubtext => AppColors.grayText;
  Color get appLine => AppColors.divider;
  Color get appShadow => Colors.black12;
  Color get appPrimaryLight => AppColors.primaryLight;
}

class AppTheme {
  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: AppColors.scaffoldBg,
      fontFamily: GoogleFonts.inter().fontFamily,
      textTheme: GoogleFonts.interTextTheme(),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: GoogleFonts.inter(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.cardBg,
        elevation: 2,
        shadowColor: Colors.black12,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.cardBg,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.grayText,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}
