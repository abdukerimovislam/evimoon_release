import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'dart:ui' as ui;

import '../providers/settings_provider.dart';
import '../providers/cycle_provider.dart';
import '../providers/wellness_provider.dart';
import '../models/cycle_model.dart'; // Для доступа к CyclePhase

import 'main_screen.dart';
import 'onboarding_screen.dart';
import '../l10n/app_localizations.dart';
import 'splash/realistic_moon.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _entranceController;
  late AnimationController _breathingController;
  late AnimationController _rotationController;
  late AnimationController _textController;

  // 🔥 НОВЫЙ КОНТРОЛЛЕР ДЛЯ СИНХРОНИЗАЦИИ
  late AnimationController _syncController;
  late Animation<double> _phaseAnimation;

  late Animation<double> _glowAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _textOpacity;
  late Animation<Offset> _textSlide;

  final List<Star> _stars = [];
  final int _starCount = 70;

  // Дефолтная фаза (Бренд) = 0.0 (Серп)
  // Целевая фаза будет вычислена
  double _targetPhase = 0.0;

  @override
  void initState() {
    super.initState();
    _generateStars();

    _entranceController = AnimationController(vsync: this, duration: const Duration(milliseconds: 2500));
    _breathingController = AnimationController(vsync: this, duration: const Duration(milliseconds: 5000));
    _rotationController = AnimationController(vsync: this, duration: const Duration(seconds: 40));
    _textController = AnimationController(vsync: this, duration: const Duration(milliseconds: 2000));

    // 🔥 Анимация синхронизации с циклом (1.5 секунды)
    _syncController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500));

    // Изначально анимация стоит на 0 (Дефолт)
    _phaseAnimation = Tween<double>(begin: 0.0, end: 0.0).animate(_syncController);

    _glowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _entranceController, curve: Curves.easeOutCubic));
    _scaleAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(CurvedAnimation(parent: _entranceController, curve: Curves.easeOutBack));
    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _textController, curve: Curves.easeInQuad));
    _textSlide = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(CurvedAnimation(parent: _textController, curve: Curves.easeOutCubic));

    _startAnimationSequence();
    _initializeApp();
  }

  // ... (методы _generateStars и _startAnimationSequence без изменений) ...
  void _generateStars() {
    final rng = math.Random();
    for (int i = 0; i < _starCount; i++) {
      _stars.add(Star(x: rng.nextDouble(), y: rng.nextDouble(), size: rng.nextDouble() * 2.5 + 0.5, offset: rng.nextDouble() * 2 * math.pi));
    }
  }

  void _startAnimationSequence() async {
    _rotationController.repeat();
    _breathingController.repeat(reverse: true);
    await _entranceController.forward();
    _textController.forward();
  }


  Future<void> _initializeApp() async {
    final minSplashTime = Future.delayed(const Duration(milliseconds: 3000));

    final dataLoading = Future(() async {
      if (!mounted) return;
      try {
        final cycleProvider = context.read<CycleProvider>();
        await cycleProvider.reload();
        context.read<WellnessProvider>().reload();
        context.read<SettingsProvider>().reload();

        // 🔥 РАСЧЕТ ФАЗЫ ПОСЛЕ ЗАГРУЗКИ ДАННЫХ
        if (mounted) {
          _calculateTargetPhase(cycleProvider);
        }
      } catch (e) {
        debugPrint("Error loading providers: $e");
      }
    });

    await Future.wait([minSplashTime, dataLoading]);

    // Ждем окончания анимации синхронизации, если она еще идет
    if (_syncController.isAnimating) {
      await _syncController.forward();
    }

    if (!mounted) return;
    _navigateToNext();
  }

  // 🔥 ЛОГИКА "ЖИВОЙ ЛУНЫ"
  void _calculateTargetPhase(CycleProvider provider) {
    if (!provider.isLoaded || provider.history.isEmpty) {
      // Нет данных -> Остаемся на Брендовом Серпе
      return;
    }

    final data = provider.currentData;
    final day = data.currentDay;
    final length = data.totalCycleLength;

    // Рассчитываем "Полноту" луны (0.0 = Серп, 1.0 = Полнолуние)
    double calculatedPhase = 0.0;

    // Простая логика (синусоида цикла)
    // День 1 (Месячные) -> 0.0 (Серп)
    // День 14 (Овуляция) -> 1.0 (Полная)
    // День 28 -> 0.0 (Серп)

    // Формула: Пик в середине цикла
    double cycleProgress = day / length; // 0.0 -> 1.0
    // Превращаем 0->1 в 0->1->0 (синусоида)
    calculatedPhase = math.sin(cycleProgress * math.pi);

    // Небольшая корректировка: даже в месячные не делать луну исчезающей,
    // а оставлять красивый серп (минимум 0.0, что в нашем Painter = серп)
    // Но если овуляция - хотим полную (1.0).

    // Запускаем анимацию от 0.0 (старт) до calculatedPhase
    setState(() {
      _targetPhase = calculatedPhase;
      _phaseAnimation = Tween<double>(begin: 0.0, end: _targetPhase).animate(
          CurvedAnimation(parent: _syncController, curve: Curves.easeInOutCubic)
      );
    });

    // Запускаем синхронизацию визуально
    _syncController.forward();
  }

  void _navigateToNext() {
    final settings = context.read<SettingsProvider>();
    Widget nextScreen = settings.hasSeenOnboarding ? const MainScreen() : const OnboardingScreen();

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 1200),
        pageBuilder: (_, __, ___) => nextScreen,
        transitionsBuilder: (ctx, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: ScaleTransition(scale: Tween<double>(begin: 0.85, end: 1.0).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutQuart)), child: child));
        },
      ),
    );
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _breathingController.dispose();
    _rotationController.dispose();
    _textController.dispose();
    _syncController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
    final l10n = AppLocalizations.of(context)!;
    final size = MediaQuery.of(context).size;
    final double moonContainerSize = (size.width * 0.55).clamp(150.0, 300.0);
    final double orbitSize = moonContainerSize * 0.85;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter, end: Alignment.bottomCenter,
            colors: [Color(0xFF05020B), Color(0xFF1A0F2E), Color(0xFF2D1A3D)], stops: [0.0, 0.6, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // 1. Звезды
            AnimatedBuilder(animation: _breathingController, builder: (context, child) => CustomPaint(painter: StarPainter(_stars, _breathingController.value), size: size)),

            // 2. Контент
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: moonContainerSize,
                    height: moonContainerSize,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Орбита
                        AnimatedBuilder(
                          animation: Listenable.merge([_rotationController, _entranceController]),
                          builder: (context, child) => Transform.rotate(angle: _rotationController.value * 2 * math.pi, child: Opacity(opacity: _entranceController.value * 0.4, child: Container(width: orbitSize, height: orbitSize, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white.withOpacity(0.15), width: 0.8)), child: Align(alignment: Alignment.topCenter, child: Container(width: orbitSize * 0.05, height: orbitSize * 0.05, decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.white.withOpacity(0.8), blurRadius: 8, spreadRadius: 1)])))))),
                        ),

                        // 🔥 ЖИВАЯ ЛУНА С АНИМАЦИЕЙ ФАЗЫ 🔥
                        AnimatedBuilder(
                          animation: Listenable.merge([_entranceController, _breathingController, _syncController]),
                          builder: (context, child) {
                            double breathVal = _breathingController.value;
                            double glowOpacity = _glowAnimation.value;
                            double scale = _scaleAnimation.value + (breathVal * 0.03);

                            // Текущая фаза (анимируется от 0 до реальной)
                            double currentPhase = _phaseAnimation.value;

                            return Transform.scale(
                              scale: scale,
                              child: Opacity(
                                opacity: glowOpacity,
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    // Свечение (сильнее при полной луне)
                                    Container(
                                      width: moonContainerSize * 0.6,
                                      height: moonContainerSize * 0.6,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(color: Colors.white.withOpacity((0.5 + currentPhase * 0.3) * glowOpacity), blurRadius: 20 + (currentPhase * 10), spreadRadius: 0),
                                          BoxShadow(color: const Color(0xFFA0A0FF).withOpacity(0.3 * glowOpacity), blurRadius: 50, spreadRadius: 10),
                                        ],
                                      ),
                                    ),
                                    // Реалистичная луна с параметром progress
                                    RealisticMoon(
                                      size: moonContainerSize * 0.55,
                                      progress: currentPhase, // Передаем анимацию
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  // Текст
                  SlideTransition(position: _textSlide, child: FadeTransition(opacity: _textOpacity, child: Column(children: [Text(l10n.splashTitle, style: const TextStyle(fontFamily: 'Didot', fontSize: 38, color: Colors.white, letterSpacing: 5.0, fontWeight: FontWeight.w200, shadows: [Shadow(color: Color(0x88000000), blurRadius: 15, offset: Offset(0, 5))])), const SizedBox(height: 14), Text(l10n.splashSlogan, style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.7), letterSpacing: 2.5, fontWeight: FontWeight.w300, shadows: const [Shadow(color: Color(0x44000000), blurRadius: 10, offset: Offset(0, 2))]))]))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ... Star и StarPainter оставляем как были ...
class Star { final double x, y, size, offset; Star({required this.x, required this.y, required this.size, required this.offset}); }
class StarPainter extends CustomPainter {
  final List<Star> stars; final double animationValue;
  StarPainter(this.stars, this.animationValue);
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    for (var star in stars) {
      double opacity = (math.sin((animationValue * 3 * math.pi) + star.offset) + math.cos(animationValue * 5 + star.x * 10) + 2) / 4;
      opacity = 0.2 + (opacity * 0.6);
      paint.color = Colors.white.withOpacity(opacity.clamp(0.0, 1.0));
      canvas.drawCircle(Offset(star.x * size.width, star.y * size.height), star.size, paint);
    }
  }
  @override bool shouldRepaint(covariant StarPainter oldDelegate) => oldDelegate.animationValue != animationValue;
}