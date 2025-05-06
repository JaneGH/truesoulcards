class Question {
  final int id;
  final String category;
  final String textEn;
  final String textUa;
  final bool predefined;
  final int color;

  const Question({
    required this.id,
    required this.category,
    required this.textEn,
    required this.textUa,
    this.predefined = true,
    required this.color,
  });

  factory Question.fromJson(Map<String, dynamic> json, String categoryId) {
    return Question(
      id: json['id'] ?? -1,
      textEn: json['text_en'],
      textUa: json['text_ua'],
      category: categoryId,
      color: json['color'] ?? 4280384511,
    );
  }

  factory Question.fromMap(Map<String, dynamic> map) {
    return Question(
      id: map ['id'] ?? -1,
      textEn: map['text_en'],
      textUa: map['text_ua'],
      category: map['category'],
      color: map['color'],
    );
  }
}
