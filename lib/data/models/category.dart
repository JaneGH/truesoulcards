class Category {
  final String id;
  final Map<String, String> titleTranslations;
  final String subcategory;
  final int color;
  final String img;

  Category({
    required this.id,
    required this.titleTranslations,
    required this.color,
    required this.subcategory,
    this.img = '',
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      titleTranslations: Map<String, String>.from(json['title']),
      subcategory: json['subcategory'],
      color: int.parse(json['color'].toString()),
      img: json['img'] ?? '',
    );
  }

  factory Category.fromMapWithTranslation(Map<String, dynamic> map) {
    return Category(
      id: map['id'],
      titleTranslations: Map<String, String>.from(map['title']),
      subcategory: map['subcategory'],
      color: int.parse(map['color'].toString()),
      img: map['img'] ?? '',
    );
  }

  String getTitle(String languageCode) {
    return titleTranslations[languageCode] ?? titleTranslations['en'] ?? 'No translation available';
  }

}
