import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';

// L10n & Theme
import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';

// Providers & Services
import '../providers/cycle_provider.dart';
import '../providers/settings_provider.dart';
import '../services/notification_service.dart';
import '../providers/coc_provider.dart';

// Models
import '../models/cycle_model.dart';

// Widgets
import '../widgets/mesh_background.dart';
import '../widgets/vision_card.dart';

// Screens
import 'main_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // --- ДАННЫЕ ПОЛЬЗОВАТЕЛЯ ---
  bool _isCOC = false; // Режим КОК
  DateTime _selectedDate = DateTime.now();
  int _selectedCycleLength = 28;

  // Для КОК: 0 = 21+7, 1 = 28, 2 = 24+4
  int _selectedPackTypeIndex = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // Настроение фона для каждого этапа
  CyclePhase get _currentPhase {
    switch (_currentPage) {
      case 0: return CyclePhase.follicular;   // Welcome
      case 1: return CyclePhase.ovulation;    // Mode Selection
      case 2: return CyclePhase.menstruation; // Date
      case 3: return CyclePhase.luteal;       // Settings
      default: return CyclePhase.follicular;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    const int totalPages = 4;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 800),
              child: MeshCycleBackground(
                key: ValueKey(_currentPage),
                phase: _currentPhase,
                child: const SizedBox.expand(),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                _buildTopProgress(totalPages),
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    onPageChanged: (idx) => setState(() => _currentPage = idx),
                    children: [
                      _buildStep(
                        title: l10n.onboardTitle1,
                        body: l10n.onboardBody1,
                        content: _buildWelcomeGraphic(), // 🔥 Теперь анимированный
                      ),
                      _buildStep(
                        title: l10n.onboardModeTitle,
                        body: "",
                        content: _buildModeSelector(l10n),
                      ),
                      _buildStep(
                        title: _isCOC ? l10n.onboardDateTitlePill : l10n.onboardDateTitleCycle,
                        body: l10n.onboardBody2,
                        content: _buildDatePicker(context),
                      ),
                      _buildStep(
                        title: _isCOC ? l10n.onboardPackTitle : l10n.onboardLengthTitle,
                        body: l10n.onboardBody3,
                        content: _isCOC
                            ? _buildPackTypeSelector(context, l10n)
                            : _buildLengthSelector(context, l10n),
                      ),
                    ],
                  ),
                ),
                _buildBottomBar(l10n, totalPages),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGETS ---

  // 🔥 Использование нового анимированного виджета
  // Заменяем старый метод на этот
  Widget _buildWelcomeGraphic() {
    return const AnimatedWelcomeGraphic();
  }

  Widget _buildModeSelector(AppLocalizations l10n) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _ModeCard(
          title: l10n.onboardModeCycle,
          subtitle: l10n.onboardModeCycleDesc,
          icon: Icons.loop_rounded,
          isSelected: !_isCOC,
          onTap: () => setState(() => _isCOC = false),
        ),
        const SizedBox(height: 16),
        _ModeCard(
          title: l10n.onboardModePill,
          subtitle: l10n.onboardModePillDesc,
          icon: Icons.medication_liquid_rounded,
          isSelected: _isCOC,
          onTap: () => setState(() => _isCOC = true),
        ),
      ],
    );
  }

  Widget _buildDatePicker(BuildContext context) {
    return VisionCard(
      isGlass: true,
      padding: const EdgeInsets.all(16),
      child: Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.light(
            primary: AppColors.primary,
            onPrimary: Colors.white,
            surface: Colors.transparent,
            onSurface: AppColors.textPrimary,
          ),
          textTheme: GoogleFonts.interTextTheme(),
        ),
        child: CalendarDatePicker(
          initialDate: _selectedDate,
          firstDate: DateTime.now().subtract(const Duration(days: 60)),
          lastDate: DateTime.now(),
          onDateChanged: (val) {
            setState(() => _selectedDate = val);
            HapticFeedback.selectionClick();
          },
        ),
      ),
    );
  }

  Widget _buildLengthSelector(BuildContext context, AppLocalizations l10n) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        VisionCard(
          isGlass: true,
          padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
          child: Column(
            children: [
              Text(
                "$_selectedCycleLength",
                style: GoogleFonts.outfit(fontSize: 90, fontWeight: FontWeight.w800, color: AppColors.primary, height: 1.0),
              ),
              Text(
                l10n.daysUnit.toUpperCase(),
                style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textSecondary, letterSpacing: 2.0),
              ),
            ],
          ),
        ),
        const SizedBox(height: 40),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppColors.primary,
              inactiveTrackColor: Colors.white.withOpacity(0.5),
              thumbColor: Colors.white,
              trackHeight: 8,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 14),
            ),
            child: Slider(
              value: _selectedCycleLength.toDouble(),
              min: 21, max: 45, divisions: 24,
              onChanged: (val) {
                if (val.toInt() != _selectedCycleLength) {
                  setState(() => _selectedCycleLength = val.toInt());
                  HapticFeedback.selectionClick();
                }
              },
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          "${l10n.lblNormalRange}",
          style: TextStyle(fontSize: 12, color: AppColors.textSecondary.withOpacity(0.7)),
        ),
      ],
    );
  }

  Widget _buildPackTypeSelector(BuildContext context, AppLocalizations l10n) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _PackTypeOption(
          label: l10n.pack21,
          isSelected: _selectedPackTypeIndex == 0,
          onTap: () => setState(() => _selectedPackTypeIndex = 0),
        ),
        const SizedBox(height: 12),
        _PackTypeOption(
          label: l10n.pack24,
          isSelected: _selectedPackTypeIndex == 2,
          onTap: () => setState(() => _selectedPackTypeIndex = 2),
        ),
        const SizedBox(height: 12),
        _PackTypeOption(
          label: l10n.pack28,
          isSelected: _selectedPackTypeIndex == 1,
          onTap: () => setState(() => _selectedPackTypeIndex = 1),
        ),
      ],
    );
  }

  // --- LAYOUT HELPERS ---

  Widget _buildStep({required String title, required String body, required Widget content}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const Spacer(flex: 1),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            child: Column(
              key: ValueKey(title),
              children: [
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(fontSize: 32, fontWeight: FontWeight.w800, color: AppColors.textPrimary, height: 1.1),
                ),
                if (body.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    body,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(fontSize: 16, color: AppColors.textSecondary, height: 1.5),
                  ),
                ],
              ],
            ),
          ),
          const Spacer(flex: 1),
          SizedBox(height: 380, child: Center(child: content)),
          const Spacer(flex: 2),
        ],
      ),
    );
  }

  Widget _buildTopProgress(int total) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(total, (index) {
          final isActive = index == _currentPage;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            height: 6,
            width: isActive ? 30 : 10,
            decoration: BoxDecoration(
              color: isActive ? AppColors.primary : Colors.black12,
              borderRadius: BorderRadius.circular(3),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildBottomBar(AppLocalizations l10n, int total) {
    final bool isLastPage = _currentPage == total - 1;

    return Padding(
      padding: const EdgeInsets.fromLTRB(30, 0, 30, 40),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (_currentPage > 0)
            GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                _pageController.previousPage(duration: const Duration(milliseconds: 500), curve: Curves.easeOutCubic);
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.5), shape: BoxShape.circle),
                child: Icon(Icons.arrow_back, color: AppColors.textPrimary),
              ),
            )
          else
            const SizedBox(width: 56),

          GestureDetector(
            onTap: () => _nextPage(total),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: 64,
              padding: EdgeInsets.symmetric(horizontal: isLastPage ? 40 : 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
                    begin: Alignment.topLeft, end: Alignment.bottomRight
                ),
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  )
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isLastPage) ...[
                    Text(
                      l10n.btnStart.toUpperCase(),
                      style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16, letterSpacing: 1.0),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Icon(isLastPage ? Icons.check : Icons.arrow_forward_rounded, color: Colors.white, size: 28),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _nextPage(int total) {
    HapticFeedback.lightImpact();
    if (_currentPage < total - 1) {
      _pageController.nextPage(duration: const Duration(milliseconds: 600), curve: Curves.easeOutCubic);
    } else {
      _finishOnboarding();
    }
  }

  Future<void> _finishOnboarding() async {
    HapticFeedback.heavyImpact();

    final cycleProvider = context.read<CycleProvider>();
    final settingsProvider = context.read<SettingsProvider>();
    final cocProvider = context.read<COCProvider>();

    try {
      if (_isCOC) {
        int pillCount = 21;
        int breakDays = 7;

        if (_selectedPackTypeIndex == 1) { pillCount = 28; breakDays = 0; }
        if (_selectedPackTypeIndex == 2) { pillCount = 24; breakDays = 4; }

        await cocProvider.initSettings(
          startDate: _selectedDate,
          activePills: pillCount,
          breakDays: breakDays,
        );

        await cycleProvider.setCOCMode(true);
        await cocProvider.toggleCOC(true);

      } else {
        await cycleProvider.setCOCMode(false);
        await cycleProvider.setSpecificCycleStartDate(_selectedDate);
        await cycleProvider.setCycleLength(_selectedCycleLength);
      }

      await context.read<NotificationService>().requestPermissions();
      await settingsProvider.completeOnboarding();

      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 1000),
          pageBuilder: (_, __, ___) => const MainScreen(),
          transitionsBuilder: (_, a, __, c) => FadeTransition(opacity: a, child: c),
        ),
      );
    } catch (e) {
      debugPrint("Onboarding error: $e");
    }
  }
}

class _ModeCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _ModeCard({required this.title, required this.subtitle, required this.icon, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () { HapticFeedback.selectionClick(); onTap(); },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white.withOpacity(0.5),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: isSelected ? AppColors.primary : Colors.white),
          boxShadow: isSelected ? [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4))] : [],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                  color: isSelected ? Colors.white.withOpacity(0.2) : Colors.white,
                  shape: BoxShape.circle
              ),
              child: Icon(icon, color: isSelected ? Colors.white : AppColors.textPrimary, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: isSelected ? Colors.white : AppColors.textPrimary)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: GoogleFonts.inter(fontSize: 13, color: isSelected ? Colors.white.withOpacity(0.8) : AppColors.textSecondary)),
                ],
              ),
            ),
            if (isSelected) Icon(Icons.check_circle, color: Colors.white, size: 24),
          ],
        ),
      ),
    );
  }
}

class _PackTypeOption extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _PackTypeOption({required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () { HapticFeedback.selectionClick(); onTap(); },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white.withOpacity(0.5),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? AppColors.primary : Colors.white),
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : AppColors.textPrimary
            ),
          ),
        ),
      ),
    );
  }
}

// 🔥 НОВЫЙ КЛАСС АНИМАЦИИ (Вставьте в конец файла onboarding_screen.dart)
class AnimatedWelcomeGraphic extends StatefulWidget {
  const AnimatedWelcomeGraphic({super.key});

  @override
  State<AnimatedWelcomeGraphic> createState() => _AnimatedWelcomeGraphicState();
}

class _AnimatedWelcomeGraphicState extends State<AnimatedWelcomeGraphic> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3), // Чуть быстрее для динамики
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final t = _controller.value;
          // Используем более резкую кривую для эффекта "вспышки"
          final curveValue = Curves.easeInOutCubic.transform(t);

          const double baseSize = 200.0;

          return SizedBox(
            width: 400, // Увеличили общую область, чтобы свечение не обрезалось
            height: 400,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Слой 1: Широкое внешнее свечение (Градиент)
                Container(
                  width: 300 + (80 * curveValue), // Сильнее расширяется
                  height: 300 + (80 * curveValue),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppColors.primary.withOpacity(0.3), // 🔥 Ярче (было 0.15)
                        Colors.transparent
                      ],
                      stops: const [0.0, 0.8], // Градиент идет дальше
                    ),
                  ),
                ),

                // Слой 2: Основное тело (Яркий источник света)
                Container(
                  width: baseSize,
                  height: baseSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    // Делаем саму "линзу" чуть светлее
                    color: Colors.white.withOpacity(0.15),
                    boxShadow: [
                      BoxShadow(
                        // 🔥 ГЛАВНОЕ ИЗМЕНЕНИЕ ИНТЕНСИВНОСТИ
                        color: AppColors.primary.withOpacity(0.5), // Намного ярче (было 0.2)
                        blurRadius: 60, // Сильнее размытие света (было 30)
                        spreadRadius: 10 + (20 * curveValue), // Намного сильнее пульсация (было 5)
                      ),
                      // Добавляем второй, белый слой для "горячего ядра"
                      BoxShadow(
                        color: Colors.white.withOpacity(0.3),
                        blurRadius: 30,
                        spreadRadius: 5 * curveValue,
                      ),
                    ],
                    border: Border.all(
                        color: Colors.white.withOpacity(0.3), // Ярче бордер
                        width: 2
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(1000),
                    child: BackdropFilter(
                      // Усиливаем блюр внутри, чтобы смешать цвета фона
                      filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                      child: const SizedBox(), // 🔥 Иконка убрана, теперь здесь пусто
                    ),
                  ),
                ),

                // Слой 3: Тонкое "дышащее" кольцо
                Container(
                  width: baseSize + (60 * curveValue), // Дальше улетает
                  height: baseSize + (60 * curveValue),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      // Начинает ярче, заканчивает прозрачным
                      color: Colors.white.withOpacity(0.4 - (0.4 * curveValue)),
                      width: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}