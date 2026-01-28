import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Перечисление доступных тем
enum AppThemeType { oceanic, nature, velvet, digital }

// Интерфейс для всех палитр
abstract class ColorPalette {
  Color get primary;
  Color get background;
  Color get surface;
  Color get textPrimary;
  Color get textSecondary;
  Color get textAccent;

  // Цвета цикла
  Color get menstruation;
  Color get follicular;
  Color get ovulation;
  Color get luteal;

  // Цвета для графиков
  Color get chartMenstruation;
  Color get chartFollicular;
  Color get chartOvulation;
  Color get chartLuteal;
}

// --- 1. OCEANIC SERENITY (Текущая) ---
class OceanicPalette implements ColorPalette {
  @override get primary => const Color(0xFF006D77);
  @override get background => const Color(0xFFEDF6F9);
  @override get surface => const Color(0xFFFFFFFF);
  @override get textPrimary => const Color(0xFF1D3557);
  @override get textSecondary => const Color(0xFF457B9D);
  @override get textAccent => const Color(0xFFA8DADC);

  @override get menstruation => const Color(0xFFE63946);
  @override get follicular => const Color(0xFFA8DADC);
  @override get ovulation => const Color(0xFFFFB703);
  @override get luteal => const Color(0xFF457B9D);

  @override get chartMenstruation => const Color(0xFFD62828);
  @override get chartFollicular => const Color(0xFF1D3557);
  @override get chartOvulation => const Color(0xFFFB8500);
  @override get chartLuteal => const Color(0xFF2A9D8F);
}

// --- 2. NATURE'S WISDOM ---
class NaturePalette implements ColorPalette {
  @override get primary => const Color(0xFF588157);
  @override get background => const Color(0xFFFAEDCD);
  @override get surface => const Color(0xFFFEFAE0);
  @override get textPrimary => const Color(0xFF344E41);
  @override get textSecondary => const Color(0xFF588157);
  @override get textAccent => const Color(0xFFA3B18A);

  @override get menstruation => const Color(0xFFBC4749);
  @override get follicular => const Color(0xFFA3B18A);
  @override get ovulation => const Color(0xFFD4A373);
  @override get luteal => const Color(0xFF6B705C);

  @override get chartMenstruation => const Color(0xFF9E2A2B);
  @override get chartFollicular => const Color(0xFF3A5A40);
  @override get chartOvulation => const Color(0xFFFAEDCD);
  @override get chartLuteal => const Color(0xFF588157);
}

// --- 3. VELVET SUNSET ---
class VelvetPalette implements ColorPalette {
  @override get primary => const Color(0xFF9D8189);
  @override get background => const Color(0xFFFFF0F3);
  @override get surface => const Color(0xFFFFFFFF);
  @override get textPrimary => const Color(0xFF4A3B40);
  @override get textSecondary => const Color(0xFF8E7C82);
  @override get textAccent => const Color(0xFFD4B5B0);

  @override get menstruation => const Color(0xFFFF4D6D);
  @override get follicular => const Color(0xFFFF8FA3);
  @override get ovulation => const Color(0xFFFFB3C1);
  @override get luteal => const Color(0xFFC9184A);

  @override get chartMenstruation => const Color(0xFF800F2F);
  @override get chartFollicular => const Color(0xFFA4133C);
  @override get chartOvulation => const Color(0xFFFF758F);
  @override get chartLuteal => const Color(0xFF590D22);
}

// --- 4. DIGITAL LAVENDER ---
class DigitalPalette implements ColorPalette {
  @override get primary => const Color(0xFF4361EE);
  @override get background => const Color(0xFFF8F9FC);
  @override get surface => const Color(0xFFFFFFFF);
  @override get textPrimary => const Color(0xFF2B2D42);
  @override get textSecondary => const Color(0xFF8D99AE);
  @override get textAccent => const Color(0xFFB8C0FF);

  @override get menstruation => const Color(0xFFEF233C);
  @override get follicular => const Color(0xFF7209B7);
  @override get ovulation => const Color(0xFF4CC9F0);
  @override get luteal => const Color(0xFFF72585);

  @override get chartMenstruation => const Color(0xFFD90429);
  @override get chartFollicular => const Color(0xFF3A0CA3);
  @override get chartOvulation => const Color(0xFF4361EE);
  @override get chartLuteal => const Color(0xFF7209B7);
}

class AppTheme {
  static ColorPalette getPalette(AppThemeType type) {
    switch (type) {
      case AppThemeType.oceanic: return OceanicPalette();
      case AppThemeType.nature: return NaturePalette();
      case AppThemeType.velvet: return VelvetPalette();
      case AppThemeType.digital: return DigitalPalette();
    }
  }
  // Текущая активная палитра (по умолчанию Digital Lavender, как в твоем коде)
  static ColorPalette colors = DigitalPalette();

  // Метод для переключения палитры
  static void setPalette(AppThemeType type) {
    switch (type) {
      case AppThemeType.oceanic: colors = OceanicPalette(); break;
      case AppThemeType.nature: colors = NaturePalette(); break;
      case AppThemeType.velvet: colors = VelvetPalette(); break;
      case AppThemeType.digital: colors = DigitalPalette(); break;
    }
  }

  // Генерация ThemeData на основе текущей палитры
  static ThemeData get lightTheme {
    // Выбираем шрифт в зависимости от темы для полного погружения
    TextTheme baseTextTheme;
    if (colors is NaturePalette) {
      baseTextTheme = GoogleFonts.spectralTextTheme(); // Serif для природы
    } else if (colors is DigitalPalette) {
      baseTextTheme = GoogleFonts.outfitTextTheme(); // Modern Sans для Digital
    } else {
      baseTextTheme = GoogleFonts.manropeTextTheme(); // Универсальный
    }

    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: colors.background,
      primaryColor: colors.primary,

      colorScheme: ColorScheme.fromSeed(
        seedColor: colors.primary,
        background: colors.background,
        surface: colors.surface,
        primary: colors.primary,
        secondary: colors.textSecondary,
        tertiary: colors.menstruation,
        onSurface: colors.textPrimary,
        onPrimary: Colors.white,
      ),

      textTheme: TextTheme(
        displayLarge: baseTextTheme.displayLarge?.copyWith(fontSize: 34, fontWeight: FontWeight.w800, color: colors.textPrimary, letterSpacing: -1.0),
        displayMedium: baseTextTheme.displayMedium?.copyWith(fontSize: 28, fontWeight: FontWeight.w700, color: colors.textPrimary),
        titleLarge: baseTextTheme.titleLarge?.copyWith(fontSize: 18, fontWeight: FontWeight.w600, color: colors.textPrimary),

        bodyLarge: baseTextTheme.bodyLarge?.copyWith(fontSize: 16, color: colors.textPrimary, height: 1.5),
        bodyMedium: baseTextTheme.bodyMedium?.copyWith(fontSize: 14, color: colors.textSecondary, height: 1.5),
        bodySmall: baseTextTheme.bodySmall?.copyWith(fontSize: 12, color: colors.textSecondary.withOpacity(0.8)),

        labelLarge: baseTextTheme.labelLarge?.copyWith(fontSize: 14, fontWeight: FontWeight.w700, color: colors.primary),
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: colors.textPrimary),
        titleTextStyle: baseTextTheme.titleLarge?.copyWith(fontSize: 20, fontWeight: FontWeight.w700, color: colors.textPrimary),
      ),

      cardTheme: CardThemeData(
        color: colors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: colors.primary.withOpacity(0.05), width: 1),
        ),
        margin: EdgeInsets.zero,
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: colors.primary,
            foregroundColor: Colors.white,
            elevation: 4,
            shadowColor: colors.primary.withOpacity(0.4),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
            textStyle: baseTextTheme.labelLarge?.copyWith(fontSize: 16),
          )
      ),

      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: colors.surface,
        selectedItemColor: colors.primary,
        unselectedItemColor: colors.textSecondary.withOpacity(0.5),
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: baseTextTheme.bodySmall?.copyWith(fontWeight: FontWeight.w700),
        unselectedLabelStyle: baseTextTheme.bodySmall,
      ),
    );
  }
}



// Для обратной совместимости (чтобы не ломать старый код, который вызывает AppColors.primary)
class AppColors {
  static Color get primary => AppTheme.colors.primary;
  static Color get background => AppTheme.colors.background;
  static Color get surface => AppTheme.colors.surface;
  static Color get textPrimary => AppTheme.colors.textPrimary;
  static Color get textSecondary => AppTheme.colors.textSecondary;
  static Color get textAccent => AppTheme.colors.textAccent;

  static Color get menstruation => AppTheme.colors.menstruation;
  static Color get follicular => AppTheme.colors.follicular;
  static Color get ovulation => AppTheme.colors.ovulation;
  static Color get luteal => AppTheme.colors.luteal;

  static Color get chartMenstruation => AppTheme.colors.chartMenstruation;
  static Color get chartFollicular => AppTheme.colors.chartFollicular;
  static Color get chartOvulation => AppTheme.colors.chartOvulation;
  static Color get chartLuteal => AppTheme.colors.chartLuteal;

  // Статические вспомогательные
  static Color get gridLines => AppTheme.colors.textPrimary.withOpacity(0.05);
  static const Color divider = Color(0xFFEDF2F4);
  static const Color success = Color(0xFF06D6A0);
  static const Color warning = Color(0xFFFFD166);
  static const Color error = Color(0xFFEF233C);

  // Для совместимости с твоим кодом secondaryBackground
  static const Color secondaryBackground = Color(0xFFE0E7FF);
}

class AppStyles {
  // Градиент фона (адаптируется под тему)
  static BoxDecoration get backgroundGradient {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          AppTheme.colors.background,
          Color.lerp(AppTheme.colors.background, AppTheme.colors.primary, 0.05)!, // Легкий оттенок
        ],
      ),
    );
  }

  static List<BoxShadow> get cardShadow {
    return [
      BoxShadow(
        color: AppTheme.colors.primary.withOpacity(0.08),
        blurRadius: 20,
        offset: const Offset(0, 8),
        spreadRadius: -2,
      ),
    ];
  }
}