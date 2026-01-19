import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../theme/app_theme.dart';
import '../services/subscription_service.dart';
import '../providers/settings_provider.dart';
import '../l10n/app_localizations.dart';

class PremiumPaywallSheet extends StatefulWidget {
  const PremiumPaywallSheet({super.key});

  @override
  State<PremiumPaywallSheet> createState() => _PremiumPaywallSheetState();
}

class _PremiumPaywallSheetState extends State<PremiumPaywallSheet> {
  List<Package> _packages = [];
  bool _isLoading = true;
  Package? _selectedPackage;

  @override
  void initState() {
    super.initState();
    _fetchOffers();
  }

  Future<void> _fetchOffers() async {
    final offers = await SubscriptionService.getOfferings();
    if (mounted) {
      setState(() {
        _packages = offers;
        if (_packages.isNotEmpty) {
          final annual = _packages.where((p) => p.packageType == PackageType.annual);
          _selectedPackage = annual.isNotEmpty ? annual.first : _packages.last;
        }
        _isLoading = false;
      });
    }
  }

  Future<void> _buy() async {
    if (_selectedPackage == null) return;
    setState(() => _isLoading = true);

    // 1. Пытаемся купить
    bool success = await SubscriptionService.purchasePackage(_selectedPackage!);

    if (success && mounted) {
      debugPrint("✅ Paywall: Purchase successful. Forcing premium ON.");

      // 🔥 ВАЖНОЕ ИЗМЕНЕНИЕ:
      // Мы не спрашиваем "есть ли премиум?", мы ПРИНУДИТЕЛЬНО его включаем,
      // так как только что получили подтверждение успешной оплаты.
      await context.read<SettingsProvider>().setPremiumStatus(true);

      Navigator.pop(context, true); // Закрываем окно
    } else {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _restore(AppLocalizations l10n) async {
    setState(() => _isLoading = true);
    final success = await SubscriptionService.restorePurchases();
    if (success && mounted) {
      await context.read<SettingsProvider>().refreshPremium();
      Navigator.pop(context, true);
    } else {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.msgNoSubscriptions)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final double h = MediaQuery.of(context).size.height;
    final EdgeInsets safe = MediaQuery.of(context).padding;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(34)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          height: h * 0.92,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.92),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(34)),
            border: Border.all(color: Colors.white.withOpacity(0.6)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.10),
                blurRadius: 30,
                offset: const Offset(0, -10),
              )
            ],
          ),
          child: Stack(
            children: [
              // Soft premium blobs
              Positioned(
                top: -140,
                left: -120,
                child: _blurBlob(
                  size: 320,
                  color: AppColors.primary.withOpacity(0.14),
                  blur: 60,
                ),
              ),
              Positioned(
                top: -180,
                right: -140,
                child: _blurBlob(
                  size: 360,
                  color: AppColors.menstruation.withOpacity(0.10),
                  blur: 70,
                ),
              ),
              Positioned(
                bottom: -220,
                left: -160,
                child: _blurBlob(
                  size: 440,
                  color: AppColors.ovulation.withOpacity(0.08),
                  blur: 80,
                ),
              ),

              Column(
                children: [
                  const SizedBox(height: 10),

                  // Drag handle (Apple-like)
                  Container(
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.10),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 22),
                    child: _header(l10n),
                  ),

                  const SizedBox(height: 14),

                  // Content
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.fromLTRB(20, 0, 20, 14 + safe.bottom * 0.2),
                      child: Column(
                        children: [
                          const SizedBox(height: 6),

                          // Premium value card
                          _glassCard(
                            child: Column(
                              children: [
                                _featureRow(
                                  icon: Icons.palette_rounded,
                                  title: l10n.featureTimersTitle,
                                  subtitle: l10n.featureTimersDesc,
                                ),
                                const SizedBox(height: 14),
                                _featureRow(
                                  icon: Icons.picture_as_pdf_rounded,
                                  title: l10n.featurePdfTitle,
                                  subtitle: l10n.featurePdfDesc,
                                ),
                                const SizedBox(height: 14),
                                _featureRow(
                                  icon: Icons.auto_awesome_rounded,
                                  title: l10n.featureAiTitle,
                                  subtitle: l10n.featureAiDesc,
                                ),
                                const SizedBox(height: 14),
                                _featureRow(
                                  icon: Icons.child_care_rounded,
                                  title: l10n.featureTtcTitle,
                                  subtitle: l10n.featureTtcDesc,
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Plans header
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              l10n.paywallSelectPlan,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary.withOpacity(0.85),
                              ),
                            ),
                          ),

                          const SizedBox(height: 10),

                          // Packages
                          if (_isLoading)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 24),
                              child: SizedBox(
                                width: 26,
                                height: 26,
                                child: CircularProgressIndicator(strokeWidth: 2.8),
                              ),
                            )
                          else if (_packages.isEmpty)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              child: Text(
                                l10n.paywallNoOffers,
                                style: const TextStyle(color: Colors.red),
                              ),
                            )
                          else
                            ..._packages.map((pkg) => _buildPackageOption(pkg, l10n)).toList(),

                          const SizedBox(height: 90),
                        ],
                      ),
                    ),
                  ),

                  // Bottom sticky CTA (Apple-style)
                  _bottomBar(l10n),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header(AppLocalizations l10n) {
    return _glassCard(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.10),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withOpacity(0.8)),
            ),
            child: const Icon(Icons.diamond_rounded, color: AppColors.primary, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.paywallTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.paywallSubtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary.withOpacity(0.95),
                    height: 1.25,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          IconButton(
            onPressed: () => Navigator.pop(context, false),
            icon: Icon(Icons.close_rounded, color: AppColors.textSecondary.withOpacity(0.7)),
            splashRadius: 18,
          ),
        ],
      ),
    );
  }

  Widget _bottomBar(AppLocalizations l10n) {
    final String ctaText = _selectedPackage == null
        ? l10n.paywallSelectPlan
        : l10n.paywallSubscribeFor(_selectedPackage!.storeProduct.priceString);

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.75),
        border: Border(
          top: BorderSide(color: Colors.black.withOpacity(0.05)),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Primary CTA
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _buy,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  disabledBackgroundColor: AppColors.primary.withOpacity(0.35),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  elevation: 0,
                ),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  child: _isLoading
                      ? const SizedBox(
                    key: ValueKey('loading'),
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.6,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                      : Text(
                    ctaText,
                    key: const ValueKey('text'),
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),

            // Secondary actions
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _linkButton(
                  text: l10n.paywallRestore,
                  onTap: _isLoading ? null : () => _restore(l10n),
                ),
                const SizedBox(width: 16),
                Text(
                  l10n.paywallTerms,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary.withOpacity(0.75),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 6),

            // Subtle note
            Text(
              // If you have an existing l10n key for this, replace with l10n.*
              'Cancel anytime in App Store settings.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary.withOpacity(0.65),
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _linkButton({required String text, required VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.translucent,
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          color: AppColors.textSecondary.withOpacity(onTap == null ? 0.35 : 0.85),
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }

  Widget _buildPackageOption(Package package, AppLocalizations l10n) {
    final isSelected = _selectedPackage == package;
    final product = package.storeProduct;

    final String title = product.title.replaceAll(RegExp(r'\(.*\)'), '').trim();
    final String price = product.priceString;

    final bool isAnnual = package.packageType == PackageType.annual;

    return GestureDetector(
      onTap: () => setState(() => _selectedPackage = package),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: isSelected ? AppColors.primary.withOpacity(0.08) : Colors.white.withOpacity(0.75),
          border: Border.all(
            color: isSelected ? AppColors.primary.withOpacity(0.55) : Colors.black.withOpacity(0.06),
            width: isSelected ? 1.6 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isSelected ? 0.08 : 0.05),
              blurRadius: isSelected ? 18 : 14,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            // Selection dot
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.primary : Colors.black.withOpacity(0.15),
                  width: 2,
                ),
                color: isSelected ? AppColors.primary : Colors.transparent,
              ),
              child: isSelected
                  ? const Icon(Icons.check_rounded, size: 14, color: Colors.white)
                  : null,
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                            color: AppColors.textPrimary.withOpacity(0.95),
                          ),
                        ),
                      ),
                      if (isAnnual) ...[
                        const SizedBox(width: 8),
                        _pillTag(l10n.paywallBestValue),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    // If you have localized per-period strings, map them here.
                    // Leaving neutral to avoid wrong claims about billing periods.
                    'Billed via App Store',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary.withOpacity(0.80),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 10),

            Text(
              price,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: isSelected ? AppColors.primary : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _pillTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.85),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 10,
          color: Colors.white,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  Widget _featureRow({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.10),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withOpacity(0.85)),
          ),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                  color: AppColors.textPrimary.withOpacity(0.95),
                  height: 1.15,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  color: AppColors.textSecondary.withOpacity(0.85),
                  fontSize: 12.5,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _glassCard({required Widget child, EdgeInsets? padding}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: double.infinity,
          padding: padding ?? const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.65),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Colors.white.withOpacity(0.75)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 22,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _blurBlob({required double size, required Color color, required double blur}) {
    return ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      ),
    );
  }
}
