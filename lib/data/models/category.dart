class Category {
  final String id;
  final Map<String, String> titleTranslations;
  final String subcategory;
  final int color;
  final bool isPremium;
  final String img;

  Category({
    required this.id,
    required this.titleTranslations,
    required this.color,
    required this.subcategory,
    this.isPremium = false,
    this.img = '',
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    String hexColor = json['color'].toString();
    if (hexColor.startsWith('#')) {
      hexColor = hexColor.substring(1);
    }
    if (hexColor.length == 6) {
      hexColor = 'FF${hexColor.toUpperCase()}';
    }
    int colorInt = int.parse(hexColor, radix: 16);

    return Category(
      id: json['id'],
      titleTranslations: Map<String, String>.from(json['title']),
      subcategory: json['subcategory'],
      color: colorInt,
      isPremium: (json['isPremium'] is bool)
          ? json['isPremium']
          : (json['isPremium']?.toString() == '1'),
      img: json['img'] ?? '',
    );
  }

  factory Category.fromMapWithTranslation(Map<String, dynamic> map) {
    String hexColor = map['color'].toString();
    if (hexColor.startsWith('#')) {
      hexColor = hexColor.substring(1);
    }
    if (hexColor.length == 6) {
      hexColor = 'FF${hexColor.toUpperCase()}';
    }
    int colorInt = int.parse(hexColor, radix: 16);

    return Category(
      id: map['id'],
      titleTranslations: Map<String, String>.from(map['title']),
      subcategory: map['subcategory'],
      color: colorInt,
      isPremium: map['isPremium'] is bool
          ? map['isPremium']
          : (map['isPremium']?.toString() == '1'),
      img: map['img'] ?? '',
    );
  }

  String getTitle(String languageCode) {
    return titleTranslations[languageCode] ?? titleTranslations['en'] ?? 'No translation available';
  }

}
