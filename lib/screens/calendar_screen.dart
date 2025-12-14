import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

import '../theme/app_theme.dart';
import '../widgets/vision_card.dart';
import '../models/cycle_model.dart';
import '../providers/cycle_provider.dart';
import '../providers/wellness_provider.dart';
import '../l10n/app_localizations.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    final cycleProvider = Provider.of<CycleProvider>(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(l10n.tabCalendar, style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Consumer<WellnessProvider>(
        builder: (context, wellnessProvider, child) {
          return Column(
            children: [
              // 1. КАЛЕНДАРЬ (В стекле)
              VisionCard(
                margin: const EdgeInsets.symmetric(horizontal: 16.0),
                padding: const EdgeInsets.only(bottom: 8),
                child: TableCalendar(
                  locale: l10n.localeName,
                  firstDay: DateTime.utc(2020, 1, 1),
                  lastDay: DateTime.utc(2030, 12, 31),
                  focusedDay: _focusedDay,
                  calendarFormat: _calendarFormat,

                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
                  },
                  onFormatChanged: (format) {
                    if (_calendarFormat != format) setState(() => _calendarFormat = format);
                  },
                  onPageChanged: (focusedDay) => _focusedDay = focusedDay,

                  eventLoader: (day) {
                    return wellnessProvider.hasLogForDate(day) ? [true] : [];
                  },

                  calendarStyle: const CalendarStyle(
                    outsideDaysVisible: false,
                    weekendTextStyle: TextStyle(color: AppColors.textPrimary),
                    defaultTextStyle: TextStyle(color: AppColors.textPrimary),
                    todayDecoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    todayTextStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    markersMaxCount: 0,
                  ),

                  calendarBuilders: CalendarBuilders(
                    // Точка индикатора записи
                    markerBuilder: (context, date, events) {
                      if (events.isNotEmpty) {
                        return Positioned(
                          bottom: 5,
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.textPrimary.withOpacity(0.6),
                            ),
                            width: 5.0,
                            height: 5.0,
                          ),
                        );
                      }
                      return null;
                    },
                    defaultBuilder: (context, day, focusedDay) => _buildDayCell(context, day, cycleProvider, false),
                    selectedBuilder: (context, day, focusedDay) => _buildDayCell(context, day, cycleProvider, true),
                  ),

                  headerStyle: const HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                    titleTextStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // 2. ДЕТАЛИ ДНЯ (Список)
              Expanded(
                child: _buildDayDetails(context, _selectedDay!, cycleProvider, wellnessProvider, l10n),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDayCell(BuildContext context, DateTime day, CycleProvider provider, bool isSelected) {
    CyclePhase? phase = provider.getPhaseForDate(day);
    Color bgColor = Colors.transparent;
    Color textColor = AppColors.textPrimary;

    if (phase != null) {
      if (provider.isCOCEnabled) {
        if (phase == CyclePhase.menstruation) {
          bgColor = Colors.redAccent.withOpacity(0.3); // Break Week
        } else {
          bgColor = Colors.tealAccent.shade400.withOpacity(0.3); // Active Pill
        }
      } else {
        bgColor = provider.getColorForPhase(phase).withOpacity(0.3);
      }
    }

    Border? border = isSelected ? Border.all(color: AppColors.primary, width: 2) : null;

    return Container(
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
        border: border,
      ),
      alignment: Alignment.center,
      child: Text(
        '${day.day}',
        style: TextStyle(
          color: textColor,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildDayDetails(BuildContext context, DateTime date, CycleProvider cycle, WellnessProvider wellness, AppLocalizations l10n) {
    final phase = cycle.getPhaseForDate(date);
    final log = wellness.getLogForDate(date);
    final hasLogs = wellness.hasLogForDate(date);

    // 1. Определение фазы и цвета метки
    String phaseName = l10n.phaseLate;
    Color phaseColor = Colors.grey;

    if (phase != null) {
      if (cycle.isCOCEnabled) {
        if (phase == CyclePhase.menstruation) {
          phaseName = l10n.cocBreakPhase;
          phaseColor = Colors.redAccent;
        } else {
          phaseName = l10n.cocActivePhase;
          phaseColor = Colors.tealAccent.shade400;
        }
      } else {
        phaseColor = cycle.getColorForPhase(phase);
        switch (phase) {
          case CyclePhase.menstruation: phaseName = l10n.phaseStatusMenstruation; break;
          case CyclePhase.follicular: phaseName = l10n.phaseStatusFollicular; break;
          case CyclePhase.ovulation: phaseName = l10n.phaseStatusOvulation; break;
          case CyclePhase.luteal: phaseName = l10n.phaseStatusLuteal; break;
          case CyclePhase.late: phaseName = l10n.phaseLate; break;
        }
      }
    } else {
      phaseName = l10n.lblNoData;
    }

    // 2. Парсинг скрытых данных из заметок
    String rawNotes = log.notes ?? "";
    String? tempVal;
    String? weightVal;
    List<String> factors = [];
    String cleanNotes = rawNotes;

    final tempRegex = RegExp(r'\[Temp: (.*?)\]');
    final weightRegex = RegExp(r'\[Weight: (.*?)\]');
    final factorsRegex = RegExp(r'\[Factors: (.*?)\]');

    if (tempRegex.hasMatch(rawNotes)) {
      tempVal = tempRegex.firstMatch(rawNotes)?.group(1);
      cleanNotes = cleanNotes.replaceAll(tempRegex, '');
    }
    if (weightRegex.hasMatch(rawNotes)) {
      weightVal = weightRegex.firstMatch(rawNotes)?.group(1);
      cleanNotes = cleanNotes.replaceAll(weightRegex, '');
    }
    if (factorsRegex.hasMatch(rawNotes)) {
      String factorsStr = factorsRegex.firstMatch(rawNotes)?.group(1) ?? "";
      factors = factorsStr.split(', ').where((e) => e.isNotEmpty).toList();
      cleanNotes = cleanNotes.replaceAll(factorsRegex, '');
    }
    cleanNotes = cleanNotes.trim();

    // 3. UI
    return VisionCard(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Заголовок с датой и фазой
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  DateFormat.yMMMMd(l10n.localeName).format(date),
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: phaseColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  phaseName.toUpperCase(),
                  style: TextStyle(color: phaseColor, fontWeight: FontWeight.bold, fontSize: 10),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),
          Divider(color: Colors.black.withOpacity(0.05)),
          const SizedBox(height: 10),

          if (!hasLogs)
            Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Text(
                  l10n.lblNoSymptoms,
                  style: TextStyle(color: AppColors.textSecondary.withOpacity(0.7), fontStyle: FontStyle.italic),
                ),
              ),
            )
          else
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                children: [

                  // A. VITALS (Показатели)
                  if (tempVal != null || weightVal != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 15),
                      child: Row(
                        children: [
                          if (tempVal != null)
                            _InfoBadge(icon: Icons.thermostat, label: "$tempVal°C", color: Colors.orange),
                          if (tempVal != null && weightVal != null)
                            const SizedBox(width: 10),
                          if (weightVal != null)
                            _InfoBadge(icon: Icons.monitor_weight_outlined, label: "$weightVal kg", color: Colors.blue),
                        ],
                      ),
                    ),

                  // B. WELLNESS GRID (С Эмодзи)
                  _buildEmojiRow(Icons.mood, l10n.logMood, log.mood, Colors.purpleAccent, ["😭", "😟", "😐", "🙂", "🤩"]),
                  _buildEmojiRow(Icons.bolt, l10n.paramEnergy, log.energy, Colors.orangeAccent, ["🪫", "🔌", "🔋", "⚡️", "🚀"]),

                  if (log.sleep > 0)
                    _buildEmojiRow(Icons.bedtime, l10n.logSleep, log.sleep, Colors.indigoAccent, ["🧟", "🥱", "😐", "😌", "😴"]),
                  if (log.skin > 0)
                    _buildEmojiRow(Icons.face, l10n.logSkin, log.skin, Colors.pinkAccent, ["🌋", "🔴", "😐", "✨", "💎"]),
                  if (log.libido > 0)
                    _buildEmojiRow(Icons.favorite, l10n.logLibido, log.libido, Colors.redAccent, ["❄️", "🌱", "🔥", "❤️‍🔥", "🌋"]),

                  // C. FLOW (Менструация)
                  if (log.flow != FlowIntensity.none)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          const Icon(Icons.water_drop, size: 20, color: Colors.red),
                          const SizedBox(width: 10),
                          Text(l10n.logFlow, style: const TextStyle(fontWeight: FontWeight.w600)),
                          const Spacer(),
                          Text(
                            _getFlowLabel(log.flow, l10n),
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
                          )
                        ],
                      ),
                    ),

                  const SizedBox(height: 10),

                  // D. LIFESTYLE FACTORS
                  if (factors.isNotEmpty) ...[
                    // 🔥 ЛОКАЛИЗАЦИЯ: Используем ключ lblLifestyleHeader
                    Text(l10n.lblLifestyleHeader, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                    const SizedBox(height: 5),
                    Wrap(
                      spacing: 8, runSpacing: 8,
                      children: factors.map((f) => _Chip(label: f, color: Colors.teal)).toList(),
                    ),
                    const SizedBox(height: 15),
                  ],

                  // E. SYMPTOMS (Физические)
                  if (log.painSymptoms.isNotEmpty || log.moodSymptoms.isNotEmpty || log.symptoms.isNotEmpty) ...[
                    Text(l10n.logPain, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                    const SizedBox(height: 5),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ...log.painSymptoms.map((s) => _Chip(label: s, color: Colors.redAccent)),
                        ...log.moodSymptoms.map((s) => _Chip(label: s, color: Colors.blueAccent)),
                        ...log.symptoms.map((s) => _Chip(label: s, color: AppColors.primary)),
                      ],
                    ),
                    const SizedBox(height: 15),
                  ],

                  // F. NOTES (Очищенные от тегов)
                  if (cleanNotes.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(top: 5),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.black.withOpacity(0.05))
                      ),
                      child: Text(cleanNotes, style: const TextStyle(fontSize: 14)),
                    )
                ],
              ),
            )
        ],
      ),
    );
  }

  // --- Helpers ---

  String _getFlowLabel(FlowIntensity flow, AppLocalizations l10n) {
    switch (flow) {
      case FlowIntensity.light: return l10n.flowLight;
      case FlowIntensity.medium: return l10n.flowMedium;
      case FlowIntensity.heavy: return l10n.flowHeavy;
      default: return "";
    }
  }

  Widget _buildEmojiRow(IconData icon, String label, int value, Color color, List<String> emojis) {
    // Безопасное получение эмодзи (fallback на индекс 2, если value 0)
    final int safeIndex = (value - 1).clamp(0, 4);
    final displayEmoji = value > 0 ? emojis[safeIndex] : "—";

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14))),
          const SizedBox(width: 8),

          if (value > 0) ...[
            Text(displayEmoji, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 4),
            Text("$value/5", style: TextStyle(fontWeight: FontWeight.bold, color: color.withOpacity(0.7), fontSize: 12)),
          ] else
            Text("—", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey.withOpacity(0.5))),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final Color color;
  const _Chip({required this.label, required this.color});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.3))
      ),
      child: Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }
}

class _InfoBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _InfoBadge({required this.icon, required this.label, required this.color});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 13)),
        ],
      ),
    );
  }
}