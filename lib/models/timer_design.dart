import 'package:flutter/material.dart';

enum TimerDesign {
  classic, // 1. Спирограф
  minimal, // 2. Кольца
  lunar,   // 3. Луна
  bloom,   // 4. Цветок
  liquid,  // 5. Жидкость
  orbit,   // 6. Орбита
  zen,     // 7. Градиент
}

extension TimerDesignExt on TimerDesign {
  String get name {
    switch (this) {
      case TimerDesign.classic: return "Classic Mystery";
      case TimerDesign.minimal: return "Clean Minimal";
      case TimerDesign.lunar:   return "Lunar Phase";
      case TimerDesign.bloom:   return "Nature Bloom";
      case TimerDesign.liquid:  return "Hydro Flow";
      case TimerDesign.orbit:   return "Star Orbit";
      case TimerDesign.zen:     return "Zen Aura";
    }
  }

  bool get isPremium {
    switch (this) {
      case TimerDesign.classic: return false; // Бесплатно
      default: return true; // Все остальные - премиум
    }
  }

  IconData get icon {
    switch (this) {
      case TimerDesign.classic: return Icons.grain_rounded;
      case TimerDesign.minimal: return Icons.circle_outlined;
      case TimerDesign.lunar:   return Icons.nightlight_round;
      case TimerDesign.bloom:   return Icons.local_florist_rounded;
      case TimerDesign.liquid:  return Icons.water_drop_rounded;
      case TimerDesign.orbit:   return Icons.public_rounded;
      case TimerDesign.zen:     return Icons.blur_on_rounded;
    }
  }
}