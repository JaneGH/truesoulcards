import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primaryContainer,
                  Theme.of(
                    context,
                  ).colorScheme.primaryContainer.withValues(alpha: 0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),

            child: Row(
              children: [
                Image.asset(
                  'assets/logo_no_bg.png',
                  width: 100,
                  height: 100,
                ),
                // SizedBox(width: 18),
                // Text(
                //   'Hey!',
                //   style: Theme.of(context).textTheme.titleLarge?.copyWith(
                //     color: Theme.of(context).colorScheme.primary,
                //   ),
                // ),
              ],
            ),
          ),
          ListTile(
            leading: Icon(Icons.category),
            title: Text(
              AppLocalizations.of(context)!.play,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            onTap: () {
              onSelectScreen("category_play");
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


