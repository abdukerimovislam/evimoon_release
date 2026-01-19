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
    // Если лога нет, возвращаем пустой шаблон с дефолтными значениями 3.0
    return SymptomLog(
      date: date,
      flow: FlowIntensity.none,
      mood: 3,
      energy: 3,
      sleep: 3,
      skin: 3,
      libido: 3,
      painSymptoms: [],
      moodSymptoms: [],
      symptoms: [],
      ovulationTest: OvulationTestResult.none, // 🔥 Важно для новых фич
    );
  }

  // Помощник для получения всех логов
  List<SymptomLog> get allLogs => _logsCache.values.toList();

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

  /// 1. История Температуры (ББТ)
  List<MapEntry<DateTime, double>> getTemperatureHistory() {
    final entries = _logsCache.values
        .where((log) => log.temperature != null && log.temperature! > 0)
        .map((log) => MapEntry(log.date, log.temperature!))
        .toList();

    entries.sort((a, b) => a.key.compareTo(b.key));
    return entries;
  }

  /// 2. История Веса
  List<MapEntry<DateTime, double>> getWeightHistory() {
    final entries = _logsCache.values
        .where((log) => log.weight != null && log.weight! > 0)
        .map((log) => MapEntry(log.date, log.weight!))
        .toList();

    entries.sort((a, b) => a.key.compareTo(b.key));
    return entries;
  }

  /// 3. Radar Data (Сравнение фаз: Фолликулярная vs Лютеиновая)
  Map<String, List<double>> calculateRadarData(CycleProvider cycle) {
    if (_logsCache.isEmpty) {
      // Заглушка, если данных нет
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

      // Группируем логи по фазам
      if (phase == CyclePhase.follicular || phase == CyclePhase.ovulation) {
        follLogs.add(log);
      } else {
        lutLogs.add(log);
      }
    }

    // Функция среднего арифметического
    double getAvg(List<SymptomLog> logs, int Function(SymptomLog) selector) {
      if (logs.isEmpty) return 3.0;

      // Фильтруем "пустые" значения (если вдруг там 0)
      final validLogs = logs.where((l) => selector(l) > 0).toList();
      if (validLogs.isEmpty) return 3.0;

      final sum = validLogs.fold(0, (prev, e) => prev + selector(e));
      return sum / validLogs.length;
    }

    // Возвращаем данные для радара в порядке: [Mood, Energy, Sleep, Libido, Skin]
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

  /// 4. Mood Wave Data (Для графика волны настроения)
  List<double> calculateWaveData() {
    if (_logsCache.isEmpty) {
      return List.filled(30, 3.0);
    }

    List<double> moodValues = [];
    final now = DateTime.now();

    // Берем последние 30 дней
    for (int i = 29; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      if (hasLogForDate(date)) {
        double val = getLogForDate(date).mood.toDouble();
        if (val == 0) val = 3.0;
        moodValues.add(val);
      } else {
        // Если данных нет, берем предыдущее значение для плавности графика
        moodValues.add(moodValues.isNotEmpty ? moodValues.last : 3.0);
      }
    }
    return moodValues;
  }

  // --- 🧠 SMART ANALYTICS ---

  /// Находит корреляцию между Факторами (симптомы) и Болью
  List<Map<String, dynamic>> analyzeCorrelations() {
    final List<Map<String, dynamic>> insights = [];
    final logs = _logsCache.values.toList();

    if (logs.length < 3) return [];

    // 1. Собираем все симптомы-факторы (кроме боли)
    final Set<String> allFactors = {};
    for (var log in logs) {
      allFactors.addAll(log.symptoms);
      // Можно добавить сюда и низкий сон, если он есть
    }

    // 2. Проверяем каждый фактор
    for (var factor in allFactors) {
      int factorCount = 0;
      Map<String, int> painCounts = {};

      for (var log in logs) {
        if (log.symptoms.contains(factor)) {
          factorCount++;
          for (var pain in log.painSymptoms) {
            painCounts[pain] = (painCounts[pain] ?? 0) + 1;
          }
        }
      }

      // 3. Считаем вероятность
      if (factorCount >= 2) {
        painCounts.forEach((pain, count) {
          double probability = count / factorCount;
          if (probability > 0.5) { // Если связь > 50%
            insights.add({
              'factor': factor,
              'symptom': pain,
              'probability': (probability * 100).toInt(),
              'count': factorCount
            });
          }
        });
      }
    }

    insights.sort((a, b) => b['probability'].compareTo(a['probability']));
    return insights;
  }

  // 🔥 🤰 FERTILITY INSIGHTS (Для режима планирования)
  List<Map<String, dynamic>> analyzeFertilityPatterns() {
    List<Map<String, dynamic>> patterns = [];
    final logs = _logsCache.values.toList();

    int positiveTests = 0;
    int highLibidoWithTest = 0;
    int painWithTest = 0;

    for (var log in logs) {
      bool isPositiveTest = log.ovulationTest == OvulationTestResult.positive ||
          log.ovulationTest == OvulationTestResult.peak;

      if (isPositiveTest) {
        positiveTests++;
        // Проверяем высокое либидо (4 или 5) во время положительного теста
        if (log.libido >= 4) highLibidoWithTest++;
        // Проверяем овуляторные боли
        if (log.painSymptoms.isNotEmpty) painWithTest++;
      }
    }

    if (positiveTests > 0) {
      if (highLibidoWithTest > 0) {
        patterns.add({'type': 'libido', 'count': highLibidoWithTest});
      }
      if (painWithTest > 0) {
        patterns.add({'type': 'pain', 'count': painWithTest});
      }
    }

    return patterns;
  }
}