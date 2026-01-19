import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import '../models/cycle_model.dart';
import '../models/personal_model.dart';
import '../logic/cycle_ai_engine.dart'; // 🔥 Импорт нового движка

class PredictionProvider extends ChangeNotifier {
  Box<PersonalModel>? _box;
  PersonalModel? _model;

  bool _isInitialized = false;

  PersonalModel get model => _model ?? PersonalModel.initial();
  bool get isInitialized => _isInitialized;

  // Инициализация
  Future<void> init() async {
    if (_isInitialized) return;

    try {
      if (!Hive.isBoxOpen('personal_model')) {
        _box = await Hive.openBox<PersonalModel>('personal_model');
      } else {
        _box = Hive.box<PersonalModel>('personal_model');
      }

      if (_box!.isEmpty) {
        _model = PersonalModel.initial();
        await _box!.add(_model!);
      } else {
        _model = _box!.getAt(0);
      }

      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      debugPrint("Error initializing PredictionProvider: $e");
      _model = PersonalModel.initial();
      _isInitialized = true;
      notifyListeners();
    }
  }

  // --- FREE FEATURE: DAILY STATE ---
  Map<String, double> calculateDailyState(CycleData currentCycle, SymptomLog? yesterdayLog) {
    final effectiveModel = model;
    final phase = currentCycle.phase;

    double baseEnergy = effectiveModel.energyWeights[phase.name] ?? 0.5;
    double baseMood = effectiveModel.moodWeights[phase.name] ?? 0.5;
    double baseFocus = effectiveModel.focusWeights[phase.name] ?? 0.5;

    double sleepModifier = 0.0;
    if (yesterdayLog != null) {
      if (yesterdayLog.sleep < 3) {
        sleepModifier = -0.05 * (3 - yesterdayLog.sleep);
      } else if (yesterdayLog.sleep > 3) {
        sleepModifier = 0.025 * (yesterdayLog.sleep - 3);
      }
    }

    return {
      'energy': ((baseEnergy + sleepModifier) * 100).clamp(10, 100),
      'mood': (baseMood * 100).clamp(10, 100),
      'focus': ((baseFocus + (sleepModifier * 0.5)) * 100).clamp(10, 100),
    };
  }

  // --- 🔥 PREMIUM FEATURE: AI CYCLE CONFIDENCE ---

  /// Возвращает результат анализа или NULL, если нет премиума.
  CycleConfidenceResult? getAiConfidence({
    required bool isPremium,
    required List<CycleModel> history, // Принимаем полную историю циклов
  }) {
    // 1. ПРОВЕРКА ПОДПИСКИ
    if (!isPremium) {
      return null; // 🔒 LOCKED (UI должен показать замок)
    }

    // 2. ДЕЛЕГИРУЕМ РАСЧЕТ В ДВИЖОК
    // Всю сложную математику делает CycleAIEngine
    return CycleAIEngine.calculateConfidence(history);
  }

  // --- FEATURE: FEEDBACK (ОБУЧЕНИЕ) ---
  Future<void> feedback(CyclePhase phase, String metric, bool isPositive) async {
    if (_box == null || _model == null) return;

    double adjustment = isPositive ? 0.05 : -0.10;
    _model!.adjustWeight(phase, metric, adjustment);

    await _box!.putAt(0, _model!);
    notifyListeners();
  }
}