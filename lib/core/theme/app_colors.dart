import 'package:flutter/material.dart';

final class AppColors {
  const AppColors._();

  /// Slate-50 page background (FuelLend mockup)
  static const Color background = Color(0xFFF8FAFC);
  static const Color onBackground = Color(0xFF0F172A); // slate-900
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceBright = Color(0xFFECFDF5); // emerald-50

  /// Emerald-900 brand
  static const Color primary = Color(0xFF064E3B);
  static const Color primaryLight = Color(0xFF065F46); // emerald-800
  static const Color primaryContainer = Color(0xFF064E3B);
  static const Color onPrimaryContainer = Color(0xFFFFFFFF);
  static const Color primaryDark = Color(0xFF022C22); // emerald-950

  /// Yellow accent (replaces old blue secondary for brand cohesion)
  static const Color secondary = Color(0xFFEAB308); // yellow-500
  static const Color secondaryContainer = Color(0xFFFEF9C3); // yellow-100
  static const Color onSecondary = Color(0xFF0F172A);
  static const Color accent = Color(0xFFFACC15); // yellow-400

  static const Color tertiary = Color(0xFFEAB308);
  static const Color muted = Color(0xFF64748B); // slate-500
  static const Color outline = Color(0xFF334155); // slate-700
  static const Color glass = Color(0x14064E3B);
  static const Color border = Color(0xFFF1F5F9); // slate-100
  static const Color borderStrong = Color(0xFFE2E8F0); // slate-200
  static const Color inputFill = Color(0xFFF8FAFC);
  static const Color navBar = Color(0xFFFFFFFF);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color danger = Color(0xFFDC2626);
  static const Color success = Color(0xFF064E3B);

  static const Color emeraldMuted = Color(0xFF6EE7B7);
  static const Color slate50 = Color(0xFFF8FAFC);
  static const Color slate100 = Color(0xFFF1F5F9);
  static const Color slate200 = Color(0xFFE2E8F0);
  static const Color slate400 = Color(0xFF94A3B8);
  static const Color slate500 = Color(0xFF64748B);
  static const Color slate700 = Color(0xFF334155);
  static const Color slate900 = Color(0xFF0F172A);

  static const Color kpiSalesBg = Color(0xFFECFDF5);
  static const Color kpiGrossBg = Color(0xFFFEF9C3);
  static const Color kpiSettlementBg = Color(0xFFF1F5F9);

  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF022C22), Color(0xFF064E3B), Color(0xFF065F46)],
  );
}
