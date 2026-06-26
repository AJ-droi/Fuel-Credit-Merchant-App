import 'package:flutter/material.dart';

final class AppColors {
  const AppColors._();

  static const Color background = Color(0xFFF0F4F2);
  static const Color onBackground = Color(0xFF142119);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceBright = Color(0xFFE3F9EC);
  static const Color primary = Color(0xFF0FA958);
  static const Color primaryLight = Color(0xFF5EE09A);
  static const Color primaryContainer = Color(0xFF087A44);
  static const Color onPrimaryContainer = Color(0xFFFFFFFF);
  static const Color secondary = Color(0xFFFF3D7A);
  static const Color secondaryContainer = Color(0xFFFFD9E8);
  static const Color tertiary = Color(0xFFFFA726);
  static const Color muted = Color(0xFF5F6B64);
  static const Color outline = Color(0xFF37443C);
  static const Color glass = Color(0x14142119);
  static const Color border = Color(0x33142119);
  static const Color borderStrong = Color(0x59142119);
  static const Color inputFill = Color(0xFFE8EFEB);
  static const Color navBar = Color(0xFFFFFFFF);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color danger = Color(0xFFE53935);
  static const Color success = Color(0xFF087A44);

  static const Color kpiSalesBg = Color(0xFFFFE4EF);
  static const Color kpiGrossBg = Color(0xFFDDF5E8);
  static const Color kpiSettlementBg = Color(0xFFFFF0D6);

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF12C06A), Color(0xFF087A44)],
  );

  static const LinearGradient heroMeshPrimary = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0x400FA958), Color(0x000FA958)],
  );

  static const LinearGradient heroMeshSecondary = LinearGradient(
    begin: Alignment.bottomRight,
    end: Alignment.topLeft,
    colors: [Color(0x35FF3D7A), Color(0x00FF3D7A)],
  );
}
