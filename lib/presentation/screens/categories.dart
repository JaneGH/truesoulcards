import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:truesoulcards/presentation/screens/question_swiper.dart';
import 'package:truesoulcards/presentation/screens/questions.dart';
import 'package:truesoulcards/presentation/widgets/category_grid_item.dart';
import 'package:truesoulcards/l10n/app_localizations.dart';
import 'package:truesoulcards/core/services/analytics_service.dart';
import 'package:truesoulcards/presentation/providers/analytics_provider.dart';
import 'package:truesoulcards/presentation/providers/categories_provider.dart';
import 'package:truesoulcards/presentation/providers/language_provider.dart';
import 'package:truesoulcards/data/models/category.dart';
import 'package:truesoulcards/presentation/providers/selected_categories_provider.dart';
import 'package:truesoulcards/presentation/widgets/shared/banner_ad_widget.dart';
import 'package:truesoulcards/theme/app_icons.dart';
import 'package:truesoulcards/theme/app_colors.dart';
import 'dart:ui';

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final screenName = widget.mode == ScreenModeCategories.edit
          ? AnalyticsScreens.categoryEdit
          : AnalyticsScreens.category;
      ref.read(analyticsServiceProvider).logManualScreenView(
            screenName: screenName,
            screenClass: 'CategoriesScreen',
          );
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  ScreenModeCategories get mode => widget.mode;

  void _startGame(BuildContext context, List<Category> categories) {
    if (categories.isEmpty) {
      ref.read(analyticsServiceProvider).logEvent(
        name: 'start_game_failed_no_category',
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.choose_at_least_one_category_to_start_game,
          ),
        ),
      );
      return;
    }
    final lang = ref.read(languageProvider)['primary'] ?? 'en';
    final analytics = ref.read(analyticsServiceProvider);
    if (categories.length == 1) {
      final c = categories.first;
      analytics.logCategoryOpened(
        categoryId: c.id,
        categoryName: c.getTitle(lang),
        selectionCount: 1,
      );
    } else {
      analytics.logCategoryOpened(
        categoryId: categories.map((c) => c.id).join(','),
        categoryName: 'multiple',
        selectionCount: categories.length,
      );
    }
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
    final lang = ref.read(languageProvider)['primary'] ?? 'en';
    ref.read(analyticsServiceProvider).logCategoryOpened(
          categoryId: category.id,
          categoryName: category.getTitle(lang),
          selectionCount: 1,
        );
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
    final isDark = theme.brightness == Brightness.dark;
    final cs = theme.colorScheme;
    final localization = AppLocalizations.of(context)!;
    final isEdit = mode == ScreenModeCategories.edit;
    final categoriesAsync = isEdit ? ref.watch(userCategoriesProvider) : ref.watch(categoriesProvider);
    final selectedCategories = ref.watch(selectedCategoriesProvider).value ?? {};
    final selectedAdultIds = selectedCategories['adults'] ?? {};
    final selectedKidsIds = selectedCategories['kids'] ?? {};
    var appBarText = isEdit ? localization.pick_to_edit : "";

    final appBarSurface = cs.surface.withAlpha((0.86 * 255).round());
    final tabLabel = theme.textTheme.titleMedium?.copyWith(
      fontWeight: FontWeight.w500,
      letterSpacing: 0.1,
    );

    return DefaultTabController(
      length: 2,
      child: Builder(
        builder: (context) {
          final tabController = DefaultTabController.of(context);
          return Scaffold(
            appBar: appBarText.isNotEmpty
                ? AppBar(
                    elevation: 0,
                    scrolledUnderElevation: 0,
                    backgroundColor: Colors.transparent,
                    foregroundColor: theme.appBarTheme.foregroundColor,
                    title: Text(appBarText),
                    flexibleSpace: ClipRect(
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                        child: Container(
                          decoration: BoxDecoration(
                            color: appBarSurface,
                            border: Border(
                              bottom: BorderSide(
                                color: cs.outlineVariant.withAlpha((0.35 * 255).round()),
                                width: 1,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    bottom: TabBar(
                      tabs: [
                        Tab(text: localization.adults),
                        Tab(text: localization.kids),
                      ],
                      labelStyle: tabLabel,
                      unselectedLabelStyle: tabLabel,
                      labelColor: cs.primary.withAlpha((0.90 * 255).round()),
                      unselectedLabelColor: cs.onSurface.withAlpha((0.62 * 255).round()),
                      indicatorSize: TabBarIndicatorSize.label,
                      indicator: UnderlineTabIndicator(
                        borderSide: BorderSide(
                          color: cs.primary.withAlpha((0.55 * 255).round()),
                          width: 2,
                        ),
                      ),
                      labelPadding: const EdgeInsets.symmetric(horizontal: 18),
                      splashFactory: NoSplash.splashFactory,
                      overlayColor: WidgetStateProperty.all(Colors.transparent),
                      dividerColor: Colors.transparent,
                    ),
                  )
                : PreferredSize(
              preferredSize: const Size.fromHeight(kToolbarHeight),
              child: ClipRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                  child: Container(
                    decoration: BoxDecoration(
                      color: appBarSurface,
                      border: Border(
                        bottom: BorderSide(
                          color: cs.outlineVariant.withAlpha((0.35 * 255).round()),
                          width: 1,
                        ),
                      ),
                    ),
                    child: SafeArea(
                      bottom: false,
                      child: TabBar(
                        tabs: [
                          Tab(text: localization.adults),
                          Tab(text: localization.kids),
                        ],
                        labelStyle: tabLabel,
                        unselectedLabelStyle: tabLabel,
                        labelColor: cs.primary.withAlpha((0.90 * 255).round()),
                        unselectedLabelColor: cs.onSurface.withAlpha((0.62 * 255).round()),
                        indicatorSize: TabBarIndicatorSize.label,
                        indicator: UnderlineTabIndicator(
                          borderSide: BorderSide(
                            color: cs.primary.withAlpha((0.55 * 255).round()),
                            width: 2,
                          ),
                        ),
                        labelPadding: const EdgeInsets.symmetric(horizontal: 18),
                        splashFactory: NoSplash.splashFactory,
                        overlayColor: WidgetStateProperty.all(Colors.transparent),
                        dividerColor: Colors.transparent,
                      ),
                    ),
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
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 66.0, right: 16.0),
                          child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: 70.0,
                        height: 70.0,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: currentIndex == 0
                                ? [
                              AppColors.lightBeige.withOpacity(isDark ? 0.7 : 1),
                              AppColors.darkBeige.withOpacity(isDark ? 0.7 : 1),
                            ]
                                : [
                              AppColors.lightBlue.withOpacity(isDark ? 0.7 : 1),
                              AppColors.darkBlue.withOpacity(isDark ? 0.7 : 1),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                          color: Colors.black.withAlpha((0.16 * 255).round()),
                          blurRadius: 18.0,
                          offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                    child: ClipOval(
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    cs.surface.withAlpha((0.10 * 255).round()),
                                    Colors.transparent,
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                            ),
                          ),
                          Center(
                            child: FloatingActionButton(
                              onPressed: () => _startGame(context, categoriesToStartGame),
                              backgroundColor: Colors.transparent,
                              elevation: 0,
                              child:  Icon(
                                Icons.play_arrow,
                                size: 40,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                      ),
                    )
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
      padding: const EdgeInsets.all(24),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 3 / 2,
        crossAxisSpacing: 22,
        mainAxisSpacing: 22,
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
