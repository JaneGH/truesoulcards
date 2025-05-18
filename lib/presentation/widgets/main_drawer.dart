import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../theme/app_colors.dart';

class MainDrawer extends StatelessWidget {
  const MainDrawer({super.key, required this.onSelectScreen, required this.onRefreshQuestions, required this.isDownloading});

  final void Function(String indetifier) onSelectScreen;
  final void Function() onRefreshQuestions;
  final bool isDownloading;

  @override
  Widget build(BuildContext context) {
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
                  color: Colors.brown.withOpacity(0.15),
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
                        color: Colors.brown.withOpacity(0.2),
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
                        AppLocalizations.of(context)!.conversations,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDarkBrown,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "${AppLocalizations.of(context)!.that_matter}...",
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
              AppLocalizations.of(context)!.explore,
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
              AppLocalizations.of(context)!.set_up_the_category_list,
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
              AppLocalizations.of(context)!.edit_sets,
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
              AppLocalizations.of(context)!.settings,
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
                AppLocalizations.of(context)!.refresh_questions,
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
        ],
      ),
    );
  }
}


