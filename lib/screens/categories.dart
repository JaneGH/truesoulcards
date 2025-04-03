import 'package:flutter/material.dart';
import 'package:truesoulcards/data/questions_data.dart';
import 'package:truesoulcards/models/category.dart';
import 'package:truesoulcards/screens/questions.dart';

import '../data/category_data.dart';
import '../widgets/category_grid_item.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  void _selectCategory(BuildContext context, Category category) {
    final currentQuestions = availableQuestions.where((question)=>question.categories.contains(category.id)).toList();
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
  Widget build(BuildContext context) {
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
          for (final category in availableCategories)
            CategoryGridItem(
              category: category,
              onSelectCategory: () {
                 _selectCategory(context, category);
              },
            ),
        ],
      ),
    );
  }
}
