import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:truesoulcards/presentation/providers/language_provider.dart';
import 'package:truesoulcards/core/services/settings_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

enum Filter { showMySets }

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen>  createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _settingsService = SettingsService();
  bool _showMySets = false;

  final List<Map<String, String>> _languageOptions = const [
    {'code': 'en', 'name': 'En'},
    {'code': 'uk', 'name': 'Uk'},
  ];

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final settings = await _settingsService.loadSettings();
    setState(() {
      _showMySets = settings['showMySets'];
    });
  }

  Future<void> _savePreferences() async {
    await _settingsService.saveSettings(
      showMySets: _showMySets,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final languageState = ref.watch(languageProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.settings),
      ),
      body: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) return;
          Navigator.of(context).pop({
            Filter.showMySets: _showMySets,
          });
        },
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              AppLocalizations.of(context)!.preferences,
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              title: Text(AppLocalizations.of(context)!.show_my_sets),
              subtitle: Text(AppLocalizations.of(context)!.only_display_sets_you_have_created),
              value: _showMySets,
              onChanged: (value) async {
                setState(() {
                  _showMySets = value;
                });
                await _savePreferences();
              },
            ),
            const Divider(height: 32),
            Text(
              AppLocalizations.of(context)!.languages,
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildDropdown(
              label: AppLocalizations.of(context)!.primary_language,
              value: languageState['primary']!,
              onChanged: (value) async {
                if (value != null) {
                  await ref.read(languageProvider.notifier).setPrimaryLanguage(value);
                  await _savePreferences();
                }
              },
            ),
            const SizedBox(height: 16),
            _buildDropdown(
              label: AppLocalizations.of(context)!.secondary_language,
              value: languageState['secondary']!,
              onChanged: (value) async {
                if (value != null) {
                  await ref.read(languageProvider.notifier).setSecondaryLanguage(value);
                  await _savePreferences();
                }
              },
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
      items: _languageOptions.map((language) {
        return DropdownMenuItem<String>(
          value: language['code'],
          child: Text(language['name']!),
        );
      }).toList(),
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      onChanged: onChanged,
    );
  }
}
