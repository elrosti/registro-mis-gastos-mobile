import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary Colors
  static const Color primaryMain = Color(0xFF2563EB);
  static const Color primaryLight = Color(0xFF3B82F6);
  static const Color primaryDark = Color(0xFF1D4ED8);
  static const Color primaryContrast = Color(0xFFFFFFFF);

  // Background Colors
  static const Color backgroundDefault = Color(0xFFF5F7FA);
  static const Color backgroundPaper = Color(0xFFFFFFFF);
  static const Color backgroundSidebar = Color(0xFF1E293B);

  // Success/Income Colors
  static const Color successMain = Color(0xFF22C55E);
  static const Color successLight = Color(0xFF4ADE80);
  static const Color successDark = Color(0xFF16A34A);

  // Error/Expense Colors
  static const Color errorMain = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFF87171);
  static const Color errorDark = Color(0xFFDC2626);

  // Warning Colors
  static const Color warningMain = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFBBF24);
  static const Color warningDark = Color(0xFFD97706);

  // Info/Balance Colors
  static const Color infoMain = Color(0xFF3B82F6);
  static const Color infoLight = Color(0xFF60A5FA);
  static const Color infoDark = Color(0xFF2563EB);

  // Text Colors (never use pure black)
  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textDisabled = Color(0xFF9CA3AF);
  static const Color textInverse = Color(0xFFFFFFFF);

  // Border Colors
  static const Color borderMain = Color(0xFFE5E7EB);
  static const Color borderLight = Color(0xFFF3F4F6);
  static const Color borderDark = Color(0xFFD1D5DB);

  // Sidebar Colors
  static const Color sidebarBackground = Color(0xFF1E293B);
  static const Color sidebarItemHover = Color(0xFF334155);
  static const Color sidebarItemActive = Color(0xFF475569);
  static const Color sidebarText = Color(0xFFF8FAFC);
  static const Color sidebarTextSecondary = Color(0xFF94A3B8);

  // Income/Expense helpers
  static Color getTransactionColor(bool isIncome) =>
      isIncome ? successMain : errorMain;

  static Color getTransactionBackgroundColor(bool isIncome) =>
      isIncome ? successLight.withOpacity(0.1) : errorLight.withOpacity(0.1);
}
