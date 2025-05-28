import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:truesoulcards/presentation/providers/language_provider.dart';
import 'package:truesoulcards/core/services/settings_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:truesoulcards/presentation/providers/font_provider.dart';
import 'package:truesoulcards/presentation/providers/ad_provider.dart';
import 'package:truesoulcards/presentation/providers/ad_purchase_provider.dart';

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
    Set<String> kIds = {dotenv.env['ADS_PRODUCT_ID'] ?? 'remove_ads'};
    final ProductDetailsResponse response = await InAppPurchase.instance
        .queryProductDetails(kIds);
    if (response.notFoundIDs.isNotEmpty) {
      return null;
    }
    return response.productDetails.first;
  }

  Future<void> _loadPreferences() async {
    final settings = await _settingsService.loadSettings();
    setState(() {
      _showAnimation = settings['showAnimation'];
    });
  }

  Future<void> _savePreferences() async {
    await _settingsService.saveSettings(showAnimation: _showAnimation);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final languageState = ref.watch(languageProvider);
    final fontSize = ref.watch(fontSizeProvider);
    final fontSizeNotifier = ref.read(fontSizeProvider.notifier);
    final localization = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: theme.colorScheme.primary.withAlpha(
          (0.8 * 255).round(),
        ),
        foregroundColor: theme.colorScheme.onPrimary,
        title: Text(localization.settings),
      ),
      body: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) return;
          Navigator.of(context).pop({Filter.showAnimation: _showAnimation});
        },
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              localization.preferences,
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              title: Text(localization.show_animation),
              subtitle: Text(localization.show_animation_when_swiping_cards),
              value: _showAnimation,
              onChanged: (value) async {
                setState(() {
                  _showAnimation = value;
                });
                await _savePreferences();
              },
            ),

            const SizedBox(height: 24),

            Text(
              '${localization.font_size}:  ${fontSize.toStringAsFixed(0)}',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            Slider(
              min: 14,
              max: 40,
              divisions: 26,
              value: fontSize,
              label: fontSize.toStringAsFixed(0),
              onChanged: fontSizeNotifier.setFontSize,
            ),

            const Divider(height: 32),
            Text(
              localization.languages,
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildDropdown(
              label: localization.primary_language,
              value: languageState['primary']!,
              onChanged: (value) async {
                if (value != null) {
                  await ref
                      .read(languageProvider.notifier)
                      .setPrimaryLanguage(value);
                  await _savePreferences();
                }
              },
            ),
            const SizedBox(height: 16),
            _buildDropdown(
              label: localization.secondary_language,
              value: languageState['secondary']!,
              onChanged: (value) async {
                if (value != null) {
                  await ref
                      .read(languageProvider.notifier)
                      .setSecondaryLanguage(value);
                  await _savePreferences();
                }
              },
            ),

            Padding(
              padding: const EdgeInsets.symmetric(vertical: 25),

              child: Text(
                'Build version: $_appVersion+$_buildNumber',
                style: theme.textTheme.bodyLarge?.copyWith(),
              ),
            ),

            ElevatedButton(
              onPressed:
                  ref.watch(adsDisabledProvider)
                      ? null
                      : () async {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(localization.processing_your_request),
                          ),
                        );

                        try {
                          await ref
                              .read(purchaseControllerProvider)
                              .buyRemoveAds();
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  localization.ads_removed_successfully,
                                ),
                              ),
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(localization.error_removing_ads),
                              ),
                            );
                          }
                        }
                      },
              child: Text(localization.remove_ad),
            ),

            ElevatedButton(
              onPressed: () async {
                try {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(localization.restoring_your_purchases),
                    ),
                  );

                  await ref.read(purchaseControllerProvider).restorePurchases();

                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          localization.purchases_restored_successfully,
                        ),
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(localization.error_restoring_purchases),
                      ),
                    );
                  }
                }
              },
              child: Text(localization.restore_purchase),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      items:
          _languageOptions.map((language) {
            return DropdownMenuItem<String>(
              value: language['code'],
              child: Text(language['name']!),
            );
          }).toList(),
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
      onChanged: onChanged,
    );
  }
}
