import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../theme/app_theme.dart';
import '../../theme/ttc_theme.dart';
import '../../models/cycle_model.dart';
import '../../providers/cycle_provider.dart';
import '../../providers/wellness_provider.dart';
import '../../l10n/app_localizations.dart';

class CalendarDayDetails extends StatelessWidget {
  final DateTime date;
  final CycleProvider cycle;
  final WellnessProvider wellness;

  const CalendarDayDetails({
    super.key,
    required this.date,
    required this.cycle,
    required this.wellness,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final phase = cycle.getPhaseForDate(date);
    final log = wellness.getLogForDate(date);
    final hasLogs = wellness.hasLogForDate(date);

    String phaseName = l10n.phaseLate;
    Color phaseColor = AppColors.textSecondary;

    if (phase != null) {
      if (cycle.isCOCEnabled) {
        if (phase == CyclePhase.menstruation) {
          phaseName = l10n.cocBreakPhase;
          phaseColor = AppColors.menstruation;
        } else {
          phaseName = l10n.cocActivePhase;
          phaseColor = AppColors.follicular;
        }
      } else {
        switch (phase) {
          case CyclePhase.menstruation: phaseName = l10n.phaseStatusMenstruation; phaseColor = AppColors.menstruation; break;
          case CyclePhase.follicular: phaseName = l10n.phaseStatusFollicular; phaseColor = AppColors.follicular; break;
          case CyclePhase.ovulation: phaseName = l10n.phaseStatusOvulation; phaseColor = AppColors.ovulation; break;
          case CyclePhase.luteal: phaseName = l10n.phaseStatusLuteal; phaseColor = AppColors.luteal; break;
          case CyclePhase.late: phaseName = l10n.phaseLate; phaseColor = AppColors.textSecondary; break;
        }
      }
    } else {
      phaseName = l10n.lblNoData;
    }

    final tempVal = log.temperature;
    final weightVal = log.weight;
    final notes = log.notes ?? "";
    final allSymptoms = [...log.painSymptoms, ...log.symptoms];
    bool hasTest = log.ovulationTest != OvulationTestResult.none;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withOpacity(0.8), width: 1),
        boxShadow: [
          BoxShadow(
            color: phaseColor.withOpacity(0.15),
            blurRadius: 30,
            spreadRadius: 5,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            DateFormat.EEEE(l10n.localeName).format(date).toUpperCase(),
                            style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textSecondary, letterSpacing: 1.5),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            DateFormat.MMMMd(l10n.localeName).format(date),
                            style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: phaseColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: phaseColor.withOpacity(0.3)),
                      ),
                      child: Text(
                        phaseName.toUpperCase(),
                        style: GoogleFonts.inter(color: phaseColor, fontWeight: FontWeight.bold, fontSize: 11),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                Expanded(
                  child: (!hasLogs && !hasTest)
                      ? Center(
                    child: Text(
                      l10n.lblNoSymptoms,
                      style: GoogleFonts.inter(color: AppColors.textSecondary.withOpacity(0.5), fontStyle: FontStyle.italic),
                    ),
                  )
                      : ListView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.zero,
                    children: [
                      if (tempVal != null || weightVal != null)
                        Row(children: [
                          if (tempVal != null && tempVal > 0) _GlassInfoChip(icon: CupertinoIcons.thermometer, label: "$tempVal°C", color: Colors.orangeAccent),
                          const SizedBox(width: 12),
                          if (weightVal != null && weightVal > 0) _GlassInfoChip(icon: CupertinoIcons.gauge, label: "$weightVal kg", color: Colors.blueAccent),
                        ]),

                      if (tempVal != null || weightVal != null) const SizedBox(height: 16),

                      if (hasTest)
                        _HoloRow(
                            icon: CupertinoIcons.drop_fill,
                            color: TTCTheme.statusTest,
                            title: l10n.ttcBtnTest,
                            value: _getTestLabel(log.ovulationTest, l10n),
                            isBold: true
                        ),

                      _HoloEmojiRow(log.mood, l10n.logMood, ["😭", "😟", "😐", "🙂", "🤩"]),

                      if (log.hadSex)
                        _HoloRow(icon: CupertinoIcons.heart_fill, color: Colors.pinkAccent, title: l10n.hadSex, value: log.protectedSex ? l10n.protectedSex : l10n.lblSexYes ?? "Yes"),

                      if (log.flow != FlowIntensity.none)
                        _HoloRow(icon: CupertinoIcons.drop_fill, color: AppColors.menstruation, title: l10n.logFlow, value: _getFlowLabel(log.flow, l10n)),

                      if (allSymptoms.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: allSymptoms.map((s) => _GlassTag(
                              // 🔥 ИСПОЛЬЗУЕМ ТВОИ СУЩЕСТВУЮЩИЕ КЛЮЧИ
                                label: _getLocalizedSymptom(context, s, l10n)
                            )).toList()
                        ),
                      ],

                      if (notes.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(color: Colors.white.withOpacity(0.4), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white.withOpacity(0.5))),
                          child: Text(notes, style: GoogleFonts.inter(fontSize: 14, color: AppColors.textPrimary)),
                        )
                      ]
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getFlowLabel(FlowIntensity flow, AppLocalizations l10n) {
    switch (flow) {
      case FlowIntensity.light: return l10n.flowLight;
      case FlowIntensity.medium: return l10n.flowMedium;
      case FlowIntensity.heavy: return l10n.flowHeavy;
      default: return "";
    }
  }

  // 🔥 МЕТОД ДЛЯ ПЕРЕВОДА СИМПТОМОВ (АДАПТИРОВАН ПОД ТВОЙ JSON)
  String _getLocalizedSymptom(BuildContext context, String key, AppLocalizations l10n) {
    final k = key.toLowerCase().trim();

    // Боль (Используем ключи pain...)
    if (k == 'cramps') return l10n.painCramps;
    if (k == 'headache') return l10n.painHeadache;
    if (k == 'backache') return l10n.painBack;

    // Общие (Используем symptom... или создаем фоллбэк)
    if (k == 'nausea') return l10n.symptomNausea;
    if (k == 'bloating') return l10n.symptomBloating;
    if (k == 'acne') return l10n.symptomAcne;

    // Если ключа нет в JSON, возвращаем английский с большой буквы
    if (key.length > 1) {
      return key[0].toUpperCase() + key.substring(1);
    }
    return key;
  }

  String _getTestLabel(OvulationTestResult result, AppLocalizations l10n) {
    switch (result) {
      case OvulationTestResult.positive: return l10n.lblPositive;
      case OvulationTestResult.peak: return l10n.lblPeak;
      case OvulationTestResult.negative: return l10n.lblNegative;
      default: return "";
    }
  }
}

// ... Остальные виджеты остаются без изменений ...

class _GlassInfoChip extends StatelessWidget {
  final IconData icon; final String label; final Color color;
  const _GlassInfoChip({required this.icon, required this.label, required this.color});
  @override
  Widget build(BuildContext context) {
    return Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: color.withOpacity(0.2))), child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(icon, size: 16, color: color), const SizedBox(width: 6), Text(label, style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: color, fontSize: 13))]));
  }
}

class _HoloRow extends StatelessWidget {
  final IconData icon; final Color color; final String title; final String value; final bool isBold;
  const _HoloRow({required this.icon, required this.color, required this.title, required this.value, this.isBold = false});
  @override
  Widget build(BuildContext context) {
    return Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Row(children: [Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle), child: Icon(icon, size: 16, color: color)), const SizedBox(width: 12), Text(title, style: GoogleFonts.inter(fontSize: 14, color: AppColors.textSecondary)), const Spacer(), Text(value, style: GoogleFonts.inter(fontSize: 14, color: isBold ? color : AppColors.textPrimary, fontWeight: isBold ? FontWeight.bold : FontWeight.w600))]));
  }
}

class _HoloEmojiRow extends StatelessWidget {
  final int value; final String title; final List<String> emojis;
  const _HoloEmojiRow(this.value, this.title, this.emojis);
  @override
  Widget build(BuildContext context) {
    if (value == 0) return const SizedBox.shrink();
    return Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Row(children: [Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.orange.withOpacity(0.1), shape: BoxShape.circle), child: const Icon(Icons.emoji_emotions, size: 16, color: Colors.orange)), const SizedBox(width: 12), Text(title, style: GoogleFonts.inter(fontSize: 14, color: AppColors.textSecondary)), const Spacer(), Text(emojis[(value - 1).clamp(0, 4)], style: const TextStyle(fontSize: 20))]));
  }
}

class _GlassTag extends StatelessWidget {
  final String label;
  const _GlassTag({required this.label});
  @override
  Widget build(BuildContext context) {
    return Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.05), borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.primary.withOpacity(0.2))), child: Text(label, style: GoogleFonts.inter(fontSize: 12, color: AppColors.textPrimary, fontWeight: FontWeight.w500)));
  }
}