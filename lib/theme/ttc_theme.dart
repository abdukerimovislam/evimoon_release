import 'package:flutter/material.dart';
import '../providers/cycle_provider.dart'; // Для enum FertilityChance

class TTCTheme {
  // --- ОСНОВНАЯ ПАЛИТРА (GOLDEN HOUR) ---
  static const Color primaryGold = Color(0xFFFFB300); // Янтарный золотой
  static const Color softSand = Color(0xFFFFF8E1);    // Песочный фон
  static const Color richGold = Color(0xFFFFD700);    // Чистое золото
  static const Color deepAmber = Color(0xFFFF8F00);   // Темный янтарь

  // --- ЦВЕТА СТАТУСОВ ---
  static const Color statusPeak = Color(0xFFFF5252);  // Пик (Красный акцент)
  static const Color statusHigh = Color(0xFFFFAB00);  // Высокая (Золото)
  static const Color statusWait = Color(0xFF90A4AE);  // Ожидание (Серо-голубой)
  static const Color statusDPO  = Color(0xFFE040FB);  // ДПО (Мистический фиолетовый)
  static const Color statusTest = Color(0xFFFF4081);  // Тест (Розовый)

  // --- ЦВЕТА КАРТОЧЕК ДЕЙСТВИЙ ---
  static const Color cardBBT = Color(0xFFFF9800);     // Оранжевый
  static const Color cardTest = Color(0xFF7C4DFF);    // Фиолетовый
  static const Color cardSex = Color(0xFFFF1744);     // Красный/Розовый

  // --- ЛОГИКА ВЫБОРА ЦВЕТА ---
  // Мы выносим логику "какой цвет показать" из UI сюда
  static Color getGlowColor({
    required int? dpo,
    required FertilityChance chance,
  }) {
    if (dpo != null) {
      if (dpo >= 10) return statusTest; // Время теста
      return statusDPO; // Время ожидания (имплантация)
    }

    switch (chance) {
      case FertilityChance.peak: return statusPeak;
      case FertilityChance.high: return statusHigh;
      case FertilityChance.low:
      default: return statusWait;
    }
  }

  // Градиент для фона (если понадобится)
  static const List<Color> backgroundGradient = [
    Color(0xFFFFFDE7), // Очень светлый желтый
    Colors.white,
  ];
}