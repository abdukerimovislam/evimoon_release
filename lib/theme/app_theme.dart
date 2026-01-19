import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // --- НОВАЯ ПАЛИТРА: "Rich & Calm" (Богатый и Спокойный) ---

  // Основной цвет: Глубокий, сложный фиолетово-серый (вместо простого лавандового)
  static const Color primary = Color(0xFF4A4063);

  // Фон: Теплый "Бумажный" белый (дороже, чем просто белый)
  static const Color background = Color(0xFFF9F8F6);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color secondaryBackground = Color(0xFFF0EFEB);

  // --- ТЕКСТ (Высокий контраст, но мягкий) ---
  static const Color textPrimary = Color(0xFF2D2A32); // Почти черный, но мягче
  static const Color textSecondary = Color(0xFF6E6A75); // Теплый серый
  static const Color textAccent = Color(0xFF8D8696);

  // --- ЦВЕТА ЦИКЛА (Глубокие природные оттенки) ---

  // Менструация: Марсала / Античная роза (вместо розового)
  static const Color menstruation = Color(0xFFA65D6A);

  // Фолликулярная: Шалфей / Глубокая мята (вместо яркой бирюзы)
  static const Color follicular = Color(0xFF6B8E85);

  // Овуляция: Приглушенное золото / Охра (вместо бежевого)
  static const Color ovulation = Color(0xFFD4A76A);

  // Лютеиновая: Пыльный фиолетовый / Вереск (вместо сиреневого)
  static const Color luteal = Color(0xFF8B7E9F);

  // --- ЦВЕТА ДЛЯ ГРАФИКОВ (Чуть насыщеннее для контраста) ---
  static const Color chartMenstruation = Color(0xFF9E5260);
  static const Color chartFollicular = Color(0xFF5E8077);
  static const Color chartOvulation = Color(0xFFC99B5E);
  static const Color chartLuteal = Color(0xFF7D7091);

  // --- ВСПОМОГАТЕЛЬНЫЕ ---
  static Color gridLines = const Color(0xFF2D2A32).withOpacity(0.05);
  static const Color divider = Color(0xFFE0DED8);
  static const Color success = Color(0xFF6B8E85);
  static const Color warning = Color(0xFFD4A76A);
  static const Color error = Color(0xFFA65D6A);
}

class AppTheme {
  static ThemeData get lightTheme {
    final baseTextTheme = GoogleFonts.interTextTheme();

    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.background,
      primaryColor: AppColors.primary,

      // Цветовая схема
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.light,
        background: AppColors.background,
        surface: AppColors.surface,
        primary: AppColors.primary,
        secondary: AppColors.textAccent,
        tertiary: AppColors.menstruation,
        onPrimary: Colors.white,
        onSurface: AppColors.textPrimary,
      ),

      // Типографика
      textTheme: TextTheme(
        displayLarge: baseTextTheme.displayLarge?.copyWith(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
          letterSpacing: -0.5, // Более плотный заголовок
        ),
        displayMedium: baseTextTheme.displayMedium?.copyWith(
          fontSize: 28,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        displaySmall: baseTextTheme.displaySmall?.copyWith(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        headlineMedium: baseTextTheme.headlineMedium?.copyWith(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        titleLarge: baseTextTheme.titleLarge?.copyWith(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        bodyLarge: baseTextTheme.bodyLarge?.copyWith(
          fontSize: 16,
          color: AppColors.textPrimary,
          height: 1.5,
        ),
        bodyMedium: baseTextTheme.bodyMedium?.copyWith(
          fontSize: 14,
          color: AppColors.textPrimary,
          height: 1.5,
        ),
        bodySmall: baseTextTheme.bodySmall?.copyWith(
          fontSize: 12,
          color: AppColors.textSecondary,
        ),
      ),

      // AppBar - чистый, без теней
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        titleTextStyle: GoogleFonts.inter(
          color: AppColors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        surfaceTintColor: Colors.transparent,
      ),

      // Карточки - мягкие, с легкой обводкой
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20), // Более скругленные углы
          side: const BorderSide(color: Colors.transparent, width: 0),
        ),
        margin: EdgeInsets.zero,
      ),

      // Кнопки
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),

      // Bottom Navigation - Минималистичный
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary.withOpacity(0.5),
        elevation: 10, // Легкая тень сверху
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: true,
        selectedLabelStyle: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600),
        unselectedLabelStyle: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500),
      ),
    );
  }
}

class AppStyles {
  // Градиент фона (очень тонкий, почти незаметный переход)
  static BoxDecoration get backgroundGradient {
    return const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppColors.background,
          AppColors.secondaryBackground,
        ],
      ),
    );
  }

  // Тень стала мягче и дороже
  static List<BoxShadow> get cardShadow {
    return [
      BoxShadow(
        color: const Color(0xFF4A4063).withOpacity(0.06), // Цвет тени в тон теме
        blurRadius: 20,
        offset: const Offset(0, 8),
      ),
    ];
  }
}