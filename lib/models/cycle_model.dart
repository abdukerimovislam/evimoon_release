import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../theme/app_theme.dart'; // Убедись, что путь к теме верный

part 'cycle_model.g.dart';

// 1. Фазы цикла
@HiveType(typeId: 4)
enum CyclePhase {
  @HiveField(0) menstruation,
  @HiveField(1) follicular,
  @HiveField(2) ovulation,
  @HiveField(3) luteal,
  @HiveField(4) late
}

// 🔥 НОВОЕ: Расширение для получения цвета фазы без хардкода в UI
extension CyclePhaseColor on CyclePhase {
  Color get color {
    switch (this) {
      case CyclePhase.menstruation:
        return AppColors.menstruation;
      case CyclePhase.follicular:
        return AppColors.follicular;
      case CyclePhase.ovulation:
        return AppColors.ovulation;
      case CyclePhase.luteal:
        return AppColors.luteal;
      case CyclePhase.late:
      default:
        return AppColors.textSecondary; // Или Colors.grey
    }
  }

  // Опционально: название ключа для локализации
  String get l10nKey {
    switch (this) {
      case CyclePhase.menstruation: return "legendPeriod";
      case CyclePhase.follicular: return "legendFollicular";
      case CyclePhase.ovulation: return "legendOvulation";
      case CyclePhase.luteal: return "legendLuteal";
      default: return "phaseLate";
    }
  }
}

// 2. Интенсивность
@HiveType(typeId: 3)
enum FlowIntensity {
  @HiveField(0) none,
  @HiveField(1) light,
  @HiveField(2) medium,
  @HiveField(3) heavy
}

// 3. ENUM: РЕЗУЛЬТАТ ТЕСТА НА ОВУЛЯЦИЮ
@HiveType(typeId: 5)
enum OvulationTestResult {
  @HiveField(0) none,      // Не делала
  @HiveField(1) negative,  // Отрицательный (-)
  @HiveField(2) positive,  // Положительный (+)
  @HiveField(3) peak       // Пик ЛГ
}

// 4. ГЛАВНАЯ МОДЕЛЬ ИСТОРИИ ЦИКЛОВ
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

// 5. Модель для UI
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

// 6. ЛОГИ СИМПТОМОВ
@HiveType(typeId: 1)
class SymptomLog extends HiveObject {
  @HiveField(0)
  final DateTime date;

  @HiveField(1)
  final FlowIntensity flow;

  @HiveField(2)
  final List<String> painSymptoms;

  @HiveField(3)
  final List<String> moodSymptoms; // Устаревшее поле, но лучше оставить, чтобы Hive не ругался

  @HiveField(4, defaultValue: 3)
  final int mood;

  @HiveField(5, defaultValue: 3)
  final int energy;

  @HiveField(6, defaultValue: 3)
  final int sleep;

  @HiveField(7, defaultValue: 3)
  final int skin;

  @HiveField(8, defaultValue: 3)
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

  @HiveField(15, defaultValue: OvulationTestResult.none)
  final OvulationTestResult ovulationTest;

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
    this.ovulationTest = OvulationTestResult.none,
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
    OvulationTestResult? ovulationTest,
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
      ovulationTest: ovulationTest ?? this.ovulationTest,
    );
  }
}