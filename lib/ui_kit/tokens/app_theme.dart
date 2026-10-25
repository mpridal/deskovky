import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_typography.dart';

ThemeData buildAppTheme() {
  final colorScheme = ColorScheme.fromSeed(seedColor: AppColors.felt).copyWith(
    primary: AppColors.gold,
    onPrimary: AppColors.ink,
    surface: AppColors.paper,
    onSurface: AppColors.ink,
  );

  final navLabel = WidgetStateProperty.resolveWith<TextStyle>(
    (states) => AppTypography.caption(
      color: states.contains(WidgetState.selected) ? AppColors.gold : AppColors.woodLight,
    ),
  );
  final navIcon = WidgetStateProperty.resolveWith<IconThemeData>(
    (states) => IconThemeData(
      color: states.contains(WidgetState.selected) ? AppColors.ink : AppColors.woodLight,
    ),
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: AppColors.felt,
    fontFamily: AppTypography.bodyFamily,
    textTheme: TextTheme(
      headlineLarge: AppTypography.h1(color: AppColors.paper),
      headlineSmall: AppTypography.h2(color: AppColors.paper),
      bodyLarge: AppTypography.body(color: AppColors.paper),
      bodyMedium: AppTypography.body(color: AppColors.paper),
      labelLarge: AppTypography.button(),
      labelSmall: AppTypography.caption(),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: AppColors.walnut,
      indicatorColor: AppColors.gold,
      labelTextStyle: navLabel,
      iconTheme: navIcon,
    ),
    navigationRailTheme: NavigationRailThemeData(
      backgroundColor: AppColors.walnut,
      indicatorColor: AppColors.gold,
      selectedLabelTextStyle: AppTypography.caption(color: AppColors.gold),
      unselectedLabelTextStyle: AppTypography.caption(color: AppColors.woodLight),
      selectedIconTheme: const IconThemeData(color: AppColors.ink),
      unselectedIconTheme: const IconThemeData(color: AppColors.woodLight),
    ),
  );
}
