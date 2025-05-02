import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart';
import 'package:truesoulcards/models/category.dart';
import 'package:truesoulcards/screens/qiestion_details.dart';
import 'package:truesoulcards/screens/question_swiper.dart';
import 'package:truesoulcards/screens/questions.dart';
import 'package:truesoulcards/widgets/category_grid_item.dart';
import '../providers/category_provider.dart';
import '../providers/questions_provider.dart';
import 'new_question.dart';

enum ScreenMode { edit, play }

class CategoriesScreen extends ConsumerWidget {
  final ScreenMode mode;

  const CategoriesScreen({super.key, required this.mode});

  Future<void> _selectCategory(BuildContext context,  Category category, bool isEdit, WidgetRef ref,) async {
    if (isEdit) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (ctx) =>
              QuestionsScreen(
                  title: category.title),
        ),
      );
    }else{
      // final question = await ref.read(firstQuestionInCategoryProvider(category.id).future);
      // if (question != null && context.mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => QuestionSwiperScreen(category: category),
          ),
        );
      // }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesProvider);
    final isEdit = mode == ScreenMode.edit;
    var appBarText ="Pick your category";
    if (isEdit) {
      appBarText = "Pick to edit";
    }
    return Scaffold(
      appBar: AppBar(title: Text(appBarText)),
      body: categoriesAsync.when(
        data: (availableCategories) {
          final adultCategories = availableCategories.where((category) => category.subcategory == 'adults').toList();
          final kidsCategories = availableCategories.where((category) => category.subcategory == 'kids').toList();

          return TabBarView(
            children: [
              _buildCategoryGrid(adultCategories, isEdit, ref),
              _buildCategoryGrid(kidsCategories, isEdit, ref),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildCategoryGrid(List<Category> categories, bool isEdit, WidgetRef ref) {
    return GridView(
      padding: const EdgeInsets.all(20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 3 / 2,
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
      ),
      children: [
        for (final category in categories)
          CategoryGridItem(
            category: category,
            onSelectCategory: () {
              _selectCategory(ref.context, category, isEdit, ref);
            },
          ),
      ],
    );
  }

}

