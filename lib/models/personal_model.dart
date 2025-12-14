import 'package:hive/hive.dart';
import 'cycle_model.dart'; // Наш существующий enum CyclePhase

part 'personal_model.g.dart'; // Не забудь запустить build_runner

@HiveType(typeId: 2) // Убедись, что ID уникален (CycleData=0, SymptomLog=1)
class PersonalModel extends HiveObject {
  // Веса для Энергии (по фазам)
  @HiveField(0)
  Map<String, double> energyWeights;

  // Веса для Настроения (по фазам)
  @HiveField(1)
  Map<String, double> moodWeights;

  // Веса для Фокуса (по фазам)
  @HiveField(2)
  Map<String, double> focusWeights;

  // Счетчик уверенности модели (сколько циклов мы обучились)
  @HiveField(3)
  int learningIterations;

  PersonalModel({
    required this.energyWeights,
    required this.moodWeights,
    required this.focusWeights,
    this.learningIterations = 0,
  });

  // Фабрика для "чистого" пользователя (начальные настройки)
  factory PersonalModel.initial() {
    return PersonalModel(
      energyWeights: {
        CyclePhase.menstruation.name: 0.4, // Обычно низкая
        CyclePhase.follicular.name: 0.8,   // Растет
        CyclePhase.ovulation.name: 1.0,    // Пик
        CyclePhase.luteal.name: 0.6,       // Спад
        CyclePhase.late.name: 0.3,
      },
      moodWeights: {
        CyclePhase.menstruation.name: 0.5,
        CyclePhase.follicular.name: 0.9,
        CyclePhase.ovulation.name: 1.0,
        CyclePhase.luteal.name: 0.4, // ПМС
        CyclePhase.late.name: 0.3,
      },
      focusWeights: {
        CyclePhase.menstruation.name: 0.4,
        CyclePhase.follicular.name: 0.9,
        CyclePhase.ovulation.name: 0.8,
        CyclePhase.luteal.name: 0.5,
        CyclePhase.late.name: 0.3,
      },
    );
  }

  // МЕТОД ОБУЧЕНИЯ (Feature A4)
  // adjustment: +1 (подтвердил), -1 (опроверг/низко)
  void adjustWeight(CyclePhase phase, String metric, double adjustment) {
    Map<String, double> targetMap;
    if (metric == 'energy') targetMap = energyWeights;
    else if (metric == 'mood') targetMap = moodWeights;
    else targetMap = focusWeights;

    double current = targetMap[phase.name] ?? 0.5;

    // Шаг обучения (Small step)
    double step = 0.05 * adjustment;

    // Обновляем и ограничиваем (0.1 ... 1.5)
    double newValue = (current + step).clamp(0.1, 1.5);

    targetMap[phase.name] = newValue;
    learningIterations++;
    save(); // Сохраняем в Hive сразу
  }
}