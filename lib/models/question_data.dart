import 'category.dart';
import 'question.dart';

class QuestionData {
  final Category category;
  final List<Question> questions;

  QuestionData({required this.category, required this.questions});

  factory QuestionData.fromJson(Map<String, dynamic> json) {
    final category = Category.fromJson(json['category']);
    final questions = (json['questions'] as List)
        .map((q) => Question.fromJson(q, category.title))
        .toList();

    return QuestionData(
      category: category,
      questions: questions,
    );
  }
}
