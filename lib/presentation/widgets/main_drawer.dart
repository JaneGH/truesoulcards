import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:share_plus/share_plus.dart';
import 'package:truesoulcards/theme/app_colors.dart';

class MainDrawer extends StatelessWidget {
  const MainDrawer({super.key, required this.onSelectScreen, required this.onRefreshQuestions, required this.isDownloading});

  final void Function(String indetifier) onSelectScreen;
  final void Function() onRefreshQuestions;
  final bool isDownloading;

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    bool isDownloadsAvailable = true;
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
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
                    color:AppColors.backgroundLightWarmer,
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
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDarkBrown,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "${localization.that_matter}...",
                        style: TextStyle(
                          fontSize: 15,
                          color: AppColors.textLightBrown,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),


          ListTile(
            leading: Icon(Icons.category),
            title: Text(
              localization.explore,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            onTap: () {
              onSelectScreen("category_play");
            },
          ),
          ListTile(
            leading: Icon(Icons.checklist),
            title: Text(
              localization.set_up_the_category_list,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            onTap: () {
              onSelectScreen("categories_settings");
            },
          ),
          ListTile(
            leading: Icon(Icons.edit),
            title: Text(
              localization.edit_sets,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            onTap: () {
              onSelectScreen("category_edit");
            },
          ),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text(
              localization.settings,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            onTap: () {
              onSelectScreen("settings");
            },
          ),
          if (isDownloadsAvailable)
            ListTile(
              leading: Icon(Icons.refresh),
              title: Text(
                localization.refresh_questions,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              onTap: () { isDownloading ? null : onRefreshQuestions();
              },
                trailing: isDownloading
                    ? CircularProgressIndicator()
                    : null
            ),

          ListTile(
            leading: const Icon(Icons.share),
            title: Text(
              localization.share,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            onTap: () {
              SharePlus.instance.share(
                  ShareParams(text: localization.discover_meaningful_questions)
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.info),
            title: Text(
              localization.about,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            onTap: () {
              onSelectScreen("information");
            },
          ),
        ],
      ),
    );
  }
}


