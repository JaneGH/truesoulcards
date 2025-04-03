import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:truesoulcards/models/question.dart';
import 'package:truesoulcards/screens/qiestion_details.dart';
import 'package:truesoulcards/widgets/question_item.dart';

class QuestionsScreen extends StatelessWidget {
  final String title;
  final List<Question> questions;

  const QuestionsScreen({
    super.key,
    required this.title,
    required this.questions,
  });

  void selectQuestion(BuildContext context, Question question) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (ctx) => QuestionDetailsScreen(
              question: question,
              // onToggleFavorite: {},
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget content = Center(
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

    if (questions.isNotEmpty) {
      content = ListView.builder(
        itemCount: questions.length,
        itemBuilder:
            (ctx, index) => QuestionItem(
              question: questions[index],
              onSelectQuestion: (question) {
                selectQuestion(context, question);
              },
            ),
      );
    }

    return Scaffold(appBar: AppBar(title: Text(title)), body: content);
  }
}
