import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart'; // Добавляем Cupertino
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';

class DnaComparisonCard extends StatelessWidget {
  final List<double> fValues;
  final List<double> lValues;
  final AppLocalizations l10n;

  const DnaComparisonCard({
    super.key,
    required this.fValues,
    required this.lValues,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    // Используем иконки, соответствующие экрану ввода
    final labels = [l10n.logMood, l10n.paramEnergy, l10n.logSleep, l10n.paramLibido, l10n.paramSkin];
    final icons = [
      Icons.mood,               // Mood (как в вводе - эмодзи, тут иконка)
      CupertinoIcons.bolt,      // Energy
      CupertinoIcons.moon,      // Sleep
      CupertinoIcons.heart,     // Libido (как в вводе heart_fill)
      CupertinoIcons.sparkles,  // Skin (Acne в вводе = sparkles)
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.5), // Glass
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.6)),
        boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.05), blurRadius: 20)],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: _DnaHelixPainter(
                  color1: Colors.blueAccent.withOpacity(0.1),
                  color2: Colors.purpleAccent.withOpacity(0.1),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("CYCLE DNA", style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                      _Legend(),
                    ],
                  ),
                  const SizedBox(height: 20),

                  ...List.generate(labels.length, (index) {
                    if (index >= fValues.length || index >= lValues.length) return const SizedBox();
                    return _DnaRow(
                      label: labels[index],
                      icon: icons[index],
                      val1: fValues[index],
                      val2: lValues[index],
                      isLast: index == labels.length - 1,
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DnaRow extends StatelessWidget {
  final String label;
  final IconData icon;
  final double val1;
  final double val2;
  final bool isLast;

  const _DnaRow({required this.label, required this.icon, required this.val1, required this.val2, this.isLast = false});

  @override
  Widget build(BuildContext context) {
    double p1 = (val1 / 5).clamp(0.0, 1.0);
    double p2 = (val2 / 5).clamp(0.0, 1.0);
    bool win1 = val1 >= val2;

    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
      child: Row(
        children: [
          // Left (Follicular)
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(val1.toStringAsFixed(1), style: GoogleFonts.inter(fontSize: 12, color: win1 ? Colors.blueAccent : Colors.grey)),
                const SizedBox(width: 8),
                SizedBox(
                  width: 60, height: 6,
                  child: ClipRRect(borderRadius: BorderRadius.circular(3), child: LinearProgressIndicator(value: p1, backgroundColor: Colors.grey.withOpacity(0.1), color: Colors.blueAccent)),
                ),
              ],
            ),
          ),

          // Nucleus Icon
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 12),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.8), // Чуть прозрачнее
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)],
                border: Border.all(color: win1 ? Colors.blueAccent.withOpacity(0.3) : Colors.purpleAccent.withOpacity(0.3))
            ),
            child: Icon(icon, size: 16, color: AppColors.textPrimary),
          ),

          // Right (Luteal)
          Expanded(
            child: Row(
              children: [
                SizedBox(
                  width: 60, height: 6,
                  child: ClipRRect(borderRadius: BorderRadius.circular(3), child: LinearProgressIndicator(value: p2, backgroundColor: Colors.grey.withOpacity(0.1), color: Colors.purpleAccent)),
                ),
                const SizedBox(width: 8),
                Text(val2.toStringAsFixed(1), style: GoogleFonts.inter(fontSize: 12, color: !win1 ? Colors.purpleAccent : Colors.grey)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _dot(Colors.blueAccent), const SizedBox(width: 4),
        Text("FOLL.", style: GoogleFonts.inter(fontSize: 10, color: Colors.grey)),
        const SizedBox(width: 8),
        _dot(Colors.purpleAccent), const SizedBox(width: 4),
        Text("LUT.", style: GoogleFonts.inter(fontSize: 10, color: Colors.grey)),
      ],
    );
  }
  Widget _dot(Color c) => Container(width: 6, height: 6, decoration: BoxDecoration(color: c, shape: BoxShape.circle));
}

class _DnaHelixPainter extends CustomPainter {
  final Color color1;
  final Color color2;
  _DnaHelixPainter({required this.color1, required this.color2});
  @override
  void paint(Canvas canvas, Size size) {
    final paint1 = Paint()..color = color1..style = PaintingStyle.stroke..strokeWidth = 3;
    final paint2 = Paint()..color = color2..style = PaintingStyle.stroke..strokeWidth = 3;
    final path1 = Path();
    final path2 = Path();
    double width = 40; double centerX = size.width / 2;
    for (double y = 0; y <= size.height; y++) {
      double x1 = centerX + math.sin(y * 0.03) * width;
      double x2 = centerX + math.sin(y * 0.03 + math.pi) * width;
      if (y == 0) { path1.moveTo(x1, y); path2.moveTo(x2, y); } else { path1.lineTo(x1, y); path2.lineTo(x2, y); }
    }
    canvas.drawPath(path1, paint1); canvas.drawPath(path2, paint2);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}