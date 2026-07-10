import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Ilova uchun mavjud 3 ta vizual uslub (foydalanuvchi Sozlamalardan
/// xohlagan birini tanlaydi va tanlovi qurilmada saqlanadi).
enum AppThemeStyle { professional, minimalist, vibrant }

extension AppThemeStyleX on AppThemeStyle {
  String get code {
    switch (this) {
      case AppThemeStyle.professional:
        return 'professional';
      case AppThemeStyle.minimalist:
        return 'minimalist';
      case AppThemeStyle.vibrant:
        return 'vibrant';
    }
  }

  static AppThemeStyle fromCode(String? code) {
    switch (code) {
      case 'minimalist':
        return AppThemeStyle.minimalist;
      case 'vibrant':
        return AppThemeStyle.vibrant;
      case 'professional':
      default:
        return AppThemeStyle.professional;
    }
  }

  /// Sozlamalar ekranida uslubni ko'rsatish uchun ishlatiladigan
  /// namunaviy rang (swatch).
  Color get previewColor {
    switch (this) {
      case AppThemeStyle.professional:
        return const Color(0xFF0B2545);
      case AppThemeStyle.minimalist:
        return const Color(0xFF1D9E75);
      case AppThemeStyle.vibrant:
        return const Color(0xFF4A3AA8);
    }
  }

  /// Splash ekrani uchun gradient fon ranglari — tanlangan uslubga mos
  /// keladi va tizim tungi/kunduzgi rejimidan qat'i nazar bir xil qoladi
  /// (brend hissi doim bir xil bo'lishi uchun).
  List<Color> get splashGradient {
    switch (this) {
      case AppThemeStyle.professional:
        return const [Color(0xFF0B2545), Color(0xFF163E73)];
      case AppThemeStyle.minimalist:
        return const [Color(0xFF0E4B38), Color(0xFF1D9E75)];
      case AppThemeStyle.vibrant:
        return const [Color(0xFF3B2E86), Color(0xFF6A3FA0)];
    }
  }

  /// Salomlashish matni atrofidagi yumshoq porlash (glow) rangi.
  Color get splashGlowColor {
    switch (this) {
      case AppThemeStyle.professional:
        return const Color(0xFFD9B872);
      case AppThemeStyle.minimalist:
        return const Color(0xFF9FE1CB);
      case AppThemeStyle.vibrant:
        return const Color(0xFFF2C9E8);
    }
  }
}

/// Ilovaning markaziy vizual identifikatori: rang sxemasi, tipografika
/// va komponent uslublari (Material Design 3).
///
/// Uchta uslub (professional / minimalist / vibrant) bitta umumiy
/// qurilish (`_build`) orqali generatsiya qilinadi — har biri faqat
/// "seed" rangi va ixtiyoriy urg'u (accent) rangi bilan farqlanadi.
class AppTheme {
  AppTheme._();

  static ThemeData light(AppThemeStyle style) =>
      _build(style, Brightness.light);

  static ThemeData dark(AppThemeStyle style) =>
      _build(style, Brightness.dark);

  static ThemeData _build(AppThemeStyle style, Brightness brightness) {
    var colorScheme = ColorScheme.fromSeed(
      seedColor: style.previewColor,
      brightness: brightness,
    );

    // Ba'zi uslublar uchun qo'shimcha urg'u (accent) rangi — asosiy tugma
    // shu rang bilan ajralib turadi (masalan "professional" uslubda oltin,
    // "vibrant" uslubda pushti urg'u).
    Color? accentColor;
    Color? onAccentColor;
    switch (style) {
      case AppThemeStyle.professional:
        accentColor = const Color(0xFFD9B872);
        onAccentColor = const Color(0xFF3A2C0C);
        break;
      case AppThemeStyle.minimalist:
        break;
      case AppThemeStyle.vibrant:
        accentColor = const Color(0xFFF2C9E8);
        onAccentColor = const Color(0xFF4B1528);
        break;
    }

    if (accentColor != null) {
      colorScheme = colorScheme.copyWith(
        tertiary: accentColor,
        onTertiary: onAccentColor,
      );
    }

    final primaryButtonColor = accentColor ?? colorScheme.primary;
    final onPrimaryButtonColor = accentColor != null
        ? onAccentColor!
        : colorScheme.onPrimary;

    // Tanish "robotcha" standart shrift o'rniga: sarlavhalar uchun nafis,
    // biroz dekorativ serif ("Fraunces"), qolgan matnlar uchun esa toza,
    // yaxshi o'qiladigan sans-serif ("Manrope"). Ikkalasi ham qorong'u va
    // yorug' rejimda bir xil ishonchli o'qilishi uchun colorScheme'dan
    // rang oladi.
    final baseTextTheme = GoogleFonts.manropeTextTheme(
      ThemeData(brightness: brightness).textTheme,
    ).apply(
      bodyColor: colorScheme.onSurface,
      displayColor: colorScheme.onSurface,
    );
    final decorativeFont = GoogleFonts.fraunces;
    final textTheme = baseTextTheme.copyWith(
      displayLarge: decorativeFont(
        textStyle: baseTextTheme.displayLarge,
        fontWeight: FontWeight.w600,
      ),
      displayMedium: decorativeFont(
        textStyle: baseTextTheme.displayMedium,
        fontWeight: FontWeight.w600,
      ),
      headlineLarge: decorativeFont(
        textStyle: baseTextTheme.headlineLarge,
        fontWeight: FontWeight.w600,
      ),
      headlineMedium: decorativeFont(
        textStyle: baseTextTheme.headlineMedium,
        fontWeight: FontWeight.w600,
      ),
      headlineSmall: decorativeFont(
        textStyle: baseTextTheme.headlineSmall,
        fontWeight: FontWeight.w600,
        fontStyle: FontStyle.italic,
      ),
      titleLarge: decorativeFont(
        textStyle: baseTextTheme.titleLarge,
        fontWeight: FontWeight.w600,
      ),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: textTheme,
      scaffoldBackgroundColor: colorScheme.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: decorativeFont(
          fontSize: 21,
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: colorScheme.surfaceContainerLow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primaryButtonColor,
          foregroundColor: onPrimaryButtonColor,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: colorScheme.surfaceContainerHighest,
        selectedColor: colorScheme.primaryContainer,
        labelStyle: TextStyle(color: colorScheme.onSurface),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
