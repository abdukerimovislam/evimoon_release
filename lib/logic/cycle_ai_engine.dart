import 'dart:math';
import '../models/cycle_model.dart';

enum ConfidenceLevel { high, medium, low, calculating }

class CycleConfidenceResult {
  final int score; // 0-100
  final ConfidenceLevel level;

  /// Localization key for the main explanation text
  final String explanationKey;

  /// Localization keys for short factors/bullets
  final List<String> factors;

  const CycleConfidenceResult({
    required this.score,
    required this.level,
    required this.explanationKey,
    this.factors = const [],
  });
}

class CycleAIEngine {
  // Guardrails for plausible cycle length (in days).
  // We use broad limits to avoid punishing valid-but-uncommon cases too much.
  static const int _minCycleLen = 15;
  static const int _maxCycleLen = 90;

  /// Main method: estimate forecast confidence based on cycle history.
  /// Returns localization KEYS only (no UI dependency).
  ///
  /// Expected input: list of completed cycles, where CycleModel.startDate is day 1 of period,
  /// and consecutive startDate distances represent cycle length.
  static CycleConfidenceResult calculateConfidence(List<CycleModel> history) {
    if (history.isEmpty) {
      return const CycleConfidenceResult(
        score: 0,
        level: ConfidenceLevel.low,
        explanationKey: 'confidenceNoData',
        factors: ['factorDataNeeded'],
      );
    }

    // Sort by startDate ascending (old -> new) for robust interval computation.
    final sorted = [...history]..sort((a, b) => a.startDate.compareTo(b.startDate));

    // Use last 12 cycles max.
    final int from = max(0, sorted.length - 12);
    final recent = sorted.sublist(from);

    // Need at least 3 cycles to build meaningful stability (2+ intervals).
    if (recent.length < 3) {
      final int score = (recent.length * 33).clamp(0, 99);
      return CycleConfidenceResult(
        score: score,
        level: ConfidenceLevel.calculating,
        explanationKey: 'confidenceCalcDesc',
        factors: const ['factorDataNeeded'],
      );
    }

    // Compute cycle lengths as difference between consecutive cycle starts.
    final lengths = <int>[];
    int invalidIntervals = 0;

    for (int i = 0; i < recent.length - 1; i++) {
      final a = _normalize(recent[i].startDate);
      final b = _normalize(recent[i + 1].startDate);

      final int days = b.difference(a).inDays;

      // Guard against impossible/dirty data.
      if (days < _minCycleLen || days > _maxCycleLen) {
        invalidIntervals++;
        continue;
      }
      lengths.add(days);
    }

    // If we cannot build enough valid intervals, confidence is low.
    if (lengths.length < 2) {
      final factors = <String>['factorDataNeeded'];
      if (invalidIntervals > 0) factors.add('factorAnomaly');
      return CycleConfidenceResult(
        score: 20,
        level: ConfidenceLevel.low,
        explanationKey: 'confidenceNoData',
        factors: factors,
      );
    }

    final double mean = lengths.reduce((a, b) => a + b) / lengths.length;
    final double variance =
        lengths.map((len) => pow(len - mean, 2)).reduce((a, b) => a + b) / lengths.length;
    final double stdDev = sqrt(variance);

    // --- Score model ---
    double score = 100.0;
    final factors = <String>[];

    // 1) Stability penalty based on std deviation.
    if (stdDev > 6.0) {
      score -= 45;
      factors.add('factorHighVar');
    } else if (stdDev > 3.5) {
      score -= 25;
      factors.add('factorSlightVar');
    } else {
      factors.add('factorStable');
    }

    // 2) Anomaly penalty (big deviations from mean).
    final bool hasAnomaly = lengths.any((l) => (l - mean).abs() > 8);
    if (hasAnomaly) {
      score -= 15;
      factors.add('factorAnomaly');
    }

    // 3) Data volume adjustment (small but meaningful).
    if (lengths.length >= 6) score += 6;
    if (lengths.length <= 2) score -= 10;

    // 4) Data quality penalty for invalid intervals.
    if (invalidIntervals >= 2) {
      score -= 10;
      if (!factors.contains('factorAnomaly')) factors.add('factorAnomaly');
    }

    final int finalScore = score.clamp(0.0, 100.0).round();

    final ConfidenceLevel level =
    (finalScore >= 80) ? ConfidenceLevel.high : (finalScore >= 50) ? ConfidenceLevel.medium : ConfidenceLevel.low;

    return CycleConfidenceResult(
      score: finalScore,
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
