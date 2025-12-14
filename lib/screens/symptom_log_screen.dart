import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';

import '../models/cycle_model.dart';
import '../providers/wellness_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/vision_card.dart';

class SymptomLogScreen extends StatefulWidget {
  final DateTime date;
  final ScrollController? scrollController;
  final bool isModal;

  const SymptomLogScreen({
    super.key,
    required this.date,
    this.scrollController,
    this.isModal = false,
  });

  @override
  State<SymptomLogScreen> createState() => _SymptomLogScreenState();
}

class _SymptomLogScreenState extends State<SymptomLogScreen> {
  late SymptomLog _currentLog;

  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _tempController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<WellnessProvider>(context, listen: false);

    _currentLog = provider.getLogForDate(widget.date);

    _notesController.text = _currentLog.notes ?? "";

    if (_currentLog.temperature != null && _currentLog.temperature! > 0) {
      _tempController.text = _currentLog.temperature.toString();
    }

    if (_currentLog.weight != null && _currentLog.weight! > 0) {
      _weightController.text = _currentLog.weight.toString();
    }
  }

  void _save() {
    final provider = Provider.of<WellnessProvider>(context, listen: false);

    double? tempVal = double.tryParse(_tempController.text.replaceAll(',', '.'));
    double? weightVal = double.tryParse(_weightController.text.replaceAll(',', '.'));

    final updatedLog = _currentLog.copyWith(
      notes: _notesController.text.trim(),
      temperature: tempVal,
      weight: weightVal,
    );

    provider.saveLog(updatedLog);

    final l10n = AppLocalizations.of(context)!;
    if (widget.isModal) {
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.msgSaved)));
      Navigator.pop(context); // Возвращаемся назад после сохранения
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Column(
        children: [
          if (widget.isModal)
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40, height: 5,
              decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2.5)),
            ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    l10n.logSymptomsTitle,
                    style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                    overflow: TextOverflow.ellipsis, maxLines: 1,
                  ),
                ),
                const SizedBox(width: 16),
                GestureDetector(
                  onTap: _save,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))]
                    ),
                    child: Text(l10n.btnSave, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView(
              controller: widget.scrollController,
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.fromLTRB(20, 10, 20, MediaQuery.of(context).viewInsets.bottom + 100),
              children: [

                // 1. VITALS
                _SectionHeader(title: l10n.logVitals, icon: Icons.monitor_heart_outlined),
                VisionCard(
                  child: Row(
                    children: [
                      Expanded(child: _CompactInput(controller: _tempController, label: l10n.lblTemp, suffix: "°C", icon: Icons.thermostat, color: Colors.orangeAccent)),
                      const SizedBox(width: 15),
                      Container(width: 1, height: 40, color: Colors.grey.withOpacity(0.2)),
                      const SizedBox(width: 15),
                      Expanded(child: _CompactInput(controller: _weightController, label: l10n.lblWeight, suffix: "kg", icon: Icons.monitor_weight_outlined, color: Colors.blueAccent)),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // 2. WELLNESS (СЛАЙДЕРЫ)
                _SectionHeader(title: l10n.lblWellness, icon: Icons.sentiment_satisfied_rounded),
                VisionCard(
                  child: Column(
                    children: [
                      // 🔥 ИСПРАВЛЕНИЕ: Если значение 0, ставим 3 (середину), чтобы слайдер не падал
                      _EmojiSlider(
                          label: l10n.logMood,
                          value: _currentLog.mood > 0 ? _currentLog.mood : 3,
                          color: Colors.purpleAccent,
                          emojis: const ["😭", "😟", "😐", "🙂", "🤩"],
                          onChanged: (v) => setState(() => _currentLog = _currentLog.copyWith(mood: v))
                      ),
                      const Divider(height: 16),
                      _EmojiSlider(
                          label: l10n.paramEnergy,
                          value: _currentLog.energy > 0 ? _currentLog.energy : 3,
                          color: Colors.orangeAccent,
                          emojis: const ["🪫", "🔌", "🔋", "⚡️", "🚀"],
                          onChanged: (v) => setState(() => _currentLog = _currentLog.copyWith(energy: v))
                      ),
                      const Divider(height: 16),
                      _EmojiSlider(
                          label: l10n.logSleep,
                          value: _currentLog.sleep > 0 ? _currentLog.sleep : 3,
                          color: Colors.indigoAccent,
                          emojis: const ["🧟", "🥱", "😐", "😌", "😴"],
                          onChanged: (v) => setState(() => _currentLog = _currentLog.copyWith(sleep: v))
                      ),
                      const Divider(height: 16),
                      _EmojiSlider(
                          label: l10n.logSkin,
                          value: _currentLog.skin > 0 ? _currentLog.skin : 3,
                          color: Colors.pinkAccent,
                          emojis: const ["🌋", "🔴", "😐", "✨", "💎"],
                          onChanged: (v) => setState(() => _currentLog = _currentLog.copyWith(skin: v))
                      ),
                      const Divider(height: 16),
                      _EmojiSlider(
                          label: l10n.logLibido,
                          value: _currentLog.libido > 0 ? _currentLog.libido : 3,
                          color: Colors.redAccent,
                          emojis: const ["❄️", "🌱", "🔥", "❤️‍🔥", "🌋"],
                          onChanged: (v) => setState(() => _currentLog = _currentLog.copyWith(libido: v))
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // 3. INTIMACY
                _SectionHeader(title: l10n.lblIntimacy, icon: Icons.favorite_rounded),
                VisionCard(
                  child: Column(
                    children: [
                      SwitchListTile.adaptive(
                        title: Text(l10n.hadSex, style: const TextStyle(fontWeight: FontWeight.w600)),
                        secondary: const Icon(Icons.favorite, color: Colors.pink),
                        activeColor: Colors.pink,
                        value: _currentLog.hadSex,
                        onChanged: (val) => setState(() => _currentLog = _currentLog.copyWith(hadSex: val)),
                      ),
                      if (_currentLog.hadSex) ...[
                        const Divider(height: 1),
                        SwitchListTile.adaptive(
                          title: Text(l10n.protectedSex, style: const TextStyle(fontWeight: FontWeight.w600)),
                          secondary: const Icon(Icons.security, color: Colors.teal),
                          activeColor: Colors.teal,
                          value: _currentLog.protectedSex,
                          onChanged: (val) => setState(() => _currentLog = _currentLog.copyWith(protectedSex: val)),
                        ),
                      ]
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // 4. FLOW
                _SectionHeader(title: l10n.logFlow, icon: Icons.water_drop_rounded),
                VisionCard(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _FlowOption(label: l10n.flowLight, color: Colors.pink[100]!, intensity: 1, isSelected: _currentLog.flow == FlowIntensity.light, onTap: () => _updateFlow(FlowIntensity.light)),
                      _FlowOption(label: l10n.flowMedium, color: Colors.pink[300]!, intensity: 2, isSelected: _currentLog.flow == FlowIntensity.medium, onTap: () => _updateFlow(FlowIntensity.medium)),
                      _FlowOption(label: l10n.flowHeavy, color: Colors.pink[600]!, intensity: 3, isSelected: _currentLog.flow == FlowIntensity.heavy, onTap: () => _updateFlow(FlowIntensity.heavy)),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // 5. LIFESTYLE
                _SectionHeader(title: l10n.lblLifestyle, icon: Icons.local_cafe_rounded),
                VisionCard(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: Wrap(
                    spacing: 10, runSpacing: 10,
                    children: [
                      _FilterChipCustom(label: l10n.factorStress, icon: Icons.warning_amber_rounded, isSelected: _currentLog.symptoms.contains('Stress'), onTap: () => _toggleSymptom('Stress')),
                      _FilterChipCustom(label: l10n.factorAlcohol, icon: Icons.wine_bar_rounded, isSelected: _currentLog.symptoms.contains('Alcohol'), onTap: () => _toggleSymptom('Alcohol')),
                      _FilterChipCustom(label: l10n.factorTravel, icon: Icons.flight_rounded, isSelected: _currentLog.symptoms.contains('Travel'), onTap: () => _toggleSymptom('Travel')),
                      _FilterChipCustom(label: l10n.factorSport, icon: Icons.fitness_center_rounded, isSelected: _currentLog.symptoms.contains('Sport'), onTap: () => _toggleSymptom('Sport')),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // 6. PAIN
                _SectionHeader(title: l10n.logPain, icon: Icons.healing_rounded),
                VisionCard(
                  child: Wrap(
                    spacing: 8, runSpacing: 10,
                    children: [
                      _SymptomChip(label: l10n.painCramps, isSelected: _currentLog.painSymptoms.contains('cramps'), onTap: () => _togglePain('cramps')),
                      _SymptomChip(label: l10n.painHeadache, isSelected: _currentLog.painSymptoms.contains('headache'), onTap: () => _togglePain('headache')),
                      _SymptomChip(label: l10n.painBack, isSelected: _currentLog.painSymptoms.contains('back'), onTap: () => _togglePain('back')),
                      _SymptomChip(label: l10n.symptomNausea, isSelected: _currentLog.painSymptoms.contains('nausea'), onTap: () => _togglePain('nausea')),
                      _SymptomChip(label: l10n.symptomBloating, isSelected: _currentLog.painSymptoms.contains('bloating'), onTap: () => _togglePain('bloating')),
                      _SymptomChip(label: l10n.symptomAcne, isSelected: _currentLog.painSymptoms.contains('acne'), onTap: () => _togglePain('acne')),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // 7. NOTES
                _SectionHeader(title: l10n.logNotes, icon: Icons.edit_note_rounded),
                VisionCard(
                  child: TextField(
                    controller: _notesController,
                    maxLines: 3,
                    style: const TextStyle(fontSize: 16),
                    decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: l10n.hintNotes,
                        hintStyle: TextStyle(color: Colors.grey[400])
                    ),
                  ),
                ),
                const SizedBox(height: 50),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _updateFlow(FlowIntensity f) {
    final newVal = (_currentLog.flow == f) ? FlowIntensity.none : f;
    setState(() => _currentLog = _currentLog.copyWith(flow: newVal));
  }

  void _togglePain(String symptom) {
    final list = List<String>.from(_currentLog.painSymptoms);
    if (list.contains(symptom)) list.remove(symptom); else list.add(symptom);
    setState(() => _currentLog = _currentLog.copyWith(painSymptoms: list));
  }

  void _toggleSymptom(String symptom) {
    final list = List<String>.from(_currentLog.symptoms);
    if (list.contains(symptom)) list.remove(symptom); else list.add(symptom);
    setState(() => _currentLog = _currentLog.copyWith(symptoms: list));
  }
}

// --- ВИДЖЕТЫ ---

class _SectionHeader extends StatelessWidget { final String title; final IconData icon; const _SectionHeader({required this.title, required this.icon}); @override Widget build(BuildContext context) { return Padding(padding: const EdgeInsets.only(left: 10, bottom: 8), child: Row(children: [Icon(icon, size: 18, color: AppColors.primary.withOpacity(0.7)), const SizedBox(width: 8), Text(title.toUpperCase(), style: const TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 1.0))])); } }
class _CompactInput extends StatelessWidget { final TextEditingController controller; final String label; final String suffix; final IconData icon; final Color color; const _CompactInput({required this.controller, required this.label, required this.suffix, required this.icon, required this.color}); @override Widget build(BuildContext context) { return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [Icon(icon, size: 14, color: color), const SizedBox(width: 4), Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold))]), TextField(controller: controller, keyboardType: const TextInputType.numberWithOptions(decimal: true), inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,1}'))], decoration: InputDecoration(border: InputBorder.none, isDense: true, hintText: "0.0", suffixText: suffix, suffixStyle: TextStyle(color: color, fontWeight: FontWeight.bold)), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary))]); } }
class _FlowOption extends StatelessWidget { final String label; final Color color; final int intensity; final bool isSelected; final VoidCallback onTap; const _FlowOption({required this.label, required this.color, required this.intensity, required this.isSelected, required this.onTap}); @override Widget build(BuildContext context) { return GestureDetector(onTap: onTap, child: AnimatedContainer(duration: const Duration(milliseconds: 200), width: 80, padding: const EdgeInsets.symmetric(vertical: 12), decoration: BoxDecoration(color: isSelected ? color.withOpacity(0.2) : Colors.transparent, borderRadius: BorderRadius.circular(16), border: Border.all(color: isSelected ? color : Colors.grey.withOpacity(0.2), width: isSelected ? 2 : 1)), child: Column(children: [Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(intensity, (index) => Icon(Icons.water_drop, size: 16, color: color))), const SizedBox(height: 6), Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isSelected ? color : Colors.grey))]))); } }
class _FilterChipCustom extends StatelessWidget { final String label; final IconData icon; final bool isSelected; final VoidCallback onTap; const _FilterChipCustom({required this.label, required this.icon, required this.isSelected, required this.onTap}); @override Widget build(BuildContext context) { return GestureDetector(onTap: onTap, child: AnimatedContainer(duration: const Duration(milliseconds: 200), padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), decoration: BoxDecoration(color: isSelected ? AppColors.primary : Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: isSelected ? Colors.transparent : Colors.grey.withOpacity(0.3)), boxShadow: isSelected ? [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 5, offset: const Offset(0, 2))] : []), child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(icon, size: 16, color: isSelected ? Colors.white : AppColors.textPrimary), const SizedBox(width: 6), Text(label, style: TextStyle(color: isSelected ? Colors.white : AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 13))]))); } }
class _SymptomChip extends StatelessWidget { final String label; final bool isSelected; final VoidCallback onTap; const _SymptomChip({required this.label, required this.isSelected, required this.onTap}); @override Widget build(BuildContext context) { return GestureDetector(onTap: onTap, child: AnimatedContainer(duration: const Duration(milliseconds: 200), padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), decoration: BoxDecoration(color: isSelected ? AppColors.primary : AppColors.primary.withOpacity(0.05), borderRadius: BorderRadius.circular(12), border: Border.all(color: isSelected ? Colors.transparent : AppColors.primary.withOpacity(0.2)),), child: Text(label, style: TextStyle(color: isSelected ? Colors.white : AppColors.primary, fontWeight: FontWeight.w600)))); } }

class _EmojiSlider extends StatelessWidget {
  final String label;
  final int value;
  final Color color;
  final List<String> emojis;
  final ValueChanged<int> onChanged;
  const _EmojiSlider({required this.label, required this.value, required this.color, required this.emojis, required this.onChanged});
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
              child: Text(emojis[(value - 1).clamp(0, 4)], key: ValueKey(value), style: const TextStyle(fontSize: 24)),
            ),
          ],
        ),
        const SizedBox(height: 5),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: color, inactiveTrackColor: color.withOpacity(0.1), thumbColor: Colors.white, trackHeight: 6, overlayColor: color.withOpacity(0.1),
            thumbShape: _EmojiThumbShape(color: color),
          ),
          child: Slider(value: value.toDouble(), min: 1, max: 5, divisions: 4, onChanged: (v) => onChanged(v.toInt())),
        ),
      ],
    );
  }
}

class _EmojiThumbShape extends SliderComponentShape {
  final Color color;
  const _EmojiThumbShape({required this.color});
  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) => const Size(24, 24);
  @override
  void paint(PaintingContext context, Offset center, {required Animation<double> activationAnimation, required Animation<double> enableAnimation, required bool isDiscrete, required TextPainter labelPainter, required RenderBox parentBox, required SliderThemeData sliderTheme, required TextDirection textDirection, required double value, required double textScaleFactor, required Size sizeWithOverflow}) {
    final canvas = context.canvas;
    canvas.drawCircle(center, 12, Paint()..color = Colors.black.withOpacity(0.1)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4));
    canvas.drawCircle(center, 10, Paint()..color = Colors.white);
    canvas.drawCircle(center, 10, Paint()..color = color..style = PaintingStyle.stroke..strokeWidth = 3);
  }
}