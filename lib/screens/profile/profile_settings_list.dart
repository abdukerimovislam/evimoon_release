import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../theme/app_theme.dart';
import '../../widgets/vision_card.dart';

class ProfileSectionTitle extends StatelessWidget {
  final String title;
  const ProfileSectionTitle({super.key, required this.title});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 10, bottom: 8),
      child: Text(title.toUpperCase(), style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
    );
  }
}

class ProfileSettingsGroup extends StatelessWidget {
  final List<Widget> children;
  const ProfileSettingsGroup({super.key, required this.children});
  @override
  Widget build(BuildContext context) {
    return VisionCard(padding: EdgeInsets.zero, margin: EdgeInsets.zero, child: Column(children: children));
  }
}

class ProfileSettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget? trailing;
  final VoidCallback? onTap;
  const ProfileSettingsTile({super.key, required this.icon, required this.title, this.trailing, this.onTap});
  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.08), borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: AppColors.primary, size: 22)),
      title: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
      trailing: trailing,
    );
  }
}

class ProfileSwitchTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;
  const ProfileSwitchTile({super.key, required this.icon, required this.title, required this.value, required this.onChanged});
  @override
  Widget build(BuildContext context) {
    return ProfileSettingsTile(icon: icon, title: title, onTap: () => onChanged(!value), trailing: CupertinoSwitch(value: value, onChanged: onChanged, activeColor: AppColors.primary));
  }
}

class ProfileSliderTile extends StatelessWidget {
  final IconData icon; final String title; final double value; final double min; final double max; final ValueChanged<double> onChanged; final String suffix;
  const ProfileSliderTile({super.key, required this.icon, required this.title, required this.value, required this.min, required this.max, required this.onChanged, required this.suffix});
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      ListTile(contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0), leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.08), borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: AppColors.primary, size: 22)), title: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: AppColors.textPrimary)), trailing: Text("${value.toInt()} $suffix", style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 16))),
      Padding(padding: const EdgeInsets.fromLTRB(16, 0, 16, 12), child: SliderTheme(data: SliderTheme.of(context).copyWith(trackHeight: 4, thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10), overlayShape: const RoundSliderOverlayShape(overlayRadius: 20), activeTrackColor: AppColors.primary, inactiveTrackColor: AppColors.primary.withOpacity(0.2), thumbColor: AppColors.primary, overlayColor: AppColors.primary.withOpacity(0.1)), child: Slider(value: value, min: min, max: max, divisions: (max - min).toInt(), onChanged: onChanged)))
    ]);
  }
}