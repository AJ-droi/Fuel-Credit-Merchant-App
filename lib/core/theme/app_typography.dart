import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

final class AppTypography {
  const AppTypography._();

  static TextTheme textTheme() {
    return TextTheme(
      displayLarge: GoogleFonts.getFont(
        'Geist',
        fontSize: 48,
        fontWeight: FontWeight.w700,
        height: 56 / 48,
        letterSpacing: -0.96,
        color: AppColors.onBackground,
      ),
      headlineLarge: GoogleFonts.getFont(
        'Geist',
        fontSize: 32,
        fontWeight: FontWeight.w600,
        height: 40 / 32,
        letterSpacing: -0.32,
        color: AppColors.onBackground,
      ),
      headlineSmall: GoogleFonts.getFont(
        'Geist',
        fontSize: 24,
        fontWeight: FontWeight.w600,
        height: 32 / 24,
        color: AppColors.onBackground,
      ),
      bodyLarge: GoogleFonts.getFont(
        'Geist',
        fontSize: 16,
        height: 24 / 16,
        color: AppColors.onBackground,
      ),
      bodyMedium: GoogleFonts.getFont(
        'JetBrains Mono',
        fontSize: 14,
        fontWeight: FontWeight.w500,
        height: 20 / 14,
        color: AppColors.onBackground,
      ),
      labelSmall: GoogleFonts.getFont(
        'JetBrains Mono',
        fontSize: 12,
        fontWeight: FontWeight.w600,
        height: 16 / 12,
        color: AppColors.muted,
      ),
    );
  }
}
