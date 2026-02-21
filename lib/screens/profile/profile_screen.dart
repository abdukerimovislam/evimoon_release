import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui'; // Для размытия в AppBar

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

  void _showLanguageSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _LanguageSelectorSheet(),
    );
  }

  // 🔥 НОВОЕ: Диалог редактирования профиля
  void _showEditProfileDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _EditProfileSheet(),
    );
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
          // 🔥 1. ОБНОВЛЕННЫЙ APPBAR С РЕДАКТИРУЕМЫМ ПРОФИЛЕМ
          SliverAppBar(
            backgroundColor: Colors.transparent,
            expandedHeight: 280.0,
            floating: false,
            pinned: true,
            elevation: 0,
            stretch: true,
            automaticallyImplyLeading: false,

            flexibleSpace: ClipRRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                child: FlexibleSpaceBar(
                  collapseMode: CollapseMode.pin,
                  centerTitle: true,
                  titlePadding: const EdgeInsets.only(bottom: 16),

                  // При скролле имя поднимается наверх
                  title: Text(
                    settings.userName,
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                    ),
                  ),

                  background: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 20, bottom: 50),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // 🔥 АВАТАР (Кликабельный)
                          GestureDetector(
                            onTap: () => _showEditProfileDialog(context),
                            child: Stack(
                              alignment: Alignment.bottomRight,
                              children: [
                                _buildAvatar(settings.userAvatar, isPremium),
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                      color: AppColors.surface,
                                      shape: BoxShape.circle,
                                      boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)]
                                  ),
                                  child: Icon(Icons.edit, size: 14, color: AppColors.primary),
                                )
                              ],
                            ),
                          ),

                          const SizedBox(height: 16),

                          // 🔥 ИМЯ (Кликабельное)
                          GestureDetector(
                            onTap: () => _showEditProfileDialog(context),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  settings.userName,
                                  style: GoogleFonts.manrope(
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 26,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Icon(Icons.edit_rounded, size: 16, color: AppColors.textSecondary.withOpacity(0.5))
                              ],
                            ),
                          ),

                          const SizedBox(height: 8),

                          // СТАТУС PREMIUM
                          if (isPremium)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                  gradient: LinearGradient(colors: [Colors.amber.shade400, Colors.orange.shade400]),
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(color: Colors.orange.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))
                                  ]
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.verified, color: Colors.white, size: 12),
                                  const SizedBox(width: 4),
                                  Text(
                                    (l10n.badgePro ?? "PREMIUM").toUpperCase(),
                                    style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
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
                    // LANGUAGE SELECTOR
                    ProfileSettingsTile(
                      icon: Icons.language,
                      title: l10n.settingsLanguage,
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _getLanguageName(settings.locale.languageCode),
                            style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600, fontSize: 16),
                          ),
                          const SizedBox(width: 4),
                          Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey.withOpacity(0.5)),
                        ],
                      ),
                      onTap: () => _showLanguageSelector(context),
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

                    // NOTIFICATIONS SWITCH
                    ProfileSwitchTile(
                        icon: Icons.notifications_active_rounded,
                        title: l10n.settingsNotifs,
                        value: settings.notificationsEnabled,
                        onChanged: (val) async {
                          await settings.setNotificationsEnabled(val);
                          if (context.mounted && val) {
                            await context.read<CycleProvider>().rescheduleNotifications();
                          }
                        }
                    ),

                    if (settings.notificationsEnabled) ...[
                      _buildDivider(),
                      ProfileSwitchTile(
                        icon: Icons.nights_stay_rounded,
                        title: l10n.settingsDailyLog ?? "Daily Check-in",
                        value: settings.dailyLogEnabled,
                        onChanged: (val) async {
                          await settings.toggleDailyLogReminder(val);
                          if (context.mounted) {
                            await context.read<CycleProvider>().rescheduleNotifications();
                          }
                        },
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
                    // 🔥 УДАЛЕНО: ProfileSwitchTile для биометрии

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

                // --- BACKUP & RESET ---
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

  String _getLanguageName(String code) {
    switch (code) {
      case 'ru': return 'Русский';
      case 'es': return 'Español';
      case 'de': return 'Deutsch';
      case 'pt': return 'Português (Brasil)';
      case 'tr': return 'Türkçe';
      case 'pl': return 'Polski';
      default: return 'English';
    }
  }

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

  // 🔥 НОВЫЙ АВАТАР (ИСПОЛЬЗУЕТСЯ ВНУТРИ AppBar)
  Widget _buildAvatar(String emoji, bool isPremium) {
    return Container(
      width: 100, height: 100,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
            colors: isPremium
                ? [Colors.amber.shade300, Colors.orange.shade400]
                : [AppColors.primary.withOpacity(0.3), AppColors.primary.withOpacity(0.1)],
            begin: Alignment.topLeft, end: Alignment.bottomRight
        ),
        boxShadow: [
          BoxShadow(
            color: (isPremium ? Colors.orange : AppColors.primary).withOpacity(0.25),
            blurRadius: 20,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: Center(
        child: Text(
          emoji,
          style: const TextStyle(fontSize: 48), // Крупный эмоджи
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
    final allLogs = wellness.getLogHistory();

    final validLogs = allLogs.where((l) {
      bool hasFlow = l.flow != FlowIntensity.none;
      bool hasPain = l.painSymptoms.isNotEmpty;
      bool hasSymptoms = l.symptoms.isNotEmpty;
      bool hasNotes = l.notes != null && l.notes!.trim().isNotEmpty;
      bool hasTemp = l.temperature != null && l.temperature! > 0;
      bool hasTest = l.ovulationTest != OvulationTestResult.none;

      return hasFlow || hasPain || hasSymptoms || hasNotes || hasTemp || hasTest;
    }).toList();

    if (validLogs.length < 2) {
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

// 🔥 НОВЫЙ ЭКРАН РЕДАКТИРОВАНИЯ ПРОФИЛЯ
class _EditProfileSheet extends StatefulWidget {
  @override
  State<_EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<_EditProfileSheet> {
  late TextEditingController _nameController;
  final List<String> _avatars = [
    "👩", "👩‍🦰", "👱‍♀️", "👩‍🦱", "🧕",
    "👵", "🦊", "🐱", "🦄", "🐰",
    "🦋", "🌸", "✨", "🌙", "🍓"
  ];

  @override
  void initState() {
    super.initState();
    final settings = context.read<SettingsProvider>();
    _nameController = TextEditingController(text: settings.userName);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    return Container(
      padding: EdgeInsets.only(
          top: 24, left: 24, right: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Edit Profile", style: GoogleFonts.manrope(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),

          // Выбор аватарки
          SizedBox(
            height: 60,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _avatars.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final avatar = _avatars[index];
                final isSelected = settings.userAvatar == avatar;
                return GestureDetector(
                  onTap: () {
                    context.read<SettingsProvider>().setUserAvatar(avatar);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 60, height: 60,
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary.withOpacity(0.2) : Colors.grey.withOpacity(0.1),
                      shape: BoxShape.circle,
                      border: isSelected ? Border.all(color: AppColors.primary, width: 2) : null,
                    ),
                    child: Center(child: Text(avatar, style: const TextStyle(fontSize: 30))),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 24),

          // Ввод имени
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: "Your Name",
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: AppColors.primary, width: 2)
              ),
            ),
            textCapitalization: TextCapitalization.words,
            onChanged: (val) {
              context.read<SettingsProvider>().setUserName(val.isEmpty ? "User" : val);
            },
          ),

          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))
              ),
              child: Text("Done", style: GoogleFonts.manrope(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          )
        ],
      ),
    );
  }
}

class _LanguageSelectorSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final currentCode = settings.locale.languageCode;

    final languages = [
      {'code': 'en', 'name': 'English', 'flag': '🇺🇸'},
      {'code': 'ru', 'name': 'Русский', 'flag': '🇷🇺'},
      {'code': 'es', 'name': 'Español', 'flag': '🇪🇸'},
      {'code': 'de', 'name': 'Deutsch', 'flag': '🇩🇪'},
      {'code': 'pt', 'name': 'Brasil', 'flag': '🇧🇷'},
      {'code': 'tr', 'name': 'Türkçe', 'flag': '🇹🇷'},
      {'code': 'pl', 'name': 'Polski', 'flag': '🇵🇱'},
    ];

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.withOpacity(0.3), borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 20),
            Text(
              "Select Language",
              style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 20),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                physics: const BouncingScrollPhysics(),
                itemCount: languages.length,
                separatorBuilder: (_, __) => const Divider(height: 1, indent: 20, endIndent: 20),
                itemBuilder: (context, index) {
                  final lang = languages[index];
                  final isSelected = lang['code'] == currentCode;

                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                    leading: Text(lang['flag']!, style: const TextStyle(fontSize: 24)),
                    title: Text(
                      lang['name']!,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        color: isSelected ? AppColors.primary : AppColors.textPrimary,
                      ),
                    ),
                    trailing: isSelected
                        ? Icon(Icons.check_circle_rounded, color: AppColors.primary)
                        : null,
                    onTap: () async {
                      await settings.setLocale(Locale(lang['code']!));

                      if (context.mounted) {
                        await context.read<CycleProvider>().rescheduleNotifications();
                        Navigator.pop(context);
                      }
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}