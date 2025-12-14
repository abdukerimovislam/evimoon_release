import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

part 'cycle_model.g.dart';

// 1. Фазы цикла (вычисляемые)
// Добавляем HiveType, если хотим хранить фазу где-то, но обычно не нужно
@HiveType(typeId: 4)
enum CyclePhase {
  @HiveField(0) menstruation,
  @HiveField(1) follicular,
  @HiveField(2) ovulation,
  @HiveField(3) luteal,
  @HiveField(4) late
}

// 2. Интенсивность (храним в БД)
@HiveType(typeId: 3)
enum FlowIntensity {
  @HiveField(0) none,
  @HiveField(1) light,
  @HiveField(2) medium,
  @HiveField(3) heavy
}

// ✅ 3. ГЛАВНАЯ МОДЕЛЬ ИСТОРИИ ЦИКЛОВ (КОТОРОЙ НЕ ХВАТАЛО)
@HiveType(typeId: 0)
class CycleModel extends HiveObject {
  @HiveField(0)
  final DateTime startDate;

  @HiveField(1)
  final DateTime? endDate;

  @HiveField(2)
  final int? length;

  CycleModel({required this.startDate, this.endDate, this.length});
}

// 4. Модель для UI (результат вычислений, в БД не кладем)
class CycleData {
  final CyclePhase phase;
  final int currentDay;
  final int totalCycleLength;
  final int periodDuration;
  final int daysUntilNextPeriod;
  final bool isFertile;
  final DateTime cycleStartDate;
  final DateTime? lastPeriodDate;

  CycleData({
    required this.phase,
    required this.currentDay,
    required this.totalCycleLength,
    this.periodDuration = 5,
    required this.daysUntilNextPeriod,
    required this.isFertile,
    required this.cycleStartDate,
    this.lastPeriodDate,
  });

  factory CycleData.empty() => CycleData(
    cycleStartDate: DateTime.now(),
    totalCycleLength: 28,
    periodDuration: 5,
    currentDay: 1,
    phase: CyclePhase.follicular,
    daysUntilNextPeriod: 27,
    isFertile: false,
  );
}

// 5. ЛОГИ СИМПТОМОВ (Главная модель для Wellness)
@HiveType(typeId: 1)
class SymptomLog extends HiveObject {
  @HiveField(0)
  final DateTime date;

  @HiveField(1)
  final FlowIntensity flow;

  @HiveField(2)
  final List<String> painSymptoms;

  @HiveField(3)
  final List<String> moodSymptoms;

  // Числовые показатели (1-5)
  @HiveField(4)
  final int mood;

  @HiveField(5)
  final int energy;

  @HiveField(6)
  final int sleep;

  @HiveField(7)
  final int skin;

  @HiveField(8)
  final int libido;

  @HiveField(9)
  final List<String> symptoms;

  @HiveField(10)
  final String? notes;

  @HiveField(11)
  final double? temperature;

  @HiveField(12)
  final double? weight;

  @HiveField(13)
  final bool hadSex;

  @HiveField(14)
  final bool protectedSex;

  SymptomLog({
    required this.date,
    this.flow = FlowIntensity.none,
    this.painSymptoms = const [],
    this.moodSymptoms = const [],
    this.mood = 3,
    this.energy = 3,
    this.sleep = 3,
    this.skin = 3,
    this.libido = 3,
    this.symptoms = const [],
    this.notes,
    this.temperature,
    this.weight,
    this.hadSex = false,
    this.protectedSex = false,
  });

  SymptomLog copyWith({
    DateTime? date,
    FlowIntensity? flow,
    List<String>? painSymptoms,
    List<String>? moodSymptoms,
    int? mood,
    int? energy,
    int? sleep,
    int? skin,
    int? libido,
    List<String>? symptoms,
    String? notes,
    double? temperature,
    double? weight,
    bool? hadSex,
    bool? protectedSex,
  }) {
    return SymptomLog(
      date: date ?? this.date,
      flow: flow ?? this.flow,
      painSymptoms: painSymptoms ?? this.painSymptoms,
      moodSymptoms: moodSymptoms ?? this.moodSymptoms,
      mood: mood ?? this.mood,
      energy: energy ?? this.energy,
      sleep: sleep ?? this.sleep,
      skin: skin ?? this.skin,
      libido: libido ?? this.libido,
      symptoms: symptoms ?? this.symptoms,
      notes: notes ?? this.notes,
      temperature: temperature ?? this.temperature,
      weight: weight ?? this.weight,
      hadSex: hadSex ?? this.hadSex,
      protectedSex: protectedSex ?? this.protectedSex,
    );
  }
}