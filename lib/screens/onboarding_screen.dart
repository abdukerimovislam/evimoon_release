import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

// L10n & Theme
import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';

// Models
import '../models/cycle_model.dart';

// Providers & Services
import '../providers/cycle_provider.dart';
import '../providers/settings_provider.dart';
import '../services/notification_service.dart';

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

  DateTime _selectedDate = DateTime.now();
  int _selectedLength = 28;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: MeshCycleBackground(
        phase: CyclePhase.follicular,
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 20),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  onPageChanged: (idx) => setState(() => _currentPage = idx),
                  children: [
                    _buildStep(
                      context,
                      title: l10n.onboardTitle1,
                      body: l10n.onboardBody1,
                      child: _buildWelcomeContent(),
                    ),
                    _buildStep(
                      context,
                      title: l10n.onboardTitle2,
                      body: l10n.onboardBody2,
                      child: _buildDateContent(context),
                    ),
                    _buildStep(
                      context,
                      title: l10n.onboardTitle3,
                      body: l10n.onboardBody3,
                      child: _buildLengthContent(context, l10n),
                    ),
                  ],
                ),
              ),
              _buildBottomControls(l10n),
            ],
          ),
        ),
      ),
    );
  }

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
            style: const TextStyle(
              fontSize: 80,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
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
                final next = val.toInt();
                if (next != _selectedLength) {
                  setState(() => _selectedLength = next);
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

  Widget _buildStep(
      BuildContext context, {
        required String title,
        required String body,
        required Widget child,
      }) {
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
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            body,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 17,
              color: AppColors.textPrimary.withOpacity(0.7),
              height: 1.5,
            ),
          ),
          const Spacer(flex: 1),
        ],
      ),
    );
  }

  Widget _buildBottomControls(AppLocalizations l10n) {
    final bool isLastPage = _currentPage == 2;

    return Container(
      padding: const EdgeInsets.fromLTRB(30, 0, 30, 40),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
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
                    Text(
                      l10n.btnStart,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
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

  Future<void> _finishOnboarding() async {
    HapticFeedback.mediumImpact();

    final cycleProvider = context.read<CycleProvider>();
    final settingsProvider = context.read<SettingsProvider>();

    // ✅ ВАЖНО: await, чтобы не было гонок сохранения
    await cycleProvider.setSpecificCycleStartDate(_selectedDate);
    await cycleProvider.setCycleLength(_selectedLength);

    try {
      await context.read<NotificationService>().requestPermissions();
    } catch (e) {
      debugPrint("Permission request failed: $e");
    }

    await settingsProvider.completeOnboarding();

    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 1000),
        pageBuilder: (_, __, ___) => const MainScreen(),
        transitionsBuilder: (_, a, __, c) => FadeTransition(opacity: a, child: c),
      ),
    );
  }
}
