import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:truesoulcards/data/models/question.dart';
import 'package:truesoulcards/presentation/screens/new_question.dart';
import 'package:truesoulcards/presentation/providers/questions_provider.dart';
import 'package:truesoulcards/data/models/category.dart';
import 'package:truesoulcards/presentation/providers/language_provider.dart';
import 'package:truesoulcards/data/datasources/database_helper.dart';
import 'package:truesoulcards/data/repositories/question_repository.dart';
import 'package:truesoulcards/l10n/app_localizations.dart';
import 'package:truesoulcards/presentation/widgets/shared/confirm_dialog.dart';
import 'package:truesoulcards/presentation/widgets/question_list_card.dart';
import 'package:truesoulcards/theme/app_icons.dart';

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
    final isDark = theme.brightness == Brightness.dark;

    final backgroundBase = colorScheme.surface;
    final backgroundTint = Color.alphaBlend(
      colorScheme.primary.withOpacity(isDark ? 0.10 : 0.06),
      backgroundBase,
    );

    return Scaffold(
      backgroundColor: backgroundBase,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        title: const Text("Questions"),
        actions: [
          TextButton(
            onPressed: () {
              _deleteAllQuestions(context, ref);
            },
            style: TextButton.styleFrom(
              foregroundColor: colorScheme.primary,
              textStyle: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w600,
                letterSpacing: 0.2,
              ),
            ),
            child: Text(localization.deleteAll),
          )
        ],
      ),

      extendBodyBehindAppBar: true,
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
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: questionsAsync.when(
              data: (questions) {
                if (questions.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        localization.nothing_here_yet,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant.withOpacity(isDark ? 0.82 : 0.78),
                          height: 1.35,
                        ),
                      ),
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.only(top: 10, bottom: 110),
                  itemCount: questions.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 14),
                  itemBuilder: (context, index) {
                    final q = questions[index];
                    return QuestionCard(
                      question: q,
                      languageCode: lang,
                      onTap: () async {
                        final didEdit = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => NewQuestion(
                              category: category,
                              question: q,
                            ),
                          ),
                        );

                        if (didEdit == true) {
                          if (category != null) {
                            ref.invalidate(questionsProviderByCategory(category!.id));
                          } else {
                            ref.invalidate(questionsProvider);
                          }
                        }
                      },
                      onDelete: () async {
                        await _confirmDeleteQuestion(context, ref, q);
                      },
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text(err.toString())),
            ),
          ),
        ),
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
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
            if (category != null) {
              ref.invalidate(questionsProviderByCategory(category!.id));
            } else {
              ref.invalidate(questionsProvider);
            }
          }
        },
        elevation: isDark ? 2 : 1.5,
        highlightElevation: isDark ? 4 : 3,
        backgroundColor: colorScheme.primaryContainer.withOpacity(isDark ? 0.85 : 0.92),
        foregroundColor: colorScheme.onPrimaryContainer,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: BorderSide(
            color: colorScheme.outlineVariant.withOpacity(isDark ? 0.24 : 0.18),
          ),
        ),
        child: Icon(AppIcons.add, size: AppIconSizes.lg),
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