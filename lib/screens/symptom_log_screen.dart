import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'dart:ui';

import '../l10n/app_localizations.dart';
import '../models/cycle_model.dart';
import '../providers/wellness_provider.dart';
import '../providers/cycle_provider.dart';
import '../logic/symptom_intelligence.dart';
import '../theme/app_theme.dart';
import '../theme/ttc_theme.dart';

// Виджеты
import '../widgets/glass_container.dart';
import '../widgets/mesh_background.dart';

class SymptomLogScreen extends StatefulWidget {
  final DateTime date;
  final bool isTab;

  const SymptomLogScreen({
    super.key,
    required this.date,
    this.isTab = false,
  });

  @override
  State<SymptomLogScreen> createState() => _SymptomLogScreenState();
}

class _SymptomLogScreenState extends State<SymptomLogScreen> {
  late DateTime _selectedDate;
  late SymptomLog _currentLog;
  final TextEditingController _notesController = TextEditingController();
  bool _isDirty = false;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.date;
    _loadDataForDate(_selectedDate);
  }

  @override
  void deactivate() {
    if (_isDirty) _save();
    super.deactivate();
  }

  void _loadDataForDate(DateTime date) {
    if (_isDirty) _save();
    final provider = Provider.of<WellnessProvider>(context, listen: false);
    setState(() {
      _selectedDate = date;
      _currentLog = provider.getLogForDate(date);
      _notesController.text = _currentLog.notes ?? "";
      _isDirty = false;
    });
  }

  void _save() {
    if (!_isDirty) return;
    final provider = Provider.of<WellnessProvider>(context, listen: false);
    final updatedLog = _currentLog.copyWith(notes: _notesController.text.trim());
    provider.saveLog(updatedLog);
    setState(() => _isDirty = false);
  }

  void _updateLog(SymptomLog newLog) {
    setState(() {
      _currentLog = newLog;
      _isDirty = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cycleProvider = Provider.of<CycleProvider>(context);
    final phase = cycleProvider.getPhaseForDate(_selectedDate) ?? CyclePhase.follicular;

    final allSymptoms = [..._currentLog.painSymptoms, ..._currentLog.symptoms];
    final insight = SymptomIntelligence.getInsight(context, allSymptoms, phase);

    return Scaffold(
      extendBody: true,
      // Используем MeshBackground, но контент делаем более контрастным
      body: MeshCycleBackground(
        phase: phase,
        child: Column(
          children: [
            // --- HEADER (Premium Style) ---
            _PremiumHeader(
              selectedDate: _selectedDate,
              isDirty: _isDirty,
              l10n: l10n,
              onSave: _save,
              onDateSelected: _loadDataForDate,
              safeTop: MediaQuery.of(context).padding.top,
            ),

            // --- BODY ---
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.fromLTRB(20, 10, 20, widget.isTab ? 110 : 40),
                children: [
                  if (insight != null) ...[
                    _AppleInsightBanner(insight: insight),
                    const SizedBox(height: 24),
                  ],

                  // 1. MOOD
                  _SectionTitle(title: l10n.logMood),
                  _PremiumMoodSelector(
                    selectedMood: _currentLog.mood,
                    onMoodChanged: (v) => _updateLog(_currentLog.copyWith(mood: v)),
                  ),
                  const SizedBox(height: 32),

                  // 2. BODY & MIND
                  _SectionTitle(title: l10n.lblBodyMind),
                  _PremiumGlassCard(
                    child: Column(
                      children: [
                        _PremiumRatingRow(
                          icon: CupertinoIcons.bolt_fill,
                          color: Colors.amber,
                          label: l10n.paramEnergy,
                          value: _currentLog.energy,
                          onChanged: (v) => _updateLog(_currentLog.copyWith(energy: v)),
                        ),
                        const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Divider(height: 1)),
                        _PremiumRatingRow(
                          icon: CupertinoIcons.moon_fill,
                          color: Colors.indigoAccent,
                          label: l10n.logSleep,
                          value: _currentLog.sleep,
                          onChanged: (v) => _updateLog(_currentLog.copyWith(sleep: v)),
                        ),
                        const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Divider(height: 1)),
                        _PremiumRatingRow(
                          icon: CupertinoIcons.heart_fill,
                          color: Colors.redAccent,
                          label: l10n.paramLibido,
                          value: _currentLog.libido,
                          onChanged: (v) => _updateLog(_currentLog.copyWith(libido: v)),
                        ),
                        const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Divider(height: 1)),
                        _PremiumRatingRow(
                          icon: CupertinoIcons.sparkles,
                          color: Colors.purpleAccent,
                          label: l10n.paramSkin,
                          value: _currentLog.skin,
                          onChanged: (v) => _updateLog(_currentLog.copyWith(skin: v)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // 3. VITALS
                  _SectionTitle(title: l10n.logVitals),
                  Row(
                    children: [
                      Expanded(
                        child: _PremiumHealthStepper(
                          title: l10n.lblTemp,
                          unit: "°C",
                          value: _currentLog.temperature,
                          defaultValue: 36.6,
                          step: 0.1,
                          min: 35.0,
                          max: 42.0,
                          icon: CupertinoIcons.thermometer,
                          color: Colors.orangeAccent,
                          onChanged: (v) => _updateLog(_currentLog.copyWith(temperature: v)),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _PremiumHealthStepper(
                          title: l10n.lblWeight,
                          unit: "kg",
                          value: _currentLog.weight,
                          defaultValue: 60.0,
                          step: 0.1,
                          min: 30.0,
                          max: 200.0,
                          icon: CupertinoIcons.gauge,
                          color: Colors.blueAccent,
                          onChanged: (v) => _updateLog(_currentLog.copyWith(weight: v)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // 4. OVULATION TEST
                  _SectionTitle(title: l10n.ttcBtnTest),
                  _PremiumOvulationSelector(
                    selectedResult: _currentLog.ovulationTest,
                    l10n: l10n,
                    onChanged: (v) => _updateLog(_currentLog.copyWith(ovulationTest: v)),
                  ),
                  const SizedBox(height: 32),

                  // 5. SYMPTOMS
                  _SectionTitle(title: l10n.logPain),
                  _PremiumSymptomGrid(
                    selectedSymptoms: _currentLog.painSymptoms,
                    l10n: l10n,
                    onToggle: (s) {
                      final list = List<String>.from(_currentLog.painSymptoms);
                      if (list.contains(s)) list.remove(s); else list.add(s);
                      _updateLog(_currentLog.copyWith(painSymptoms: list));
                    },
                  ),
                  const SizedBox(height: 32),

                  // 6. FLOW & LOVE
                  _SectionTitle(title: l10n.lblFlowAndLove),
                  _PremiumGlassCard(
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _PremiumFlowBtn(
                                  intensity: FlowIntensity.light,
                                  isSelected: _currentLog.flow == FlowIntensity.light,
                                  onTap: () => _updateLog(_currentLog.copyWith(flow: _currentLog.flow == FlowIntensity.light ? FlowIntensity.none : FlowIntensity.light))
                              ),
                              _PremiumFlowBtn(
                                  intensity: FlowIntensity.medium,
                                  isSelected: _currentLog.flow == FlowIntensity.medium,
                                  onTap: () => _updateLog(_currentLog.copyWith(flow: _currentLog.flow == FlowIntensity.medium ? FlowIntensity.none : FlowIntensity.medium))
                              ),
                              _PremiumFlowBtn(
                                  intensity: FlowIntensity.heavy,
                                  isSelected: _currentLog.flow == FlowIntensity.heavy,
                                  onTap: () => _updateLog(_currentLog.copyWith(flow: _currentLog.flow == FlowIntensity.heavy ? FlowIntensity.none : FlowIntensity.heavy))
                              ),
                            ],
                          ),
                        ),
                        const Divider(height: 1),
                        _PremiumIntimacyRow(
                          hadSex: _currentLog.hadSex,
                          protected: _currentLog.protectedSex,
                          l10n: l10n,
                          onSexChanged: (v) => _updateLog(_currentLog.copyWith(hadSex: v)),
                          onProtectedChanged: (v) => _updateLog(_currentLog.copyWith(protectedSex: v)),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // 7. NOTES
                  _SectionTitle(title: l10n.logNotes),
                  _PremiumGlassCard(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(minHeight: 100),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: TextField(
                          controller: _notesController,
                          maxLines: null,
                          onChanged: (_) => setState(() => _isDirty = true),
                          style: const TextStyle(fontSize: 16, height: 1.5, color: AppColors.textPrimary),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: l10n.hintNotes,
                            hintStyle: TextStyle(color: AppColors.textSecondary.withOpacity(0.5)),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- PREMIUM WIDGETS ---

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.2,
          color: AppColors.textSecondary.withOpacity(0.7),
        ),
      ),
    );
  }
}

class _PremiumHeader extends StatelessWidget {
  final DateTime selectedDate;
  final bool isDirty;
  final AppLocalizations l10n;
  final VoidCallback onSave;
  final Function(DateTime) onDateSelected;
  final double safeTop;

  const _PremiumHeader({
    required this.selectedDate,
    required this.isDirty,
    required this.l10n,
    required this.onSave,
    required this.onDateSelected,
    required this.safeTop,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: EdgeInsets.only(top: safeTop + 10, bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.5),
            border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.4))),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // 🔥 ИСПРАВЛЕНИЕ: Оборачиваем Text в Expanded
                    Expanded(
                      child: Text(
                        l10n.logSymptomsTitle,
                        style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                            color: AppColors.textPrimary
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis, // Обрезаем с троеточием, если не влезает
                      ),
                    ),
                    // Кнопка сохранения (если есть изменения)
                    if (isDirty)
                      Padding(
                        padding: const EdgeInsets.only(left: 12.0),
                        child: GestureDetector(
                          onTap: onSave,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(colors: [AppColors.primary, Color(0xFFFF9A9E)]),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.4), blurRadius: 10, offset: const Offset(0, 4))],
                            ),
                            child: Text(
                                l10n.btnSave,
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // ... Calendar ListView (без изменений) ...
              SizedBox(
                height: 75,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: 30,
                  reverse: true,
                  physics: const BouncingScrollPhysics(),
                  itemBuilder: (ctx, index) {
                    final date = DateTime.now().subtract(Duration(days: index));
                    final isSelected = date.year == selectedDate.year && date.month == selectedDate.month && date.day == selectedDate.day;

                    return GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        onDateSelected(date);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        margin: const EdgeInsets.symmetric(horizontal: 6),
                        width: 52,
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.textPrimary : Colors.white.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(18),
                          border: isSelected ? null : Border.all(color: Colors.white.withOpacity(0.6)),
                          boxShadow: isSelected
                              ? [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 12, offset: const Offset(0, 6))]
                              : [],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              DateFormat('E', Localizations.localeOf(context).toString()).format(date).toUpperCase(),
                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isSelected ? Colors.white.withOpacity(0.8) : AppColors.textSecondary),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              date.day.toString(),
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: isSelected ? Colors.white : AppColors.textPrimary),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class _PremiumGlassCard extends StatelessWidget {
  final Widget child;
  const _PremiumGlassCard({required this.child});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.55),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.6)),
        boxShadow: [
          BoxShadow(color: AppColors.primary.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: child,
        ),
      ),
    );
  }
}

class _PremiumRatingRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final int value;
  final ValueChanged<int> onChanged;

  const _PremiumRatingRow({
    required this.icon, required this.color, required this.label, required this.value, required this.onChanged
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: AppColors.textPrimary)),
          ),
          // Bar Styled Selector
          SizedBox(
            height: 24,
            child: Row(
              children: List.generate(5, (index) {
                final int starValue = index + 1;
                final bool isSelected = starValue <= value;
                return GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    onChanged(starValue);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                    margin: const EdgeInsets.only(left: 4),
                    width: 16,
                    height: isSelected ? 24 : 12,
                    decoration: BoxDecoration(
                      color: isSelected ? color : Colors.grey.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                );
              }),
            ),
          )
        ],
      ),
    );
  }
}

class _PremiumMoodSelector extends StatelessWidget {
  final int selectedMood;
  final ValueChanged<int> onMoodChanged;
  const _PremiumMoodSelector({required this.selectedMood, required this.onMoodChanged});

  @override
  Widget build(BuildContext context) {
    final moods = [
      {"v": 1, "e": "😭", "c": Colors.purple},
      {"v": 2, "e": "😟", "c": Colors.blueGrey},
      {"v": 3, "e": "😐", "c": Colors.grey},
      {"v": 4, "e": "🙂", "c": Colors.orange},
      {"v": 5, "e": "🤩", "c": Colors.amber},
    ];

    return SizedBox(
      height: 75,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: moods.map((m) {
          final isSelected = selectedMood == m['v'];
          return GestureDetector(
            onTap: () {
              HapticFeedback.mediumImpact();
              onMoodChanged(m['v'] as int);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.elasticOut,
              width: isSelected ? 65 : 48,
              height: isSelected ? 65 : 48,
              decoration: BoxDecoration(
                color: isSelected ? Colors.white : Colors.white.withOpacity(0.4),
                shape: BoxShape.circle,
                border: isSelected ? Border.all(color: (m['c'] as Color).withOpacity(0.3), width: 3) : Border.all(color: Colors.white.withOpacity(0.5)),
                boxShadow: isSelected
                    ? [BoxShadow(color: (m['c'] as Color).withOpacity(0.4), blurRadius: 20, spreadRadius: 5)]
                    : [],
              ),
              alignment: Alignment.center,
              child: Text(m['e'] as String, style: TextStyle(fontSize: isSelected ? 34 : 22)),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _PremiumHealthStepper extends StatelessWidget {
  final String title;
  final String unit;
  final double? value;
  final double defaultValue;
  final double step;
  final double min;
  final double max;
  final IconData icon;
  final Color color;
  final ValueChanged<double> onChanged;

  const _PremiumHealthStepper({
    required this.title, required this.unit, required this.value, required this.defaultValue, required this.step, required this.min, required this.max, required this.icon, required this.color, required this.onChanged
  });

  @override
  Widget build(BuildContext context) {
    final displayValue = value != null ? value!.toStringAsFixed(1) : "--";
    final activeValue = value ?? defaultValue;

    return _PremiumGlassCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 16, color: color),
                const SizedBox(width: 8),
                Expanded(child: Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textSecondary))),
              ],
            ),
            const SizedBox(height: 16),
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(displayValue, style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w800, color: AppColors.textPrimary, height: 1.0)),
                  const SizedBox(width: 4),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Text(unit, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _PremiumCircleBtn(
                    icon: CupertinoIcons.minus,
                    onTap: () {
                      HapticFeedback.lightImpact();
                      final newVal = (activeValue - step).clamp(min, max);
                      onChanged(double.parse(newVal.toStringAsFixed(1)));
                    }
                ),
                _PremiumCircleBtn(
                    icon: CupertinoIcons.plus,
                    onTap: () {
                      HapticFeedback.lightImpact();
                      final newVal = (activeValue + step).clamp(min, max);
                      onChanged(double.parse(newVal.toStringAsFixed(1)));
                    }
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class _PremiumCircleBtn extends StatefulWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _PremiumCircleBtn({required this.icon, required this.onTap});
  @override
  State<_PremiumCircleBtn> createState() => _PremiumCircleBtnState();
}

class _PremiumCircleBtnState extends State<_PremiumCircleBtn> {
  Timer? _timer;
  void _startHolding() {
    widget.onTap();
    _timer = Timer.periodic(const Duration(milliseconds: 80), (t) => widget.onTap());
  }
  void _stopHolding() { _timer?.cancel(); _timer = null; }
  @override
  void dispose() { _stopHolding(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onLongPressStart: (_) => _startHolding(),
      onLongPressEnd: (_) => _stopHolding(),
      onLongPressCancel: () => _stopHolding(),
      child: Container(
        width: 38, height: 38,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5, offset: const Offset(0, 2))],
          border: Border.all(color: Colors.grey.withOpacity(0.1)),
        ),
        child: Icon(widget.icon, size: 18, color: AppColors.primary),
      ),
    );
  }
}

class _PremiumSymptomGrid extends StatelessWidget {
  final List<String> selectedSymptoms;
  final ValueChanged<String> onToggle;
  final AppLocalizations l10n;
  const _PremiumSymptomGrid({required this.selectedSymptoms, required this.onToggle, required this.l10n});
  @override
  Widget build(BuildContext context) {
    final items = [
      {"id": "cramps", "label": l10n.painCramps, "icon": CupertinoIcons.bolt_horizontal_circle},
      {"id": "headache", "label": l10n.painHeadache, "icon": CupertinoIcons.bandage},
      {"id": "bloating", "label": l10n.symptomBloating, "icon": CupertinoIcons.wind},
      {"id": "acne", "label": l10n.symptomAcne, "icon": CupertinoIcons.sparkles},
      {"id": "back", "label": l10n.painBack, "icon": CupertinoIcons.person_crop_rectangle},
    ];

    return Wrap(
      spacing: 12, runSpacing: 12,
      children: items.map((item) {
        final isSel = selectedSymptoms.contains(item['id']);
        return GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            onToggle(item['id'] as String);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: BoxDecoration(
              color: isSel ? AppColors.primary : Colors.white.withOpacity(0.6),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: isSel ? AppColors.primary : Colors.white, width: 1.5),
              boxShadow: isSel ? [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))] : [],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(item['icon'] as IconData, size: 18, color: isSel ? Colors.white : AppColors.textPrimary),
                const SizedBox(width: 8),
                Text(item['label'] as String, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: isSel ? Colors.white : AppColors.textPrimary)),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _PremiumFlowBtn extends StatelessWidget {
  final FlowIntensity intensity;
  final bool isSelected;
  final VoidCallback onTap;
  const _PremiumFlowBtn({required this.intensity, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    int drops = 1;
    String label = "Light";
    Color c = Colors.pink[200]!;
    if (intensity == FlowIntensity.medium) { drops = 2; c = Colors.pink[400]!; label = "Medium"; }
    if (intensity == FlowIntensity.heavy) { drops = 3; c = Colors.pink[600]!; label = "Heavy"; }

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 70, height: 90,
        decoration: BoxDecoration(
          color: isSelected ? c : Colors.white.withOpacity(0.5),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? c : Colors.white),
          boxShadow: isSelected ? [BoxShadow(color: c.withOpacity(0.4), blurRadius: 12, offset: const Offset(0, 6))] : [],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(drops, (i) => Icon(CupertinoIcons.drop_fill, size: 14, color: isSelected ? Colors.white : c))),
            const SizedBox(height: 8),
            Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isSelected ? Colors.white : Colors.grey[600])),
          ],
        ),
      ),
    );
  }
}

class _PremiumIntimacyRow extends StatelessWidget {
  final bool hadSex;
  final bool protected;
  final ValueChanged<bool> onSexChanged;
  final ValueChanged<bool> onProtectedChanged;
  final AppLocalizations l10n;

  const _PremiumIntimacyRow({
    required this.hadSex, required this.protected, required this.l10n, required this.onSexChanged, required this.onProtectedChanged
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () { HapticFeedback.mediumImpact(); onSexChanged(!hadSex); },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: hadSex ? Colors.pinkAccent.withOpacity(0.1) : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: hadSex ? Colors.pinkAccent : Colors.grey.withOpacity(0.2)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(hadSex ? CupertinoIcons.heart_fill : CupertinoIcons.heart, color: Colors.pinkAccent, size: 22),
                    const SizedBox(width: 8),
                    Text(l10n.hadSex, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textPrimary)),
                  ],
                ),
              ),
            ),
          ),
          if (hadSex) ...[
            const SizedBox(width: 12),
            Expanded(
              child: GestureDetector(
                onTap: () { HapticFeedback.lightImpact(); onProtectedChanged(!protected); },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: protected ? Colors.teal : Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: protected ? Colors.teal : Colors.grey.withOpacity(0.2)),
                    boxShadow: protected ? [BoxShadow(color: Colors.teal.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))] : [],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(CupertinoIcons.shield_fill, color: protected ? Colors.white : Colors.grey, size: 18),
                      const SizedBox(width: 6),
                      Text(l10n.protectedSex, style: TextStyle(fontSize: 13, color: protected ? Colors.white : Colors.grey[600], fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            ),
          ]
        ],
      ),
    );
  }
}

class _PremiumOvulationSelector extends StatelessWidget {
  final OvulationTestResult selectedResult;
  final ValueChanged<OvulationTestResult> onChanged;
  final AppLocalizations l10n;
  const _PremiumOvulationSelector({required this.selectedResult, required this.onChanged, required this.l10n});
  @override
  Widget build(BuildContext context) {
    return _PremiumGlassCard(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Expanded(child: _PremiumTestOption(l10n.lblNegative, selectedResult == OvulationTestResult.negative, Colors.grey, () => onChanged(selectedResult == OvulationTestResult.negative ? OvulationTestResult.none : OvulationTestResult.negative))),
            const SizedBox(width: 8),
            Expanded(child: _PremiumTestOption(l10n.lblPositive, selectedResult == OvulationTestResult.positive, TTCTheme.statusTest, () => onChanged(selectedResult == OvulationTestResult.positive ? OvulationTestResult.none : OvulationTestResult.positive))),
            const SizedBox(width: 8),
            Expanded(child: _PremiumTestOption(l10n.lblPeak, selectedResult == OvulationTestResult.peak, Colors.purpleAccent, () => onChanged(selectedResult == OvulationTestResult.peak ? OvulationTestResult.none : OvulationTestResult.peak))),
          ],
        ),
      ),
    );
  }
}

class _PremiumTestOption extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;
  const _PremiumTestOption(this.label, this.isSelected, this.color, this.onTap);
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () { HapticFeedback.selectionClick(); onTap(); },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isSelected ? color : Colors.grey.withOpacity(0.2)),
        ),
        alignment: Alignment.center,
        child: Text(label, style: TextStyle(color: isSelected ? Colors.white : AppColors.textSecondary, fontWeight: FontWeight.bold, fontSize: 13)),
      ),
    );
  }
}

// Повторное использование существующего компонента для Insight
class _AppleInsightBanner extends StatelessWidget {
  final SymptomInsight insight;
  const _AppleInsightBanner({required this.insight});
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: AppColors.surface.withOpacity(0.7), borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.white.withOpacity(0.6)), boxShadow: [BoxShadow(color: (insight.isWarning ? AppColors.error : AppColors.primary).withOpacity(0.15), blurRadius: 25, offset: const Offset(0, 8))]),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: (insight.isWarning ? AppColors.error : AppColors.primary).withOpacity(0.1), shape: BoxShape.circle), child: Icon(insight.isWarning ? CupertinoIcons.exclamationmark_triangle_fill : CupertinoIcons.lightbulb_fill, color: insight.isWarning ? AppColors.error : AppColors.primary, size: 24)), const SizedBox(width: 16), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(insight.title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Colors.black)), const SizedBox(height: 6), Text(insight.description, style: TextStyle(fontSize: 15, height: 1.4, color: Colors.black.withOpacity(0.8), fontWeight: FontWeight.w500))]))]),
        ),
      ),
    );
  }
}