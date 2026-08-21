import 'package:flutter/material.dart';
import 'colors.dart';

/*
From here on: mostly AI generated code for the app theme, I am more interested in writing business logic code,
 instead of styling everything in detail
*/

class AppTheme {
  // --- LIGHT THEME ---
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primaryOrange,
        surface: AppColors.surfaceLight,
        onSurface: AppColors.textPrimaryLight,
        background: AppColors.backgroundLight,
      ),
      scaffoldBackgroundColor: AppColors.backgroundLight,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.backgroundLight,
        foregroundColor: AppColors.textPrimaryLight,
        elevation: 0,
      ),
      
      // Global fix for the "cheap" flash: removes the ripple/splash effect
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,

      // Styling for modern Material 3 NavigationBar
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.backgroundLight,
        indicatorColor: AppColors.primaryOrange.withValues(alpha: 0.1), // Subtle orange glow
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(color: AppColors.primaryOrange, fontWeight: FontWeight.bold, fontSize: 12);
          }
          return const TextStyle(color: AppColors.textSecondaryLight, fontSize: 12);
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppColors.primaryOrange);
          }
          return const IconThemeData(color: AppColors.textSecondaryLight);
        }),
      ),

      // Styling for legacy BottomNavigationBar (fallback)
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.backgroundLight,
        selectedItemColor: AppColors.primaryOrange,
        unselectedItemColor: AppColors.textSecondaryLight,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),

      textTheme: const TextTheme(
        displayLarge: TextStyle(color: AppColors.primaryOrange, fontWeight: FontWeight.bold),
        headlineMedium: TextStyle(color: AppColors.primaryOrange, fontWeight: FontWeight.w600),
        bodyLarge: TextStyle(color: AppColors.textPrimaryLight),
        bodyMedium: TextStyle(color: AppColors.textSecondaryLight),
      ),
    );
  }

  // --- DARK THEME ---
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primaryOrange,
        surface: AppColors.surfaceDark,
        onSurface: AppColors.textPrimaryDark,
        background: AppColors.backgroundDark,
      ),
      scaffoldBackgroundColor: AppColors.backgroundDark,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.backgroundDark,
        foregroundColor: AppColors.textPrimaryDark,
        elevation: 0,
      ),

      // Global fix for the "cheap" flash: removes the ripple/splash effect
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,

      // Styling for modern Material 3 NavigationBar
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.backgroundDark,
        indicatorColor: AppColors.primaryOrange.withValues(alpha: 0.15), // Subtle orange glow
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(color: AppColors.primaryOrange, fontWeight: FontWeight.bold, fontSize: 12);
          }
          return const TextStyle(color: AppColors.textSecondaryDark, fontSize: 12);
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppColors.primaryOrange);
          }
          return const IconThemeData(color: AppColors.textSecondaryDark);
        }),
      ),

      // Styling for legacy BottomNavigationBar (fallback)
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.backgroundDark,
        selectedItemColor: AppColors.primaryOrange,
        unselectedItemColor: AppColors.textSecondaryDark,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),

      textTheme: const TextTheme(
        displayLarge: TextStyle(color: AppColors.primaryOrange, fontWeight: FontWeight.bold),
        headlineMedium: TextStyle(color: AppColors.primaryOrange, fontWeight: FontWeight.w600),
        bodyLarge: TextStyle(color: AppColors.textPrimaryDark),
        bodyMedium: TextStyle(color: AppColors.textSecondaryDark),
        bodySmall: TextStyle(color: AppColors.textSecondaryDark),
      ),
    );
  }
}
