import 'package:flutter/material.dart';
import 'app_theme.dart';

class TTCTheme {
  // 🔥 Фон страницы: Очень светлый оттенок основного фона или Primary цвета
  // Это обеспечивает мягкость, свойственную TTC режиму, но в цветах темы.
  static Color get background => AppColors.primary.withOpacity(0.03);

  // Основной "Акцент" TTC (Раньше был Золотой).
  // Теперь он следует за Primary цветом темы (синий, зеленый, розовый и т.д.)
  static Color get primaryGold => AppColors.primary;

  // --- Статусы фертильности ---

  // Пик фертильности = Самый яркий цвет темы (Primary)
  static Color get statusPeak => AppColors.primary;
  static Color get statusTest => AppColors.chartOvulation;
  // Высокая фертильность = Немного прозрачный Primary
  static Color get statusHigh => AppColors.primary.withOpacity(0.7);

  // --- Цвета карточек (Tiles) ---
  // Мы мапим их на палитру графиков, чтобы они были разными, но гармоничными

  // Температура (BBT) -> Используем Luteal или ChartLuteal цвет (обычно спокойный)
  static Color get cardBBT => AppColors.chartLuteal;

  // Тесты (LH) -> Используем Ovulation цвет (яркий)
  static Color get cardTest => AppColors.chartOvulation;

  // Секс -> Используем Menstruation цвет (обычно красный/розовый - цвет любви/страсти)
  static Color get cardSex => AppColors.chartMenstruation;

  // --- Градиенты ---
  // Используется в главном круге (Gauge) и прогресс-барах
  static List<Color> get gradientColors => [
    AppColors.primary.withOpacity(0.3), // Светлый хвост
    AppColors.primary,                  // Основное тело
    AppColors.textAccent,               // Блик (Accent цвет темы)
  ];
}