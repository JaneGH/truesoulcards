import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:truesoulcards/models/question.dart';
import 'package:truesoulcards/screens/new_question.dart';
import 'package:truesoulcards/screens/qiestion_details.dart';
import 'package:truesoulcards/widgets/question_item.dart';
import 'package:truesoulcards/providers/questions_provider.dart';

class QuestionsScreen extends ConsumerWidget {
  final String title;

  const QuestionsScreen({
    super.key,
    required this.title,
  });

  void selectQuestion(BuildContext context, Question question) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => QuestionDetailsScreen(
          question: question,
          // onToggleFavorite: {},
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final questionsAsync = ref.watch(questionsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: questionsAsync.when(
        data: (questions) {
          if (questions.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Uh oh ... nothing here!',
                    style: Theme.of(context).textTheme.headlineLarge!.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Try selecting a different category!',
                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
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
                selectQuestion(context, question);
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
