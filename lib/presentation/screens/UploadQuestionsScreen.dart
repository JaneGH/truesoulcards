import 'dart:convert';
import 'dart:async';

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
import 'package:truesoulcards/theme/app_colors.dart';

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
    final defaultCategoriesAsync = ref.watch(defaultCategoriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(localization.upload_questions),
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
                color: theme.colorScheme.onSurface.withAlpha((0.7 * 255).round()),
              ),
            ),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Theme.of(context).colorScheme.surface,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'AI Prompt',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.copy),
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: promptText));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Copied')),
                          );
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  AnimatedCrossFade(
                    duration: const Duration(milliseconds: 200),
                    crossFadeState: _isPromptExpanded
                        ? CrossFadeState.showSecond
                        : CrossFadeState.showFirst,

                    firstChild: Text(
                      promptText,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12),
                    ),

                    secondChild: SelectableText(
                      promptText,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),

                  const SizedBox(height: 8),

                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _isPromptExpanded = !_isPromptExpanded;
                      });
                    },
                    child: Text(
                      _isPromptExpanded ? 'Show less' : 'Show more',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),
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
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: AppColors.backgroundLightWarmer,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: theme.dividerColor.withAlpha((0.15 * 255).round())),
              ),
              padding: const EdgeInsets.all(18),
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
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 68,
                              height: 68,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(18),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withAlpha((0.06 * 255).round()),
                                    blurRadius: 18,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.cloud_upload_outlined,
                                color: theme.colorScheme.primary,
                                size: 34,
                              ),
                            ),
                            const SizedBox(height: 14),
                            Text(
                              localization.upload_tap_or_drop_files,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              localization.upload_json_format_hint,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurface.withAlpha((0.6 * 255).round()),
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 14),
                            if (_selectedFileName != null) ...[
                              Text(
                                _selectedFileName!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 6),
                            ],
                            SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: ElevatedButton(
                                onPressed: (_isImporting || _selectedCategoryId == null)
                                    ? null
                                    : () => _pickAndParseFile(context),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.mediumBrown,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                ),
                                child: _isImporting
                                    ? Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
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
                              const SizedBox(height: 10),
                              Text(
                                _validationError!,
                                textAlign: TextAlign.center,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: Colors.red[700],
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
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
                    Text(
                      localization.detected_languages_label(languages.join(', ')),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withAlpha((0.7 * 255).round()),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final lang in languages)
                          Chip(
                            label: Text(lang),
                            backgroundColor: theme.colorScheme.surface,
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                  for (int i = 0; i < preview.length; i++) ...[
                    Text(
                      localization.questions_preview_item(
                        i + 1,
                        preview[i].entries.take(2).map((e) => '${e.key}: ${e.value}').join(' / '),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: (!_isImporting && _selectedCategoryId != null && _parsedQuestions != null)
                          ? () => _importParsedQuestions(context)
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.mediumBrown,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: _isImporting
                          ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
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
                child: ElevatedButton(
                  onPressed: null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.surface,
                    foregroundColor: theme.colorScheme.onSurface.withAlpha((0.45 * 255).round()),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          localization.pick_category,
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: theme.dividerColor.withAlpha((0.25 * 255).round())),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selectedCategoryId,
              hint: Text(localization.pick_category),
              isExpanded: true,
              onChanged: onChanged,
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
            color: theme.colorScheme.onSurface.withAlpha((0.65 * 255).round()),
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
    final trailing = entry.isSuccess == null
        ? null
        : (entry.isSuccess == true
        ? Icon(Icons.check_circle, color: Colors.green[600])
        : Icon(Icons.error, color: Colors.red[600]));

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor.withAlpha((0.15 * 255).round())),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.backgroundLightWarmer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.description_outlined, size: 22),
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
                        color: theme.colorScheme.onSurface.withAlpha((0.65 * 255).round()),
                      ),
                    ),
                  ],
                ),
              ),
              if (trailing != null) trailing,
            ],
          ),
          if (showProgress) ...[
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(100),
              child: LinearProgressIndicator(
                minHeight: 6,
                backgroundColor: theme.dividerColor.withAlpha((0.18 * 255).round()),
              ),
            ),
          ],
        ],
      ),
    );
  }


}

