import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'dart:math';
import '../providers/coc_provider.dart';
import '../providers/cycle_provider.dart';
import '../theme/app_theme.dart';
import '../l10n/app_localizations.dart';

class PillWidget extends StatefulWidget {
  const PillWidget({super.key});

  @override
  State<PillWidget> createState() => _PillWidgetState();
}

class _PillWidgetState extends State<PillWidget> {
  final FireflyController _fireflyCtrl = FireflyController();

  @override
  Widget build(BuildContext context) {
    final coc = Provider.of<COCProvider>(context);
    final cycle = Provider.of<CycleProvider>(context);
    final l10n = AppLocalizations.of(context)!;

    if (!coc.isLoaded || !coc.isEnabled) return const SizedBox.shrink();

    final currentDay = cycle.currentData.currentDay;

    // ✅ FIX: Use provider logic instead of hardcoded 21 days
    // This supports both 21/7 and 24/4 pack types automatically
    final bool isBreakWeek = coc.isOnBreak;

    // Обертка для эффекта частиц
    return FireflyOverlay(
      controller: _fireflyCtrl,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        transitionBuilder: (child, animation) => FadeTransition(opacity: animation, child: child),
        child: isBreakWeek
            ? _BreakWeekCard(currentDay: currentDay, l10n: l10n)
            : _ActivePillCard(
            coc: coc,
            l10n: l10n,
            onTake: () {
              // ЗАПУСК МАГИИ ПРИ НАЖАТИИ
              _fireflyCtrl.explode();
            }
        ),
      ),
    );
  }
}

// --- КАРТОЧКА АКТИВНОЙ ТАБЛЕТКИ ---
class _ActivePillCard extends StatelessWidget {
  final COCProvider coc;
  final AppLocalizations l10n;
  final VoidCallback onTake;

  const _ActivePillCard({required this.coc, required this.l10n, required this.onTake});

  @override
  Widget build(BuildContext context) {
    final isTaken = coc.isTakenToday;

    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        if (!isTaken) {
          onTake(); // Запускаем салют только если ПРИНИМАЕМ
          coc.takePill();
        } else {
          coc.undoTakePill();
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: isTaken
              ? const LinearGradient(colors: [Color(0xFF69F0AE), Color(0xFF00C853)])
              : LinearGradient(colors: [Colors.white.withOpacity(0.8), Colors.white.withOpacity(0.5)]),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isTaken ? Colors.transparent : Colors.white.withOpacity(0.8),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: isTaken ? const Color(0xFF00C853).withOpacity(0.3) : Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, 8),
            )
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)],
              ),
              child: Icon(
                Icons.medication_rounded,
                color: isTaken ? const Color(0xFF00C853) : AppColors.primary,
                size: 26,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: Text(
                      isTaken ? l10n.pillTaken : l10n.pillTake,
                      key: ValueKey(isTaken),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                        color: isTaken ? Colors.white : AppColors.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (!isTaken)
                    Text(
                      l10n.pillScheduled(coc.reminderTime.format(context)),
                      style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                    ),
                ],
              ),
            ),
            AnimatedScale(
              scale: isTaken ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 400),
              curve: Curves.elasticOut,
              child: const Icon(Icons.check_circle, color: Colors.white, size: 32),
            ),
          ],
        ),
      ),
    );
  }
}

// --- КАРТОЧКА ПЕРЕРЫВА ---
class _BreakWeekCard extends StatelessWidget {
  final int currentDay;
  final AppLocalizations l10n;

  const _BreakWeekCard({required this.currentDay, required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEDE7F6).withOpacity(0.9),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            child: const Icon(Icons.pause_circle_filled_rounded, color: Colors.deepPurpleAccent, size: 26),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.cocBreakPhase,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.deepPurple),
                ),
                Text(
                  l10n.cocDayInfo(currentDay),
                  style: TextStyle(fontSize: 13, color: Colors.deepPurple.withOpacity(0.7)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 🔥 СИСТЕМА ЧАСТИЦ (MOON DUST)
// ---------------------------------------------------------------------------

class FireflyController extends ChangeNotifier {
  void explode() => notifyListeners();
}

class FireflyOverlay extends StatefulWidget {
  final Widget child;
  final FireflyController controller;
  const FireflyOverlay({super.key, required this.child, required this.controller});
  @override
  State<FireflyOverlay> createState() => _FireflyOverlayState();
}

class _FireflyOverlayState extends State<FireflyOverlay> with TickerProviderStateMixin {
  final List<_Firefly> _fireflies = [];
  final Random _rnd = Random();

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_spawnFireflies);
  }

  void _spawnFireflies() {
    for (int i = 0; i < 20; i++) {
      final controller = AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 600 + _rnd.nextInt(600)),
      );

      final angle = _rnd.nextDouble() * 2 * pi;
      final speed = 30.0 + _rnd.nextDouble() * 60.0;

      final firefly = _Firefly(
        controller: controller,
        angle: angle,
        speed: speed,
        size: 3.0 + _rnd.nextDouble() * 5.0,
        color: i % 2 == 0 ? Colors.amberAccent : Colors.white,
      );

      setState(() => _fireflies.add(firefly));

      controller.forward().then((_) {
        setState(() => _fireflies.remove(firefly));
        controller.dispose();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        widget.child,
        ..._fireflies.map((f) => AnimatedBuilder(
          animation: f.controller,
          builder: (context, child) {
            final t = f.controller.value;
            final dx = cos(f.angle) * f.speed * t;
            final dy = sin(f.angle) * f.speed * t - (20 * t * t);

            return Positioned(
              left: (MediaQuery.of(context).size.width / 2) + dx - (MediaQuery.of(context).size.width / 2),
              child: Transform.translate(
                offset: Offset(dx, dy),
                child: Opacity(
                  opacity: 1.0 - t,
                  child: Container(
                    width: f.size,
                    height: f.size,
                    decoration: BoxDecoration(
                        color: f.color,
                        shape: BoxShape.circle,
                        boxShadow: [BoxShadow(color: f.color, blurRadius: 4)]
                    ),
                  ),
                ),
              ),
            );
          },
        ))
      ],
    );
  }
}

class _Firefly {
  final AnimationController controller;
  final double angle;
  final double speed;
  final double size;
  final Color color;
  _Firefly({required this.controller, required this.angle, required this.speed, required this.size, required this.color});
}