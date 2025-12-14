import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'dart:ui' as ui; // Нужен для Shader

// Импорты логики
import '../providers/settings_provider.dart';
import '../providers/cycle_provider.dart';
import '../providers/wellness_provider.dart';

// Импорты экранов
import 'onboarding_screen.dart';
import '../main.dart';
import '../l10n/app_localizations.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  // --- КОНТРОЛЛЕРЫ ---
  late AnimationController _entranceController;
  late AnimationController _breathingController;
  late AnimationController _rotationController;
  late AnimationController _textController;

  // --- АНИМАЦИИ ---
  late Animation<double> _glowAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _textOpacity;
  late Animation<Offset> _textSlide;

  // --- ЗВЕЗДЫ ---
  final List<Star> _stars = [];
  final int _starCount = 70; // Чуть больше звезд

  @override
  void initState() {
    super.initState();
    _generateStars();

    // 1. Появление (медленнее для величия)
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );

    // 2. Дыхание (очень медленное)
    _breathingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 5000),
    );

    // 3. Вращение орбиты
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 25),
    );

    // 4. Текст
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    // --- КРИВЫЕ ---
    _glowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _entranceController, curve: Curves.easeOutCubic),
    );

    _scaleAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _entranceController, curve: Curves.easeOutBack),
    );

    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeInQuad),
    );

    _textSlide = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeOutCubic),
    );

    _startAnimationSequence();
    _initializeAppData();
  }

  void _generateStars() {
    final rng = math.Random();
    for (int i = 0; i < _starCount; i++) {
      _stars.add(Star(
        x: rng.nextDouble(),
        y: rng.nextDouble(),
        size: rng.nextDouble() * 2.5 + 0.5,
        offset: rng.nextDouble() * 2 * math.pi,
      ));
    }
  }

  void _startAnimationSequence() async {
    _rotationController.repeat();
    _breathingController.repeat(reverse: true);
    await _entranceController.forward();
    _textController.forward();
  }

  Future<void> _initializeAppData() async {
    // Даем насладиться красотой подольше
    await Future.delayed(const Duration(milliseconds: 4000));

    if (!mounted) return;

    try {
      context.read<CycleProvider>().reload();
      context.read<WellnessProvider>().reload();
      context.read<SettingsProvider>().reload();
    } catch (e) {
      debugPrint("Error loading providers: $e");
    }

    final settings = context.read<SettingsProvider>();
    final bool seenOnboarding = settings.hasSeenOnboarding;
    Widget nextScreen = seenOnboarding ? const MainScreen() : const OnboardingScreen();

    if (mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 1500),
          pageBuilder: (_, __, ___) => nextScreen,
          transitionsBuilder: (_, a, __, c) => FadeTransition(opacity: a, child: c),
        ),
      );
    }
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _breathingController.dispose();
    _rotationController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);

    final l10n = AppLocalizations.of(context);

    return Scaffold(
      body: Container(
        // ФОН: Улучшенный глубокий градиент
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF05020B), // Почти черный космос
              Color(0xFF1A0F2E), // Глубокий индиго
              Color(0xFF2D1A3D), // Мистический фиолетовый внизу
            ],
            stops: [0.0, 0.6, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // СЛОЙ 1: Звезды
            AnimatedBuilder(
              animation: _breathingController,
              builder: (context, child) {
                return CustomPaint(
                  painter: StarPainter(_stars, _breathingController.value),
                  size: MediaQuery.of(context).size,
                );
              },
            ),

            // СЛОЙ 2: Контент
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // --- КОМПОЗИЦИЯ ЛУНЫ ---
                  SizedBox(
                    width: 220, // Чуть больше места для свечения
                    height: 220,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // А. Орбита
                        AnimatedBuilder(
                          animation: Listenable.merge([_rotationController, _entranceController]),
                          builder: (context, child) {
                            return Transform.rotate(
                              angle: _rotationController.value * 2 * math.pi,
                              child: Opacity(
                                opacity: _entranceController.value * 0.4,
                                child: Container(
                                  width: 170,
                                  height: 170,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.15),
                                      width: 0.8,
                                    ),
                                  ),
                                  child: Align(
                                    alignment: Alignment.topCenter,
                                    child: Container(
                                      width: 7,
                                      height: 7,
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(color: Colors.white.withOpacity(0.8), blurRadius: 8, spreadRadius: 1)
                                          ]
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),

                        // Б. 🔥 КРАСИВАЯ ЛУНА 🔥
                        AnimatedBuilder(
                          animation: Listenable.merge([_entranceController, _breathingController]),
                          builder: (context, child) {
                            double breathVal = _breathingController.value;
                            double glowOpacity = _glowAnimation.value;
                            double scale = _scaleAnimation.value + (breathVal * 0.03); // Очень легкое дыхание по размеру

                            return Transform.scale(
                              scale: scale,
                              // Оборачиваем в Opacity для плавного появления всей конструкции
                              child: Opacity(
                                opacity: glowOpacity,
                                child: Container(
                                  // 🔥 МНОГОСЛОЙНОЕ СВЕЧЕНИЕ (3 слоя)
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      // 1. Яркий ободок (Rim Light) - четкий контур
                                      BoxShadow(
                                        color: Colors.white.withOpacity(0.7 * glowOpacity),
                                        blurRadius: 15,
                                        spreadRadius: 0,
                                      ),
                                      // 2. Мягкое гало (Soft Halo) - основной свет
                                      BoxShadow(
                                        color: const Color(0xFFA0A0FF).withOpacity(0.3 * glowOpacity),
                                        blurRadius: 40,
                                        spreadRadius: 5,
                                      ),
                                      // 3. Дышащая аура (Breathing Aura) - глубокий цвет
                                      BoxShadow(
                                        color: const Color(0xFF7A50FF).withOpacity(0.2 * glowOpacity + breathVal * 0.15),
                                        blurRadius: 80,
                                        spreadRadius: 15 + (breathVal * 25),
                                      ),
                                    ],
                                  ),
                                  // 🔥 ГРАДИЕНТНАЯ ЗАЛИВКА ИКОНКИ
                                  child: ShaderMask(
                                    shaderCallback: (Rect bounds) {
                                      return const LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          Colors.white,          // Яркий верхний край
                                          Color(0xFFE0E0FF),     // Середина
                                          Color(0xFFA0A0FF),     // Мягкий фиолетовый низ
                                        ],
                                        stops: [0.0, 0.5, 1.0],
                                      ).createShader(bounds);
                                    },
                                    blendMode: BlendMode.srcIn, // Накладываем градиент на форму иконки
                                    child: const Icon(
                                      Icons.nightlight_round,
                                      size: 110,
                                      color: Colors.white, // Базовый цвет нужен для маски
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  // --- ТЕКСТ ---
                  SlideTransition(
                    position: _textSlide,
                    child: FadeTransition(
                      opacity: _textOpacity,
                      child: Column(
                        children: [
                          const Text(
                            "EviMoon",
                            style: TextStyle(
                                fontFamily: 'Didot',
                                fontSize: 38,
                                color: Colors.white,
                                letterSpacing: 5.0,
                                fontWeight: FontWeight.w200, // Более тонкий и изящный
                                shadows: [
                                  Shadow(color: Color(0x88000000), blurRadius: 15, offset: Offset(0, 5))
                                ]
                            ),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            // Используем перевод или дефолтный текст, если null
                            l10n?.splashSlogan ?? "Your cycle. Your rhythm.",
                            style: TextStyle(
                                fontSize: 14,
                                color: Colors.white.withOpacity(0.7),
                                letterSpacing: 2.5,
                                fontWeight: FontWeight.w300,
                                shadows: const [
                                  Shadow(color: Color(0x44000000), blurRadius: 10, offset: Offset(0, 2))
                                ]
                            ),
                          ),
                        ],
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

// --- ЗВЕЗДЫ (Без изменений) ---
class Star { final double x, y, size, offset; Star({required this.x, required this.y, required this.size, required this.offset}); }
class StarPainter extends CustomPainter {
  final List<Star> stars; final double animationValue;
  StarPainter(this.stars, this.animationValue);
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    for (var star in stars) {
      double opacity = (math.sin((animationValue * 2 * math.pi) + star.offset) + 1) / 2;
      opacity = 0.15 + (opacity * 0.65); // Чуть ярче звезды
      paint.color = Colors.white.withOpacity(opacity);
      canvas.drawCircle(Offset(star.x * size.width, star.y * size.height), star.size, paint);
    }
  }
  @override bool shouldRepaint(covariant StarPainter oldDelegate) => oldDelegate.animationValue != animationValue;
}