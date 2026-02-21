import 'dart:math';
import '../models/cycle_model.dart';

enum ConfidenceLevel { high, medium, low, calculating }

class CycleConfidenceResult {
  final double score; // 0.0 - 1.0
  final double stdDevDays; // Отклонение в днях
  final ConfidenceLevel level;

  /// Localization key for the main explanation text
  final String explanationKey;

  /// Localization keys for short factors/bullets
  final List<String> factors;

  const CycleConfidenceResult({
    required this.score,
    required this.stdDevDays,
    required this.level,
    required this.explanationKey,
    this.factors = const [],
  });
}

class CycleAIEngine {
  // 🔥 FIX: Расширяем границы для поддержки PCOS и длинных циклов
  // 10 дней - минимум (меньше - это скорее кровотечение прорыва)
  // 150 дней - максимум (чтобы охватить пропуски циклов)
  static const int _minCycleLen = 10;
  static const int _maxCycleLen = 150;

  static CycleConfidenceResult calculateConfidence(List<CycleModel> history) {
    if (history.isEmpty) {
      return const CycleConfidenceResult(
        score: 0.0,
        stdDevDays: 0.0,
        level: ConfidenceLevel.low,
        explanationKey: 'confidenceNoData',
        factors: ['factorDataNeeded'],
      );
    }

    // Сортируем от старых к новым
    final sorted = [...history]..sort((a, b) => a.startDate.compareTo(b.startDate));

    // Берем последние 12 циклов для анализа (год)
    final int from = max(0, sorted.length - 12);
    final recent = sorted.sublist(from);

    // Нужно минимум 3 цикла (2 интервала) для анализа стабильности
    if (recent.length < 3) {
      final double score = (recent.length * 0.33).clamp(0.0, 0.99);
      return CycleConfidenceResult(
        score: score,
        stdDevDays: 0.0,
        level: ConfidenceLevel.calculating,
        explanationKey: 'confidenceCalcDesc',
        factors: const ['factorDataNeeded'],
      );
    }

    final lengths = <int>[];
    int invalidIntervals = 0;
    int longCycles = 0; // Счетчик длинных циклов (PCOS маркер)

    for (int i = 0; i < recent.length - 1; i++) {
      final a = _normalize(recent[i].startDate);
      final b = _normalize(recent[i + 1].startDate);

      final int days = b.difference(a).inDays;

      // Фильтр откровенного мусора (ошибки ввода)
      if (days < _minCycleLen || days > _maxCycleLen) {
        invalidIntervals++;
        continue;
      }

      if (days > 45) {
        longCycles++;
      }

      lengths.add(days);
    }

    // Если после фильтрации мало данных
    if (lengths.length < 2) {
      final factors = <String>['factorDataNeeded'];
      if (invalidIntervals > 0) factors.add('factorAnomaly');
      return CycleConfidenceResult(
        score: 0.2,
        stdDevDays: 0.0,
        level: ConfidenceLevel.low,
        explanationKey: 'confidenceNoData',
        factors: factors,
      );
    }

    final double mean = lengths.reduce((a, b) => a + b) / lengths.length;
    final double variance =
        lengths.map((len) => pow(len - mean, 2)).reduce((a, b) => a + b) / lengths.length;
    final double stdDev = sqrt(variance);

    // --- Score Model ---
    double rawScore = 100.0;
    final factors = <String>[];

    // 1) Штраф за вариативность (Standard Deviation)
    if (stdDev > 7.0) {
      rawScore -= 50; // Очень нестабильно
      factors.add('factorHighVar');
    } else if (stdDev > 4.0) {
      rawScore -= 30; // Умеренно нестабильно
      factors.add('factorSlightVar');
    } else {
      factors.add('factorStable');
    }

    // 2) Штраф за аномалии (выбросы > 10 дней от среднего)
    final bool hasAnomaly = lengths.any((l) => (l - mean).abs() > 10);
    if (hasAnomaly) {
      rawScore -= 15;
      if (!factors.contains('factorAnomaly')) factors.add('factorAnomaly');
    }

    // 3) Бонус за объем данных
    if (lengths.length >= 6) rawScore += 10;
    if (lengths.length <= 2) rawScore -= 10;

    // 4) Штраф за "битые" интервалы
    if (invalidIntervals >= 1) {
      rawScore -= 10;
      if (!factors.contains('factorAnomaly')) factors.add('factorAnomaly');
    }

    // 5) 🔥 PCOS логика: если циклы длинные, но стабильные (stdDev низкий),
    // мы не должны сильно штрафовать, но стоит предупредить.
    if (longCycles > 1 && stdDev < 5.0) {
      // Если циклы длинные, но регулярные — восстанавливаем очки, которые могли потерять
      // (Движок мог подумать, что это аномалия относительно "нормы" в 28 дней)
      if (rawScore < 80) rawScore += 10;
    }

    // Переводим 0-100 в 0.0-1.0
    final double finalScore = (rawScore.clamp(0.0, 100.0) / 100.0);

    final ConfidenceLevel level =
    (finalScore >= 0.8) ? ConfidenceLevel.high : (finalScore >= 0.5) ? ConfidenceLevel.medium : ConfidenceLevel.low;

    return CycleConfidenceResult(
      score: finalScore,
      stdDevDays: stdDev,
      level: level,
      explanationKey: _explanationKey(level),
      factors: factors,
    );
  }

  static String _explanationKey(ConfidenceLevel level) {
    switch (level) {
      case ConfidenceLevel.high:
        return 'confidenceHighDesc';
      case ConfidenceLevel.medium:
        return 'confidenceMedDesc';
      case ConfidenceLevel.low:
        return 'confidenceLowDesc';
      case ConfidenceLevel.calculating:
        return 'confidenceCalcDesc';
    }
  }

  static DateTime _normalize(DateTime d) => DateTime(d.year, d.month, d.day);
}