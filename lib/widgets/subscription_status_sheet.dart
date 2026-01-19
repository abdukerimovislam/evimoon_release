import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart'; // 🔥 Нужен для открытия настроек iOS

import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';
import '../services/subscription_service.dart';
import '../providers/settings_provider.dart';

class SubscriptionStatusSheet extends StatelessWidget {
  const SubscriptionStatusSheet({super.key});

  Future<void> _openIOSSettings(BuildContext context) async {
    // Ссылка, которая открывает раздел подписок в App Store
    final Uri url = Uri.parse('https://apps.apple.com/account/subscriptions');

    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppLocalizations.of(context)!.msgLinkError))
        );
      }
    }
  }

  Future<void> _restore(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    bool success = await SubscriptionService.restorePurchases();

    if (context.mounted) {
      if (success) {
        await context.read<SettingsProvider>().refreshPremium();
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Purchases restored successfully!"), backgroundColor: Colors.green)
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.msgNoSubscriptions))
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag Handle
          Container(
            width: 40, height: 4,
            decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(height: 30),

          // Icon
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.verified_rounded, size: 50, color: Colors.amber),
          ),
          const SizedBox(height: 20),

          // Title
          Text(
            l10n.proStatusActive,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 10),
          Text(
            l10n.proStatusDesc,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 40),

          // Manage Button (Apple Requirement)
          ListTile(
            onTap: () => _openIOSSettings(context),
            leading: const Icon(Icons.settings_suggest_rounded, color: AppColors.primary),
            title: Text(l10n.btnManageSub, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(l10n.btnManageSubDesc, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.grey.withOpacity(0.2))
            ),
          ),

          const SizedBox(height: 16),

          // Restore Button
          TextButton(
            onPressed: () => _restore(context),
            child: Text(l10n.paywallRestore, style: const TextStyle(color: Colors.grey)),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}