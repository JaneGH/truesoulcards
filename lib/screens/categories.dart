import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:truesoulcards/data/questions_data.dart';
import 'package:truesoulcards/models/category.dart';
import 'package:truesoulcards/screens/questions.dart';

import '../data/category_data.dart';
import '../models/question.dart';
import '../providers/questions_provider.dart';
import '../widgets/category_grid_item.dart';
import 'new_question.dart';

class CategoriesScreen extends ConsumerWidget {
  const CategoriesScreen({super.key});

  void _selectCategory(BuildContext context,  Category category, WidgetRef ref,) {
    final currentQuestions = ref
        .read(questionProvider)
        .where((question) => question.categories.contains(category.id))
        .toList();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (ctx) => QuestionsScreen(
            title: category.title,
            questions: currentQuestions),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text("Pick your category")),
      body: GridView(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 3 / 2,
          crossAxisSpacing: 20,
          mainAxisSpacing: 20,
        ),
        children: [
          // for (final category in availableCategories)
          //   CategoryGridItem(
          //     category: category,
          //     onSelectCategory: () {
          //        _selectCategory(context, category, ref);
          //     },
          //   ),
          for (final category in userCategories)
            CategoryGridItem(
              category: category,
              onSelectCategory: () {
                _selectCategory(context, category, ref);
              },
            ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // var question = Question(
          //   id: 'q1',
          //   text: 'Hi',
          //   categories: ['c1'],
          // );

          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => NewQuestion()),
          );

          // ref.read(questionProvider.notifier).addQuestions(question);

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Question added!')),
          );

          // Navigator.push(
          //   context,
          //   MaterialPageRoute(builder: (ctx) => QuestionsScreen(...)),
          // );
        },
        tooltip: 'Create New Question',
        child: const Icon(Icons.add),
      ),

    );
  }
}
