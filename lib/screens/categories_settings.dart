import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:truesoulcards/widgets/saved_category_grid_item.dart';

import '../providers/categories_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../widgets/category_grid_item.dart';

class CategoriesSettingsScreen extends ConsumerWidget {
  const CategoriesSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesProvider);
    final appBarText = AppLocalizations.of(context)!.pick_category;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(appBarText),
          bottom: TabBar(
            tabs: [
              Tab(text: AppLocalizations.of(context)!.adults),
              Tab(text: AppLocalizations.of(context)!.kids),
            ],
          ),
        ),
        body: categoriesAsync.when(
          data: (categories) {
            final adultCategories = categories.where((c) => c.subcategory == 'adults').toList();
            final kidsCategories = categories.where((c) => c.subcategory == 'kids').toList();

            return TabBarView(
              children: [
                SavedCategoryGrid(type: 'adults', categories: adultCategories),
                SavedCategoryGrid(type: 'kids', categories: kidsCategories),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e')),
        ),
      ),
    );
  }
}
