import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import '../models/cycle_model.dart';
import 'cycle_provider.dart';

class WellnessProvider extends ChangeNotifier {
  final Box _logsBox;
  final Map<String, SymptomLog> _logsCache = {};

  WellnessProvider(this._logsBox) {
    _init();
  }

  void _init() {
    try {
      for (var key in _logsBox.keys) {
        final log = _logsBox.get(key);
        if (log is SymptomLog) {
          _logsCache[_dateKey(log.date)] = log;
        }
      }
      notifyListeners();
    } catch (e) {
      debugPrint("Error initializing WellnessProvider: $e");
    }
  }

  void reload() {
    notifyListeners();
  }

  // --- CRUD METHODS ---

  bool hasLogForDate(DateTime date) {
    return _logsCache.containsKey(_dateKey(date));
  }

  SymptomLog getLogForDate(DateTime date) {
    if (hasLogForDate(date)) {
      return _logsCache[_dateKey(date)]!;
    }
    return SymptomLog(
      date: date,
      flow: FlowIntensity.none,
      mood: 0, energy: 0, sleep: 0, skin: 0, libido: 0,
      painSymptoms: [], moodSymptoms: [], symptoms: [],
    );
  }

  List<SymptomLog> getLogHistory() {
    return _logsCache.values.toList();
  }

  Future<void> saveLog(SymptomLog log) async {
    final key = _dateKey(log.date);
    await _logsBox.put(key, log);
    _logsCache[key] = log;
    notifyListeners();
  }

  String _dateKey(DateTime date) {
    return "${date.year}-${date.month}-${date.day}";
  }

  // --- CHART METHODS ---

  /// 1. История температуры для графика Vitals
  List<MapEntry<DateTime, double>> getTemperatureHistory() {
    final entries = _logsCache.values
        .where((log) => log.temperature != null && log.temperature! > 0)
        .map((log) => MapEntry(log.date, log.temperature!))
        .toList();

    entries.sort((a, b) => a.key.compareTo(b.key));
    return entries;
  }

  /// 2. История веса
  List<MapEntry<DateTime, double>> getWeightHistory() {
    final entries = _logsCache.values
        .where((log) => log.weight != null && log.weight! > 0)
        .map((log) => MapEntry(log.date, log.weight!))
        .toList();

    entries.sort((a, b) => a.key.compareTo(b.key));
    return entries;
  }

  /// 3. Данные для Радара (Сравнение фаз)
  Map<String, List<double>> calculateRadarData(CycleProvider cycle) {
    if (_logsCache.isEmpty) {
      return {
        'follicular': [3.0, 3.0, 3.0, 3.0, 3.0],
        'luteal': [3.0, 3.0, 3.0, 3.0, 3.0],
      };
    }

    final allLogs = getLogHistory();
    List<SymptomLog> follLogs = [];
    List<SymptomLog> lutLogs = [];

    for (var log in allLogs) {
      final phase = cycle.getPhaseForDate(log.date);

      if (phase == CyclePhase.follicular || phase == CyclePhase.ovulation) {
        follLogs.add(log);
      } else {
        lutLogs.add(log);
      }
    }

    double getAvg(List<SymptomLog> logs, int Function(SymptomLog) selector) {
      if (logs.isEmpty) return 3.0;
      final sum = logs.fold(0, (prev, e) => prev + selector(e));
      return sum / logs.length;
    }

    return {
      'follicular': [
        getAvg(follLogs, (l) => l.mood),
        getAvg(follLogs, (l) => l.energy),
        getAvg(follLogs, (l) => l.sleep),
        getAvg(follLogs, (l) => l.libido),
        getAvg(follLogs, (l) => l.skin),
      ],
      'luteal': [
        getAvg(lutLogs, (l) => l.mood),
        getAvg(lutLogs, (l) => l.energy),
        getAvg(lutLogs, (l) => l.sleep),
        getAvg(lutLogs, (l) => l.libido),
        getAvg(lutLogs, (l) => l.skin),
      ],
    };
  }

  /// 4. Данные для Волны настроения
  List<double> calculateWaveData() {
    if (_logsCache.isEmpty) {
      return List.filled(30, 3.0);
    }

    List<double> moodValues = [];
    final now = DateTime.now();

    for (int i = 29; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      if (hasLogForDate(date)) {
        double val = getLogForDate(date).mood.toDouble();
        if (val == 0) val = 3.0;
        moodValues.add(val);
      } else {
        moodValues.add(moodValues.isNotEmpty ? moodValues.last : 3.0);
      }
    }
    return moodValues;
  }

  // --- 🧠 SMART ANALYTICS (НОВОЕ) ---

  /// Ищет связь между Фактором (Lifestyle) и Симптомом (Pain)
  List<Map<String, dynamic>> analyzeCorrelations() {
    final List<Map<String, dynamic>> insights = [];
    final logs = _logsCache.values.toList();

    if (logs.length < 3) return []; // Нужно хотя бы немного данных

    // 1. Собираем все использованные факторы (Lifestyle)
    final Set<String> allFactors = {};
    for (var log in logs) {
      allFactors.addAll(log.symptoms);
    }

    // 2. Проверяем каждый фактор
    for (var factor in allFactors) {
      int factorCount = 0;
      Map<String, int> symptomCounts = {};

      for (var log in logs) {
        if (log.symptoms.contains(factor)) {
          factorCount++;
          // Если в этот день был фактор, проверяем, что болело
          for (var pain in log.painSymptoms) {
            symptomCounts[pain] = (symptomCounts[pain] ?? 0) + 1;
          }
        }
      }

      // 3. Считаем вероятность (если фактор встречался хотя бы 2 раза)
      if (factorCount >= 2) {
        symptomCounts.forEach((symptom, count) {
          double probability = count / factorCount;
          // Если вероятность > 50%, добавляем в инсайты
          if (probability > 0.5) {
            insights.add({
              'factor': factor,
              'symptom': symptom,
              'probability': (probability * 100).toInt(),
              'count': factorCount
            });
          }
        });
      }
    }

    // Сортируем: сначала самые вероятные
    insights.sort((a, b) => b['probability'].compareTo(a['probability']));
    return insights;
  }
}