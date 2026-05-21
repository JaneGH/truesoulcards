import 'package:truesoulcards/data/models/category.dart';

enum CategoryTabType { adults, kids }

/// User-created category stored locally; system/premium categories use [Category].
class CustomCategory {
  final String id;
  final String title;
  final CategoryTabType tabType;
  final int color;
  final String iconName;
  final DateTime createdAt;
  final bool isSystem;

  const CustomCategory({
    required this.id,
    required this.title,
    required this.tabType,
    required this.color,
    required this.iconName,
    required this.createdAt,
    this.isSystem = false,
  });

  String get subcategory =>
      tabType == CategoryTabType.adults ? 'adults' : 'kids';

  factory CustomCategory.fromCategory(Category category) {
    return CustomCategory(
      id: category.id,
      title: category.titleTranslations.values.first,
      tabType: category.subcategory.toLowerCase() == 'kids'
          ? CategoryTabType.kids
          : CategoryTabType.adults,
      color: category.color,
      iconName: category.img,
      createdAt: DateTime.now(),
      isSystem: false,
    );
  }

  Category toCategory({Map<String, String>? titleTranslations}) {
    final titles = titleTranslations ??
        {
          'en': title,
          'uk': title,
          'es': title,
          'it': title,
          'fr': title,
          'de': title,
          'pl': title,
          'pt': title,
        };
    return Category(
      id: id,
      titleTranslations: titles,
      subcategory: subcategory,
      color: color,
      img: iconName,
      isPremium: false,
    );
  }

  static String generateId() =>
      'custom_${DateTime.now().microsecondsSinceEpoch}';
}

bool isCustomCategoryId(String id) => id.startsWith('custom_');

/// Whether uploaded or manually added questions may be stored under [id].
bool isQuestionAssignableCategoryId(String id) {
  if (id == 'uncategorized') return true;
  if (id.startsWith('usr_')) return true;
  if (isCustomCategoryId(id)) return true;
  return false;
}
