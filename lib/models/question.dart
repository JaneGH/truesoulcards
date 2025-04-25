class Question {
  final int id;
  final String category;
  final String text;
  final bool predefined;

  const Question({
    required this.id,
    required this.category,
    required this.text,
    this.predefined = true,
  });

  factory Question.fromJson(Map<String, dynamic> json, String categoryId) {
    return Question(
      id: json['id'] ?? -1,
      text: json['text'],
      category: categoryId,
    );
  }

  factory Question.fromMap(Map<String, dynamic> map) {
    return Question(
      id: map ['id'] ?? -1,
      text: map['text'],
      category: map['category'],
    );
  }
}
