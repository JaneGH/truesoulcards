import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:truesoulcards/presentation/screens/question_swiper.dart';
import 'package:truesoulcards/presentation/screens/questions.dart';
import 'package:truesoulcards/presentation/widgets/category_grid_item.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:truesoulcards/presentation/providers/categories_provider.dart';
import 'package:truesoulcards/data/models/category.dart';
import 'package:truesoulcards/presentation/providers/selected_categories_provider.dart';

enum ScreenModeCategories { edit, play }

class CategoriesScreen extends ConsumerWidget {
  final ScreenModeCategories mode;

  const CategoriesScreen({super.key, required this.mode});

  void _startGame(BuildContext context, List<Category> categories) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuestionSwiperScreen(categories: categories),
      ),
    );
  }

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
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => QuestionSwiperScreen(categories: [category]),
        ),
      );
      // }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<Category>> categoriesAsync;

    final isEdit = mode == ScreenModeCategories.edit;
    if (isEdit) {
      categoriesAsync = ref.watch(userCategoriesProvider);
    } else {
      categoriesAsync = ref.watch(categoriesProvider);
    }
    final selectedCategories =
        ref.watch(selectedCategoriesProvider).value ?? {};
    final selectedAdultIds = selectedCategories['adults'] ?? {};
    final selectedKidsIds = selectedCategories['kids'] ?? {};
    var appBarText = AppLocalizations.of(context)!.pick_category;

    if (isEdit) {
      appBarText = AppLocalizations.of(context)!.pick_to_edit;
    }

    return DefaultTabController(
      length: 2,
      child: Builder(
        builder: (context) {
          final tabController = DefaultTabController.of(context);
          return Scaffold(
            appBar: AppBar(
              title: Text(
                appBarText,
                style: Theme.of(context).appBarTheme.titleTextStyle?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              bottom: TabBar(
                tabs: [
                  Tab(text: AppLocalizations.of(context)!.adults),
                  Tab(text: AppLocalizations.of(context)!.kids),
                ],
                labelStyle: Theme.of(context).textTheme.titleMedium,
                labelColor: Theme.of(context).colorScheme.primary,
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
                final adultCategories =
                    availableCategories
                        .where((c) => c.subcategory.toLowerCase() == 'adults')
                        .toList();

                final kidsCategories =
                    availableCategories
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

            floatingActionButton: AnimatedBuilder(
              animation: tabController.animation!,
              builder: (context, child) {
                final currentIndex = tabController.index;

                return categoriesAsync.when(
                  data: (availableCategories) {
                    final adultCategories =
                        availableCategories
                            .where(
                              (c) => c.subcategory.toLowerCase() == 'adults',
                            )
                            .toList();

                    final kidsCategories =
                        availableCategories
                            .where((c) => c.subcategory.toLowerCase() == 'kids')
                            .toList();

                    final categoriesToStartGame =
                        currentIndex == 0
                            ? selectedAdultIds
                                .map(
                                  (id) => adultCategories.firstWhere(
                                    (category) => category.id == id,
                                  ),
                                )
                                .toList()
                            : selectedKidsIds
                                .map(
                                  (id) => kidsCategories.firstWhere(
                                    (category) => category.id == id,
                                  ),
                                )
                                .toList();

                    return Visibility(
                      visible: !isEdit,
                      child: AnimatedContainer(
                        duration: Duration(milliseconds: 300),
                        width: 70.0,
                        height: 70.0,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors:
                                currentIndex == 0
                                    ? [Color(0xFFF1D0A2), Color(0xFFDA9B7F)]
                                    : [Color(0xFFA2DFF1), Color(0xFF7FBCDA)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(
                                (0.2 * 255).round(),
                              ),
                              blurRadius: 12.0,
                              offset: Offset(4, 4),
                            ),
                          ],
                        ),
                        child: FloatingActionButton(
                          onPressed:
                              () => _startGame(context, categoriesToStartGame),
                          backgroundColor: Colors.transparent,
                          elevation: 0,
                          child: Icon(
                            Icons.play_arrow,
                            size: 40,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    );
                  },
                  loading: () => const CircularProgressIndicator(),
                  error: (err, _) => const SizedBox.shrink(),
                );
              },
            ),
          );
        },
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
