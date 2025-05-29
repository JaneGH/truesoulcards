import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:share_plus/share_plus.dart';
import 'package:truesoulcards/theme/app_colors.dart';

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

class MainDrawer extends StatelessWidget {
  const MainDrawer({
    super.key,
    required this.onSelectScreen,
    required this.onRefreshQuestions,
    required this.isDownloading,
    this.isDownloadsAvailable = true,
  });

  final void Function(String identifier) onSelectScreen;
  final VoidCallback onRefreshQuestions;
  final bool isDownloading;
  final bool isDownloadsAvailable;

  TextStyle _drawerTextStyle(BuildContext context) {
    return Theme.of(context).textTheme.titleLarge!.copyWith(
      color: Theme.of(context).colorScheme.primary,
    );
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;

    final List<DrawerItem> drawerItems = [
      DrawerItem(
        icon: Icons.category,
        title: localization.explore,
        identifier: "category_play",
      ),
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
          onTap: isDownloading ? null : onRefreshQuestions,
          trailing: isDownloading
              ? SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
              : null,
        ),
      DrawerItem(
        icon: Icons.share,
        title: localization.share,
        identifier: "share",
        onTap: () {
          SharePlus.instance.share(
            ShareParams(text: localization.discover_meaningful_questions),
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
      child: Column(
        children: [
          DrawerHeader(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  AppColors.backgroundLight,
                  AppColors.lightBrownOrange,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.brown.withAlpha((0.15 * 255).round()),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.backgroundLightWarmer,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.brown.withAlpha((0.2 * 255).round()),
                        blurRadius: 14,
                        offset: const Offset(0, 7),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(12),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/logo_no_bg.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        localization.conversations,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: AppColors.mediumBrown,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "${localization.that_matter}...",
                        style: const TextStyle(
                          fontSize: 15,
                          color: AppColors.lightBrown,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: drawerItems.length,
              itemBuilder: (ctx, index) {
                final item = drawerItems[index];

                if (item.identifier == 'share') {
                  return ListTile(
                    leading: Icon(item.icon),
                    title: Text(
                      item.title,
                      style: _drawerTextStyle(context),
                    ),
                    onTap: item.onTap,
                  );
                }

                if (item.onTap != null) {
                  return ListTile(
                    leading: Icon(item.icon),
                    title: Text(
                      item.title,
                      style: _drawerTextStyle(context),
                    ),
                    onTap: item.onTap,
                    trailing: item.trailing,
                  );
                }

                return ListTile(
                  leading: Icon(item.icon),
                  title: Text(
                    item.title,
                    style: _drawerTextStyle(context),
                  ),
                  onTap: () => onSelectScreen(item.identifier),
                  trailing: item.trailing,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
