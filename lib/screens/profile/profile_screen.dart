import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

// Imports
import '../../l10n/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../providers/settings_provider.dart';
import '../../providers/cycle_provider.dart';
import '../../providers/wellness_provider.dart';
import '../../providers/coc_provider.dart';
import '../../models/cycle_model.dart';
import '../../services/pdf_service.dart';
import '../../services/backup_service.dart';
import '../../widgets/mode_transition_overlay.dart';
import '../../widgets/premium_paywall_sheet.dart';
import '../../widgets/theme_selector_sheet.dart';
import '../../widgets/vision_card.dart';

import '../profile/profile_logic_mixin.dart';
import '../profile/profile_settings_list.dart';

class ProfileScreen extends StatelessWidget with ProfileLogicMixin {
  const ProfileScreen({super.key});

  Future<void> _ensureBoxes() async {
    if (!Hive.isBoxOpen('cycles')) await Hive.openBox('cycles');
    if (!Hive.isBoxOpen('settings')) await Hive.openBox('settings');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    final settings = context.watch<SettingsProvider>();
    final cycle = context.watch<CycleProvider>();
    final wellness = context.watch<WellnessProvider>();
    final coc = context.watch<COCProvider>();

    final bool isCOC = coc.isEnabled;
    final bool isTTC = settings.isTTCMode;
    final bool isPremium = settings.isPremium;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // 🔥 ИСПРАВЛЕНИЕ: Стандартный компактный AppBar вместо Large
          SliverAppBar(
            backgroundColor: Colors.transparent, // Прозрачный фон
            title: Text(
              l10n.tabProfile,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 20, // Аккуратный размер шрифта
              ),
            ),
            centerTitle: true, // Центрируем заголовок для аккуратности
            pinned: true,      // Закреплен при прокрутке
            floating: false,
            elevation: 0,      // Убираем тень
            automaticallyImplyLeading: false,
          ),

          // 2. Avatar Section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 24), // Немного отступа
              child: Column(
                children: [
                  _buildAvatar(isTTC, isPremium),
                  const SizedBox(height: 12),
                  Text(
                    l10n.lblUser,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w800,
                      fontSize: 22,
                    ),
                  ),
                  if (isPremium) ...[
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [Colors.amber.shade300, Colors.amber.shade600]),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        "PREMIUM MEMBER",
                        style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // 3. Settings List
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            sliver: SliverList(
              delegate: SliverChildListDelegate([

                // --- CONTRACEPTION ---
                if (!isTTC) ...[
                  _buildSectionHeader(l10n.settingsContraception),
                  _buildGlassGroup(
                    children: [
                      ProfileSwitchTile(
                        icon: Icons.medication_liquid_rounded,
                        title: l10n.settingsTrackPill,
                        value: isCOC,
                        onChanged: (val) {
                          if (val) {
                            showCOCStartDialog(context);
                          } else {
                            ModeTransitionOverlay.show(context, TransitionMode.tracking, l10n.transitionTrack, onComplete: () {
                              coc.toggleCOC(false);
                              cycle.setCOCMode(false);
                              goToHome(context);
                            });
                          }
                        },
                      ),
                      if (isCOC) ...[
                        _buildDivider(),
                        ProfileSettingsTile(
                          icon: Icons.grid_on_rounded,
                          title: l10n.settingsPackType,
                          trailing: _buildBadge(l10n.settingsPills(coc.pillCount)),
                          onTap: () => showPackTypePicker(context),
                        ),
                        _buildDivider(),
                        ProfileSettingsTile(
                          icon: Icons.access_alarm_rounded,
                          title: l10n.settingsReminder,
                          trailing: Text(
                              coc.reminderTime.format(context),
                              style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)
                          ),
                          onTap: () async {
                            final newTime = await showTimePicker(context: context, initialTime: coc.reminderTime);
                            if (newTime != null) coc.setTime(newTime, notifTitle: l10n.notifPillTitle, notifBody: l10n.notifPillBody);
                          },
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 24),
                ],

                // --- CYCLE SETTINGS ---
                _buildSectionHeader(isCOC ? l10n.settingsPackSettings : l10n.sectionCycle),
                _buildGlassGroup(
                  children: [
                    if (!isCOC)
                      ProfileSliderTile(
                        icon: Icons.loop_rounded,
                        title: l10n.insightAvgCycle,
                        value: cycle.cycleLength.toDouble().clamp(21.0, 45.0),
                        min: 21, max: 45,
                        onChanged: (val) => cycle.setCycleLength(val.toInt()),
                        suffix: l10n.daysUnit,
                      ),
                    if (!isCOC) _buildDivider(),
                    ProfileSliderTile(
                      icon: isCOC ? Icons.pause_circle_outline_rounded : Icons.water_drop_rounded,
                      title: isCOC ? (coc.pillCount == 28 ? l10n.settingsPlaceboCount : l10n.settingsBreakDuration) : l10n.insightAvgPeriod,
                      value: cycle.periodDuration.toDouble().clamp(2.0, 10.0),
                      min: 2, max: 10,
                      onChanged: (val) => cycle.setAveragePeriodDuration(val.toInt()),
                      suffix: l10n.daysUnit,
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // --- GENERAL ---
                _buildSectionHeader(l10n.settingsGeneral),
                _buildGlassGroup(
                  children: [
                    ProfileSettingsTile(
                      icon: Icons.language,
                      title: l10n.settingsLanguage,
                      trailing: DropdownButton<String>(
                        value: settings.locale.languageCode,
                        underline: const SizedBox(),
                        icon: Icon(Icons.arrow_drop_down, color: AppColors.primary),
                        style: TextStyle(color: AppColors.textPrimary, fontSize: 16),
                        items: const [
                          DropdownMenuItem(value: 'en', child: Text('English')),
                          DropdownMenuItem(value: 'ru', child: Text('Русский'))
                        ],
                        onChanged: (val) {
                          if (val != null) settings.setLocale(Locale(val));
                          cycle.reload();
                        },
                      ),
                    ),
                    _buildDivider(),

                    // THEME SELECTOR
                    ProfileSettingsTile(
                      icon: Icons.palette_rounded,
                      title: l10n.settingsTheme,
                      trailing: Container(
                        width: 24, height: 24,
                        decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                            boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 4)]
                        ),
                      ),
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          backgroundColor: Colors.transparent,
                          isScrollControlled: true,
                          builder: (context) => const ThemeSelectorSheet(),
                        );
                      },
                    ),
                    _buildDivider(),

                    ProfileSwitchTile(
                        icon: Icons.notifications_active_rounded,
                        title: l10n.settingsNotifs,
                        value: settings.notificationsEnabled,
                        onChanged: settings.setNotificationsEnabled
                    ),

                    if (settings.notificationsEnabled) ...[
                      _buildDivider(),
                      ProfileSwitchTile(
                        icon: Icons.nights_stay_rounded,
                        title: l10n.settingsDailyLog ?? "Daily Check-in",
                        value: settings.dailyLogEnabled,
                        onChanged: (val) => settings.toggleDailyLogReminder(val),
                      ),
                    ],

                    _buildDivider(),
                    ProfileSettingsTile(
                        icon: Icons.mail_outline_rounded,
                        title: l10n.settingsSupport,
                        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey),
                        onTap: () => openSupportEmail(context)
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // --- DATA & EXPORT ---
                _buildSectionHeader(l10n.settingsData),
                _buildGlassGroup(
                  children: [
                    ProfileSwitchTile(
                        icon: Icons.fingerprint_rounded,
                        title: l10n.settingsBiometrics,
                        value: settings.biometricsEnabled,
                        onChanged: (v) => handleBiometrics(context, v)
                    ),
                    _buildDivider(),

                    ProfileSettingsTile(
                      icon: Icons.picture_as_pdf_rounded,
                      title: l10n.settingsExport,
                      trailing: isPremium
                          ? const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey)
                          : const Icon(Icons.lock_outline, size: 20, color: Colors.amber),
                      onTap: () async {
                        if (!isPremium) {
                          await showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (_) => const PremiumPaywallSheet(),
                          );
                          return;
                        }
                        _handleExport(context, wellness, l10n);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // --- BACKUP ---
                _buildSectionHeader(l10n.sectionBackup),
                _buildGlassGroup(
                  children: [
                    Builder(builder: (ctx) => ProfileSettingsTile(
                        icon: Icons.cloud_upload_rounded,
                        title: l10n.btnSaveBackup,
                        trailing: Icon(Icons.save_alt, size: 20, color: AppColors.primary),
                        onTap: () async {
                          await _ensureBoxes();
                          if (ctx.mounted) await BackupService.createBackup(ctx);
                        }
                    )),
                    _buildDivider(),
                    ProfileSettingsTile(
                      icon: Icons.cloud_download_rounded,
                      title: l10n.btnRestoreBackup,
                      trailing: Icon(Icons.restore_page, size: 20, color: AppColors.primary),
                      onTap: () => showCupertinoDialog(
                        context: context,
                        builder: (ctx) => CupertinoAlertDialog(
                          title: Text(l10n.dialogRestoreTitle), content: Text(l10n.dialogRestoreBody),
                          actions: [
                            CupertinoDialogAction(child: Text(l10n.btnCancel), onPressed: () => Navigator.pop(ctx)),
                            CupertinoDialogAction(isDestructiveAction: true, child: Text(l10n.btnRestore), onPressed: () async {
                              Navigator.pop(ctx);
                              await _ensureBoxes();
                              await BackupService.restoreBackup(context);
                              cycle.reload();
                              settings.reload();
                            }),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),

                // --- RESET ---
                Center(
                    child: TextButton(
                        onPressed: () => showDeleteDialog(context),
                        style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            backgroundColor: Colors.red.withOpacity(0.1),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))
                        ),
                        child: Text(
                            l10n.settingsReset,
                            style: GoogleFonts.inter(color: Colors.red, fontSize: 16, fontWeight: FontWeight.bold)
                        )
                    )
                ),
                const SizedBox(height: 120),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  // --- HELPERS ---

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 12, bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: AppColors.textSecondary,
            letterSpacing: 1.2
        ),
      ),
    );
  }

  Widget _buildGlassGroup({required List<Widget> children}) {
    return VisionCard(
      isGlass: true,
      padding: EdgeInsets.zero,
      child: Column(children: children),
    );
  }

  Widget _buildDivider() {
    return const Divider(height: 1, indent: 56, color: Colors.black12);
  }

  Widget _buildAvatar(bool isTTC, bool isPremium) {
    return Center(
      child: Container(
        width: 100, height: 100,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
              colors: isPremium
                  ? [Colors.amber, Colors.orange]
                  : [AppColors.primary.withOpacity(0.5), AppColors.primary.withOpacity(0.1)],
              begin: Alignment.topLeft, end: Alignment.bottomRight
          ),
          boxShadow: [
            BoxShadow(
                color: (isPremium ? Colors.amber : AppColors.primary).withOpacity(0.2),
                blurRadius: 20,
                spreadRadius: 2
            )
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(3),
          child: Container(
            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            child: Icon(Icons.person, size: 50, color: AppColors.primary),
          ),
        ),
      ),
    );
  }

  Widget _buildBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
      child: Text(text, style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 12)),
    );
  }

  Future<void> _handleExport(BuildContext context, WellnessProvider wellness, AppLocalizations l10n) async {
    // ... logic remains same ...
    final allLogs = wellness.getLogHistory();
    final validLogs = allLogs.where((l) {
      return l.flow != FlowIntensity.none ||
          l.painSymptoms.isNotEmpty ||
          l.symptoms.isNotEmpty ||
          (l.notes != null && l.notes!.trim().isNotEmpty) ||
          (l.temperature != null && l.temperature! > 0) ||
          l.ovulationTest != OvulationTestResult.none ||
          l.mood != 3 ||
          l.energy != 3 ||
          l.libido != 3;
    }).toList();

    if (validLogs.length < 7) {
      if (context.mounted) {
        showCupertinoDialog(
          context: context,
          builder: (ctx) => CupertinoAlertDialog(
            title: Text(l10n.dialogDataInsufficientTitle),
            content: Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(l10n.dialogDataInsufficientBody),
            ),
            actions: [
              CupertinoDialogAction(
                child: Text(l10n.btnOk),
                onPressed: () => Navigator.pop(ctx),
              )
            ],
          ),
        );
      }
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (c) => const Center(child: CircularProgressIndicator()),
    );

    try {
      await PdfService.generateReport(context);
      if (context.mounted) Navigator.pop(context);
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.msgExportError)));
      }
    }
  }
}