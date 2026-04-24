import 'package:flutter/material.dart';
import 'package:truesoulcards/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:truesoulcards/theme/app_colors.dart';
import 'package:truesoulcards/presentation/providers/categories_provider.dart';
import 'package:truesoulcards/presentation/providers/questions_provider.dart';

class DrawerItem {
  final IconData icon;
  final String title;
  final String identifier;
  final VoidCallback? onTap;
  final Widget? trailing;

  DrawerItem({
    required this.icon,
    required this.title,
    required this.identifier,
    this.onTap,
    this.trailing,
  });
}

class MainDrawer extends ConsumerWidget {
  const MainDrawer({
    super.key,
    required this.onSelectScreen,
    required this.onRefreshQuestions,
    required this.isDownloading,
    this.isDownloadsAvailable = true,
  });

  final void Function(String identifier) onSelectScreen;
  final Future<void> Function() onRefreshQuestions;
  final bool isDownloading;
  final bool isDownloadsAvailable;

  TextStyle _drawerTextStyle(BuildContext context) {
    final theme = Theme.of(context);
    return theme.textTheme.titleMedium!.copyWith(
      color: theme.colorScheme.onSurface.withAlpha((0.86 * 255).round()),
      fontWeight: FontWeight.w600,
      letterSpacing: 0.2,
    );
  }

  Future<void> _handleRefresh(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final navigator = Navigator.of(context);
    final container = ProviderScope.containerOf(context, listen: false);

    await onRefreshQuestions();

    if (!context.mounted) return;

    container.refresh(categoriesProvider);
    container.refresh(userCategoriesProvider);
    container.refresh(questionsProvider);

    navigator.pop();
  }

  Widget _buildHeader(BuildContext context, AppLocalizations localization) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    int alpha(double v) => (v * 255).round();

    final titleStyle = theme.textTheme.titleLarge?.copyWith(
      fontWeight: FontWeight.w700,
      color: scheme.onPrimaryContainer.withAlpha(alpha(0.92)),
      letterSpacing: 0.2,
    );

    final subtitleStyle = theme.textTheme.bodyMedium?.copyWith(
      color: scheme.onPrimaryContainer.withAlpha(alpha(0.70)),
      height: 1.25,
      fontWeight: FontWeight.w500,
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
      child: Container(
        height: 128,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            colors: [
              scheme.primaryContainer.withAlpha(alpha(isDark ? 0.55 : 0.75)),
              scheme.secondaryContainer.withAlpha(alpha(isDark ? 0.45 : 0.65)),
              scheme.secondaryContainer.withAlpha(alpha(isDark ? 0.40 : 0.60)),
            ],
            stops: const [0.0, 0.55, 1.0],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: scheme.shadow.withAlpha(alpha(isDark ? 0.25 : 0.10)),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                width: 75,
                height: 75,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: scheme.surface.withAlpha(alpha(isDark ? 0.25 : 0.65)),
                  border: Border.all(
                    color: scheme.outlineVariant.withAlpha(alpha(0.30)),
                    width: 1,
                  ),
                ),
                child: ClipOval(
                  child: Image.asset(
                    'assets/logo_no_bg.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      localization.conversations,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: titleStyle,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "${localization.that_matter}...",
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: subtitleStyle,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuRow(
    BuildContext context, {
    required DrawerItem item,
    required VoidCallback? onTap,
  }) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final enabled = onTap != null;

    final iconFg = scheme.primary.withAlpha((0.78 * 255).round());
    final iconBg = scheme.primary.withAlpha((0.10 * 255).round());
    final rowHover = scheme.primary.withAlpha((0.06 * 255).round());
    final rowSplash = scheme.primary.withAlpha((0.10 * 255).round());

    final content = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: Icon(item.icon, size: 20, color: iconFg),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              item.title,
              style: _drawerTextStyle(context).copyWith(
                color: enabled
                    ? theme.colorScheme.onSurface.withAlpha((0.86 * 255).round())
                    : theme.colorScheme.onSurface.withAlpha((0.40 * 255).round()),
              ),
            ),
          ),
          if (item.trailing != null) ...[
            const SizedBox(width: 10),
            IconTheme.merge(
              data: IconThemeData(
                color: scheme.onSurface.withAlpha((0.55 * 255).round()),
                size: 18,
              ),
              child: SizedBox(
                width: 18,
                height: 18,
                child: Center(child: item.trailing),
              ),
            ),
          ],
        ],
      ),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          hoverColor: rowHover,
          splashColor: rowSplash,
          highlightColor: rowHover,
          child: Opacity(
            opacity: enabled ? 1 : 0.7,
            child: content,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localization = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    final List<DrawerItem> drawerItems = [
      // DrawerItem(
      //   icon: Icons.category,
      //   title: localization.start_game,
      //   identifier: "category_play",
      // ),
      DrawerItem(
        icon: Icons.checklist,
        title: localization.set_up_the_category_list,
        identifier: "categories_settings",
      ),
      DrawerItem(
        icon: Icons.edit,
        title: localization.edit_sets,
        identifier: "category_edit",
      ),
      DrawerItem(
        icon: Icons.settings,
        title: localization.settings,
        identifier: "settings",
      ),
      if (isDownloadsAvailable)
        DrawerItem(
          icon: Icons.refresh,
          title: localization.refresh_questions,
          identifier: "refresh_questions",
          onTap: isDownloading
              ? null
              : () => _handleRefresh(context, ref),
          trailing: isDownloading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : null,
        ),
      DrawerItem(
        icon: Icons.upload,
        title: localization.upload_questions,
        identifier: "upload",
      ),
      DrawerItem(
        icon: Icons.share,
        title: localization.share,
        identifier: "share",
        onTap: () {
          SharePlus.instance.share(
            ShareParams(
              text: "✨ ${localization.discover_meaningful_questions}\n\nGoogle Play:\nhttps://play.google.com/store/apps/details?id=com.itclimb.truesoulcards",
            ),
          );
        },
      ),
      DrawerItem(
        icon: Icons.info,
        title: localization.about,
        identifier: "information",
      ),
    ];

    return Drawer(
      backgroundColor: theme.colorScheme.surface,
      child: SafeArea(
        bottom: true,
        child: Column(
          children: [
            _buildHeader(context, localization),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.only(top: 4, bottom: 12),
                itemCount: drawerItems.length,
                itemBuilder: (ctx, index) {
                  final item = drawerItems[index];

                  return _buildMenuRow(
                    context,
                    item: item,
                    onTap: item.onTap ??
                        (item.identifier == 'refresh_questions'
                            ? null
                            : () => onSelectScreen(item.identifier)),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
