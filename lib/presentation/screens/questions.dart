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

class QuestionsScreen extends ConsumerWidget {
  final Category? category;

  const QuestionsScreen({
    super.key,
    required this.category,
  });

  void selectQuestion(BuildContext context, Question question, int color) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => QuestionDetailsScreen(
          question: question,
          color: color,
          // onToggleFavorite: {},
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final languages = ref.watch(languageProvider);
    final questionsAsync = (() {
      if (category != null) {
        return ref.watch(questionsProviderByCategory(category!.id));
      } else {
        return ref.watch(questionsProvider);
      }
    })();

    return Scaffold(
      appBar: AppBar(
        title: Text(category?.getTitle(languages['primary']!) ?? 'All Questions'),
      ),
      body: questionsAsync.when(
        data: (questions) {
          if (questions.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.sentiment_dissatisfied_outlined,
                    size: 80,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    "Oops! Nothing here yet.",
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Try to choose different category!',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: questions.length,
            itemBuilder: (ctx, index) => QuestionItem(
              question: questions[index],
              onSelectQuestion: (question) {
                selectQuestion(context, question, questions[index].color);
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Text(
            'Something went wrong!\n$err',
            style: TextStyle(color: Theme.of(context).colorScheme.error),
            textAlign: TextAlign.center,
          ),
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => NewQuestion()),
          );
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Question added!')),
          );
        },
        tooltip: 'Create New Question',
        child: const Icon(Icons.add),
      ),

    );
  }
}
