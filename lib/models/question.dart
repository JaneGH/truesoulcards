class Question {

  const Question({
    required this.id,
    required this.categories,
    required this.text,
    this.predefined = true,
    });

  final String id;
  final List<String> categories;
  final String text;
  final bool predefined;
 }