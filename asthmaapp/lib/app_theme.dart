import 'package:flutter/material.dart';

/// App-wide theme for Asthma Activity Advisor.
/// Boise State brand-aligned palette and typography.
class AppTheme {
  AppTheme._();

  /// Boise State official colors.
  ///
  /// Source: https://www.boisestate.edu/brand/visual-identity/colors/
  static const Color bsuBlue = Color(0xFF0033A0); // Pantone 286C
  static const Color bsuOrange = Color(0xFFD64309); // Pantone 172C

  /// Neutral palette (should recede behind blue/orange).
  static const Color surface = Color(0xFFF7F8FA);
  static const Color surfaceCard = Color(0xFFFFFFFF);
  static const Color borderSubtle = Color(0x1F000000); // ~12% black

  /// Text on light surfaces.
  static const Color textPrimary = Color(0xFF1D1E20);
  static const Color textSecondary = Color(0xFF4B5563);

  /// Link color policy: use BSU blue.
  static const Color linkColor = bsuBlue;

  /// Typography fallbacks per brand standards: Montserrat/Arial and Georgia.
  static const String sansFamily = 'Gotham';
  static const String serifFamily = 'Garamond';
  static const List<String> sansFallback = <String>['Arial', 'sans-serif'];
  static const List<String> serifFallback = <String>[
    'Georgia',
    'Times New Roman',
    'serif',
  ];

  static TextStyle? _normal(TextStyle? s) {
    if (s == null) return null;
    return s.copyWith(fontStyle: FontStyle.normal);
  }

  static TextTheme _forceNoItalics(TextTheme t) {
    return t.copyWith(
      displayLarge: _normal(t.displayLarge),
      displayMedium: _normal(t.displayMedium),
      displaySmall: _normal(t.displaySmall),
      headlineLarge: _normal(t.headlineLarge),
      headlineMedium: _normal(t.headlineMedium),
      headlineSmall: _normal(t.headlineSmall),
      titleLarge: _normal(t.titleLarge),
      titleMedium: _normal(t.titleMedium),
      titleSmall: _normal(t.titleSmall),
      bodyLarge: _normal(t.bodyLarge),
      bodyMedium: _normal(t.bodyMedium),
      bodySmall: _normal(t.bodySmall),
      labelLarge: _normal(t.labelLarge),
      labelMedium: _normal(t.labelMedium),
      labelSmall: _normal(t.labelSmall),
    );
  }

  static ThemeData get lightTheme {
    final baseScheme = ColorScheme.fromSeed(
      seedColor: bsuBlue,
      brightness: Brightness.light,
      primary: bsuBlue,
      onPrimary: Colors.white,
      secondary: bsuOrange,
      onSecondary: Colors.white,
      surface: surface,
      onSurface: textPrimary,
    );

    final baseTextTheme = Typography.material2021().black;
    final sansTheme = _forceNoItalics(baseTextTheme.apply(
      fontFamily: sansFamily,
      bodyColor: textPrimary,
      displayColor: textPrimary,
    ));

    // Use Garamond for body copy to soften the UI (keeps headings in Gotham).
    final serifBodyTheme = _forceNoItalics(baseTextTheme.apply(
      fontFamily: serifFamily,
      bodyColor: textPrimary,
      displayColor: textPrimary,
    ));

    final textTheme = sansTheme.copyWith(
      // Explicitly pin title styles to non-italic Gotham; some platform font
      // matching can otherwise pick an italic face when one is bundled.
      titleLarge: const TextStyle(
        fontFamily: sansFamily,
        fontStyle: FontStyle.normal,
      ).merge(sansTheme.titleLarge),
      titleMedium: const TextStyle(
        fontFamily: sansFamily,
        fontStyle: FontStyle.normal,
      ).merge(sansTheme.titleMedium),
      titleSmall: const TextStyle(
        fontFamily: sansFamily,
        fontStyle: FontStyle.normal,
      ).merge(sansTheme.titleSmall),
      bodyLarge: serifBodyTheme.bodyLarge?.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        height: 1.5,
      ),
      bodyMedium: serifBodyTheme.bodyMedium?.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 1.5,
      ),
      bodySmall: serifBodyTheme.bodySmall?.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        height: 1.45,
      ),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: baseScheme,
      scaffoldBackgroundColor: surface,
      textTheme: textTheme,
      fontFamilyFallback: sansFallback,
      fontFamily: sansFamily,
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: bsuBlue,
        foregroundColor: Colors.white,
        titleTextStyle: const TextStyle(
          fontFamily: sansFamily,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: borderSubtle),
        ),
        color: surfaceCard,
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: bsuBlue,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          minimumSize: const Size(48, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontFamily: sansFamily,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: bsuBlue,
          side: const BorderSide(color: bsuBlue, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          minimumSize: const Size(48, 44),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontFamily: sansFamily,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceCard,
        labelStyle: const TextStyle(
          fontFamily: sansFamily,
          color: textSecondary,
          fontWeight: FontWeight.w500,
        ),
        hintStyle: TextStyle(
          fontFamily: sansFamily,
          color: textSecondary.withValues(alpha: 0.7),
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: borderSubtle),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: bsuBlue, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  /// Hero strip behind the home title — friendly gradient, no logic impact.
  static BoxDecoration homeHeroDecoration() {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(24),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          bsuBlue,
          const Color(0xFF1B4DB8),
          bsuOrange.withValues(alpha: 0.85),
        ],
      ),
      boxShadow: [
        BoxShadow(
          color: bsuBlue.withValues(alpha: 0.28),
          blurRadius: 20,
          offset: const Offset(0, 10),
        ),
      ],
    );
  }
}
