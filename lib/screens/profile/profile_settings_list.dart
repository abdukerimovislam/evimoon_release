import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../l10n/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../providers/settings_provider.dart';
import '../../providers/cycle_provider.dart';
import '../../services/pdf_service.dart';
import '../../services/backup_service.dart';
import '../../widgets/vision_card.dart';

class ProfileSettingsList extends StatelessWidget {
  const ProfileSettingsList({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final cycle = context.watch<CycleProvider>();
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // --- 1. ОСНОВНЫЕ ---
        ProfileSectionTitle(title: l10n.sectionGeneral),
        ProfileSettingsGroup(
          children: [
            // Уведомления
            ProfileSwitchTile(
              icon: CupertinoIcons.bell,
              title: l10n.prefNotifications,
              value: settings.notificationsEnabled,
              onChanged: (v) => settings.setNotifications(v),
            ),
            const _Divider(),
            // FaceID
            ProfileSwitchTile(
              icon: CupertinoIcons.lock_shield,
              title: l10n.prefBiometrics,
              value: settings.biometricsEnabled,
              onChanged: (v) => settings.setBiometrics(v),
            ),
            const _Divider(),
            // Режим КОК
            ProfileSwitchTile(
              icon: Icons.medication_outlined,
              title: l10n.prefCOC,
              value: cycle.isCOCEnabled,
              onChanged: (v) => cycle.setCOCMode(v),
            ),
          ],
        ),

        const SizedBox(height: 24),

        // --- 2. НАСТРОЙКИ ЦИКЛА (Слайдеры) ---
        if (!cycle.isCOCEnabled) ...[
          // Используем хардкод заголовок пока нет в l10n, или l10n.sectionGeneral
          const ProfileSectionTitle(title: "CYCLE CONFIGURATION"),
          ProfileSettingsGroup(
            children: [
              ProfileSliderTile(
                icon: CupertinoIcons.arrow_2_circlepath,
                title: "Cycle Length", // l10n.lblCycleLength
                value: cycle.cycleLength.toDouble(),
                min: 21,
                max: 45,
                suffix: l10n.unitDays, // "дн."
                onChanged: (val) => cycle.setCycleLength(val.toInt()),
              ),
              const _Divider(),
              ProfileSliderTile(
                icon: CupertinoIcons.drop,
                title: "Period Length", // l10n.lblPeriodLength
                value: cycle.avgPeriodDuration.toDouble(),
                min: 2,
                max: 9,
                suffix: l10n.unitDays,
                onChanged: (val) => cycle.setAveragePeriodDuration(val.toInt()),
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],

        // --- 3. УПРАВЛЕНИЕ ДАННЫМИ ---
        ProfileSectionTitle(title: l10n.sectionData),
        ProfileSettingsGroup(
          children: [
            // PDF Report
            ProfileSettingsTile(
              icon: CupertinoIcons.doc_text,
              title: l10n.btnExportPdf,
              trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
              onTap: () => PdfService.generateReport(context),
            ),
            const _Divider(),
            // Backup (Export)
            ProfileSettingsTile(
              icon: CupertinoIcons.cloud_upload,
              title: l10n.btnBackup, // "Резервная копия (Экспорт)"
              trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
              onTap: () => BackupService.createBackup(context),
            ),
            const _Divider(),
            // Restore (Import)
            ProfileSettingsTile(
              icon: CupertinoIcons.cloud_download,
              title: "Restore Data", // Добавьте в l10n: btnRestore
              trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
              onTap: () => BackupService.restoreBackup(context),
            ),
          ],
        ),

        const SizedBox(height: 24),

        // --- 4. О ПРИЛОЖЕНИИ ---
        ProfileSectionTitle(title: l10n.sectionAbout),
        ProfileSettingsGroup(
          children: [
            ProfileSettingsTile(
              icon: CupertinoIcons.mail,
              title: l10n.btnContactSupport,
              onTap: () => launchUrl(Uri.parse('mailto:support@evimoon.com')),
            ),
            const _Divider(),
            ProfileSettingsTile(
              icon: CupertinoIcons.star,
              title: l10n.btnRateApp,
              onTap: () {}, // Реализовать открытие стора
            ),
          ],
        ),

        const SizedBox(height: 40),
      ],
    );
  }
}

// --- ВАШИ ВИДЖЕТЫ UI ---

class _Divider extends StatelessWidget {
  const _Divider();
  @override
  Widget build(BuildContext context) {
    return const Divider(height: 1, indent: 50, color: Colors.black12);
  }
}

class ProfileSectionTitle extends StatelessWidget {
  final String title;
  const ProfileSectionTitle({super.key, required this.title});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2),
      ),
    );
  }
}

class ProfileSettingsGroup extends StatelessWidget {
  final List<Widget> children;
  const ProfileSettingsGroup({super.key, required this.children});
  @override
  Widget build(BuildContext context) {
    return VisionCard(
      padding: EdgeInsets.zero,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(children: children),
    );
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
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.08), borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: AppColors.primary, size: 22),
      ),
      title: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
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
    return ProfileSettingsTile(
      icon: icon,
      title: title,
      onTap: () => onChanged(!value),
      trailing: CupertinoSwitch(value: value, onChanged: onChanged, activeColor: AppColors.primary),
    );
  }
}

class ProfileSliderTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final double value;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;
  final String suffix;

  const ProfileSliderTile({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
    required this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.08), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: AppColors.primary, size: 22),
          ),
          title: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          trailing: Text("${value.toInt()} $suffix", style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 16)),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 4,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
              activeTrackColor: AppColors.primary,
              inactiveTrackColor: AppColors.primary.withOpacity(0.2),
              thumbColor: AppColors.primary,
              overlayColor: AppColors.primary.withOpacity(0.1),
            ),
            child: Slider(
              value: value,
              min: min,
              max: max,
              divisions: (max - min).toInt(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}