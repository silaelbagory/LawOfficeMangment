import 'package:flutter/material.dart';

class AppConstants {
  // App Information
  static const String appName = 'Law Office Management';
  static const String appVersion = '1.0.0';
  
  // Firebase Collections
  static const String usersCollection = 'users';
  static const String casesCollection = 'cases';
  static const String clientsCollection = 'clients';
  static const String documentsCollection = 'documents';
  
  // Storage Paths
  static const String documentsStoragePath = 'documents';
  static const String profileImagesStoragePath = 'profile_images';
  
  // Validation
  static const int minPasswordLength = 6;
  static const int maxNameLength = 50;
  static const int maxDescriptionLength = 500;
  
  // UI Constants
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double borderRadius = 12.0;
  static const double cardElevation = 4.0;
  
  // Responsive Breakpoints
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 1200;
  
  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);
}


class AppColors {
  // Light Theme Colors
  static const Color primaryLight = Color(0xFFD4AF37); // Gold
  static const Color secondaryLight = Color(0xFF0D1B2A); // Navy
  static const Color surfaceLight = Color(0xFFFFFFFF); // White cards
  static const Color backgroundLight = Color(0xFFF9F9F9); // Light gray (شفاف مع Scaffold)
  static const Color errorLight = Color(0xFFB00020);
  static const Color onPrimaryLight = Color(0xFFFFFFFF);
  static const Color onSecondaryLight = Color(0xFF000000);
  static const Color onSurfaceLight = Color(0xFF0D1B2A); // نص داكن
  static const Color onBackgroundLight = Color(0xFF000000);
  static const Color onErrorLight = Color(0xFFFFFFFF);

  // Dark Theme Colors
  static const Color primaryDark = Color(0xFFD4AF37); // Gold accent
  static const Color secondaryDark = Color(0xFF1B263B); // Dark slate
  static const Color surfaceDark = Color(0xFF121212); // Dark cards
  static const Color backgroundDark = Color(0xFF000000); // شفافية لصورة الليل
  static const Color errorDark = Color(0xFFCF6679);
  static const Color onPrimaryDark = Color(0xFF000000);
  static const Color onSecondaryDark = Color(0xFFFFFFFF);
  static const Color onSurfaceDark = Color(0xFFFFFFFF); // White text
  static const Color onBackgroundDark = Color(0xFFFFFFFF);
  static const Color onErrorDark = Color(0xFF000000);

  // Status Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color info = Color(0xFF2196F3);

  // Case Status Colors
  static const Color caseOpen = Color(0xFF4CAF50);
  static const Color caseInProgress = Color(0xFFFF9800);
  static const Color caseClosed = Color(0xFF9E9E9E);
  static const Color caseOnHold = Color(0xFFF44336);
}

class AppTextStyles {
  static const TextStyle headlineSmall = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
  );
}

class AppThemes {
  static ThemeData get lightTheme {
    return ThemeData(
      fontFamily: null,
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: Colors.transparent, // الصورة تبان
      colorScheme: const ColorScheme.light(
        primary: AppColors.primaryLight,
        secondary: AppColors.secondaryLight,
        surface: AppColors.surfaceLight,
        background: AppColors.backgroundLight,
        error: AppColors.errorLight,
        onPrimary: AppColors.onPrimaryLight,
        onSecondary: AppColors.onSecondaryLight,
        onSurface: AppColors.onSurfaceLight,
        onBackground: AppColors.onBackgroundLight,
        onError: AppColors.onErrorLight,
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.secondaryLight,
        titleTextStyle: AppTextStyles.headlineSmall,
      ),
      cardTheme: CardTheme(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: const EdgeInsets.all(12),
        color: AppColors.surfaceLight,
        shadowColor: AppColors.secondaryLight.withOpacity(0.1),
      ),
      textTheme: const TextTheme(
        headlineSmall: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: AppColors.onSurfaceLight,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: AppColors.onSurfaceLight,
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: Colors.transparent, // صورة الليل تبان
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primaryDark,
        secondary: AppColors.secondaryDark,
        surface: AppColors.surfaceDark,
        background: AppColors.backgroundDark,
        error: AppColors.errorDark,
        onPrimary: AppColors.onPrimaryDark,
        onSecondary: AppColors.onSecondaryDark,
        onSurface: AppColors.onSurfaceDark,
        onBackground: AppColors.onBackgroundDark,
        onError: AppColors.onErrorDark,
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.primaryDark,
        titleTextStyle: AppTextStyles.headlineSmall,
      ),
      cardTheme: CardTheme(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: const EdgeInsets.all(12),
        color: AppColors.surfaceDark,
        shadowColor: AppColors.primaryDark.withOpacity(0.2),
      ),
      textTheme: const TextTheme(
        headlineSmall: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: AppColors.onSurfaceDark,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: AppColors.onSurfaceDark,
        ),
      ),
    );
  }
}
