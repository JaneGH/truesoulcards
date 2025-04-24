import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:truesoulcards/models/category.dart';
import 'package:truesoulcards/screens/questions.dart';
import 'package:truesoulcards/providers/questions_provider.dart';
import 'package:truesoulcards/providers/category_provider.dart';
import 'package:truesoulcards/widgets/category_grid_item.dart';
import 'new_question.dart';

class CategoriesScreen extends ConsumerWidget {
  const CategoriesScreen({super.key});

  void _selectCategory(BuildContext context,  Category category, WidgetRef ref,) {
    final currentQuestions = ref
        .read(questionProvider)
        .where((question) => question.category == category.id)
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
    final categoriesAsync = ref.watch(categoriesProvider);
    return Scaffold(
      appBar: AppBar(title: const Text("Pick your category")),
      body: categoriesAsync.when(
        data: (availableCategories) => GridView(
          padding: const EdgeInsets.all(20),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 3 / 2,
            crossAxisSpacing: 20,
            mainAxisSpacing: 20,
          ),
          children: [
            for (final category in availableCategories)
              CategoryGridItem(
                category: category,
                onSelectCategory: () {
                  _selectCategory(context, category, ref);
                },
              ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
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

