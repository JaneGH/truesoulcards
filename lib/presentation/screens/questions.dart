import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:truesoulcards/data/models/question.dart';
import 'package:truesoulcards/presentation/screens/new_question.dart';
import 'package:truesoulcards/presentation/screens/qiestion_details.dart';
import 'package:truesoulcards/presentation/providers/questions_provider.dart';
import 'package:truesoulcards/data/models/category.dart';
import 'package:truesoulcards/presentation/widgets/question_item.dart';
import 'package:truesoulcards/presentation/providers/language_provider.dart';
import 'package:truesoulcards/data/datasources/database_helper.dart';
import 'package:truesoulcards/data/repositories/question_repository.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../widgets/shared/confirm_dialog.dart';

class QuestionsScreen extends ConsumerWidget {
  final Category? category;
  final QuestionRepository _repository = QuestionRepository(
    DatabaseHelper.instance,
  );

  QuestionsScreen({super.key, required this.category});

  void selectQuestion(BuildContext context, Question question, int color) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (ctx) => QuestionDetailsScreen(question: question, color: color),
      ),
    );
  }

  Future<void> _confirmDeleteQuestion(
    BuildContext context,
    WidgetRef ref,
    Question question, {
    Category? category,
  }) async {
    final localization = AppLocalizations.of(context)!;

    final confirm = await showDeleteConfirmationDialog(
      context: context,
      title: localization.delete_question,
      content: localization.are_you_sure_you_want_to_delete_question,
      confirmText: localization.delete,
      cancelText: localization.cancel,
    );

    if (confirm == true) {
      await _repository.deleteQuestion(question.id);

      if (category != null) {
        ref.invalidate(questionsProviderByCategory(category.id));
      } else {
        ref.invalidate(questionsProvider);
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final languages = ref.watch(languageProvider);
    final localization = AppLocalizations.of(context)!;
    final questionsAsync =
        (() {
          if (category != null) {
            return ref.watch(questionsProviderByCategory(category!.id));
          } else {
            return ref.watch(questionsProvider);
          }
        })();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          category?.getTitle(languages['primary']!) ?? 'All Questions',
        ),
      ),
      body: questionsAsync.when(
        data: (questions) {
          return ListView.builder(
            itemCount: questions.length,
            itemBuilder:
                (ctx, index) => GestureDetector(
                  onLongPress:
                      () => _confirmDeleteQuestion(
                        context,
                        ref,
                        questions[index],
                      ),
                  child: QuestionItem(
                    question: questions[index],
                    onSelectQuestion: (question) {
                      selectQuestion(context, question, question.color);
                    },
                  ),
                ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error:
            (err, stack) => Center(
              child: Text(
                '${localization.something_went_wrong}\n$err',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
                textAlign: TextAlign.center,
              ),
            ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final didAdd = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NewQuestion(category: category),
            ),
          );
          if (didAdd == true && category != null) {
            ref.invalidate(questionsProviderByCategory(category!.id));
          } else {
            ref.invalidate(questionsProvider);
          }
        },
        tooltip: localization.create_question,
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
        child: const Icon(Icons.add),
      ),
    );
  }
}
