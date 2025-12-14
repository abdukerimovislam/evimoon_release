import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Для HapticFeedback
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

// Локализация и Тема
import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';

// Модели
import '../models/cycle_model.dart';

// Провайдеры и Сервисы
import '../providers/cycle_provider.dart';
import '../providers/settings_provider.dart';
import '../services/notification_service.dart'; // ✅ Важно для запроса прав

// Виджеты
import '../widgets/mesh_background.dart';
import '../widgets/vision_card.dart';

// Экраны
import '../main.dart'; // ✅ Переход на MainScreen (где есть НавБар)

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Временные данные для сохранения
  DateTime _selectedDate = DateTime.now();
  int _selectedLength = 28;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      // Используем MeshBackground для единого стиля
      body: MeshCycleBackground(
        phase: CyclePhase.follicular, // Нейтрально-свежая фаза для фона
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 20),

              // MAIN CONTENT (Слайдер шагов)
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(), // Блокируем свайп, только кнопки
                  onPageChanged: (idx) => setState(() => _currentPage = idx),
                  children: [
                    // Step 1: Welcome
                    _buildStep(
                      context,
                      title: l10n.onboardTitle1,
                      body: l10n.onboardBody1,
                      child: _buildWelcomeContent(),
                    ),

                    // Step 2: Date Picker
                    _buildStep(
                      context,
                      title: l10n.onboardTitle2,
                      body: l10n.onboardBody2,
                      child: _buildDateContent(context),
                    ),

                    // Step 3: Cycle Length
                    _buildStep(
                      context,
                      title: l10n.onboardTitle3,
                      body: l10n.onboardBody3,
                      child: _buildLengthContent(context, l10n),
                    ),
                  ],
                ),
              ),

              // BOTTOM NAVIGATION (Точки и кнопка)
              _buildBottomControls(),
            ],
          ),
        ),
      ),
    );
  }

  // --- КОНТЕНТ ШАГОВ ---

  Widget _buildWelcomeContent() {
    return Center(
      child: Container(
        width: 200,
        height: 200,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(0.1),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.3),
              blurRadius: 60,
              spreadRadius: 10,
            ),
            BoxShadow(
              color: Colors.white.withOpacity(0.5),
              blurRadius: 20,
              spreadRadius: 2,
            )
          ],
        ),
        child: const Icon(Icons.nightlight_round, size: 80, color: Colors.white),
      ),
    );
  }

  Widget _buildDateContent(BuildContext context) {
    return VisionCard(
      padding: const EdgeInsets.all(10),
      child: Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppColors.primary,
            onPrimary: Colors.white,
            surface: Colors.transparent,
            onSurface: AppColors.textPrimary,
          ),
        ),
        child: CalendarDatePicker(
          initialDate: _selectedDate,
          firstDate: DateTime(2023),
          lastDate: DateTime.now(),
          onDateChanged: (val) {
            setState(() => _selectedDate = val);
            HapticFeedback.selectionClick();
          },
        ),
      ),
    );
  }

  Widget _buildLengthContent(BuildContext context, AppLocalizations l10n) {
    return VisionCard(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 20),
          Text(
            "$_selectedLength",
            style: const TextStyle(fontSize: 80, fontWeight: FontWeight.bold, color: AppColors.primary),
          ),
          Text(l10n.daysUnit, style: const TextStyle(fontSize: 20, color: AppColors.textSecondary)),

          const SizedBox(height: 30),

          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppColors.primary,
              inactiveTrackColor: AppColors.primary.withOpacity(0.2),
              thumbColor: AppColors.primary,
              overlayColor: AppColors.primary.withOpacity(0.1),
              trackHeight: 6,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
            ),
            child: Slider(
              value: _selectedLength.toDouble(),
              min: 21,
              max: 35,
              divisions: 14,
              onChanged: (val) {
                if (val.toInt() != _selectedLength) {
                  setState(() => _selectedLength = val.toInt());
                  HapticFeedback.selectionClick();
                }
              },
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            "Normal cycle: 21-35 days",
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // --- ОБЩАЯ СТРУКТУРА ШАГА ---

  Widget _buildStep(BuildContext context, {required String title, required String body, required Widget child}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const Spacer(flex: 1),
          child,
          const Spacer(flex: 2),

          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary,
                height: 1.2,
                letterSpacing: -0.5
            ),
          ),
          const SizedBox(height: 16),
          Text(
            body,
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 17,
                color: AppColors.textPrimary.withOpacity(0.7),
                height: 1.5
            ),
          ),
          const Spacer(flex: 1),
        ],
      ),
    );
  }

  // --- НИЖНЯЯ ПАНЕЛЬ ---

  Widget _buildBottomControls() {
    final bool isLastPage = _currentPage == 2;

    return Container(
      padding: const EdgeInsets.fromLTRB(30, 0, 30, 40),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Индикаторы страниц
          Row(
            children: List.generate(3, (index) {
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.only(right: 8),
                height: 8,
                width: _currentPage == index ? 24 : 8,
                decoration: BoxDecoration(
                  color: _currentPage == index ? AppColors.primary : Colors.white.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(4),
                ),
              );
            }),
          ),

          // Кнопка NEXT / START
          GestureDetector(
            onTap: _nextPage,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: EdgeInsets.symmetric(horizontal: isLastPage ? 32 : 20, vertical: 16),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(30),
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
                    const Text(
                        "Start",
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)
                    ),
                    const SizedBox(width: 8),
                  ],
                  Icon(
                    isLastPage ? Icons.check : Icons.arrow_forward,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _nextPage() {
    HapticFeedback.lightImpact();
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeOutCubic,
      );
    } else {
      _finishOnboarding();
    }
  }

  // 🔥 САМАЯ ВАЖНАЯ ЛОГИКА
  Future<void> _finishOnboarding() async {
    HapticFeedback.mediumImpact();

    // 1. Сохраняем данные цикла (Hive)
    final cycleProvider = Provider.of<CycleProvider>(context, listen: false);
    cycleProvider.setPeriodDate(_selectedDate);
    cycleProvider.setCycleLength(_selectedLength);

    // 2. ✅ ЗАПРАШИВАЕМ РАЗРЕШЕНИЯ (Android 13+ / iOS)
    try {
      await context.read<NotificationService>().requestPermissions();
    } catch (e) {
      debugPrint("Permission request failed: $e");
    }

    // 3. Отмечаем, что онбординг пройден (Hive)
    await Provider.of<SettingsProvider>(context, listen: false).completeOnboarding();

    // 4. Переходим на Главный Экран (MainScreen)
    if (mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 1000),
          pageBuilder: (_, __, ___) => const MainScreen(),
          transitionsBuilder: (_, a, __, c) => FadeTransition(opacity: a, child: c),
        ),
      );
    }
  }
}