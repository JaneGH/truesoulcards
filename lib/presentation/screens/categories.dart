import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:truesoulcards/presentation/screens/question_swiper.dart';
import 'package:truesoulcards/presentation/screens/questions.dart';
import 'package:truesoulcards/presentation/widgets/category_grid_item.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:truesoulcards/presentation/providers/categories_provider.dart';
import 'package:truesoulcards/data/models/category.dart';
import 'package:truesoulcards/presentation/providers/selected_categories_provider.dart';
import 'package:truesoulcards/presentation/widgets/shared/banner_ad_widget.dart';
import 'package:truesoulcards/theme/app_colors.dart';

enum ScreenModeCategories { edit, play }

class CategoriesScreen extends ConsumerStatefulWidget {
  final ScreenModeCategories mode;

  const CategoriesScreen({super.key, required this.mode});

  @override
  ConsumerState<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends ConsumerState<CategoriesScreen> {

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  ScreenModeCategories get mode => widget.mode;

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
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localization = AppLocalizations.of(context)!;

    final isEdit = mode == ScreenModeCategories.edit;
    final categoriesAsync = isEdit ? ref.watch(userCategoriesProvider) : ref.watch(categoriesProvider);
    final selectedCategories = ref.watch(selectedCategoriesProvider).value ?? {};
    final selectedAdultIds = selectedCategories['adults'] ?? {};
    final selectedKidsIds = selectedCategories['kids'] ?? {};
    var appBarText = isEdit ? localization.pick_to_edit : "";

    return DefaultTabController(
      length: 2,
      child: Builder(
        builder: (context) {
          final tabController = DefaultTabController.of(context);
          return Scaffold(
            appBar: appBarText.isNotEmpty
                ? AppBar(
              title: Text(appBarText),
              bottom: TabBar(
                tabs: [
                  Tab(text: localization.adults),
                  Tab(text: localization.kids),
                ],
                labelStyle: theme.textTheme.titleMedium,
                labelColor: theme.colorScheme.primary,
                indicator: UnderlineTabIndicator(
                  borderSide: BorderSide(color: theme.colorScheme.primary),
                ),
                splashFactory: NoSplash.splashFactory,
                overlayColor: WidgetStateProperty.all(Colors.transparent),
              ),
              backgroundColor: theme.appBarTheme.backgroundColor,
              foregroundColor: theme.appBarTheme.foregroundColor,
            )
                : PreferredSize(
              preferredSize: const Size.fromHeight(kToolbarHeight),
              child: Container(
                color: theme.appBarTheme.backgroundColor,
                child: SafeArea(
                  bottom: false,
                  child: TabBar(
                    tabs: [
                      Tab(text: localization.adults),
                      Tab(text: localization.kids),
                    ],
                    labelStyle: theme.textTheme.titleMedium,
                    labelColor: theme.colorScheme.primary,
                    indicator: UnderlineTabIndicator(
                      borderSide: BorderSide(color: theme.colorScheme.primary),
                    ),
                    splashFactory: NoSplash.splashFactory,
                    overlayColor: WidgetStateProperty.all(Colors.transparent),
                  ),
                ),
              ),
            ),
            body: Column(
              children: [
                Expanded(
                  child: categoriesAsync.when(
                    data: (availableCategories) {
                      final adultCategories = availableCategories.where((c) => c.subcategory.toLowerCase() == 'adults').toList();
                      final kidsCategories = availableCategories.where((c) => c.subcategory.toLowerCase() == 'kids').toList();

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
                const BannerAdWidget(),
              ],
            ),
            floatingActionButton: AnimatedBuilder(
              animation: tabController.animation!,
              builder: (context, child) {
                final currentIndex = tabController.index;

                return categoriesAsync.when(
                  data: (availableCategories) {
                    final adultCategories = availableCategories.where((c) => c.subcategory.toLowerCase() == 'adults').toList();
                    final kidsCategories = availableCategories.where((c) => c.subcategory.toLowerCase() == 'kids').toList();

                    final List<Category> categoriesToStartGame = isEdit
                        ? []
                        : currentIndex == 0
                        ? selectedAdultIds
                        .where((id) => adultCategories.any((c) => c.id == id))
                        .map((id) => adultCategories.firstWhere((c) => c.id == id))
                        .toList()
                        : selectedKidsIds
                        .where((id) => kidsCategories.any((c) => c.id == id))
                        .map((id) => kidsCategories.firstWhere((c) => c.id == id))
                        .toList();

                    return Visibility(
                      visible: !isEdit,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: 70.0,
                        height: 70.0,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: currentIndex == 0
                                ? const [AppColors.lightBeige, AppColors.darkBeige]
                                : const [AppColors.lightBlue, AppColors.darkBlue],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha((0.2 * 255).round()),
                              blurRadius: 12.0,
                              offset: const Offset(4, 4),
                            ),
                          ],
                        ),
                        child: FloatingActionButton(
                          onPressed: () => _startGame(context, categoriesToStartGame),
                          backgroundColor: Colors.transparent,
                          elevation: 0,
                          child: const Icon(
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
