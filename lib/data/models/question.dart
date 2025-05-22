class Question {
  final int id;
  final String category;
  final Map<String, String> translations;
  final bool predefined;
  final int color;

  const Question({
    required this.id,
    required this.category,
    required this.translations,
    this.predefined = true,
    required this.color,
  });

  factory Question.fromJson(Map<String, dynamic> json, String categoryId) {
    return Question(
      id: json['id'] ?? -1,
      translations: Map<String, String>.from(json['text']),
      category: categoryId,
      color: json['color'] ?? 4280384511,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'text': translations,
    'category': category,
    'color': color,
  };

  factory Question.fromMapWithTranslation(Map<String, dynamic> map) {
    return Question(
      id: map['id'],
      category: map['category'],
      translations: Map<String, String>.from(map['text']),
      predefined: map['predefined'] == 1 || map['predefined'] == true,
      color: map['color'],
    );
  }

  String getText(String languageCode) {
    return translations[languageCode] ?? translations['en'] ?? 'No translation available';
  }



}
