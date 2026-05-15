import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:truesoulcards/core/services/analytics_service.dart';
import 'package:truesoulcards/data/models/category.dart';
import 'package:truesoulcards/l10n/app_localizations.dart';
import 'package:truesoulcards/presentation/providers/analytics_provider.dart';
import 'package:truesoulcards/presentation/providers/categories_provider.dart';
import 'package:truesoulcards/presentation/providers/category_picker_ui_provider.dart';
import 'package:truesoulcards/presentation/providers/language_provider.dart';
import 'package:truesoulcards/presentation/providers/selected_categories_provider.dart';
import 'package:truesoulcards/presentation/screens/question_swiper.dart';
import 'package:truesoulcards/presentation/screens/questions.dart';
import 'package:truesoulcards/presentation/widgets/premium_category_pick_card.dart';
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
    if (widget.mode == ScreenModeCategories.play) {
      ref.read(categoriesPlayInvokerProvider.notifier).state = null;
    }
    super.dispose();
  }

  ScreenModeCategories get mode => widget.mode;

  String _tabKey(int tabIndex) =>
      tabIndex == 0 ? 'adults' : 'kids';

  static const double _gridChildAspectRatio = 1.0;

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

  Future<void> _togglePlaySelection(
    String type,
    Category category,
    Set<String> selectedIds,
  ) async {
    final wasSelected = selectedIds.contains(category.id);
    await ref.read(selectedCategoriesProvider.notifier).toggleCategory(type, category.id);
    if (!wasSelected) {
      final lang = ref.read(languageProvider)['primary'] ?? 'en';
      ref.read(analyticsServiceProvider).logCategoryOpened(
            categoryId: category.id,
            categoryName: category.getTitle(lang),
            selectionCount: 1,
          );
    }
  }

  List<Category> _categoriesForStart({
    required int tabIndex,
    required List<Category> adultCategories,
    required List<Category> kidsCategories,
    required Set<String> selectedAdultIds,
    required Set<String> selectedKidsIds,
  }) {
    if (tabIndex == 0) {
      return selectedAdultIds
          .where((id) => adultCategories.any((c) => c.id == id))
          .map((id) => adultCategories.firstWhere((c) => c.id == id))
          .toList();
    }
    return selectedKidsIds
        .where((id) => kidsCategories.any((c) => c.id == id))
        .map((id) => kidsCategories.firstWhere((c) => c.id == id))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isEdit = mode == ScreenModeCategories.edit;
    final categoriesAsync =
        isEdit ? ref.watch(userCategoriesProvider) : ref.watch(categoriesProvider);
    final selectedAsync = ref.watch(selectedCategoriesProvider);
    final tabIndex = ref.watch(categoryPickerTabIndexProvider);

    final title = isEdit
        ? l10n.pick_to_edit
        : l10n.pick_category;

    final scaffoldBg = BoxDecoration(
      gradient: LinearGradient(
        colors: [
          AppColors.backgroundLight,
          Color.lerp(
                AppColors.backgroundLight,
                AppColors.backgroundLightWarmer,
                0.45,
              ) ??
              AppColors.backgroundLight,
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ),
    );

    return DecoratedBox(
      decoration: scaffoldBg,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: isEdit
            ? AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(l10n.pick_to_edit),
        )
            : null,
        body: SafeArea(
          bottom: false,
          child: categoriesAsync.when(
            data: (availableCategories) {
              final adultCategories = availableCategories
                  .where((c) => c.subcategory.toLowerCase() == 'adults')
                  .toList();
              final kidsCategories = availableCategories
                  .where((c) => c.subcategory.toLowerCase() == 'kids')
                  .toList();
              final tabCategories =
                  tabIndex == 0 ? adultCategories : kidsCategories;
              final categoriesToStartGame = _categoriesForStart(
                tabIndex: tabIndex,
                adultCategories: adultCategories,
                kidsCategories: kidsCategories,
                selectedAdultIds: selectedAsync.value?['adults'] ?? {},
                selectedKidsIds: selectedAsync.value?['kids'] ?? {},
              );

              if (!isEdit) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (!mounted) return;
                  ref.read(categoriesPlayInvokerProvider.notifier).state =
                      () => _startGame(context, categoriesToStartGame);
                });
              }

              return Column(
                children: [
                  Expanded(
                    child: CustomScrollView(
                      physics: const BouncingScrollPhysics(
                        parent: AlwaysScrollableScrollPhysics(),
                      ),
                      slivers: [
                            SliverToBoxAdapter(
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                                child: _PremiumSegmentedControl(
                                  tabIndex: tabIndex,
                                  onChanged: (i) {
                                    ref
                                        .read(categoryPickerTabIndexProvider.notifier)
                                        .state = i;
                                  },
                                ),
                              ),
                            ),
                            if (!isEdit)
                              SliverToBoxAdapter(
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 6),
                                  child: selectedAsync.when(
                                    data: (selectedMap) {
                                      final type = _tabKey(tabIndex);
                                      final ids = selectedMap[type] ?? {};
                                      final allIds =
                                          tabCategories.map((c) => c.id).toSet();
                                      final isAllSelected = allIds.isNotEmpty &&
                                          ids.length == allIds.length;
                                      return _SelectionActionsRow(
                                        selectedLabel:
                                            l10n.category_picker_selected_count(
                                          ids.length,
                                        ),
                                        onSelectAll: () async {
                                          await ref
                                              .read(selectedCategoriesProvider.notifier)
                                              .setSelectedCategories(type, allIds);
                                        },
                                        onClear: () async {
                                          await ref
                                              .read(selectedCategoriesProvider.notifier)
                                              .setSelectedCategories(type, {});
                                        },
                                        selectAllEnabled: !isAllSelected,
                                        clearEnabled: ids.isNotEmpty,
                                      );
                                    },
                                    loading: () => const SizedBox(height: 44),
                                    error: (_, __) => const SizedBox(height: 44),
                                  ),
                                ),
                              ),
                            SliverPadding(
                              padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                              sliver: selectedAsync.when(
                                data: (selectedMap) {
                                  final type = _tabKey(tabIndex);
                                  final selectedIds = selectedMap[type] ?? {};
                                  return SliverGrid(
                                    gridDelegate:
                                        SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                          mainAxisSpacing: 16,
                                          crossAxisSpacing: 16,
                                      childAspectRatio: _gridChildAspectRatio,
                                    ),
                                    delegate: SliverChildBuilderDelegate(
                                      (context, index) {
                                        final category = tabCategories[index];
                                        final isSelected =
                                            selectedIds.contains(category.id);
                                        final subtitle = tabIndex == 0
                                            ? l10n.category_picker_card_subtitle_adults
                                            : l10n.category_picker_card_subtitle_kids;
                                        return PremiumCategoryPickCard(
                                          category: category,
                                          subtitle: subtitle,
                                          isSelected: isEdit ? false : isSelected,
                                          onTap: () async {
                                            if (isEdit) {
                                              await _selectCategory(
                                                context,
                                                category,
                                                isEdit,
                                                ref,
                                              );
                                            } else {
                                              await _togglePlaySelection(
                                                type,
                                                category,
                                                selectedIds,
                                              );
                                            }
                                          },
                                        );
                                      },
                                      childCount: tabCategories.length,
                                    ),
                                  );
                                },
                                loading: () => const SliverToBoxAdapter(
                                  child: Center(
                                    child: Padding(
                                      padding: EdgeInsets.all(48),
                                      child: CircularProgressIndicator(),
                                    ),
                                  ),
                                ),
                                error: (e, _) => SliverToBoxAdapter(
                                  child: Padding(
                                    padding: const EdgeInsets.all(24),
                                    child: Text('Error: $e'),
                                  ),
                                ),
                              ),
                            ),
                            const SliverToBoxAdapter(child: SizedBox(height: 8)),
                          ],
                        ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 6),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: const BannerAdWidget(),
                    ),
                  ),

                  SizedBox(
                    height: MediaQuery.paddingOf(context).bottom + 6,
                  ),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => Center(child: Text('Error: $err')),
          ),
        ),
      ),
    );
  }
}

class _GlassHeader extends StatelessWidget {
  const _GlassHeader({
    required this.title,
    this.subtitle,
  });

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final frosted = cs.surface.withAlpha(((isDark ? 0.42 : 0.52) * 255).round());

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 320),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            decoration: BoxDecoration(
              color: frosted,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: cs.outlineVariant.withAlpha((0.35 * 255).round()),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha((0.06 * 255).round()),
                  blurRadius: 24,
                  offset: const Offset(0, 14),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.2,
                    color: AppColors.darkBrown,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    subtitle!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.lightBrown,
                      fontWeight: FontWeight.w500,
                      height: 1.35,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PremiumSegmentedControl extends StatelessWidget {
  const _PremiumSegmentedControl({
    required this.tabIndex,
    required this.onChanged,
  });

  final int tabIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final isDark = theme.brightness == Brightness.dark;

    return LayoutBuilder(
      builder: (context, c) {
        final track = c.maxWidth;
        final innerW = track - 8;
        final segmentW = innerW / 2;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOutCubic,
          height: 52,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.88),
            borderRadius: BorderRadius.circular(26),
            border: Border.all(
              color: cs.outlineVariant.withAlpha((0.25 * 255).round()),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha((0.05 * 255).round()),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(26),
            child: Stack(
              alignment: Alignment.center,
              children: [
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 320),
                  curve: Curves.easeOutCubic,
                  left: 4 + (tabIndex == 0 ? 0 : segmentW),
                  top: 4,
                  width: segmentW - 4,
                  height: 44,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 320),
                    curve: Curves.easeOutCubic,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(22),
                      gradient: LinearGradient(
                        colors: tabIndex == 0
                            ? [
                                AppColors.lightBeige.withAlpha(
                                  ((isDark ? 0.75 : 1.0) * 255).round(),
                                ),
                                AppColors.darkBeige.withAlpha(
                                  ((isDark ? 0.72 : 1.0) * 255).round(),
                                ),
                              ]
                            : [
                                AppColors.lightBlue.withAlpha(
                                  ((isDark ? 0.75 : 1.0) * 255).round(),
                                ),
                                AppColors.darkBlue.withAlpha(
                                  ((isDark ? 0.72 : 1.0) * 255).round(),
                                ),
                              ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha((0.12 * 255).round()),
                          blurRadius: 14,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: _SegmentTap(
                        selected: tabIndex == 0,
                        icon: Icons.people_outline_rounded,
                        label: l10n.adults,
                        accent: AppColors.darkBrown,
                        muted: AppColors.lightBrown.withAlpha((0.75 * 255).round()),
                        onTap: () => onChanged(0),
                      ),
                    ),
                    Expanded(
                      child: _SegmentTap(
                        selected: tabIndex == 1,
                        icon: Icons.sentiment_satisfied_alt_outlined,
                        label: l10n.kids,
                        accent: AppColors.darkBrown,
                        muted: AppColors.lightBrown.withAlpha((0.75 * 255).round()),
                        onTap: () => onChanged(1),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SegmentTap extends StatelessWidget {
  const _SegmentTap({
    required this.selected,
    required this.icon,
    required this.label,
    required this.accent,
    required this.muted,
    required this.onTap,
  });

  final bool selected;
  final IconData icon;
  final String label;
  final Color accent;
  final Color muted;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = selected ? accent : muted;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        splashFactory: NoSplash.splashFactory,
        overlayColor: WidgetStateProperty.all(Colors.transparent),
        child: Center(
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 240),
            curve: Curves.easeOutCubic,
            style: theme.textTheme.titleSmall!.copyWith(
              fontWeight: FontWeight.w700,
              color: color,
              letterSpacing: 0.2,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 20, color: color),
                const SizedBox(width: 8),
                Text(label),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SelectionActionsRow extends StatelessWidget {
  const _SelectionActionsRow({
    required this.selectedLabel,
    required this.onSelectAll,
    required this.onClear,
    required this.selectAllEnabled,
    required this.clearEnabled,
  });

  final String selectedLabel;
  final VoidCallback onSelectAll;
  final VoidCallback onClear;
  final bool selectAllEnabled;
  final bool clearEnabled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Row(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: cs.surface.withAlpha((0.92 * 255).round()),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: cs.outlineVariant.withAlpha((0.35 * 255).round()),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha((0.05 * 255).round()),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.check_rounded,
                size: 18,
                color: AppColors.darkBrown,
              ),
              const SizedBox(width: 6),
              Text(
                selectedLabel,
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkBrown,
                ),
              ),
            ],
          ),
        ),
        const Spacer(),
        TextButton(
          onPressed: selectAllEnabled ? onSelectAll : null,
          child: Text(
            l10n.category_picker_select_all,
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.darkBrownOrange,
            ),
          ),
        ),
        Container(
          width: 1,
          height: 18,
          color: cs.outlineVariant.withAlpha((0.45 * 255).round()),
        ),
        TextButton(
          onPressed: clearEnabled ? onClear : null,
          child: Text(
            l10n.category_picker_clear,
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.lightBrown.withAlpha((0.95 * 255).round()),
            ),
          ),
        ),
      ],
    );
  }
}
