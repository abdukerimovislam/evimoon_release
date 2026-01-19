import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../theme/ttc_theme.dart';

enum TransitionMode { ttc, coc, tracking }

class ModeTransitionOverlay extends StatefulWidget {
  final TransitionMode mode;
  final String text;
  final VoidCallback onAnimationComplete;

  const ModeTransitionOverlay({
    super.key,
    required this.mode,
    required this.text,
    required this.onAnimationComplete,
  });

  /// Статический метод для удобного вызова
  static void show(BuildContext context, TransitionMode mode, String text, {VoidCallback? onComplete}) {
    Navigator.of(context, rootNavigator: true).push(
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (_, __, ___) => ModeTransitionOverlay(
          mode: mode,
          text: text,
          onAnimationComplete: onComplete ?? () {},
        ),
        transitionDuration: Duration.zero,
        reverseTransitionDuration: const Duration(milliseconds: 800),
      ),
    );
  }

  @override
  State<ModeTransitionOverlay> createState() => _ModeTransitionOverlayState();
}

class _ModeTransitionOverlayState extends State<ModeTransitionOverlay> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnim;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500), // Длительность всей магии
    );

    _opacityAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 20), // Быстрое появление
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 50),          // Пауза
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 30), // Исчезновение
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _scaleAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.8, end: 1.1), weight: 60),
      TweenSequenceItem(tween: Tween(begin: 1.1, end: 1.5), weight: 40),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _startAnimation();
  }

  void _startAnimation() async {
    HapticFeedback.mediumImpact();
    await _controller.forward();
    widget.onAnimationComplete();
    if (mounted) {
      Navigator.of(context).pop(); // Закрываем Overlay
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Настраиваем цвета и иконки под режим
    Color bgColor;
    Color iconColor;
    IconData iconData;
    List<Color> gradientColors;

    switch (widget.mode) {
      case TransitionMode.ttc:
        bgColor = TTCTheme.primaryGold;
        iconColor = Colors.white;
        iconData = Icons.child_care; // Или auto_awesome
        gradientColors = [TTCTheme.primaryGold, Colors.orangeAccent];
        break;
      case TransitionMode.coc:
        bgColor = Colors.teal;
        iconColor = Colors.white;
        iconData = Icons.security;
        gradientColors = [Colors.teal, Colors.tealAccent.shade700];
        break;
      case TransitionMode.tracking:
      default:
        bgColor = AppColors.primary;
        iconColor = Colors.white;
        iconData = Icons.spa;
        gradientColors = [AppColors.primary, AppColors.luteal];
        break;
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        // Игнорируем нажатия, пока идет анимация
        return IgnorePointer(
          child: Material(
            color: Colors.transparent,
            child: Stack(
              children: [
                // 1. Размытый фон
                BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10 * _opacityAnim.value, sigmaY: 10 * _opacityAnim.value),
                  child: Container(color: Colors.white.withOpacity(0.1)),
                ),

                // 2. Цветная подложка с градиентом
                Opacity(
                  opacity: _opacityAnim.value,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: gradientColors.map((c) => c.withOpacity(0.9)).toList(),
                      ),
                    ),
                  ),
                ),

                // 3. Контент по центру
                Center(
                  child: Opacity(
                    opacity: _opacityAnim.value,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Иконка с пульсацией
                        Transform.scale(
                          scale: _scaleAnim.value,
                          child: Container(
                            padding: const EdgeInsets.all(30),
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withOpacity(0.2),
                                border: Border.all(color: Colors.white.withOpacity(0.5), width: 2),
                                boxShadow: [
                                  BoxShadow(
                                    color: iconColor.withOpacity(0.3),
                                    blurRadius: 30,
                                    spreadRadius: 10,
                                  )
                                ]
                            ),
                            child: Icon(iconData, size: 60, color: iconColor),
                          ),
                        ),
                        const SizedBox(height: 40),

                        // Текст
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 40),
                          child: Text(
                            widget.text,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 1.2,
                              height: 1.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}