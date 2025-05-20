import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:truesoulcards/data/models/category.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:truesoulcards/data/datasources/database_helper.dart';
import 'package:truesoulcards/data/repositories/question_repository.dart';

import '../providers/language_provider.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class NewQuestion extends ConsumerStatefulWidget {
  final Category? category;
  const NewQuestion({
    super.key,
    required this.category,
  });


  @override
  ConsumerState<NewQuestion> createState() =>
      _NewQuestionState();
}

class _NewQuestionState  extends ConsumerState<NewQuestion> {
  final QuestionRepository _repository = QuestionRepository(
      DatabaseHelper.instance);
  final TextEditingController _primaryController = TextEditingController();
  final TextEditingController _secondaryController = TextEditingController();

  void _submitForm() {
    final category = widget.category;
    final languageState = ref.read(languageProvider);
    final primaryLang = languageState['primary']!;
    final secondaryLang = languageState['secondary']!;

    final primaryQuestion = _primaryController.text.trim();
    final secondaryQuestion = _secondaryController.text.trim();

    if (primaryQuestion.isEmpty || secondaryQuestion.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Please fill in both questions')));
      return;
    }

    final translations = {
      primaryLang: primaryQuestion,
      secondaryLang: secondaryQuestion,
    };

    saveQuestion(category!.id, translations);
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _primaryController.dispose();
    _secondaryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("New question")),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            TextField(
              controller: _primaryController,
              decoration: InputDecoration(
                labelText: 'Primary Language',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _secondaryController,
              decoration: InputDecoration(
                labelText: 'Secondary Language',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
                ElevatedButton(
                  onPressed: _submitForm,
                  child: const Text('Submit'),
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
      Map<String, String> translations) async {
    await _repository.insertQuestion(category, false, translations);
  }
}
