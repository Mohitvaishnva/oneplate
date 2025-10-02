import 'package:flutter/material.dart';

// App Colors
class AppColors {
  static const Color primaryPurple = Color(0xFF8B5CF6);
  static const Color primaryBlue = Color(0xFF7C3AED);
  static const Color white = Color(0xFFFFFFFF);
  static const Color lightGrey = Color(0xFFF5F5F5);
  static const Color darkGrey = Color(0xFF757575);
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFE57373);
  static const Color warning = Color(0xFFFF9800);
}

// App Gradients
class AppGradients {
  static const LinearGradient primary = LinearGradient(
    colors: [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient primaryVertical = LinearGradient(
    colors: [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
  
  static const LinearGradient subtle = LinearGradient(
    colors: [Color(0xFFF8F9FA), Color(0xFFE9ECEF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

// App Text Styles
class AppTextStyles {
  static TextStyle get heading1 => const TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.white,
    fontFamily: 'SF Pro Display',
  );
  
  static TextStyle get heading2 => const TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: Colors.black87,
    fontFamily: 'SF Pro Display',
  );
  
  static TextStyle get heading3 => const TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: Colors.black87,
    fontFamily: 'SF Pro Display',
  );
  
  static TextStyle get bodyLarge => const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: Colors.black87,
    fontFamily: 'SF Pro Display',
  );
  
  static TextStyle get bodyMedium => const TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: Colors.black87,
    fontFamily: 'SF Pro Display',
  );
  
  static TextStyle get bodySmall => const TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.darkGrey,
    fontFamily: 'SF Pro Display',
  );
  
  static TextStyle get buttonText => const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.white,
    fontFamily: 'SF Pro Display',
  );
  
  static TextStyle get caption => const TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.darkGrey,
    fontFamily: 'SF Pro Display',
  );
}

// App Shadows
class AppShadows {
  static List<BoxShadow> get soft => [
    BoxShadow(
      color: Colors.black.withOpacity(0.08),
      blurRadius: 10,
      offset: const Offset(0, 4),
    ),
  ];
  
  static List<BoxShadow> get medium => [
    BoxShadow(
      color: Colors.black.withOpacity(0.12),
      blurRadius: 15,
      offset: const Offset(0, 6),
    ),
  ];
  
  static List<BoxShadow> get strong => [
    BoxShadow(
      color: Colors.black.withOpacity(0.16),
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
  ];
}

// App Border Radius
class AppBorderRadius {
  static BorderRadius get small => BorderRadius.circular(8.0);
  static BorderRadius get medium => BorderRadius.circular(12.0);
  static BorderRadius get large => BorderRadius.circular(16.0);
  static BorderRadius get extraLarge => BorderRadius.circular(24.0);
}

// App Spacing
class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
}

// App Theme
class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: AppColors.primaryPurple,
      scaffoldBackgroundColor: AppColors.white,
      fontFamily: 'SF Pro Display',
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        titleTextStyle: AppTextStyles.heading3.copyWith(color: AppColors.white),
        iconTheme: const IconThemeData(color: AppColors.white),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
          shape: RoundedRectangleBorder(borderRadius: AppBorderRadius.medium),
          textStyle: AppTextStyles.buttonText,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.lightGrey,
        border: OutlineInputBorder(
          borderRadius: AppBorderRadius.medium,
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppBorderRadius.medium,
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppBorderRadius.medium,
          borderSide: const BorderSide(color: AppColors.primaryPurple, width: 2),
        ),
        contentPadding: const EdgeInsets.all(AppSpacing.md),
        labelStyle: AppTextStyles.bodyMedium,
        hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.darkGrey),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: AppBorderRadius.medium),
        margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      ),
    );
  }
}