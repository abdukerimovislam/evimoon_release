import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../l10n/app_localizations.dart';
import '../../../theme/app_theme.dart';
import '../../../theme/ttc_theme.dart';
import '../../../models/cycle_model.dart';
import '../../../providers/wellness_provider.dart';
import '../../../providers/cycle_provider.dart';

enum QuickLogFocus { bbt, test, sex, none }

class TTCQuickLogSheet extends StatefulWidget {
  final DateTime date;
  final QuickLogFocus initialFocus;

  const TTCQuickLogSheet({
    super.key,
    required this.date,
    this.initialFocus = QuickLogFocus.none
  });

  @override
  State<TTCQuickLogSheet> createState() => _TTCQuickLogSheetState();
}

class _TTCQuickLogSheetState extends State<TTCQuickLogSheet> {
  late double _temp;
  late OvulationTestResult _testResult;
  late bool _hadSex;
  late bool _protectedSex;

  final ScrollController _scrollController = ScrollController();
  final GlobalKey _keyBBT = GlobalKey();
  final GlobalKey _keyTest = GlobalKey();
  final GlobalKey _keySex = GlobalKey();

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<WellnessProvider>(context, listen: false);
    final log = provider.getLogForDate(widget.date);

    _temp = log.temperature ?? 36.6;
    _testResult = log.ovulationTest;
    _hadSex = log.hadSex;
    _protectedSex = log.protectedSex;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 100), _scrollToFocus);
    });
  }

  void _scrollToFocus() {
    BuildContext? targetContext;
    switch (widget.initialFocus) {
      case QuickLogFocus.bbt: targetContext = _keyBBT.currentContext; break;
      case QuickLogFocus.test: targetContext = _keyTest.currentContext; break;
      case QuickLogFocus.sex: targetContext = _keySex.currentContext; break;
      default: break;
    }

    if (targetContext != null) {
      Scrollable.ensureVisible(
        targetContext,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOutCubic,
        alignment: 0.1,
      );
    }
  }

  // 🔥 MAIN SAVE LOGIC (PIPELINE)
  void _save() async {
    // 1. Проверка температуры
    if (!await _checkTemperatureLogic()) return;

    // 2. Проверка Менструация + Тест
    if (!await _checkPeriodLogic()) return;

    // 3. Проверка Секса (если добавим логику защиты)
    // if (!await _checkIntimacyLogic()) return;

    // ✅ Все чисто - сохраняем
    _performSave();
  }

  // --- VALIDATION LOGIC ---

  Future<bool> _checkTemperatureLogic() async {
    final l10n = AppLocalizations.of(context)!;

    // Жар (> 37.5)
    if (_temp > 37.5) {
      return await _showDialog(
        title: l10n.dialogHighTempTitle,
        content: l10n.dialogHighTempBody,
        confirmText: l10n.btnLogAnyway,
        isDestructive: false,
      );
    }
    // Слишком низкая (< 35.5)
    if (_temp < 35.5) {
      return await _showDialog(
        title: l10n.dialogLowTempTitle,
        content: l10n.dialogLowTempBody,
        confirmText: l10n.btnConfirm,
        isDestructive: false,
      );
    }
    return true;
  }

  Future<bool> _checkPeriodLogic() async {
    final l10n = AppLocalizations.of(context)!;
    final cycleProvider = Provider.of<CycleProvider>(context, listen: false);
    final currentDay = cycleProvider.currentData.currentDay;

    bool isPeriodPhase = currentDay <= 6;
    bool isHighLH = _testResult == OvulationTestResult.positive || _testResult == OvulationTestResult.peak;

    if (isPeriodPhase && isHighLH) {
      return await _showDialog(
        title: l10n.dialogPeriodLHTitle,
        content: l10n.dialogPeriodLHBody,
        confirmText: l10n.btnLogAnyway,
        isDestructive: true, // Красный цвет, так как это скорее всего ошибка
      );
    }
    return true;
  }

  // --- GENERIC DIALOG ---
  Future<bool> _showDialog({
    required String title,
    required String content,
    required String confirmText,
    bool isDestructive = false,
  }) async {
    final l10n = AppLocalizations.of(context)!;
    bool shouldProceed = false;

    await showCupertinoDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          CupertinoDialogAction(
            child: Text(l10n.btnCancel),
            onPressed: () {
              shouldProceed = false;
              Navigator.pop(ctx);
            },
          ),
          CupertinoDialogAction(
            isDestructiveAction: isDestructive,
            child: Text(confirmText),
            onPressed: () {
              shouldProceed = true;
              Navigator.pop(ctx);
            },
          ),
        ],
      ),
    );
    return shouldProceed;
  }

  // --- ACTUAL SAVE ---
  void _performSave() {
    final provider = Provider.of<WellnessProvider>(context, listen: false);
    final log = provider.getLogForDate(widget.date);

    provider.saveLog(log.copyWith(
      temperature: _temp,
      ovulationTest: _testResult,
      hadSex: _hadSex,
      protectedSex: _protectedSex,
    ));

    HapticFeedback.mediumImpact();
    Navigator.pop(context);

    if (_testResult == OvulationTestResult.positive || _testResult == OvulationTestResult.peak) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("LH Peak recorded! High fertility window active."), // Можно тоже перевести
            backgroundColor: TTCTheme.primaryGold,
          )
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        children: [
          // HEADER
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(l10n.ttcLogTitle, style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              GestureDetector(
                onTap: _save, // 🔥 ЗАПУСК ПРОВЕРКИ
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(color: TTCTheme.primaryGold, borderRadius: BorderRadius.circular(20)),
                  child: Text(l10n.btnSave, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              )
            ],
          ),
          const SizedBox(height: 10),
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.only(bottom: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  // BBT
                  _FocusHighlightWrapper(
                    key: _keyBBT,
                    isActive: widget.initialFocus == QuickLogFocus.bbt,
                    highlightColor: TTCTheme.cardBBT,
                    child: Column(
                      children: [
                        _SectionHeader(title: l10n.ttcSectionBBT, icon: CupertinoIcons.thermometer),
                        const SizedBox(height: 15),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _CircleButton(icon: CupertinoIcons.minus, onTap: () => setState(() => _temp = double.parse((_temp - 0.1).toStringAsFixed(1)))),
                            Container(
                              width: 120,
                              alignment: Alignment.center,
                              child: Text("${_temp.toStringAsFixed(1)}°C", style: GoogleFonts.inter(fontSize: 36, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                            ),
                            _CircleButton(icon: CupertinoIcons.plus, onTap: () => setState(() => _temp = double.parse((_temp + 0.1).toStringAsFixed(1)))),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  const Divider(height: 1, color: Colors.black12),
                  const SizedBox(height: 30),
                  // TEST
                  _FocusHighlightWrapper(
                    key: _keyTest,
                    isActive: widget.initialFocus == QuickLogFocus.test,
                    highlightColor: TTCTheme.cardTest,
                    child: Column(
                      children: [
                        _SectionHeader(title: l10n.ttcSectionTest, icon: CupertinoIcons.drop),
                        const SizedBox(height: 15),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(child: _ChoiceChip(
                                label: l10n.lblNegative,
                                isSelected: _testResult == OvulationTestResult.negative,
                                color: Colors.grey,
                                onTap: () => setState(() => _testResult = OvulationTestResult.negative)
                            )),
                            const SizedBox(width: 10),
                            Expanded(child: _ChoiceChip(
                                label: l10n.lblPositive,
                                isSelected: _testResult == OvulationTestResult.positive,
                                color: TTCTheme.statusTest,
                                onTap: () => setState(() => _testResult = OvulationTestResult.positive)
                            )),
                            const SizedBox(width: 10),
                            Expanded(child: _ChoiceChip(
                                label: l10n.lblPeak,
                                isSelected: _testResult == OvulationTestResult.peak,
                                color: Colors.purpleAccent,
                                onTap: () => setState(() => _testResult = OvulationTestResult.peak)
                            )),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  const Divider(height: 1, color: Colors.black12),
                  const SizedBox(height: 30),
                  // SEX
                  _FocusHighlightWrapper(
                    key: _keySex,
                    isActive: widget.initialFocus == QuickLogFocus.sex,
                    highlightColor: TTCTheme.cardSex,
                    child: Column(
                      children: [
                        _SectionHeader(title: l10n.ttcSectionSex, icon: CupertinoIcons.heart_fill),
                        const SizedBox(height: 15),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(color: Colors.grey.withOpacity(0.05), borderRadius: BorderRadius.circular(20)),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(_hadSex ? CupertinoIcons.heart_fill : CupertinoIcons.heart, color: TTCTheme.cardSex, size: 28),
                                  const SizedBox(width: 12),
                                  Text(_hadSex ? l10n.lblSexYes : l10n.lblSexNo, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                                ],
                              ),
                              CupertinoSwitch(
                                value: _hadSex,
                                activeColor: TTCTheme.cardSex,
                                onChanged: (v) => setState(() => _hadSex = v),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 50),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// --- HELPER WIDGETS ---

class _FocusHighlightWrapper extends StatefulWidget {
  final bool isActive;
  final Color highlightColor;
  final Widget child;

  const _FocusHighlightWrapper({
    super.key,
    required this.isActive,
    required this.highlightColor,
    required this.child
  });

  @override
  State<_FocusHighlightWrapper> createState() => _FocusHighlightWrapperState();
}

class _FocusHighlightWrapperState extends State<_FocusHighlightWrapper> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500));
    _opacityAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 0.15), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 0.15, end: 0.0), weight: 80),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    if (widget.isActive) {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) _controller.forward();
      });
    }
  }

  @override
  void dispose() { _controller.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: widget.highlightColor.withOpacity(_opacityAnim.value),
            border: Border.all(color: widget.highlightColor.withOpacity(_opacityAnim.value * 3), width: 2),
            borderRadius: BorderRadius.circular(24),
          ),
          child: widget.child,
        );
      },
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  const _SectionHeader({required this.title, required this.icon});
  @override
  Widget build(BuildContext context) {
    return Row(children: [Icon(icon, size: 18, color: AppColors.textSecondary), const SizedBox(width: 8), Text(title, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textSecondary))]);
  }
}

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _CircleButton({required this.icon, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(onTap: () { HapticFeedback.selectionClick(); onTap(); }, child: Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), shape: BoxShape.circle), child: Icon(icon, color: AppColors.primary, size: 24)));
  }
}

class _ChoiceChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;
  const _ChoiceChip({required this.label, required this.isSelected, required this.color, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(onTap: () { HapticFeedback.selectionClick(); onTap(); }, child: AnimatedContainer(duration: const Duration(milliseconds: 200), alignment: Alignment.center, padding: const EdgeInsets.symmetric(vertical: 12), decoration: BoxDecoration(color: isSelected ? color : Colors.transparent, borderRadius: BorderRadius.circular(16), border: Border.all(color: isSelected ? color : Colors.grey.withOpacity(0.3), width: 1.5)), child: Text(label, textAlign: TextAlign.center, style: TextStyle(color: isSelected ? Colors.white : Colors.grey, fontWeight: FontWeight.bold, fontSize: 12))));
  }
}