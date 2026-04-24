import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:truesoulcards/data/models/category.dart';
import 'package:truesoulcards/data/models/question.dart';
import 'package:truesoulcards/l10n/app_localizations.dart';
import 'package:truesoulcards/data/datasources/database_helper.dart';
import 'package:truesoulcards/data/repositories/question_repository.dart';
import 'package:truesoulcards/presentation/providers/language_provider.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class NewQuestion extends ConsumerStatefulWidget {
  final Category? category;
  final Question? question;

  const NewQuestion({super.key, this.category, this.question});

  @override
  ConsumerState<NewQuestion> createState() => _NewQuestionState();
}

class _NewQuestionState extends ConsumerState<NewQuestion> {
  final QuestionRepository _repository = QuestionRepository(
    DatabaseHelper.instance,
  );
  final TextEditingController _primaryController = TextEditingController();
  final TextEditingController _secondaryController = TextEditingController();

  late final SpeechToText _speech;
  bool _isListening = false;
  String? _activeField; // 'primary' | 'secondary'
  bool _speechAvailable = false;

  String getSpeechLocale(String langCode) {
    switch (langCode) {
      case 'en':
        return 'en_US';
      case 'de':
        return 'de_DE';
      case 'es':
        return 'es_ES';
      case 'fr':
        return 'fr_FR';
      case 'it':
        return 'it_IT';
      case 'pl':
        return 'pl_PL';
      case 'pt':
        return 'pt_PT';
      case 'uk':
        return 'uk_UA';
      default:
        return 'en_US';
    }
  }

  Future<String?> _resolveSupportedLocaleId(String langCode) async {
    final desired = getSpeechLocale(langCode);

    try {
      final locales = await _speech.locales();

      final supported = locales.any((l) => l.localeId == desired);
      if (supported) return desired;
    } catch (_) {}

    return null;
  }

  @override
  void initState() {
    super.initState();

    final existingQuestion = widget.question;
    if (existingQuestion != null) {
      final languageState = ref.read(languageProvider);
      final primaryLang = languageState['primary']!;
      final secondaryLang = languageState['secondary']!;

      _primaryController.text = existingQuestion.translations[primaryLang] ?? '';
      _secondaryController.text = existingQuestion.translations[secondaryLang] ?? '';
    }

    _speech = SpeechToText();
    _speech
        .initialize(
          onStatus: (status) {
            if (!mounted) return;
            if (status == 'notListening' || status == 'done') {
              if (_isListening) {
                setState(() {
                  _isListening = false;
                  _activeField = null;
                });
              }
            }
          },
          onError: (_) {
            if (!mounted) return;
            if (_isListening) {
              setState(() {
                _isListening = false;
                _activeField = null;
              });
            }
          },
        )
        .then((available) {
          if (!mounted) return;
          setState(() {
            _speechAvailable = available;
          });
        });
  }

  Future<void> startListening(String field, String lang) async {
    if (_isListening && _activeField == field) {
      await stopListening();
      return;
    }

    if (_isListening) {
      await stopListening();
    }

    if (!_speechAvailable) {
      final available = await _speech.initialize();
      if (!mounted) return;
      setState(() {
        _speechAvailable = available;
      });
    }

    if (!_speechAvailable) return;

    final localeId = await _resolveSupportedLocaleId(lang);
    final controller = field == 'primary' ? _primaryController : _secondaryController;

    if (localeId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Speech recognition is not supported for this language on this device'),
        ),
      );
      return;
    }

    if (!mounted) return;
    setState(() {
      _activeField = field;
      _isListening = true;
    });
    HapticFeedback.lightImpact();

    await _speech.listen(
      localeId: localeId,
      onResult: (result) {
        final text = result.recognizedWords;
        controller.value = controller.value.copyWith(
          text: text,
          selection: TextSelection.collapsed(offset: text.length),
          composing: TextRange.empty,
        );
      },
    );
  }

  Future<void> stopListening() async {
    if (!_isListening) return;
    try {
      await _speech.stop();
    } catch (_) {
      // Ignore platform stop errors.
    }
    if (!mounted) return;
    setState(() {
      _isListening = false;
      _activeField = null;
    });
    HapticFeedback.lightImpact();
  }

  Future<void> _submitForm() async {
    final editing = widget.question != null;
    final categoryId = widget.category?.id ?? widget.question?.category;
    final languageState = ref.read(languageProvider);
    final primaryLang = languageState['primary']!;
    final secondaryLang = languageState['secondary']!;
    final localization = AppLocalizations.of(context)!;

    final primaryQuestion = _primaryController.text.trim();
    final secondaryQuestion = _secondaryController.text.trim();

    if (primaryQuestion.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            localization.please_fill_in_question_text,
          ),
        ),
      );
      return;
    }

    final  Map<String, String> translations;
    if (primaryLang==secondaryLang) {
      translations =  {primaryLang: primaryQuestion};
    }else {
      translations = {
        primaryLang: primaryQuestion,
        secondaryLang: secondaryQuestion,
      };
    }

    try {
      if (categoryId == null) return;
      if (editing) {
        await _repository.updateQuestion(widget.question!.id, translations);
      } else {
        await saveQuestion(categoryId, translations);
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(localization.question_added)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(localization.failed_to_add_question),
        ),
      );
    }
    Navigator.pop(context, true);
  }

  @override
  void dispose() {
    _speech.stop();
    _primaryController.dispose();
    _secondaryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final languageState = ref.read(languageProvider);
    final localization = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.question != null ? 'Edit Question' : localization.new_question),
        elevation: 0,
        backgroundColor: theme.colorScheme.primary.withAlpha((0.8 * 255).round()),
        foregroundColor: theme.colorScheme.onPrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _primaryController,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                labelText:
                '${localization.primary_language} (${languageState['primary']})',
                suffixIcon: IconButton(
                  onPressed: () => startListening(
                    'primary',
                    languageState['primary'] as String,
                  ),
                  icon: Icon(
                    Icons.mic,
                    color: _isListening && _activeField == 'primary'
                        ? Colors.red
                        : Theme.of(context).iconTheme.color,
                  ),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                labelStyle: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                floatingLabelStyle: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                ),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 20,
                ),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _secondaryController,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                labelText:
                '${localization.secondary_language} (${languageState['secondary']})',
                suffixIcon: IconButton(
                  onPressed: () => startListening(
                    'secondary',
                    languageState['secondary'] as String,
                  ),
                  icon: Icon(
                    Icons.mic,
                    color: _isListening && _activeField == 'secondary'
                        ? Colors.red
                        : Theme.of(context).iconTheme.color,
                  ),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                labelStyle: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                floatingLabelStyle: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                ),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 20,
                ),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 40),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                    label: Text(localization.cancel),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _submitForm,
                    icon: const Icon(Icons.send),
                    label: Text(localization.submit),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> saveQuestion(
    String category,
    Map<String, String> translations,
  ) async {
    await _repository.insertQuestion(category, false, translations);
  }
}
