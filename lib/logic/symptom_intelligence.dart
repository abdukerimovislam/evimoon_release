import 'package:flutter/material.dart';
import '../models/cycle_model.dart';
import '../l10n/app_localizations.dart';

class SymptomInsight {
  final String title;
  final String description;
  final bool isWarning; // Красный или обычный цвет

  SymptomInsight({
    required this.title,
    required this.description,
    this.isWarning = false,
  });
}

class SymptomIntelligence {

  /// Главный метод: Получить инсайт по симптомам и фазе
  /// Требует [context] для доступа к переводам
  static SymptomInsight? getInsight(BuildContext context, List<String> selectedSymptoms, CyclePhase phase) {
    if (selectedSymptoms.isEmpty) return null;

    final l10n = AppLocalizations.of(context)!;

    // Приводим к нижнему регистру для поиска (предполагаем, что ключи симптомов на английском)
    // Если у тебя ключи симптомов переведены, логику нужно адаптировать
    final symptoms = selectedSymptoms.map((e) => e.toLowerCase()).toList();

    // --- 1. АНАЛИЗ ПО ФАЗАМ ---

    // 🩸 МЕНСТРУАЦИЯ
    if (phase == CyclePhase.menstruation) {
      if (_has(symptoms, ['cramp', 'pain', 'болит', 'спазм'])) {
        return SymptomInsight(
          title: l10n.insightProstaglandinsTitle,
          description: l10n.insightProstaglandinsBody,
        );
      }
      if (_has(symptoms, ['fatigue', 'tired', 'low energy', 'усталость'])) {
        return SymptomInsight(
          title: l10n.insightWinterPhaseTitle,
          description: l10n.insightWinterPhaseBody,
        );
      }
    }

    // 🌱 ФОЛЛИКУЛЯРНАЯ
    if (phase == CyclePhase.follicular) {
      if (_has(symptoms, ['energy', 'happy', 'active', 'энергия'])) {
        return SymptomInsight(
          title: l10n.insightEstrogenTitle,
          description: l10n.insightEstrogenBody,
        );
      }
    }

    // 🌸 ОВУЛЯЦИЯ
    if (phase == CyclePhase.ovulation) {
      if (_has(symptoms, ['pain', 'ovary', 'side', 'боль'])) {
        return SymptomInsight(
          title: l10n.insightMittelschmerzTitle,
          description: l10n.insightMittelschmerzBody,
        );
      }
      if (_has(symptoms, ['libido', 'sexy', 'social', 'либидо'])) {
        return SymptomInsight(
          title: l10n.insightFertilityTitle,
          description: l10n.insightFertilityBody,
        );
      }
    }

    // 🍂 ЛЮТЕИНОВАЯ (ПМС)
    if (phase == CyclePhase.luteal) {
      if (_has(symptoms, ['bloating', 'weight', 'отек', 'вес'])) {
        return SymptomInsight(
          title: l10n.insightWaterTitle,
          description: l10n.insightWaterBody,
        );
      }
      if (_has(symptoms, ['irritab', 'mood', 'sad', 'cry', 'грусть', 'нервы'])) {
        return SymptomInsight(
          title: l10n.insightProgesteroneTitle,
          description: l10n.insightProgesteroneBody,
        );
      }
      if (_has(symptoms, ['acne', 'skin', 'pimple', 'акне', 'кожа'])) {
        return SymptomInsight(
          title: l10n.insightSkinTitle,
          description: l10n.insightSkinBody,
        );
      }
      if (_has(symptoms, ['cravings', 'sugar', 'hungry', 'сладкое', 'аппетит'])) {
        return SymptomInsight(
          title: l10n.insightMetabolismTitle,
          description: l10n.insightMetabolismBody,
        );
      }
    }

    // --- 2. ОБЩИЕ ПРЕДУПРЕЖДЕНИЯ ---
    if (_has(symptoms, ['spotting', 'bleed', 'мазня']) && phase != CyclePhase.menstruation) {
      return SymptomInsight(
        title: l10n.insightSpottingTitle,
        description: l10n.insightSpottingBody,
        isWarning: true,
      );
    }

    return null;
  }

  // Вспомогательный метод для нечеткого поиска (содержит ли список хотя бы одно ключевое слово)
  static bool _has(List<String> userSymptoms, List<String> keywords) {
    for (var s in userSymptoms) {
      for (var k in keywords) {
        if (s.contains(k)) return true;
      }
    }
    return false;
  }
}