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
import 'package:truesoulcards/presentation/widgets/glass_card.dart';
import 'package:truesoulcards/theme/app_icons.dart';

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

    final Map<String, String> translations;
    if (primaryLang == secondaryLang) {
      translations = {primaryLang: primaryQuestion};
    } else {
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

  InputDecoration _fieldDecoration({
    required ColorScheme colorScheme,
    required VoidCallback onMic,
    required bool micActive,
  }) {
    final isDarkField = colorScheme.brightness == Brightness.dark;
    final mutedIcon = colorScheme.onSurface.withOpacity(isDarkField ? 0.72 : 0.68);

    return InputDecoration(
      isCollapsed: false,
      border: InputBorder.none,
      enabledBorder: InputBorder.none,
      focusedBorder: InputBorder.none,
      errorBorder: InputBorder.none,
      focusedErrorBorder: InputBorder.none,
      disabledBorder: InputBorder.none,
      filled: false,
      suffixIcon: IconButton(
        onPressed: onMic,
        icon: Icon(
          AppIcons.mic,
          size: AppIconSizes.md,
          color: micActive ? colorScheme.error : mutedIcon,
        ),
      ),
      contentPadding: const EdgeInsets.fromLTRB(16, 14, 6, 14),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final languageState = ref.read(languageProvider);
    final localization = AppLocalizations.of(context)!;

    final isDark = theme.brightness == Brightness.dark;
    final backgroundBase = colorScheme.surface;
    final backgroundTint = Color.alphaBlend(
      colorScheme.primary.withOpacity(isDark ? 0.10 : 0.06),
      backgroundBase,
    );

    final glassBase = colorScheme.surface.withOpacity(isDark ? 0.72 : 0.86);
    final glassOutline = colorScheme.outlineVariant.withOpacity(isDark ? 0.22 : 0.18);
    final mutedText = colorScheme.onSurface.withOpacity(isDark ? 0.72 : 0.68);
    final softShadow = theme.shadowColor.withOpacity(isDark ? 0.18 : 0.10);

    final titleText =
        widget.question != null ? 'Edit Question' : localization.new_question;

    return Scaffold(
      backgroundColor: backgroundBase,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(titleText),
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        foregroundColor: colorScheme.onSurface,
      ),
      body: DecoratedBox(
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
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 24),
            children: [
              Text(
                '${localization.primary_language} (${languageState['primary']})',
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                  color: mutedText,
                ),
              ),
              const SizedBox(height: 8),
              GlassCard(
                padding: EdgeInsets.zero,
                backgroundColor: glassBase,
                outlineColor: glassOutline,
                shadowColor: softShadow,
                borderRadius: 20,
                blurSigma: 10,
                child: TextField(
                  controller: _primaryController,
                  maxLines: 3,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w500,
                    height: 1.35,
                  ),
                  cursorColor: colorScheme.primary,
                  decoration: _fieldDecoration(
                    colorScheme: colorScheme,
                    onMic: () => startListening(
                      'primary',
                      languageState['primary'] as String,
                    ),
                    micActive: _isListening && _activeField == 'primary',
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '${localization.secondary_language} (${languageState['secondary']})',
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                  color: mutedText,
                ),
              ),
              const SizedBox(height: 8),
              GlassCard(
                padding: EdgeInsets.zero,
                backgroundColor: glassBase,
                outlineColor: glassOutline,
                shadowColor: softShadow,
                borderRadius: 20,
                blurSigma: 10,
                child: TextField(
                  controller: _secondaryController,
                  maxLines: 3,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w500,
                    height: 1.35,
                  ),
                  cursorColor: colorScheme.primary,
                  decoration: _fieldDecoration(
                    colorScheme: colorScheme,
                    onMic: () => startListening(
                      'secondary',
                      languageState['secondary'] as String,
                    ),
                    micActive: _isListening && _activeField == 'secondary',
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _SoftSecondaryActionButton(
                      onPressed: () => Navigator.pop(context),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(AppIcons.close, size: AppIconSizes.sm),
                          const SizedBox(width: 8),
                          Text(localization.cancel),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _SoftPrimaryActionButton(
                      onPressed: _submitForm,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(AppIcons.send, size: AppIconSizes.sm),
                          const SizedBox(width: 8),
                          Text(localization.submit),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
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

class _SoftPrimaryActionButton extends StatelessWidget {
  const _SoftPrimaryActionButton({
    required this.onPressed,
    required this.child,
  });

  final VoidCallback? onPressed;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final enabled = onPressed != null;
    final bgEnabled = cs.primary.withOpacity(isDark ? 0.92 : 0.94);
    final bgDisabled = cs.primary.withOpacity(isDark ? 0.20 : 0.16);
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
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
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
      ),
    );
  }
}

class _SoftSecondaryActionButton extends StatelessWidget {
  const _SoftSecondaryActionButton({
    required this.onPressed,
    required this.child,
  });

  final VoidCallback? onPressed;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final enabled = onPressed != null;
    final bg = cs.surface.withOpacity(isDark ? 0.55 : 0.78);
    final outline = cs.outlineVariant.withOpacity(isDark ? 0.22 : 0.18);
    final fg = cs.onSurface.withOpacity(isDark ? 0.88 : 0.86);
    final fgDisabled = cs.onSurface.withOpacity(isDark ? 0.45 : 0.42);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: outline),
        boxShadow: [
          if (enabled)
            BoxShadow(
              color: theme.shadowColor.withOpacity(isDark ? 0.14 : 0.08),
              blurRadius: 14,
              offset: const Offset(0, 8),
            ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Center(
              child: DefaultTextStyle.merge(
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: enabled ? fg : fgDisabled,
                  letterSpacing: 0.2,
                ),
                child: IconTheme(
                  data: IconThemeData(color: enabled ? fg : fgDisabled),
                  child: child,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
