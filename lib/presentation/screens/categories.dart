import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:truesoulcards/core/services/analytics_service.dart';
import 'package:truesoulcards/data/models/category.dart';
import 'package:truesoulcards/data/models/custom_category.dart';
import 'package:truesoulcards/l10n/app_localizations.dart';
import 'package:truesoulcards/presentation/providers/analytics_provider.dart';
import 'package:truesoulcards/presentation/providers/categories_provider.dart';
import 'package:truesoulcards/presentation/providers/category_picker_ui_provider.dart';
import 'package:truesoulcards/presentation/providers/language_provider.dart';
import 'package:truesoulcards/presentation/providers/selected_categories_provider.dart';
import 'package:truesoulcards/presentation/screens/question_swiper.dart';
import 'package:truesoulcards/presentation/screens/questions.dart';
import 'package:truesoulcards/presentation/providers/custom_categories_provider.dart';
import 'package:truesoulcards/presentation/widgets/create_category_card.dart';
import 'package:truesoulcards/presentation/widgets/create_category_sheet.dart';
import 'package:truesoulcards/presentation/widgets/premium_category_pick_card.dart';
import 'package:truesoulcards/presentation/widgets/shared/confirm_dialog.dart';
import 'package:truesoulcards/presentation/widgets/shared/calm_tap_scale.dart';
import 'package:truesoulcards/presentation/widgets/shared/async_status_view.dart';
import 'package:truesoulcards/presentation/widgets/shared/banner_ad_widget.dart';
import 'package:truesoulcards/theme/app_colors.dart';
import 'package:truesoulcards/theme/app_decorations.dart';

enum ScreenModeCategories { edit, play }

class CategoriesScreen extends ConsumerStatefulWidget {
  final ScreenModeCategories mode;
  final bool isInitialDataLoading;

  const CategoriesScreen({
    super.key,
    required this.mode,
    this.isInitialDataLoading = false,
  });

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

  static const double _gridChildAspectRatio = 1.08;

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

  CategoryTabType _tabType(int tabIndex) =>
      tabIndex == 0 ? CategoryTabType.adults : CategoryTabType.kids;

  Future<void> _openCreateCategorySheet(BuildContext context, int tabIndex) async {
    final created = await showCreateCategorySheet(
      context: context,
      tabType: _tabType(tabIndex),
    );
    if (created == true && mounted) {
      ref.invalidate(userCategoriesProvider);
      ref.invalidate(categoriesProvider);
    }
  }

  Future<void> _showCustomCategoryActions(
    BuildContext context,
    Category category,
    int tabIndex,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final lang = ref.read(languageProvider)['primary'] ?? 'en';
    final action = await showModalBottomSheet<String>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.drive_file_rename_outline_rounded),
              title: Text(l10n.rename_category),
              onTap: () => Navigator.pop(ctx, 'rename'),
            ),
            ListTile(
              leading: Icon(Icons.delete_outline_rounded, color: Theme.of(ctx).colorScheme.error),
              title: Text(
                l10n.delete_category,
                style: TextStyle(color: Theme.of(ctx).colorScheme.error),
              ),
              onTap: () => Navigator.pop(ctx, 'delete'),
            ),
          ],
        ),
      ),
    );

    if (!mounted || action == null) return;

    if (action == 'rename') {
      await showCreateCategorySheet(
        context: context,
        tabType: _tabType(tabIndex),
        categoryId: category.id,
        initialTitle: category.getTitle(lang),
        initialColor: category.color,
        initialIcon: category.img,
      );
    } else if (action == 'delete') {
      final confirmed = await showDeleteConfirmationDialog(
        context: context,
        title: l10n.delete_category,
        content: l10n.delete_category_confirm,
        confirmText: l10n.delete,
        cancelText: l10n.cancel,
      );
      if (confirmed == true) {
        await ref.read(customCategoriesControllerProvider).delete(category.id);
      }
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

    if (widget.isInitialDataLoading) {
      return _buildScaffoldShell(
        context: context,
        isEdit: isEdit,
        l10n: l10n,
        body: AsyncStatusView.loading(
          message: l10n.initial_data_loading_from_server,
        ),
      );
    }
    final categoriesAsync =
        isEdit ? ref.watch(userCategoriesProvider) : ref.watch(categoriesProvider);
    final selectedAsync = ref.watch(selectedCategoriesProvider);
    final tabIndex = ref.watch(categoryPickerTabIndexProvider);
    final theme = Theme.of(context);

    return _buildScaffoldShell(
      context: context,
      isEdit: isEdit,
      l10n: l10n,
      body: SafeArea(
          bottom: false,
          left: true,
          right: true,
          child: ClipRect(
            child: categoriesAsync.when(
            data: (availableCategories) {
              final adultCategories = mergeTabCategories(
                source: availableCategories,
                tabIndex: 0,
              );
              final kidsCategories = mergeTabCategories(
                source: availableCategories,
                tabIndex: 1,
              );
              final tabCategories =
                  tabIndex == 0 ? adultCategories : kidsCategories;
              final gridItemCount =
                  tabCategories.length + (isEdit ? 1 : 0);
              final categoriesToStartGame = _categoriesForStart(
                tabIndex: tabIndex,
                adultCategories: adultCategories,
                kidsCategories: kidsCategories,
                selectedAdultIds: selectedAsync.value?['adults'] ?? {},
                selectedKidsIds: selectedAsync.value?['kids'] ?? {},
              );
              final tabType = _tabKey(tabIndex);
              final gridSelectedIds = selectedAsync.when(
                data: (selectedMap) => selectedMap[tabType] ?? {},
                loading: () => <String>{},
                error: (_, __) => <String>{},
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
                                padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
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
                                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
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
                              padding: const EdgeInsets.fromLTRB(20, 10, 20, 12),
                              sliver: SliverGrid(
                                    gridDelegate:
                                        SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      mainAxisSpacing: 16,
                                      crossAxisSpacing: 16,
                                      childAspectRatio: _gridChildAspectRatio,
                                    ),
                                    delegate: SliverChildBuilderDelegate(
                                      (context, index) {
                                        if (isEdit && index == 0) {
                                          return CreateCategoryCard(
                                            key: const ValueKey(
                                              'create-category',
                                            ),
                                            onTap: () =>
                                                _openCreateCategorySheet(
                                              context,
                                              tabIndex,
                                            ),
                                          );
                                        }

                                        final categoryIndex =
                                            isEdit ? index - 1 : index;
                                        final category =
                                            tabCategories[categoryIndex];
                                        final isSelected = gridSelectedIds
                                            .contains(category.id);
                                        final subtitle = tabIndex == 0
                                            ? l10n
                                                .category_picker_card_subtitle_adults
                                            : l10n
                                                .category_picker_card_subtitle_kids;
                                        final card = PremiumCategoryPickCard(
                                          key: ValueKey(
                                            '${category.id}:${category.img}',
                                          ),
                                          category: category,
                                          subtitle: subtitle,
                                          isSelected:
                                              isEdit ? false : isSelected,
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
                                                tabType,
                                                category,
                                                gridSelectedIds,
                                              );
                                            }
                                          },
                                        );

                                        if (isEdit &&
                                            isCustomCategoryId(category.id)) {
                                          return GestureDetector(
                                            key: ValueKey(
                                              'custom-${category.id}',
                                            ),
                                            onLongPress: () =>
                                                _showCustomCategoryActions(
                                              context,
                                              category,
                                              tabIndex,
                                            ),
                                            child: card,
                                          );
                                        }
                                        return card;
                                      },
                                      childCount: gridItemCount,
                                      findChildIndexCallback: (Key key) {
                                        if (key ==
                                            const ValueKey('create-category')) {
                                          return isEdit ? 0 : null;
                                        }
                                        if (key is ValueKey<String>) {
                                          final raw = key.value;
                                          if (raw.startsWith('custom-')) {
                                            final categoryId =
                                                raw.substring('custom-'.length);
                                            final idx = tabCategories.indexWhere(
                                              (c) => c.id == categoryId,
                                            );
                                            if (idx < 0) return null;
                                            return isEdit ? idx + 1 : idx;
                                          }
                                          final categoryId = raw.contains(':')
                                              ? raw.split(':').first
                                              : raw;
                                          final idx = tabCategories.indexWhere(
                                            (c) => c.id == categoryId,
                                          );
                                          if (idx < 0) return null;
                                          return isEdit ? idx + 1 : idx;
                                        }
                                        return null;
                                      },
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
                      child: const SizedBox(
                        width: double.infinity,
                        child: BannerAdWidget(),
                      ),
                    ),
                  ),

                  SizedBox(
                    height: MediaQuery.paddingOf(context).bottom + 6,
                  ),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => Center(
              child: Text(
                l10n.failed_to_load_questions,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.error,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildScaffoldShell({
    required BuildContext context,
    required bool isEdit,
    required AppLocalizations l10n,
    required Widget body,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final scaffoldBg = AppDecorations.scaffoldBackground(isDark);

    return DecoratedBox(
      decoration: scaffoldBg,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: isEdit
            ? AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                foregroundColor: theme.colorScheme.onSurface,
                title: Text(l10n.pick_to_edit),
              )
            : null,
        body: body,
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
    final trackColor = AppDecorations.premiumSurfaceFill(cs, isDark: isDark);
    final accent = isDark ? cs.onSurface : AppColors.darkBrown;
    final muted = isDark
        ? cs.onSurfaceVariant
        : AppColors.mediumBrown.withAlpha((0.82 * 255).round());

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
            color: trackColor,
            borderRadius: BorderRadius.circular(26),
            border: Border.all(
              color: AppDecorations.premiumSurfaceBorder(cs, isDark: isDark),
            ),
            boxShadow: AppDecorations.ambientCardShadow(
              isDark: isDark,
              elevation: 0.95,
            ),
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
                  top: 3,
                  width: segmentW - 4,
                  height: 43,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 320),
                    curve: Curves.easeOutCubic,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(21.5),
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
                          color: AppColors.shadowWarm.withOpacity(0.14),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                          spreadRadius: -2,
                        ),
                        BoxShadow(
                          color: AppColors.edgeHighlightWarm.withOpacity(
                            isDark ? 0.08 : 0.36,
                          ),
                          blurRadius: 4,
                          offset: const Offset(0, 0),
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
                        accent: accent,
                        muted: muted,
                        onTap: () => onChanged(0),
                      ),
                    ),
                    Expanded(
                      child: _SegmentTap(
                        selected: tabIndex == 1,
                        icon: Icons.sentiment_satisfied_alt_outlined,
                        label: l10n.kids,
                        accent: accent,
                        muted: muted,
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
    return CalmTapScale(
      pressedScale: 0.985,
      child: Material(
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
                fontWeight: FontWeight.w600,
                color: color,
                letterSpacing: 0.14,
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
    final isDark = theme.brightness == Brightness.dark;
    final primaryText = isDark ? cs.onSurface : AppColors.darkBrown;
    final actionAccent = isDark ? cs.primary : AppColors.goldDeep;
    final clearText = isDark
        ? cs.onSurfaceVariant
        : AppColors.mediumBrown.withAlpha((0.88 * 255).round());

    final actionButtons = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextButton(
          style: TextButton.styleFrom(
            visualDensity: VisualDensity.compact,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          onPressed: selectAllEnabled ? onSelectAll : null,
          child: Text(
            l10n.category_picker_select_all,
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: actionAccent,
            ),
          ),
        ),
        Container(
          width: 1,
          height: 18,
          color: cs.outlineVariant.withAlpha((0.45 * 255).round()),
        ),
        TextButton(
          style: TextButton.styleFrom(
            visualDensity: VisualDensity.compact,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          onPressed: clearEnabled ? onClear : null,
          child: Text(
            l10n.category_picker_clear,
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: clearText,
            ),
          ),
        ),
      ],
    );

    return Row(
      children: [
        Flexible(
          fit: FlexFit.loose,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppDecorations.premiumNestedFill(cs, isDark: isDark),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppDecorations.premiumSurfaceBorder(cs, isDark: isDark),
              ),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: AppDecorations.premiumSurfaceSheen(isDark),
                stops: const [0.0, 0.65],
              ),
              boxShadow: [
                ...AppDecorations.ambientCardShadow(
                  isDark: isDark,
                  elevation: 0.75,
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.check_rounded,
                  size: 18,
                  color: primaryText,
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    selectedLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: primaryText,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          fit: FlexFit.loose,
          child: Align(
            alignment: Alignment.centerRight,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerRight,
              child: actionButtons,
            ),
          ),
        ),
      ],
    );
  }
}
