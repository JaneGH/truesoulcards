class Question {
  final String id;
  final List<String> categories;
  final String text;
  final bool predefined;

  const Question({
    required this.id,
    required this.categories,
    required this.text,
    this.predefined = true,
  });

  factory Question.fromJson(Map<String, dynamic> json, List<String> categoryIds) {
    return Question(
      id: json['id'],
      text: json['text'],
      categories: categoryIds,
    );
  }
}
