import 'package:truesoulcards/data/models/category.dart';

/// Stable widget key so category cards rebuild when synced metadata changes.
String categoryDisplayKey(Category category) {
  final title =
      category.titleTranslations['en'] ??
      (category.titleTranslations.isNotEmpty
          ? category.titleTranslations.values.first
          : '');
  return '${category.id}:${category.color}:${category.img}:$title';
}
