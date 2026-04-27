import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:truesoulcards/presentation/providers/language_provider.dart';
import 'package:truesoulcards/core/services/settings_service.dart';
import 'package:truesoulcards/l10n/app_localizations.dart';
import 'package:truesoulcards/presentation/providers/font_provider.dart';
import 'package:truesoulcards/presentation/providers/ad_provider.dart';
import 'package:truesoulcards/presentation/providers/ad_purchase_provider.dart';
import 'package:truesoulcards/presentation/widgets/glass_card.dart';

enum Filter { showAnimation }

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _settingsService = SettingsService();

  bool _showAnimation = false;
  String _appVersion = '';
  String _buildNumber = '';

  String _removeAdsPrice = '';

  final List<Map<String, String>> _languageOptions = const [
    {"code": "en", "name": "EN"},
    {"code": "uk", "name": "UA"},
    {"code": "es", "name": "ES"},
    {"code": "it", "name": "IT"},
    {"code": "fr", "name": "FR"},
    {"code": "de", "name": "DE"},
    {"code": "pl", "name": "PL"},
    {"code": "pt", "name": "PT"},
  ];

  @override
  void initState() {
    super.initState();
    _loadPreferences();
    _loadAppInfo();
    _loadRemoveAdsPrice();
  }

  Future<void> _loadAppInfo() async {
    final info = await PackageInfo.fromPlatform();
    if (!mounted) return;
    setState(() {
      _appVersion = info.version;
      _buildNumber = info.buildNumber;
    });
  }

  Future<ProductDetails?> fetchProductDetails() async {
    final String productId = dotenv.env['IN_APP_PRODUCT_ID'] ?? '';
    if (productId.isEmpty) return null;

    final Set<String> kIds = {productId};
    final response = await InAppPurchase.instance.queryProductDetails(kIds);

    if (response.notFoundIDs.isNotEmpty) {
      if (kDebugMode) {
        print('Product not found: ${response.notFoundIDs}');
      }
      return null;
    }

    return response.productDetails.first;
  }

  Future<void> _loadRemoveAdsPrice() async {
    final productDetails = await fetchProductDetails();
    if (!mounted) return;
    setState(() {
      _removeAdsPrice = productDetails?.price ?? '';
    });
  }

  Future<void> _loadPreferences() async {
    final settings = await _settingsService.loadSettings();
    setState(() {
      _showAnimation = settings['showAnimation'] ?? false;
    });
  }

  Future<void> _savePreferences() async {
    await _settingsService.saveSettings(showAnimation: _showAnimation);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final localization = AppLocalizations.of(context)!;
    final languageState = ref.watch(languageProvider);
    final fontSize = ref.watch(fontSizeProvider);
    final fontSizeNotifier = ref.read(fontSizeProvider.notifier);
    final adsDisabled = ref.watch(adsDisabledProvider);

    final isDark = theme.brightness == Brightness.dark;
    final backgroundBase = cs.surface;
    final backgroundTint = Color.alphaBlend(
      cs.primary.withOpacity(isDark ? 0.10 : 0.06),
      backgroundBase,
    );

    final glassBase = cs.surface.withOpacity(isDark ? 0.72 : 0.86);
    final glassOutline = cs.outlineVariant.withOpacity(isDark ? 0.22 : 0.18);
    final mutedText = cs.onSurface.withOpacity(isDark ? 0.72 : 0.68);
    final softShadow = theme.shadowColor.withOpacity(isDark ? 0.18 : 0.10);
    final bodyMuted = cs.onSurface.withOpacity(isDark ? 0.70 : 0.66);

    return Scaffold(
      backgroundColor: backgroundBase,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(localization.settings),
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) return;
          Navigator.of(context).pop({Filter.showAnimation: _showAnimation});
        },
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                backgroundTint,
                backgroundBase,
              ],
            ),
          ),
          child: SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(18, 10, 18, 28),
              children: [
                _SettingsSectionTitle(
                  text: localization.preferences,
                ),
                const SizedBox(height: 10),
                GlassCard(
                  padding: const EdgeInsets.fromLTRB(16, 14, 14, 16),
                  backgroundColor: glassBase,
                  outlineColor: glassOutline,
                  shadowColor: softShadow,
                  borderRadius: 22,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  localization.show_animation,
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.15,
                                    color: cs.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  localization.show_animation_when_swiping_cards,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    height: 1.28,
                                    color: bodyMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SwitchTheme(
                            data: SwitchThemeData(
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                              trackOutlineColor:
                                  WidgetStateProperty.resolveWith((states) {
                                if (states.contains(WidgetState.selected)) {
                                  return Colors.transparent;
                                }
                                return glassOutline;
                              }),
                              thumbColor:
                                  WidgetStateProperty.resolveWith((states) {
                                if (states.contains(WidgetState.disabled)) {
                                  return cs.onSurface.withOpacity(0.38);
                                }
                                if (states.contains(WidgetState.selected)) {
                                  return cs.onPrimary;
                                }
                                return cs.outline;
                              }),
                              trackColor:
                                  WidgetStateProperty.resolveWith((states) {
                                if (states.contains(WidgetState.selected)) {
                                  return cs.primary.withOpacity(
                                      isDark ? 0.65 : 0.78);
                                }
                                return cs.surfaceContainerHighest
                                    .withOpacity(isDark ? 0.5 : 0.65);
                              }),
                            ),
                            child: Switch(
                              value: _showAnimation,
                              onChanged: (value) async {
                                setState(() => _showAnimation = value);
                                await _savePreferences();
                              },
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        child: Divider(
                          height: 1,
                          thickness: 1,
                          color: glassOutline.withOpacity(0.65),
                        ),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              localization.font_size,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.15,
                                color: cs.onSurface,
                              ),
                            ),
                          ),
                          Text(
                            fontSize.toStringAsFixed(0),
                            style: theme.textTheme.labelLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: cs.primary.withOpacity(
                                  isDark ? 0.92 : 0.88),
                            ),
                          ),
                        ],
                      ),
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          trackHeight: 3.5,
                          thumbShape: const RoundSliderThumbShape(
                            enabledThumbRadius: 9,
                          ),
                          overlayShape: const RoundSliderOverlayShape(
                            overlayRadius: 18,
                          ),
                          activeTrackColor:
                              cs.primary.withOpacity(isDark ? 0.55 : 0.62),
                          inactiveTrackColor:
                              cs.onSurface.withOpacity(isDark ? 0.14 : 0.10),
                          thumbColor: cs.primary,
                          overlayColor: WidgetStateColor.resolveWith((states) {
                            return cs.primary.withOpacity(0.12);
                          }),
                        ),
                        child: Slider(
                          min: 14,
                          max: 40,
                          divisions: 26,
                          value: fontSize.clamp(14, 40),
                          label: fontSize.toStringAsFixed(0),
                          onChanged: fontSizeNotifier.setFontSize,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),
                _SettingsSectionTitle(
                  text: localization.languages,
                ),
                const SizedBox(height: 10),
                GlassCard(
                  padding: const EdgeInsets.fromLTRB(16, 14, 14, 14),
                  backgroundColor: glassBase,
                  outlineColor: glassOutline,
                  shadowColor: softShadow,
                  borderRadius: 22,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _GlassDropdownRow(
                        label: localization.primary_language,
                        value: languageState['primary']!,
                        mutedText: mutedText,
                        items: _languageOptions,
                        onChanged: (value) async {
                          if (value != null) {
                            await ref
                                .read(languageProvider.notifier)
                                .setPrimaryLanguage(value);
                            await _savePreferences();
                          }
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Divider(
                          height: 1,
                          thickness: 1,
                          color: glassOutline.withOpacity(0.65),
                        ),
                      ),
                      _GlassDropdownRow(
                        label: localization.secondary_language,
                        value: languageState['secondary']!,
                        mutedText: mutedText,
                        items: _languageOptions,
                        onChanged: (value) async {
                          if (value != null) {
                            await ref
                                .read(languageProvider.notifier)
                                .setSecondaryLanguage(value);
                            await _savePreferences();
                          }
                        },
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.only(top: 18, bottom: 8),
                  child: Text(
                    'Build version: $_appVersion+$_buildNumber',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: bodyMuted,
                    ),
                  ),
                ),

                if (_removeAdsPrice.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _SettingsSectionTitle(
                    text: localization.remove_ad.split(' ').first !=
                            localization.remove_ad
                        ? localization.remove_ad
                        : 'Purchases',
                  ),
                  const SizedBox(height: 10),
                  GlassCard(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                    backgroundColor: glassBase,
                    outlineColor: glassOutline,
                    shadowColor: softShadow,
                    borderRadius: 22,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(
                          height: 48,
                          child: _SoftPrimaryButton(
                            onPressed: (adsDisabled ?? true)
                                ? null
                                : () async {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          localization
                                              .processing_your_request,
                                        ),
                                      ),
                                    );

                                    try {
                                      await ref
                                          .read(purchaseControllerProvider)
                                          .buyRemoveAds();
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              localization
                                                  .ads_removed_successfully,
                                            ),
                                          ),
                                        );
                                      }
                                    } catch (_) {
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              localization.error_removing_ads,
                                            ),
                                          ),
                                        );
                                      }
                                    }
                                  },
                            child: Text(
                              '${localization.remove_ad} ($_removeAdsPrice)',
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          height: 48,
                          child: _SoftPrimaryButton(
                            filled: false,
                            onPressed: () async {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    localization.restoring_your_purchases,
                                  ),
                                ),
                              );

                              try {
                                await ref
                                    .read(purchaseControllerProvider)
                                    .restorePurchases();
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        localization
                                            .purchases_restored_successfully,
                                      ),
                                    ),
                                  );
                                }
                              } catch (_) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        localization
                                            .error_restoring_purchases,
                                      ),
                                    ),
                                  );
                                }
                              }
                            },
                            child: Text(localization.restore_purchase),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SettingsSectionTitle extends StatelessWidget {
  const _SettingsSectionTitle({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    return Text(
      text,
      style: theme.textTheme.titleSmall?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: 0.5,
        color: cs.primary.withOpacity(isDark ? 0.90 : 0.88),
      ),
    );
  }
}

class _GlassDropdownRow extends StatelessWidget {
  const _GlassDropdownRow({
    required this.label,
    required this.value,
    required this.mutedText,
    required this.items,
    required this.onChanged,
  });

  final String label;
  final String value;
  final Color mutedText;
  final List<Map<String, String>> items;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
            color: cs.onSurface.withOpacity(0.78),
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: value,
            isExpanded: true,
            borderRadius: BorderRadius.circular(16),
            dropdownColor: cs.surfaceContainerHigh,
            icon: Icon(
              Icons.keyboard_arrow_down_rounded,
              color: mutedText,
              size: 22,
            ),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: cs.onSurface.withOpacity(0.92),
              fontWeight: FontWeight.w500,
            ),
            items: items
                .map(
                  (language) => DropdownMenuItem<String>(
                    value: language['code'],
                    child: Text(language['name']!),
                  ),
                )
                .toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}

/// Matches upload screen primary / soft affordances; optional outline style for secondary.
class _SoftPrimaryButton extends StatelessWidget {
  const _SoftPrimaryButton({
    required this.onPressed,
    required this.child,
    this.filled = true,
  });

  final VoidCallback? onPressed;
  final Widget child;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final enabled = onPressed != null;
    final outline = cs.outlineVariant.withOpacity(isDark ? 0.22 : 0.18);

    if (filled) {
      final bgEnabled = cs.primary.withOpacity(isDark ? 0.92 : 0.94);
      final fgEnabled = cs.onPrimary;

      return AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: enabled ? bgEnabled : cs.primary.withOpacity(isDark ? 0.22 : 0.18),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: enabled ? Colors.transparent : outline,
          ),
          boxShadow: [
            if (enabled)
              BoxShadow(
                color: theme.shadowColor.withOpacity(isDark ? 0.18 : 0.12),
                blurRadius: 16,
                offset: const Offset(0, 10),
              ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(16),
            child: Center(
              child: DefaultTextStyle.merge(
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: enabled
                      ? fgEnabled
                      : cs.onSurface.withOpacity(isDark ? 0.45 : 0.42),
                  letterSpacing: 0.2,
                ),
                child: child,
              ),
            ),
          ),
        ),
      );
    }

    final bg = cs.surface.withOpacity(isDark ? 0.45 : 0.72);

    return Material(
      color: bg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: outline),
      ),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(16),
        child: Center(
          child: DefaultTextStyle.merge(
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: cs.primary.withOpacity(enabled ? 1.0 : 0.45),
              letterSpacing: 0.2,
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
