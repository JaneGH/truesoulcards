class Question {
  final String id;
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
      id: json['id'],
      text: json['text'],
      category: categoryId,
    );
  }
}
