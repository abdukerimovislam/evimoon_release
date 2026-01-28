import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_theme.dart';
import '../../../theme/ttc_theme.dart';

enum TTCCTATone { soft, medium, strong }

class TTCCTAData {
  final IconData icon;
  final String title;
  final String body;
  final TTCCTATone tone;

  const TTCCTAData({
    required this.icon,
    required this.title,
    required this.body,
    required this.tone,
  });
}

class TTCCTACard extends StatelessWidget {
  final TTCCTAData data;

  const TTCCTACard({super.key, required this.data});

  Color _tint(TTCCTATone t) {
    switch (t) {
      case TTCCTATone.soft:
        return AppColors.primary.withOpacity(0.10);
      case TTCCTATone.medium:
        return TTCTheme.statusHigh.withOpacity(0.14);
      case TTCCTATone.strong:
        return TTCTheme.statusPeak.withOpacity(0.16);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(color: Colors.black.withOpacity(0.05)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _tint(data.tone),
              shape: BoxShape.circle,
            ),
            child: Icon(data.icon, color: AppColors.primary, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.title,
                  style: GoogleFonts.manrope(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  data.body,
                  style: GoogleFonts.manrope(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    height: 1.3,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}