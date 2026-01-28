import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'dart:ui'; // For ImageFilter

import '../l10n/app_localizations.dart';
import '../models/cycle_model.dart';
import '../providers/wellness_provider.dart';
import '../providers/cycle_provider.dart';
import '../logic/symptom_intelligence.dart';
import '../theme/app_theme.dart';
import '../theme/ttc_theme.dart';

// Widgets
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

    // Safe area for top padding
    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      extendBody: true,
      body: MeshCycleBackground(
        phase: phase,
        child: Column(
          children: [
            // --- HEADER ---
            _buildHeader(l10n, topPadding),

            // --- SCROLLABLE CONTENT ---
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.fromLTRB(20, 10, 20, widget.isTab ? 110 : 40),
                children: [
                  if (insight != null) ...[
                    _InsightCard(insight: insight),
                    const SizedBox(height: 24),
                  ],

                  // 1. MOOD
                  _SectionHeader(title: l10n.logMood, icon: CupertinoIcons.smiley),
                  _MoodSelector(
                    selectedMood: _currentLog.mood,
                    onMoodChanged: (v) => _updateLog(_currentLog.copyWith(mood: v)),
                  ),
                  const SizedBox(height: 24),

                  // 2. BODY & MIND (Now includes Skin!)
                  _SectionHeader(title: l10n.lblBodyMind, icon: CupertinoIcons.person),
                  _GlassContainer(
                    child: Column(
                      children: [
                        _RatingRow(
                          icon: CupertinoIcons.bolt_fill,
                          color: Colors.amber,
                          label: l10n.paramEnergy,
                          value: _currentLog.energy,
                          onChanged: (v) => _updateLog(_currentLog.copyWith(energy: v)),
                        ),
                        _Divider(),
                        _RatingRow(
                          icon: CupertinoIcons.moon_stars_fill,
                          color: Colors.indigoAccent,
                          label: l10n.logSleep,
                          value: _currentLog.sleep,
                          onChanged: (v) => _updateLog(_currentLog.copyWith(sleep: v)),
                        ),
                        _Divider(),
                        _RatingRow(
                          icon: CupertinoIcons.heart_fill,
                          color: Colors.pinkAccent,
                          label: l10n.paramLibido,
                          value: _currentLog.libido,
                          onChanged: (v) => _updateLog(_currentLog.copyWith(libido: v)),
                        ),
                        _Divider(),
                        // 🔥 ADDED SKIN BACK
                        _RatingRow(
                          icon: CupertinoIcons.sparkles,
                          color: Colors.purpleAccent,
                          label: l10n.paramSkin,
                          value: _currentLog.skin,
                          onChanged: (v) => _updateLog(_currentLog.copyWith(skin: v)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 3. VITALS (2 Columns)
                  _SectionHeader(title: l10n.logVitals, icon: CupertinoIcons.waveform_path_ecg),
                  Row(
                    children: [
                      Expanded(
                        child: _VitalsCard(
                          title: l10n.lblTemp,
                          unit: "°C",
                          value: _currentLog.temperature,
                          defaultValue: 36.6,
                          step: 0.1,
                          min: 35.0,
                          max: 42.0,
                          icon: CupertinoIcons.thermometer,
                          color: Colors.orange,
                          onChanged: (v) => _updateLog(_currentLog.copyWith(temperature: v)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _VitalsCard(
                          title: l10n.lblWeight,
                          unit: "kg",
                          value: _currentLog.weight,
                          defaultValue: 60.0,
                          step: 0.1,
                          min: 30.0,
                          max: 200.0,
                          icon: CupertinoIcons.gauge,
                          color: Colors.blue,
                          onChanged: (v) => _updateLog(_currentLog.copyWith(weight: v)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // 4. OVULATION TEST
                  _SectionHeader(title: l10n.ttcBtnTest, icon: CupertinoIcons.lab_flask),
                  _OvulationSelector(
                    selectedResult: _currentLog.ovulationTest,
                    l10n: l10n,
                    onChanged: (v) => _updateLog(_currentLog.copyWith(ovulationTest: v)),
                  ),
                  const SizedBox(height: 24),

                  // 5. SYMPTOMS & PAIN
                  _SectionHeader(title: l10n.logPain, icon: CupertinoIcons.bandage),
                  _SymptomGrid(
                    selectedSymptoms: _currentLog.painSymptoms,
                    l10n: l10n,
                    onToggle: (s) {
                      final list = List<String>.from(_currentLog.painSymptoms);
                      if (list.contains(s)) list.remove(s); else list.add(s);
                      _updateLog(_currentLog.copyWith(painSymptoms: list));
                    },
                  ),
                  const SizedBox(height: 24),

                  // 6. FLOW & INTIMACY
                  _SectionHeader(title: l10n.lblFlowAndLove, icon: CupertinoIcons.drop),
                  _GlassContainer(
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _FlowButton(
                                  intensity: FlowIntensity.light,
                                  isSelected: _currentLog.flow == FlowIntensity.light,
                                  onTap: () => _updateLog(_currentLog.copyWith(flow: _currentLog.flow == FlowIntensity.light ? FlowIntensity.none : FlowIntensity.light))
                              ),
                              _FlowButton(
                                  intensity: FlowIntensity.medium,
                                  isSelected: _currentLog.flow == FlowIntensity.medium,
                                  onTap: () => _updateLog(_currentLog.copyWith(flow: _currentLog.flow == FlowIntensity.medium ? FlowIntensity.none : FlowIntensity.medium))
                              ),
                              _FlowButton(
                                  intensity: FlowIntensity.heavy,
                                  isSelected: _currentLog.flow == FlowIntensity.heavy,
                                  onTap: () => _updateLog(_currentLog.copyWith(flow: _currentLog.flow == FlowIntensity.heavy ? FlowIntensity.none : FlowIntensity.heavy))
                              ),
                            ],
                          ),
                        ),
                        _Divider(),
                        _IntimacyRow(
                          hadSex: _currentLog.hadSex,
                          protected: _currentLog.protectedSex,
                          l10n: l10n,
                          onSexChanged: (v) => _updateLog(_currentLog.copyWith(hadSex: v)),
                          onProtectedChanged: (v) => _updateLog(_currentLog.copyWith(protectedSex: v)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 7. NOTES
                  _SectionHeader(title: l10n.logNotes, icon: CupertinoIcons.pencil),
                  _GlassContainer(
                    child: Container(
                      constraints: const BoxConstraints(minHeight: 120),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: TextField(
                        controller: _notesController,
                        maxLines: null,
                        onChanged: (_) => setState(() => _isDirty = true),
                        style: TextStyle(fontSize: 16, height: 1.5, color: AppColors.textPrimary),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: l10n.hintNotes,
                          hintStyle: TextStyle(color: AppColors.textSecondary.withOpacity(0.5)),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- UI BUILDERS ---

  Widget _buildHeader(AppLocalizations l10n, double topPadding) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: EdgeInsets.only(top: topPadding + 10, bottom: 20),
          decoration: BoxDecoration(
            color: AppColors.surface.withOpacity(0.6),
            border: Border(bottom: BorderSide(color: AppColors.primary.withOpacity(0.1))),
          ),
          child: Column(
            children: [
              // Top Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            DateFormat.MMMMd(Localizations.localeOf(context).toString()).format(_selectedDate).toUpperCase(),
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textSecondary,
                              letterSpacing: 1.0,
                            ),
                          ),
                          Text(
                            l10n.logSymptomsTitle,
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                              height: 1.1,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (_isDirty)
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.mediumImpact();
                          _save();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)]),
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(color: AppColors.primary.withOpacity(0.4), blurRadius: 10, offset: const Offset(0, 4))
                            ],
                          ),
                          child: Text(
                            l10n.btnSave,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                      )
                  ],
                ),
              ),
              const SizedBox(height: 15),
              // Calendar Strip
              SizedBox(
                height: 70,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: 30, // Last 30 days
                  reverse: true,
                  physics: const BouncingScrollPhysics(),
                  itemBuilder: (ctx, index) {
                    final date = DateTime.now().subtract(Duration(days: index));
                    final isSelected = date.year == _selectedDate.year && date.month == _selectedDate.month && date.day == _selectedDate.day;

                    return GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        _loadDataForDate(date);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.symmetric(horizontal: 5),
                        width: 50,
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primary : Colors.white.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(16),
                          border: isSelected ? null : Border.all(color: Colors.white),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              DateFormat('E', Localizations.localeOf(context).toString()).format(date).toUpperCase(),
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: isSelected ? Colors.white.withOpacity(0.9) : AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              date.day.toString(),
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: isSelected ? Colors.white : AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// 🔥 MODERNIZED UI COMPONENTS
// =============================================================================

class _GlassContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;

  const _GlassContainer({required this.child, this.padding});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.surface.withOpacity(0.6),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.8), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          )
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

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;

  const _SectionHeader({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.primary.withOpacity(0.8)),
          const SizedBox(width: 8),
          Text(
            title.toUpperCase(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Divider(height: 1, indent: 56, color: AppColors.textSecondary.withOpacity(0.1));
  }
}

class _MoodSelector extends StatelessWidget {
  final int selectedMood;
  final ValueChanged<int> onMoodChanged;

  const _MoodSelector({required this.selectedMood, required this.onMoodChanged});

  @override
  Widget build(BuildContext context) {
    final moods = [
      {"v": 1, "e": "😭", "c": Colors.purple},
      {"v": 2, "e": "😟", "c": Colors.blueGrey},
      {"v": 3, "e": "😐", "c": Colors.grey},
      {"v": 4, "e": "🙂", "c": Colors.orange},
      {"v": 5, "e": "🤩", "c": Colors.amber},
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: moods.map((m) {
        final isSelected = selectedMood == m['v'];
        return GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            onMoodChanged(m['v'] as int);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.elasticOut,
            width: isSelected ? 60 : 48,
            height: isSelected ? 60 : 48,
            decoration: BoxDecoration(
              color: isSelected ? Colors.white : Colors.white.withOpacity(0.3),
              shape: BoxShape.circle,
              border: Border.all(
                  color: isSelected ? (m['c'] as Color).withOpacity(0.5) : Colors.white.withOpacity(0.5),
                  width: isSelected ? 3 : 1
              ),
              boxShadow: isSelected ? [BoxShadow(color: (m['c'] as Color).withOpacity(0.3), blurRadius: 15, spreadRadius: 2)] : [],
            ),
            alignment: Alignment.center,
            child: Text(m['e'] as String, style: TextStyle(fontSize: isSelected ? 28 : 22)),
          ),
        );
      }).toList(),
    );
  }
}

class _RatingRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final int value;
  final ValueChanged<int> onChanged;

  const _RatingRow({required this.icon, required this.color, required this.label, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(width: 16),
          Expanded(child: Text(label, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary))),
          SizedBox(
            height: 28,
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
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(left: 4),
                    width: 20,
                    height: isSelected ? 24 : 12,
                    decoration: BoxDecoration(
                      color: isSelected ? color : AppColors.textSecondary.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(6),
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

class _VitalsCard extends StatelessWidget {
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

  const _VitalsCard({
    required this.title, required this.unit, required this.value, required this.defaultValue,
    required this.step, required this.min, required this.max, required this.icon,
    required this.color, required this.onChanged
  });

  @override
  Widget build(BuildContext context) {
    final displayValue = value != null ? value!.toStringAsFixed(1) : "--";
    final activeValue = value ?? defaultValue;

    return _GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 6),
              Text(title, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
            ],
          ),
          const SizedBox(height: 12),
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(displayValue, style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: AppColors.textPrimary, height: 1.0)),
                const SizedBox(width: 2),
                Padding(padding: const EdgeInsets.only(bottom: 5), child: Text(unit, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary))),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _CircleButton(icon: CupertinoIcons.minus, onTap: () {
                HapticFeedback.lightImpact();
                final newVal = (activeValue - step).clamp(min, max);
                onChanged(double.parse(newVal.toStringAsFixed(1)));
              }),
              _CircleButton(icon: CupertinoIcons.plus, onTap: () {
                HapticFeedback.lightImpact();
                final newVal = (activeValue + step).clamp(min, max);
                onChanged(double.parse(newVal.toStringAsFixed(1)));
              }),
            ],
          )
        ],
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _CircleButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36, height: 36,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))],
        ),
        child: Icon(icon, size: 18, color: AppColors.primary),
      ),
    );
  }
}

class _SymptomGrid extends StatelessWidget {
  final List<String> selectedSymptoms;
  final ValueChanged<String> onToggle;
  final AppLocalizations l10n;

  const _SymptomGrid({required this.selectedSymptoms, required this.onToggle, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final items = [
      {"id": "cramps", "label": l10n.painCramps, "icon": CupertinoIcons.bolt_horizontal_circle},
      {"id": "headache", "label": l10n.painHeadache, "icon": CupertinoIcons.bandage},
      {"id": "bloating", "label": l10n.symptomBloating, "icon": CupertinoIcons.wind},
      {"id": "acne", "label": l10n.symptomAcne, "icon": CupertinoIcons.sparkles},
      {"id": "back", "label": l10n.painBack, "icon": CupertinoIcons.person_crop_rectangle},
      {"id": "nausea", "label": "Nausea", "icon": CupertinoIcons.tornado},
    ];

    return Wrap(
      spacing: 10, runSpacing: 10,
      children: items.map((item) {
        final isSelected = selectedSymptoms.contains(item['id']);
        return GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            onToggle(item['id'] as String);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : Colors.white.withOpacity(0.6),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: isSelected ? AppColors.primary : Colors.white, width: 1.5),
              boxShadow: isSelected ? [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))] : [],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(item['icon'] as IconData, size: 16, color: isSelected ? Colors.white : AppColors.textPrimary),
                const SizedBox(width: 8),
                Text(item['label'] as String, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: isSelected ? Colors.white : AppColors.textPrimary)),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _FlowButton extends StatelessWidget {
  final FlowIntensity intensity;
  final bool isSelected;
  final VoidCallback onTap;

  const _FlowButton({required this.intensity, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    int drops = 1;
    String label = "Light";
    Color c = Colors.pink[200]!;
    if (intensity == FlowIntensity.medium) { drops = 2; c = Colors.pink[400]!; label = "Medium"; }
    if (intensity == FlowIntensity.heavy) { drops = 3; c = Colors.pink[600]!; label = "Heavy"; }

    return GestureDetector(
      onTap: () { HapticFeedback.selectionClick(); onTap(); },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 70, height: 85,
        decoration: BoxDecoration(
          color: isSelected ? c : Colors.white.withOpacity(0.4),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? c : Colors.white.withOpacity(0.6), width: 1.5),
          boxShadow: isSelected ? [BoxShadow(color: c.withOpacity(0.4), blurRadius: 10, offset: const Offset(0, 5))] : [],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(drops, (i) => Icon(CupertinoIcons.drop_fill, size: 14, color: isSelected ? Colors.white : c)),
            ),
            const SizedBox(height: 8),
            Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isSelected ? Colors.white : AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}

class _IntimacyRow extends StatelessWidget {
  final bool hadSex;
  final bool protected;
  final ValueChanged<bool> onSexChanged;
  final ValueChanged<bool> onProtectedChanged;
  final AppLocalizations l10n;

  const _IntimacyRow({required this.hadSex, required this.protected, required this.l10n, required this.onSexChanged, required this.onProtectedChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: _IntimacyToggle(
              label: l10n.hadSex,
              icon: hadSex ? CupertinoIcons.heart_fill : CupertinoIcons.heart,
              isActive: hadSex,
              color: Colors.pinkAccent,
              onTap: () => onSexChanged(!hadSex),
            ),
          ),
          if (hadSex) ...[
            const SizedBox(width: 12),
            Expanded(
              child: _IntimacyToggle(
                label: l10n.protectedSex,
                icon: CupertinoIcons.shield_fill,
                isActive: protected,
                color: Colors.teal,
                onTap: () => onProtectedChanged(!protected),
              ),
            ),
          ]
        ],
      ),
    );
  }
}

class _IntimacyToggle extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isActive;
  final Color color;
  final VoidCallback onTap;

  const _IntimacyToggle({required this.label, required this.icon, required this.isActive, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () { HapticFeedback.mediumImpact(); onTap(); },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? color.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isActive ? color : AppColors.textSecondary.withOpacity(0.2)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isActive ? color : AppColors.textSecondary, size: 20),
            const SizedBox(width: 8),
            Text(label, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: isActive ? color : AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}

class _OvulationSelector extends StatelessWidget {
  final OvulationTestResult selectedResult;
  final ValueChanged<OvulationTestResult> onChanged;
  final AppLocalizations l10n;

  const _OvulationSelector({required this.selectedResult, required this.onChanged, required this.l10n});

  @override
  Widget build(BuildContext context) {
    return _GlassContainer(
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          Expanded(child: _OvulationOption(l10n.lblNegative, selectedResult == OvulationTestResult.negative, Colors.grey, () => onChanged(selectedResult == OvulationTestResult.negative ? OvulationTestResult.none : OvulationTestResult.negative))),
          const SizedBox(width: 8),
          Expanded(child: _OvulationOption(l10n.lblPositive, selectedResult == OvulationTestResult.positive, TTCTheme.statusTest, () => onChanged(selectedResult == OvulationTestResult.positive ? OvulationTestResult.none : OvulationTestResult.positive))),
          const SizedBox(width: 8),
          Expanded(child: _OvulationOption(l10n.lblPeak, selectedResult == OvulationTestResult.peak, Colors.purpleAccent, () => onChanged(selectedResult == OvulationTestResult.peak ? OvulationTestResult.none : OvulationTestResult.peak))),
        ],
      ),
    );
  }
}

class _OvulationOption extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  const _OvulationOption(this.label, this.isSelected, this.color, this.onTap);

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
          border: Border.all(color: isSelected ? color : AppColors.textSecondary.withOpacity(0.2)),
        ),
        alignment: Alignment.center,
        child: Text(label, style: TextStyle(color: isSelected ? Colors.white : AppColors.textSecondary, fontWeight: FontWeight.bold, fontSize: 13)),
      ),
    );
  }
}

class _InsightCard extends StatelessWidget {
  final SymptomInsight insight;
  const _InsightCard({required this.insight});

  @override
  Widget build(BuildContext context) {
    return _GlassContainer(
      padding: const EdgeInsets.all(20),
      child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: (insight.isWarning ? AppColors.error : AppColors.primary).withOpacity(0.1), shape: BoxShape.circle),
                child: Icon(insight.isWarning ? CupertinoIcons.exclamationmark_triangle_fill : CupertinoIcons.lightbulb_fill, color: insight.isWarning ? AppColors.error : AppColors.primary, size: 20)
            ),
            const SizedBox(width: 16),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(insight.title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                      const SizedBox(height: 4),
                      Text(insight.description, style: TextStyle(fontSize: 14, height: 1.4, color: AppColors.textSecondary))
                    ]
                )
            )
          ]
      ),
    );
  }
}