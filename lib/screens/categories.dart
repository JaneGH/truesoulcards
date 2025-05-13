import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:truesoulcards/models/category.dart';
import 'package:truesoulcards/screens/question_swiper.dart';
import 'package:truesoulcards/screens/questions.dart';
import 'package:truesoulcards/widgets/category_grid_item.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:truesoulcards/providers/category_provider.dart';

enum ScreenMode { edit, play }

class CategoriesScreen extends ConsumerWidget {
  final ScreenMode mode;

  const CategoriesScreen({super.key, required this.mode});

  Future<void> _selectCategory(
    BuildContext context,
    Category category,
    bool isEdit,
    WidgetRef ref,
  ) async {
    if (isEdit) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (ctx) => QuestionsScreen(category: category),
        ),
      );
    } else {
      // final question = await ref.read(firstQuestionInCategoryProvider(category.id).future);
      // if (question != null && context.mounted) {
      List<Category> categories = [];
      categories.add(category);
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => QuestionSwiperScreen(categories: categories),
        ),
      );
      // }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesProvider);
    final isEdit = mode == ScreenMode.edit;
    var appBarText = AppLocalizations.of(context)!.pick_category;
    if (isEdit) {
      appBarText = AppLocalizations.of(context)!.pick_to_edit;
    }
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(appBarText),
          bottom: TabBar(
            tabs: [Tab(text: AppLocalizations.of(context)!.adults), Tab(text: AppLocalizations.of(context)!.kids)],
            labelStyle: Theme.of(context).textTheme.titleMedium,
            labelColor: Theme.of(context).colorScheme.primary,
            // unselectedLabelColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            indicator: UnderlineTabIndicator(
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            splashFactory: NoSplash.splashFactory,
            overlayColor: WidgetStateProperty.all(Colors.transparent),
          ),
        ),
        body: categoriesAsync.when(
          data: (availableCategories) {
            final adultCategories = availableCategories
                .where((c) => c.subcategory.toLowerCase() == 'adults')
                .toList();

            final kidsCategories = availableCategories
                .where((c) => c.subcategory.toLowerCase() == 'kids')
                .toList();

            return TabBarView(
              children: [
                _buildCategoryGrid(adultCategories, isEdit, ref),
                _buildCategoryGrid(kidsCategories, isEdit, ref),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(child: Text('Error: $err')),
        ),
      ),
    );
  }

  Widget _buildCategoryGrid(
    List<Category> categories,
    bool isEdit,
    WidgetRef ref,
  ) {
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
