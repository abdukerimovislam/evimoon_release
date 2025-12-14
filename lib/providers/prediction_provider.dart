import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import '../models/cycle_model.dart';
import '../models/personal_model.dart';
import 'cycle_provider.dart';

class PredictionProvider extends ChangeNotifier {
  Box<PersonalModel>? _box;
  PersonalModel? _model;

  bool _isInitialized = false;

  // Безопасный геттер: если база не готова, отдаем "чистую" модель
  PersonalModel get model => _model ?? PersonalModel.initial();
  bool get isInitialized => _isInitialized;

  // Инициализация (вызывается из main.dart)
  Future<void> init() async {
    if (_isInitialized) return;

    try {
      // Открываем бокс, если он еще не открыт
      if (!Hive.isBoxOpen('personal_model')) {
        _box = await Hive.openBox<PersonalModel>('personal_model');
      } else {
        _box = Hive.box<PersonalModel>('personal_model');
      }

      if (_box!.isEmpty) {
        // Создаем новую модель при первом запуске
        _model = PersonalModel.initial();
        await _box!.add(_model!);
      } else {
        // Загружаем существующую
        _model = _box!.getAt(0);
      }

      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      debugPrint("Error initializing PredictionProvider: $e");
      // В случае ошибки fallback на дефолтную модель
      _model = PersonalModel.initial();
      _isInitialized = true; // Считаем, что "готово" (в безопасном режиме)
      notifyListeners();
    }
  }

  // --- FEATURE B2: РАСЧЕТ ПРЕДСКАЗАНИЯ ---

  Map<String, double> calculateDailyState(CycleData currentCycle, SymptomLog? yesterdayLog) {
    // Используем безопасный геттер
    final effectiveModel = model;
    final phase = currentCycle.phase;

    // 1. Берем веса ИЗ БАЗЫ (Персональные)
    // Используем значения по умолчанию (0.5), если весов для этой фазы еще нет
    double baseEnergy = effectiveModel.energyWeights[phase.name] ?? 0.5;
    double baseMood = effectiveModel.moodWeights[phase.name] ?? 0.5;
    double baseFocus = effectiveModel.focusWeights[phase.name] ?? 0.5;

    // 2. Модификаторы (Реальное влияние сна)
    double sleepModifier = 0.0;
    if (yesterdayLog != null) {
      // Нормализуем оценку сна (1..5) в модификатор (-0.1 .. +0.05)
      // 1=-0.1, 3=0, 5=+0.05
      if (yesterdayLog.sleep < 3) {
        sleepModifier = -0.05 * (3 - yesterdayLog.sleep); // Штраф
      } else if (yesterdayLog.sleep > 3) {
        sleepModifier = 0.025 * (yesterdayLog.sleep - 3); // Бонус
      }
    }

    // 3. Расчет (Результат всегда динамический)
    // clamp(10, 100) гарантирует, что мы не покажем 0% или 150%
    return {
      'energy': ((baseEnergy + sleepModifier) * 100).clamp(10, 100),
      'mood': (baseMood * 100).clamp(10, 100),
      'focus': ((baseFocus + (sleepModifier * 0.5)) * 100).clamp(10, 100),
    };
  }

  // --- FEATURE B4: ОБРАТНАЯ СВЯЗЬ (ОБУЧЕНИЕ) ---

  Future<void> feedback(CyclePhase phase, String metric, bool isPositive) async {
    if (_box == null || _model == null) return;

    // 1. Корректируем веса в памяти
    // Если "Да, совпало" -> усиливаем вес чуть-чуть (+0.05 к вероятности)
    // Если "Нет, не так" -> ослабляем сильнее (-0.10 к вероятности)
    double adjustment = isPositive ? 0.05 : -0.10;

    _model!.adjustWeight(phase, metric, adjustment);

    // 2. ✅ СОХРАНЯЕМ В HIVE (Критически важно!)
    // Перезаписываем модель по индексу 0
    await _box!.putAt(0, _model!);

    notifyListeners();
  }
}