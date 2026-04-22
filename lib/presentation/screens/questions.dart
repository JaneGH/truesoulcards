import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:truesoulcards/data/models/question.dart';
import 'package:truesoulcards/presentation/screens/new_question.dart';
import 'package:truesoulcards/presentation/screens/qiestion_details.dart';
import 'package:truesoulcards/presentation/providers/questions_provider.dart';
import 'package:truesoulcards/data/models/category.dart';
import 'package:truesoulcards/presentation/providers/language_provider.dart';
import 'package:truesoulcards/data/datasources/database_helper.dart';
import 'package:truesoulcards/data/repositories/question_repository.dart';
import 'package:truesoulcards/l10n/app_localizations.dart';
import 'package:truesoulcards/presentation/widgets/shared/confirm_dialog.dart';
import 'package:truesoulcards/presentation/widgets/question_list_card.dart';

class QuestionsScreen extends ConsumerWidget {
  final Category? category;

  const QuestionsScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final languages = ref.watch(languageProvider);
    final lang = languages['primary'] ?? 'en';
    final localization = AppLocalizations.of(context)!;

    final questionsAsync = category != null
        ? ref.watch(questionsProviderByCategory(category!.id))
        : ref.watch(questionsProvider);

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: theme.appBarTheme.elevation,
        title: const Text("Questions"),
        actions: [
          TextButton(
            onPressed: () {
              _deleteAllQuestions(context, ref);
            },
            style: TextButton.styleFrom(
              foregroundColor: colorScheme.primary,
            ),
            child: Text(localization.deleteAll),
          )
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: questionsAsync.when(
          data: (questions) {
            if (questions.isEmpty) {
              return Center(
                child: Text(
                  localization.nothing_here_yet,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface,
                  ),
                ),
              );
            }

            return ListView(
              children: [
                // const SizedBox(height: 8),
                //
                // Text(
                //   category?.getTitle(languages['primary']!) ??
                //       "Daily Inquiries",
                //   style: theme.textTheme.headlineLarge?.copyWith(
                //     fontWeight: FontWeight.w800,
                //   ),
                // ),

                const SizedBox(height: 20),
                ...questions.map((q) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: QuestionCard(
                      question: q,
                      languageCode: lang,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                QuestionDetailsScreen(question: q, color: q.color),
                          ),
                        );
                      },
                      onDelete: () async {
                        await _confirmDeleteQuestion(context, ref, q);
                      },
                    ),
                  );
                }),

                const SizedBox(height: 80),
              ],
            );
          },
          loading: () =>
          const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(child: Text(err.toString())),
        ),
      ),

      floatingActionButton: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: colorScheme.primary,
          borderRadius: BorderRadius.circular(18),
        ),
        child: IconButton(
          icon: Icon(Icons.add, color: colorScheme.onPrimary, size: 30),
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
              if (category != null) {
                ref.invalidate(questionsProviderByCategory(category!.id));
              } else {
                ref.invalidate(questionsProvider);
              }
            }
          },
        ),
      ),
    );
  }

  Future<void> _deleteAllQuestions(
      BuildContext context,
      WidgetRef ref,
      ) async {
    final localization = AppLocalizations.of(context)!;

    final confirm = await showDeleteConfirmationDialog(
      context: context,
      title: localization.deleteAll,
      content: localization.sureToDeleteAllQuestions,
      confirmText: localization.delete,
      cancelText: localization.cancel,
    );

    if (confirm == true) {
      final repo = QuestionRepository(DatabaseHelper.instance);

      if (category != null) {
        await repo.deleteQuestionsByCategory(category!.id);
        ref.invalidate(questionsProviderByCategory(category!.id));
      } else {
        await repo.deleteAllQuestions();
        ref.invalidate(questionsProvider);
      }
    }
  }

  Future<void> _confirmDeleteQuestion(
      BuildContext context,
      WidgetRef ref,
      Question question,
      ) async {
    final localization = AppLocalizations.of(context)!;

    final confirm = await showDeleteConfirmationDialog(
      context: context,
      title: localization.delete_question,
      content: localization.are_you_sure_you_want_to_delete_question,
      confirmText: localization.delete,
      cancelText: localization.cancel,
    );

    if (confirm == true) {
      final repo = QuestionRepository(DatabaseHelper.instance);
      await repo.deleteQuestion(question.id);

      if (category != null) {
        ref.invalidate(questionsProviderByCategory(category!.id));
      } else {
        ref.invalidate(questionsProvider);
      }
    }
  }
}