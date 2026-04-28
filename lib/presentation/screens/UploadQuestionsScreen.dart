import 'dart:convert';
import 'dart:async';
import 'dart:ui';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:truesoulcards/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dropzone/flutter_dropzone.dart';
import 'package:truesoulcards/data/models/category.dart' as model;
import 'package:truesoulcards/extensions/localization_extension.dart';
import 'package:truesoulcards/presentation/providers/categories_provider.dart';
import 'package:truesoulcards/presentation/providers/questions_provider.dart';
import 'package:truesoulcards/core/services/analytics_service.dart';
import 'package:truesoulcards/presentation/providers/analytics_provider.dart';
import 'package:truesoulcards/presentation/widgets/glass_card.dart';
import 'package:truesoulcards/theme/app_icons.dart';

class UploadQuestionsScreen extends ConsumerStatefulWidget {
  const UploadQuestionsScreen({super.key});

  @override
  ConsumerState<UploadQuestionsScreen> createState() => _UploadQuestionsScreenState();
}

class _UploadQuestionsScreenState extends ConsumerState<UploadQuestionsScreen> {
  String? _selectedCategoryId;
  bool _isImporting = false;
  _UploadEntry? _currentUpload;
  _UploadEntry? _lastUploaded;

  Uint8List? _selectedFileBytes;
  String? _selectedFileName;
  int? _selectedFileSize;

  List<Map<String, String>>? _parsedQuestions;
  final Set<String> _detectedLanguages = <String>{};
  String? _validationError;

  DropzoneViewController? _dropzoneController;

  void _clearSelectedFile() {
    _selectedFileBytes = null;
    _selectedFileName = null;
    _selectedFileSize = null;
    _parsedQuestions = null;
    _detectedLanguages.clear();
    _validationError = null;
  }

  bool _isPromptExpanded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(analyticsServiceProvider).logManualScreenView(
            screenName: AnalyticsScreens.uploadQuestions,
            screenClass: 'UploadQuestionsScreen',
          );
    });
  }

  Future<void> _pickAndParseFile(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    if (_selectedCategoryId == null) {
      setState(() => _validationError = l10n.upload_select_category_first);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.upload_select_category_first)),
      );
      return;
    }
    if (_isImporting) return;

    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['json'],
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;

    final file = result.files.first;
    final bytes = file.bytes;
    if (bytes == null) {
      setState(() => _validationError = l10n.upload_failed_read_file);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.upload_failed_read_file)),
      );
      return;
    }

    await _onFileBytesSelected(
      context,
      bytes: bytes,
      name: file.name,
      size: bytes.length,
    );
  }

  List<Map<String, String>> _parseQuestionsJson(Uint8List bytes, AppLocalizations l10n) {
    final decoded = utf8.decode(bytes);
    final dynamic jsonValue = json.decode(decoded);

    if (jsonValue is! List) {
      throw FormatException(l10n.upload_json_error_root_must_be_array);
    }

    final parsed = <Map<String, String>>[];

    for (final item in jsonValue) {
      if (item is! Map) {
        throw FormatException(l10n.upload_json_error_item_must_be_object);
      }

      final map = Map<String, dynamic>.from(item as Map);
      final translations = <String, String>{};

      for (final entry in map.entries) {
        final key = entry.key.toString().trim();
        if (key.isEmpty) continue;

        final value = entry.value;
        if (value is String) {
          final trimmed = value.trim();
          if (trimmed.isNotEmpty) {
            translations[key] = trimmed;
          }
        }
      }

      // Requirement: each object contains at least one language key.
      if (translations.isEmpty) {
        throw FormatException(l10n.upload_json_error_needs_language_key);
      }

      parsed.add(translations);
    }

    return parsed;
  }

  Future<void> _onFileBytesSelected(
      BuildContext context, {
        required Uint8List bytes,
        required String name,
        required int size,
      }) async {
    final l10n = AppLocalizations.of(context)!;
    setState(() {
      _validationError = null;
      _selectedFileBytes = bytes;
      _selectedFileName = name;
      _selectedFileSize = size;
      _parsedQuestions = null;
      _detectedLanguages.clear();
    });

    try {
      final parsed = _parseQuestionsJson(bytes, l10n);
      final languages = <String>{};
      for (final translations in parsed) {
        languages.addAll(translations.keys);
      }

      if (!mounted) return;
      setState(() {
        _parsedQuestions = parsed;
        _detectedLanguages
          ..clear()
          ..addAll(languages);
      });
    } on FormatException catch (e) {
      if (!mounted) return;
      setState(() {
        _validationError = e.message;
        _selectedFileBytes = null;
        _selectedFileName = null;
        _selectedFileSize = null;
        _parsedQuestions = null;
        _detectedLanguages.clear();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.invalid_json_with_message(e.message))),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _validationError = l10n.upload_failed_parse_json_file;
        _selectedFileBytes = null;
        _selectedFileName = null;
        _selectedFileSize = null;
        _parsedQuestions = null;
        _detectedLanguages.clear();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.invalid_json_with_message(e.toString()))),
      );
    }
  }

  Future<void> _importParsedQuestions(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    if (_selectedCategoryId == null) {
      setState(() => _validationError = l10n.upload_select_category_first);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.upload_select_category_first)),
      );
      return;
    }
    if (_parsedQuestions == null) {
      setState(() => _validationError = l10n.upload_choose_json_first);
      return;
    }
    if (_isImporting) return;

    final categoryId = _selectedCategoryId!;
    final importName = _selectedFileName ?? l10n.default_questions_json_filename;
    final importBytes = _selectedFileSize ?? _selectedFileBytes?.length ?? 0;

    setState(() {
      _isImporting = true;
      _currentUpload = _UploadEntry(
        name: importName,
        bytes: importBytes,
        statusText: l10n.upload_importing,
      );
      _lastUploaded = null;
    });

    try {
      int imported = 0;
      for (final translations in _parsedQuestions!) {
        await ref.read(questionRepositoryProvider).insertQuestion(
          categoryId,
          false, // custom questions should survive remote sync
          translations,
        );
        imported++;
      }

      ref.invalidate(questionsProvider);
      ref.invalidate(questionsProviderByCategory(categoryId));
      ref.read(analyticsServiceProvider).logUploadQuestionsUsed(
            categoryId: categoryId,
            importedCount: imported,
          );

      if (!mounted) return;
      final uploadedLabel = imported == 1
          ? l10n.upload_questions_uploaded_singular
          : l10n.upload_questions_uploaded_plural(imported);
      setState(() {
        _lastUploaded = _UploadEntry(
          name: importName,
          bytes: importBytes,
          statusText: uploadedLabel,
          isSuccess: true,
        );
        _currentUpload = null;
        _clearSelectedFile();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(uploadedLabel)),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _lastUploaded = _UploadEntry(
          name: importName,
          bytes: importBytes,
          statusText: l10n.upload_status_failed,
          isSuccess: false,
        );
        _currentUpload = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.upload_failed_with_error(e.toString()))),
      );
    } finally {
      if (!mounted) return;
      setState(() => _isImporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    final promptFirst = AppLocalizations.of(context)!.ai_prompt_text;

    const jsonExample = '''[
  {
    "en": "What truth about yourself is hardest to admit?",
    "uk": "Яку правду про себе тобі найважче визнати?"
  }
]''';

    final promptText = '''
$promptFirst

$jsonExample

Create file to download.
''';

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final defaultCategoriesAsync = ref.watch(defaultCategoriesProvider);
    final isDark = theme.brightness == Brightness.dark;

    // Glass/surface tuning – kept local so it tracks the active theme.
    final glassBase = colorScheme.surface.withOpacity(isDark ? 0.72 : 0.86);
    final glassOutline = colorScheme.outlineVariant.withOpacity(isDark ? 0.22 : 0.18);
    final mutedText = colorScheme.onSurface.withOpacity(isDark ? 0.72 : 0.68);
    final softShadow = theme.shadowColor.withOpacity(isDark ? 0.18 : 0.10);

    return Scaffold(
    backgroundColor: colorScheme.surface,
    extendBodyBehindAppBar: true,
    appBar: AppBar(
      title: Text(localization.upload_questions),
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
    ),
    body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
          children: [
            // Text(
            //   localization.upload_questions,
            //   style: theme.textTheme.headlineMedium?.copyWith(
            //     fontWeight: FontWeight.w700,
            //     color: theme.colorScheme.onSurface,
            //   ),
            // ),
            // const SizedBox(height: 8),
            Text(
              localization.upload_subtitle_secure_import,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: mutedText,
              ),
            ),
            const SizedBox(height: 18),

            GlassCard(
              padding: const EdgeInsets.fromLTRB(18, 16, 14, 14),
              backgroundColor: glassBase,
              outlineColor: glassOutline,
              shadowColor: softShadow,
              borderRadius: 22,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'AI Prompt',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.2,
                                color: colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              localization.upload_json_format_hint,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: mutedText,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      _SoftIconButton(
                        icon: AppIcons.copy,
                        tooltip: MaterialLocalizations.of(context).copyButtonLabel,
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: promptText));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Copied')),
                          );
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  AnimatedCrossFade(
                    duration: const Duration(milliseconds: 200),
                    crossFadeState: _isPromptExpanded
                        ? CrossFadeState.showSecond
                        : CrossFadeState.showFirst,

                    firstChild: Text(
                      promptText,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        height: 1.35,
                        color: colorScheme.onSurface.withOpacity(isDark ? 0.80 : 0.82),
                      ),
                    ),

                    secondChild: SelectableText(
                      promptText,
                      style: theme.textTheme.bodySmall?.copyWith(
                        height: 1.35,
                        color: colorScheme.onSurface.withOpacity(isDark ? 0.80 : 0.82),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  Align(
                    alignment: Alignment.centerLeft,
                    child: _SoftTextAction(
                      label: _isPromptExpanded ? 'Show less' : 'Show more',
                      onPressed: () {
                        setState(() {
                          _isPromptExpanded = !_isPromptExpanded;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),

            defaultCategoriesAsync.when(
              data: (cats) {
                final categories = cats.toList()
                  ..sort((a, b) => a.getTitle(Localizations.localeOf(context).languageCode).compareTo(
                    b.getTitle(Localizations.localeOf(context).languageCode),
                  ));
                return _CategoryPicker(
                  categories: categories,
                  selectedCategoryId: _selectedCategoryId,
                  onChanged: _isImporting
                      ? null
                      : (id) => setState(() {
                    _selectedCategoryId = id;
                    _validationError = null;
                  }),
                );
              },
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (err, _) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(localization.upload_categories_load_error(err.toString())),
              ),
            ),
            const SizedBox(height: 18),
            GlassCard(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
              backgroundColor: glassBase,
              outlineColor: glassOutline,
              shadowColor: softShadow,
              borderRadius: 24,
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: Stack(
                      children: [
                        if (kIsWeb)
                          Positioned.fill(
                            child: DropzoneView(
                              operation: DragOperation.copy,
                              cursor: CursorType.grab,
                              onCreated: (ctrl) => _dropzoneController = ctrl,
                              onDropFile: (file) {
                                unawaited(() async {
                                  if (!mounted) return;
                                  final l10n = AppLocalizations.of(context)!;
                                  if (_selectedCategoryId == null) {
                                    setState(() => _validationError = l10n.upload_select_category_first);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(l10n.upload_select_category_first)),
                                    );
                                    return;
                                  }
                                  if (_isImporting) return;

                                  final controller = _dropzoneController;
                                  if (controller == null) return;

                                  try {
                                    final filename = await controller.getFilename(file);
                                    if (!filename.toLowerCase().endsWith('.json')) {
                                      setState(() => _validationError = l10n.upload_only_json_files);
                                      return;
                                    }

                                    final bytes = await controller.getFileData(file);
                                    final size = await controller.getFileSize(file);

                                    await _onFileBytesSelected(
                                      context,
                                      bytes: bytes,
                                      name: filename,
                                      size: size,
                                    );
                                  } catch (_) {
                                    if (!mounted) return;
                                    setState(() => _validationError = l10n.upload_failed_read_dropped_file);
                                  }
                                }());
                              },
                              onError: (String? ev) {
                                if (!mounted) return;
                                final l10n = AppLocalizations.of(context)!;
                                setState(() => _validationError =
                                    l10n.drop_error_with_detail(ev ?? l10n.upload_drop_error_unknown));
                              },
                            ),
                          ),
                        _DropzoneSurface(
                          borderRadius: 22,
                          outlineColor: glassOutline,
                          backgroundColor: colorScheme.surfaceContainerHighest.withOpacity(isDark ? 0.28 : 0.40),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _SoftIconBadge(
                                icon: AppIcons.upload,
                                color: colorScheme.primary,
                                backgroundColor: colorScheme.primary.withOpacity(isDark ? 0.12 : 0.10),
                              ),
                              const SizedBox(height: 14),
                              Text(
                                localization.upload_tap_or_drop_files,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.1,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                localization.upload_json_format_hint,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: mutedText,
                                  height: 1.3,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 14),
                              if (_selectedFileName != null) ...[
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: colorScheme.surface.withOpacity(isDark ? 0.55 : 0.78),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(color: glassOutline),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        AppIcons.document,
                                        size: AppIconSizes.sm,
                                        color: colorScheme.onSurface.withOpacity(isDark ? 0.80 : 0.78),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          _selectedFileName!,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: theme.textTheme.bodySmall?.copyWith(
                                            fontWeight: FontWeight.w600,
                                            color: colorScheme.onSurface,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      _SoftIconButton(
                                        icon: AppIcons.close,
                                        tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
                                        onPressed: _isImporting
                                            ? null
                                            : () {
                                                setState(() {
                                                  _clearSelectedFile();
                                                });
                                              },
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 12),
                              ],
                              SizedBox(
                                width: double.infinity,
                                height: 50,
                                child: _PrimaryActionButton(
                                  onPressed: (_isImporting || _selectedCategoryId == null)
                                      ? null
                                      : () => _pickAndParseFile(context),
                                  child: _isImporting
                                      ? Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            SizedBox(
                                              width: 18,
                                              height: 18,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: colorScheme.onPrimary,
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            Text(localization.upload_importing),
                                          ],
                                        )
                                      : Text(localization.browse_json),
                                ),
                              ),
                              if (_validationError != null) ...[
                                const SizedBox(height: 12),
                                _InlineMessage(
                                  text: _validationError!,
                                  tone: _InlineMessageTone.error,
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Builder(builder: (context) {
              if (_parsedQuestions == null) return const SizedBox.shrink();
              final preview = _parsedQuestions!.take(3).toList();

              final languages = _detectedLanguages.toList()..sort();

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SectionTitle(title: localization.upload_preview_title),
                  const SizedBox(height: 10),
                  Text(
                    localization.questions_detected_count(_parsedQuestions!.length),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (languages.isNotEmpty) ...[
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final lang in languages)
                          _SoftChip(
                            label: lang,
                            backgroundColor: colorScheme.surface.withOpacity(isDark ? 0.60 : 0.82),
                            outlineColor: glassOutline,
                            textColor: colorScheme.onSurface.withOpacity(isDark ? 0.90 : 0.88),
                          ),
                      ],
                    ),
                    const SizedBox(height: 14),
                  ],
                  for (int i = 0; i < preview.length; i++) ...[
                    GlassCard(
                      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                      backgroundColor: glassBase,
                      outlineColor: glassOutline,
                      shadowColor: Colors.transparent,
                      borderRadius: 18,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 26,
                            height: 26,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: colorScheme.primary.withOpacity(isDark ? 0.14 : 0.10),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${i + 1}',
                              style: theme.textTheme.labelMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: colorScheme.primary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              localization.questions_preview_item(
                                i + 1,
                                preview[i].entries.take(2).map((e) => '${e.key}: ${e.value}').join(' / '),
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodySmall?.copyWith(
                                height: 1.3,
                                color: colorScheme.onSurface.withOpacity(isDark ? 0.88 : 0.86),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: _PrimaryActionButton(
                      onPressed: (!_isImporting && _selectedCategoryId != null && _parsedQuestions != null)
                          ? () => _importParsedQuestions(context)
                          : null,
                      child: _isImporting
                          ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: colorScheme.onPrimary),
                          ),
                          const SizedBox(width: 10),
                          Text(localization.upload_importing),
                        ],
                      )
                          : Text(localization.upload_questions),
                    ),
                  ),
                  const SizedBox(height: 18),
                ],
              );
            }),
            if (_parsedQuestions == null)
              SizedBox(
                width: double.infinity,
                height: 52,
                child: _PrimaryActionButton(
                  onPressed: null,
                  isSecondaryWhenDisabled: true,
                  child: Text(localization.upload_questions),
                ),
              ),
            const SizedBox(height: 22),
            if (_currentUpload != null) ...[
              _SectionTitle(title: localization.upload_section_import_in_progress),
              const SizedBox(height: 10),
              _UploadTile(entry: _currentUpload!, showProgress: true),
              const SizedBox(height: 22),
            ],
            if (_lastUploaded != null) ...[
              _SectionTitle(title: localization.upload_section_recently_uploaded),
              const SizedBox(height: 10),
              _UploadTile(entry: _lastUploaded!, showProgress: false),
            ],
          ],
        ),
      ),
    );
  }
}

class _CategoryPicker extends StatelessWidget {
  const _CategoryPicker({
    required this.categories,
    required this.selectedCategoryId,
    required this.onChanged,
  });

  final List<model.Category> categories;
  final String? selectedCategoryId;
  final ValueChanged<String?>? onChanged;

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).languageCode;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final glassBase = colorScheme.surface.withOpacity(isDark ? 0.72 : 0.86);
    final glassOutline = colorScheme.outlineVariant.withOpacity(isDark ? 0.22 : 0.18);
    final mutedText = colorScheme.onSurface.withOpacity(isDark ? 0.72 : 0.68);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          localization.pick_category,
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        GlassCard(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
          backgroundColor: glassBase,
          outlineColor: glassOutline,
          shadowColor: Colors.transparent,
          borderRadius: 20,
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selectedCategoryId,
              hint: Text(
                localization.pick_category,
                style: theme.textTheme.bodyMedium?.copyWith(color: mutedText),
              ),
              isExpanded: true,
              onChanged: onChanged,
              icon: Icon(AppIcons.chevronDown, color: mutedText, size: AppIconSizes.md),
              items: categories
                  .map(
                    (c) => DropdownMenuItem(
                      value: c.id,
                      child: Text(
                        localization.category_title_with_subcategory(
                          c.getTitle(locale),
                          c.subcategory.trSub(context),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Text(
          title,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: 0.6,
            color: theme.colorScheme.onSurface.withOpacity(0.62),
          ),
        ),
      ],
    );
  }
}

class _UploadEntry {
  final String name;
  final int bytes;
  final String statusText;
  final bool? isSuccess;

  const _UploadEntry({
    required this.name,
    required this.bytes,
    required this.statusText,
    this.isSuccess,
  });
}

class _UploadTile extends StatelessWidget {
  const _UploadTile({required this.entry, required this.showProgress});

  final _UploadEntry entry;
  final bool showProgress;

  String _formatBytes(BuildContext context, int bytes) {
    final l10n = AppLocalizations.of(context)!;
    final mb = bytes / (1024 * 1024);
    if (mb >= 1) return l10n.file_size_mb(mb.toStringAsFixed(1));
    final kb = bytes / 1024;
    return l10n.file_size_kb(kb.toStringAsFixed(0));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final glassBase = colorScheme.surface.withOpacity(isDark ? 0.72 : 0.86);
    final glassOutline = colorScheme.outlineVariant.withOpacity(isDark ? 0.22 : 0.18);

    final bool? success = entry.isSuccess;
    final Color statusColor = success == null
        ? colorScheme.onSurface.withOpacity(isDark ? 0.72 : 0.68)
        : (success ? colorScheme.tertiary : colorScheme.error);
    final IconData statusIcon = success == null
        ? AppIcons.hourglass
        : (success ? AppIcons.success : AppIcons.error);

    return GlassCard(
      backgroundColor: glassBase,
      outlineColor: glassOutline,
      shadowColor: Colors.transparent,
      borderRadius: 20,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(isDark ? 0.14 : 0.10),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  AppIcons.document,
                  size: AppIconSizes.md,
                  color: statusColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${_formatBytes(context, entry.bytes)} • ${entry.statusText}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        height: 1.25,
                        color: colorScheme.onSurface.withOpacity(isDark ? 0.70 : 0.66),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Icon(statusIcon, color: statusColor, size: AppIconSizes.md),
            ],
          ),
          if (showProgress) ...[
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(100),
              child: LinearProgressIndicator(
                minHeight: 6,
                backgroundColor: colorScheme.onSurface.withOpacity(isDark ? 0.14 : 0.10),
                color: colorScheme.primary.withOpacity(isDark ? 0.65 : 0.78),
              ),
            ),
          ],
        ],
      ),
    );
  }


}

class _SoftIconButton extends StatelessWidget {
  const _SoftIconButton({required this.icon, required this.onPressed, this.tooltip});

  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final bg = cs.surface.withOpacity(isDark ? 0.55 : 0.78);
    final outline = cs.outlineVariant.withOpacity(isDark ? 0.22 : 0.18);

    return Tooltip(
      message: tooltip ?? '',
      child: Material(
        color: bg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: outline),
        ),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Icon(icon, size: AppIconSizes.sm, color: cs.onSurface.withOpacity(isDark ? 0.86 : 0.82)),
          ),
        ),
      ),
    );
  }
}

class _SoftTextAction extends StatelessWidget {
  const _SoftTextAction({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: cs.primary,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
      ),
      child: Text(label),
    );
  }
}

class _PrimaryActionButton extends StatelessWidget {
  const _PrimaryActionButton({
    required this.onPressed,
    required this.child,
    this.isSecondaryWhenDisabled = false,
  });

  final VoidCallback? onPressed;
  final Widget child;
  final bool isSecondaryWhenDisabled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final enabled = onPressed != null;
    final bgEnabled = cs.primary.withOpacity(isDark ? 0.92 : 0.94);
    final bgDisabled = isSecondaryWhenDisabled
        ? cs.surface.withOpacity(isDark ? 0.55 : 0.78)
        : cs.primary.withOpacity(isDark ? 0.20 : 0.16);
    final fgEnabled = cs.onPrimary;
    final fgDisabled = cs.onSurface.withOpacity(isDark ? 0.55 : 0.48);
    final outline = cs.outlineVariant.withOpacity(isDark ? 0.22 : 0.18);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: enabled ? bgEnabled : bgDisabled,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: enabled ? Colors.transparent : outline),
        boxShadow: [
          if (enabled)
            BoxShadow(
              color: theme.shadowColor.withOpacity(isDark ? 0.18 : 0.12),
              blurRadius: 18,
              offset: const Offset(0, 12),
            ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(18),
          child: Center(
            child: DefaultTextStyle.merge(
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: enabled ? fgEnabled : fgDisabled,
                letterSpacing: 0.2,
              ),
              child: IconTheme(
                data: IconThemeData(color: enabled ? fgEnabled : fgDisabled),
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SoftIconBadge extends StatelessWidget {
  const _SoftIconBadge({
    required this.icon,
    required this.color,
    required this.backgroundColor,
  });

  final IconData icon;
  final Color color;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 66,
      height: 66,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Icon(icon, color: color, size: 34),
    );
  }
}

class _SoftChip extends StatelessWidget {
  const _SoftChip({
    required this.label,
    required this.backgroundColor,
    required this.outlineColor,
    required this.textColor,
  });

  final String label;
  final Color backgroundColor;
  final Color outlineColor;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: outlineColor),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelMedium?.copyWith(
          color: textColor,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}

enum _InlineMessageTone { error }

class _InlineMessage extends StatelessWidget {
  const _InlineMessage({required this.text, required this.tone});

  final String text;
  final _InlineMessageTone tone;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final Color accent = switch (tone) { _InlineMessageTone.error => cs.error };
    final Color bg = accent.withOpacity(isDark ? 0.14 : 0.10);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accent.withOpacity(isDark ? 0.22 : 0.18)),
      ),
      child: Row(
        children: [
          Icon(AppIcons.info, size: AppIconSizes.sm, color: accent),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              textAlign: TextAlign.left,
              style: theme.textTheme.bodySmall?.copyWith(
                color: cs.onSurface.withOpacity(isDark ? 0.88 : 0.86),
                fontWeight: FontWeight.w600,
                height: 1.25,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DropzoneSurface extends StatelessWidget {
  const _DropzoneSurface({
    required this.child,
    required this.borderRadius,
    required this.outlineColor,
    required this.backgroundColor,
  });

  final Widget child;
  final double borderRadius;
  final Color outlineColor;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedRoundedRectPainter(
        radius: borderRadius,
        color: outlineColor,
        dashWidth: 8,
        dashGap: 6,
        strokeWidth: 1.2,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
            child: child,
          ),
        ),
      ),
    );
  }
}

class _DashedRoundedRectPainter extends CustomPainter {
  _DashedRoundedRectPainter({
    required this.radius,
    required this.color,
    required this.dashWidth,
    required this.dashGap,
    required this.strokeWidth,
  });

  final double radius;
  final Color color;
  final double dashWidth;
  final double dashGap;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect = RRect.fromRectAndRadius(rect.deflate(strokeWidth / 2), Radius.circular(radius));
    final path = Path()..addRRect(rrect);

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final metrics = path.computeMetrics().toList();
    for (final metric in metrics) {
      double distance = 0;
      while (distance < metric.length) {
        final double end = (distance + dashWidth) > metric.length ? metric.length : (distance + dashWidth);
        final extract = metric.extractPath(distance, end);
        canvas.drawPath(extract, paint);
        distance = end + dashGap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedRoundedRectPainter oldDelegate) {
    return oldDelegate.radius != radius ||
        oldDelegate.color != color ||
        oldDelegate.dashWidth != dashWidth ||
        oldDelegate.dashGap != dashGap ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}

