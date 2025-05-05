class Question {
  final int id;
  final String category;
  final String text;
  final bool predefined;
  final int color;

  const Question({
    required this.id,
    required this.category,
    required this.text,
    this.predefined = true,
    required this.color,
  });

  factory Question.fromJson(Map<String, dynamic> json, String categoryId) {
    return Question(
      id: json['id'] ?? -1,
      text: json['text'],
      category: categoryId,
      color: json['color'] ?? 4280384511,
    );
  }

  factory Question.fromMap(Map<String, dynamic> map) {
    return Question(
      id: map ['id'] ?? -1,
      text: map['text'],
      category: map['category'],
      color: map['color'],
    );
  }
}
