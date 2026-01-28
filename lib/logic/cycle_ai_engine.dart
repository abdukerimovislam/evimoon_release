import 'dart:math';
import '../models/cycle_model.dart';

enum ConfidenceLevel { high, medium, low, calculating }

class CycleConfidenceResult {
  final double score; // 🔥 Исправлено: теперь double (0.0 - 1.0)
  final double stdDevDays; // 🔥 Добавлено: отклонение в днях
  final ConfidenceLevel level;

  /// Localization key for the main explanation text
  final String explanationKey;

  /// Localization keys for short factors/bullets
  final List<String> factors;

  const CycleConfidenceResult({
    required this.score,
    required this.stdDevDays, // 🔥
    required this.level,
    required this.explanationKey,
    this.factors = const [],
  });
}

class CycleAIEngine {
  // Guardrails for plausible cycle length (in days).
  static const int _minCycleLen = 15;
  static const int _maxCycleLen = 90;

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

    // Sort by startDate ascending (old -> new)
    final sorted = [...history]..sort((a, b) => a.startDate.compareTo(b.startDate));

    // Use last 12 cycles max.
    final int from = max(0, sorted.length - 12);
    final recent = sorted.sublist(from);

    // Need at least 3 cycles to build meaningful stability.
    if (recent.length < 3) {
      // Score based on data count (max 0.99 for calc state)
      final double score = (recent.length * 0.33).clamp(0.0, 0.99);
      return CycleConfidenceResult(
        score: score,
        stdDevDays: 0.0,
        level: ConfidenceLevel.calculating,
        explanationKey: 'confidenceCalcDesc',
        factors: const ['factorDataNeeded'],
      );
    }

    // Compute cycle lengths
    final lengths = <int>[];
    int invalidIntervals = 0;

    for (int i = 0; i < recent.length - 1; i++) {
      final a = _normalize(recent[i].startDate);
      final b = _normalize(recent[i + 1].startDate);

      final int days = b.difference(a).inDays;

      if (days < _minCycleLen || days > _maxCycleLen) {
        invalidIntervals++;
        continue;
      }
      lengths.add(days);
    }

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
    final double stdDev = sqrt(variance); // 🔥 Рассчитываем отклонение

    // --- Score model ---
    double rawScore = 100.0;
    final factors = <String>[];

    // 1) Stability penalty based on std deviation.
    if (stdDev > 6.0) {
      rawScore -= 45;
      factors.add('factorHighVar');
    } else if (stdDev > 3.5) {
      rawScore -= 25;
      factors.add('factorSlightVar');
    } else {
      factors.add('factorStable');
    }

    // 2) Anomaly penalty (big deviations from mean).
    final bool hasAnomaly = lengths.any((l) => (l - mean).abs() > 8);
    if (hasAnomaly) {
      rawScore -= 15;
      factors.add('factorAnomaly');
    }

    // 3) Data volume adjustment.
    if (lengths.length >= 6) rawScore += 6;
    if (lengths.length <= 2) rawScore -= 10;

    // 4) Data quality penalty.
    if (invalidIntervals >= 2) {
      rawScore -= 10;
      if (!factors.contains('factorAnomaly')) factors.add('factorAnomaly');
    }

    // Переводим 0-100 в 0.0-1.0
    final double finalScore = (rawScore.clamp(0.0, 100.0) / 100.0);

    final ConfidenceLevel level =
    (finalScore >= 0.8) ? ConfidenceLevel.high : (finalScore >= 0.5) ? ConfidenceLevel.medium : ConfidenceLevel.low;

    return CycleConfidenceResult(
      score: finalScore,
      stdDevDays: stdDev, // 🔥 Передаем рассчитанное значение
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