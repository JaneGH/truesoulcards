import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:truesoulcards/data/models/category.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:truesoulcards/data/datasources/database_helper.dart';
import 'package:truesoulcards/data/repositories/question_repository.dart';
import 'package:truesoulcards/presentation/providers/language_provider.dart';
import 'package:truesoulcards/theme/app_colors.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class NewQuestion extends ConsumerStatefulWidget {
  final Category? category;

  const NewQuestion({super.key, required this.category});

  @override
  ConsumerState<NewQuestion> createState() => _NewQuestionState();
}

class _NewQuestionState extends ConsumerState<NewQuestion> {
  final QuestionRepository _repository = QuestionRepository(
    DatabaseHelper.instance,
  );
  final TextEditingController _primaryController = TextEditingController();
  final TextEditingController _secondaryController = TextEditingController();

  Future<void> _submitForm() async {
    final category = widget.category;
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
      await saveQuestion(category!.id, translations);
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
    _primaryController.dispose();
    _secondaryController.dispose();
    super.dispose();
  }

  @override
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final languageState = ref.read(languageProvider);
    final localization = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(localization.new_question),
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
